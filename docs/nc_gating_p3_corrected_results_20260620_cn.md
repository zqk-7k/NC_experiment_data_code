# NC gating P3 corrected 实验结果报告

日期：2026-06-20
项目：`/root/autodl-tmp/gw-catalog`

本轮修正 `docs/nc_gating_p3_results_20260619_cn.md` 中 P3-A/P3-B 的两个口径问题：

1. P3-A 原始 shortlist 只用 `time + sky + SNR`，在 realistic rarity 下会把大量真对排到很靠后，形成 downstream recall ceiling。
2. P3-B 原始 `waveform_like_HNSW_embedding` 是 clean 参数的随机投影 proxy，不是真实训练 waveform encoder；不能用它直接代表波形通道。

## 1. 代码更新

### P3-A

脚本：`scripts/server_experiments/p3a_end_to_end_confirmation.py`

主要改动：

- 新增 `--shortlist-mode {physical,posterior,physical_posterior}`。
- 默认 `--shortlist-mode posterior`，用 cheap posterior-summary 参数一致性做 confirmation 前的 shortlist。
- 保留 `physical` 和 `physical_posterior` 作为诊断对照。
- 新增 `p3a_shortlist_diagnostics.csv`，输出三种 shortlist score 在不同 budget 下的 recall/precision 和真对 rank。
- summary 新增通用字段 `shortlist_budget`、`shortlist_true_pairs`、`shortlist_recall`，同时保留旧 `physical_shortlist_*` 字段以兼容历史 CSV。

### P3-B

脚本：`scripts/server_experiments/p3b_domain_baselines.py`

主要改动：

- 将原 `waveform_like_HNSW_embedding` 重命名为 `synthetic_waveform_proxy_HNSW_lossy_projection`。
- 新增真实 ET3 训练 embedding baseline：
  `native_et3_trained_embedding_HNSW`。
- 默认读取：
  `runs/et3_fresh50_full_catalog_20260616/fresh_mixed_encoders/et3_noisy_mixed_sis_pm_ep50/test_embeddings.npy`
  和
  `runs/p2a_ann_et3_noisy_meta_20260618/catalog_meta.csv`。

## 2. P3-A corrected：posterior-summary shortlist

运行命令：

```bash
cd /root/autodl-tmp/gw-catalog
for seed in 0 1 2; do
  /root/miniconda3/bin/python scripts/server_experiments/p3a_end_to_end_confirmation.py \
    --n-true-pairs 60 \
    --lens-fraction 1e-3 \
    --n-background 110000 \
    --seed "$seed" \
    --topk 100 \
    --shortlist-budget 5000 \
    --followup-budget 200 \
    --shortlist-mode posterior \
    --out "runs/p3a_end_to_end_confirmation_posterior_20260620_seed${seed}"
done
```

### 2.1 3-seed summary

| seed | events | true pairs | HNSW recall | shortlist recall | final recall @200 | final precision @200 | final FDR @200 | wall s |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 52602 | 52 | 1.0000 | 1.0000 | 1.0000 | 0.2600 | 0.7400 | 22.52 |
| 1 | 52459 | 52 | 0.9808 | 0.9808 | 0.9808 | 0.2550 | 0.7450 | 22.06 |
| 2 | 52456 | 57 | 0.9825 | 0.9825 | 0.9825 | 0.2800 | 0.7200 | 22.68 |

Mean +/- std:

| metric | mean | std |
| --- | ---: | ---: |
| HNSW recall | 0.9877 | 0.0106 |
| shortlist recall | 0.9877 | 0.0106 |
| final recall @200 | 0.9877 | 0.0106 |
| final precision @200 | 0.2650 | 0.0132 |
| final FDR @200 | 0.7350 | 0.0132 |
| wall time s | 22.42 | 0.32 |

### 2.2 Follow-up budget curve, 3-seed mean

| follow-up budget | recall | precision | FDR |
| ---: | ---: | ---: | ---: |
| 50 | 0.9334 | 1.0000 | 0.0000 |
| 100 | 0.9877 | 0.5300 | 0.4700 |
| 200 | 0.9877 | 0.2650 | 0.7350 |
| 500 | 0.9877 | 0.1060 | 0.8940 |
| 1000 | 0.9877 | 0.0530 | 0.9470 |
| 2000 | 0.9877 | 0.0265 | 0.9735 |
| 5000 | 0.9877 | 0.0106 | 0.9894 |

