# Sky-overlap 通道设计说明

本文档整理当前 `gw-catalog` 项目中 sky 信息的设计、计算方式和进入最终排序的口径。重点区分两条路线：

1. 模拟目录 ET/LIGO：没有真实 PE sky map，因此使用数据生成参数构造 **observed-sky proxy**。
2. 真实 GWTC-3/GWTC-4：使用 PE release 中的真实 **HEALPix sky posterior map**，不使用 A90 surrogate。

sky 通道的目标不是单独判定透镜事件，而是在 catalog-level ranking 中提供一个物理一致性约束：透镜双像应来自同一天区，因此两次观测的 sky localization 应相容。

## 1. 模拟目录中的 observed-sky proxy

模拟数据在生成时包含真实源天空位置：

```text
ra_true, dec_true
```

主实验不能直接把 `ra_true/dec_true` 用作 rerank 特征，否则会成为 oracle。当前做法是只用它们生成一个带误差的“观测天空定位”，后续排序只使用观测量：

```text
ra_obs
dec_obs
sky_area90_deg2
sky_sigma_rad
```

### 1.1 用 SNR 估计 A90

对每个事件，先用 network SNR 估计 90% 定位面积：

```text
A90 = A90_ref * (rho_ref / max(SNR, 1))^2 * lognormal_noise
```

然后裁剪到合理范围。

当前默认场景：

| detector key | scenario | A90_ref | rho_ref | clip range |
|---|---:|---:|---:|---:|
| ET3 | ET_TRIANGLE | 100 deg^2 | 12 | 20--1000 deg^2 |
| LIGO | LIGO_HL | 100 deg^2 | 12 | 10--500 deg^2 |

注意：这里的 `ET3` 是 sky-localization scenario，不代表 waveform 数据是三通道。当前 ET synthetic waveform 文件是 `(N, 98304)` 的单通道 strain。

### 1.2 A90 转换为高斯宽度

近似把 sky posterior 看作球面小角度下的二维高斯。二维高斯的 90% containment area 满足：

```text
A90 = 2 pi sigma_sky^2 ln(10)
```

因此：

```text
sigma_sky = sqrt(A90_rad2 / (2 pi ln(10)))
```

### 1.3 从 true sky 生成 observed sky center

在真实方向 `ra_true/dec_true` 的切平面上采样二维高斯扰动：

```text
dx, dy ~ Normal(0, sigma_sky)
```

将扰动后的三维单位向量重新归一化并转换为：

```text
ra_obs, dec_obs
```

这一步中 true sky 只用于模拟观测中心，后续 pair feature 不再读取 true sky。

### 1.4 pair-level sky feature

对任意事件对 `(i, j)`：

```text
theta_ij = angular_separation(ra_obs_i, dec_obs_i, ra_obs_j, dec_obs_j)
sigma_ij = sqrt(sigma_i^2 + sigma_j^2)
d_ij = theta_ij / sigma_ij
```

输出以下特征：

```text
sky_norm_sep        = d_ij
sky_gaussian_weight = exp(-0.5 * d_ij^2)
sky_log_overlap     = -log(2 pi sigma_ij^2) - theta_ij^2 / (2 sigma_ij^2)
```

另外保留一个分段 step score：

```text
d <= 1.18  -> 1.0
d <= 2.15  -> 0.5
d <= 3.03  -> 0.1
else       -> -0.5
```

这些阈值大致对应二维高斯的 50%、90%、99% containment 半径。

## 2. 真实 GWTC 中的 HEALPix sky overlap

真实 GWTC 部署不使用模拟 A90 proxy，而是读取每个事件 PE release 里的真实 HEALPix posterior map：

```text
p_i(pixel)
p_j(pixel)
```

当前脚本口径：

```text
scripts/real_search/01_build_healpix_overlap.py
```

### 2.1 map 读取和归一化

对每个事件：

1. 读取 HDF5/FITS skymap。
2. 若为 HDF5，优先选择包含 `/skymap/data` 的 PE group。
3. 若为 NESTED ordering，转为 RING。
4. 统一到 common nside，例如 `nside=512`。
5. 清理非有限值和负值。
6. 归一化：