解释：posterior-summary shortlist 基本不再形成额外 recall ceiling。剩余 recall loss 主要来自 HNSW top100 是否覆盖真对；在 seed1/seed2 中 HNSW 本身分别覆盖 51/52、56/57。

### 2.3 Shortlist diagnostics

3-seed mean，选取关键 budget：

| score mode | budget | recall | precision | median true-pair rank |
| --- | ---: | ---: | ---: | ---: |
| physical | 50 | 0.1803 | 0.1933 | 2649.17 |
| physical | 5000 | 0.5355 | 0.0057 | 2644.00 |
| physical_posterior | 50 | 0.2246 | 0.2400 | 2265.83 |
| physical_posterior | 5000 | 0.5478 | 0.0059 | 2265.83 |
| posterior | 50 | 0.9334 | 1.0000 | 1.00 |
| posterior | 5000 | 0.9877 | 0.0106 | 1.00 |

结论：在当前 simulator 中，`time + sky + SNR` 不适合作为 first shortlist score；它会把真对排到中位两千名之后。cheap posterior-summary 参数一致性是更合适的 first shortlist signal。`physical_posterior` 的简单等权相加仍会被 physical score 拖偏，因此默认采用 `posterior`，将 time/sky 留到 confirmation 或后续 validation-selected fusion 中使用。

## 3. P3-B corrected：领域 baseline + native waveform embedding

运行命令：

```bash
cd /root/autodl-tmp/gw-catalog
/root/miniconda3/bin/python scripts/server_experiments/p3b_domain_baselines.py \
  --n-true-pairs 60 \
  --lens-fraction 1e-3 \
  --n-background 110000 \
  --seed 1 \
  --topk 50 \
  --out runs/p3b_domain_baselines_corrected_20260620
```

结果：

| dataset | method | queries | R@1 | R@5 | R@10 | R@50 |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| synthetic realistic-rarity ET3 | synthetic waveform proxy HNSW lossy projection | 104 | 0.5385 | 0.7885 | 0.8269 | 0.9327 |
| synthetic realistic-rarity ET3 | posterior-summary kNN | 104 | 0.8942 | 0.9712 | 0.9808 | 0.9904 |
| synthetic realistic-rarity ET3 | physical time/sky/SNR | 104 | 0.4038 | 0.5000 | 0.5000 | 0.7692 |
| synthetic realistic-rarity ET3 | posterior-summary + physical | 104 | 0.5096 | 0.5192 | 0.5192 | 0.7692 |
| native ET3 noisy test embeddings | native ET3 trained embedding HNSW | 6000 | 0.6245 | 0.7978 | 0.8542 | 0.9360 |

解释：

- `posterior-summary kNN` 是 synthetic observable catalog 上的强领域 baseline。
- `synthetic waveform proxy` 只是 clean 参数的 lossy random-projection proxy，不能代表真实 waveform encoder。
- 真实 ET3 trained embedding 的 R@10=0.8542，与 ET3 full report / P2-A native verified 结果一致，应用于论文时应作为 waveform channel 的真实数字。

## 4. 投稿口径更新

可以正面写：

- Sparse retrieval + cheap posterior-summary shortlist 将 all-pairs 约 `1.38e9` 缩到 50-200 次 follow-up。
- 在 realistic rarity、3 seeds 下，50 次 follow-up 的 mean recall=0.933、precision=1.000；200 次 follow-up 的 mean recall=0.988、precision=0.265。
- 强领域 baseline 已加入：posterior-summary kNN 在 synthetic observable catalog 上 R@10=0.9808。
- 真实 waveform encoder 不应由 synthetic proxy 代表；native ET3 trained embedding 的 R@10=0.8542。

仍需谨慎写：

- P3-A confirmation 仍是 posterior-summary surrogate，不是完整 lensing Bayes factor。
- posterior-summary features 在 synthetic simulator 中非常强，可能部分受模拟生成机制影响；需要真实 PE posterior overlap / fast Bayes factor 做最终 confirmation。
- `physical_posterior` naive fusion 不稳定，后续应使用 validation-selected 或 ranking-objective calibration。