```text
sum_pixel p_i(pixel) = 1
```

### 2.2 pair-level posterior overlap

对每个 unordered event pair：

```text
raw_posterior_overlap = sum_pixel p_i(pixel) * p_j(pixel)
```

并计算归一化 cosine overlap：

```text
cosine_overlap =
    sum(p_i p_j) / sqrt(sum(p_i^2) * sum(p_j^2))
```

最终用于 observable feature 的默认 sky score 是：

```text
sky_score = log(cosine_overlap)
```

真实部署输出列通常包括：

```text
raw_posterior_overlap
cosine_overlap
sky_log_cosine_overlap
angular_sep_map_deg
```

在 shortlist 中：

```text
healpix_overlap   = sky_cosine_overlap
healpix_sky_score = sky_score
```

## 3. sky 通道如何进入最终排序

sky 通道不进入 waveform encoder，也不改变 waveform embedding。它在 catalog-level fusion 阶段作为独立物理通道加入。

当前主流程：

```text
waveform_score
time_score
sky_score
```

每个通道先构造成 pairwise score matrix。由于不同通道数值范围不同，融合前做 row-wise 标准化：

```text
z_ij = (score_ij - mean_i) / std_i
```

最终分数：

```text
final_score_ij =
    w_waveform * z_waveform_ij
  + w_time     * z_time_ij
  + w_sky      * z_sky_ij
```

对真实部署，权重不从真实 catalog top pairs 调，而是在 held-out synthetic lensed injections into real off-source noise validation set 上选择。

当前 authoritative 结果中的三通道权重：

| deployment | waveform | time | sky |
|---|---:|---:|---:|
| GWTC-3 | 0.25 | 0.25 | 4.0 |
| GWTC-4.1 | 1.0 | 0.25 | 4.0 |

SNR/amplitude 只保留为 audit column 或 supplementary diagnostic，不进入主 `final_score`。

## 4. 推荐论文表述

模拟目录：

> For simulated catalogs, true source sky coordinates are used only to generate an observed localization proxy. Each event is assigned an SNR-dependent 90% localization area, converted into an effective Gaussian width, and the observed sky center is sampled around the source direction. Pairwise sky consistency is then computed from the observed centers and localization widths; true sky coordinates are not used directly in ranking.

真实 GWTC：

> For GWTC deployments, the proxy is replaced by real PE HEALPix sky posteriors. All maps are normalized on a common HEALPix grid, and pairwise sky consistency is quantified by the cosine overlap of posterior probability maps. This HEALPix sky score enters the same waveform + time-delay + sky fusion used in the simulated catalog experiments.

结论口径：

> The sky channel is a catalog-level physical-consistency prior. It helps rank candidate pairs for Bayesian follow-up but is not itself a lensing detection statistic.

## 5. 注意事项

1. `ET3` 不是 waveform 三通道，而是当前代码中的 sky-localization scenario / ET-like catalog key。
2. 模拟数据中的 `ra_true/dec_true` 不应作为最终 pair feature，只能用于生成 `ra_obs/dec_obs`。
3. 真实 GWTC 中应优先使用真实 HEALPix posterior overlap，不要退回 A90 surrogate。
4. 若某事件没有 skymap，应从 primary PE-supported catalog 排除，或作为 sensitivity check 单独说明。
5. sky 通道强并不意味着发现透镜，只说明两个事件天空定位相容，仍需 waveform、time 和 Bayesian follow-up。

## 6. 对应代码位置

现有项目实现：

```text
matchgw/aux_priors/observed_sky.py
matchgw/aux_priors/feature_builder.py
scripts/real_search/01_build_healpix_overlap.py
scripts/real_search/02_build_observable_features.py
scripts/real_search/15_gwtc34_real_deployment.py
```

本次抽离出的 reference code：

```text
scripts/real_search/sky_channel_reference.py
```

它集中包含：

- simulated observed-sky proxy 生成；
- pair-level normalized separation / Gaussian overlap；
- real HEALPix posterior overlap；
- row-wise z-score；
- waveform/time/sky weighted fusion 的最小实现。
