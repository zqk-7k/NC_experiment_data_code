# Sequence Mitigation Sandbox（2026-07-03）

## 实验目的

这个实验回答一个很具体的问题：在真实 3G 规模和低透镜率下，只有 time-delay + sky-localization 是否会因为事件序列密度升高而不足；加入 **calibrated surrogate waveform embedding** 后，companion retrieval 和 fixed-budget shortlist 是否改善。

重要边界：这里没有生成完整 strain 大目录，也不是完整 strain-level 10^5 event experiment。waveform 通道是 calibrated surrogate waveform embedding，只用于机制 sandbox。

## 方法

三种方法在同一批 catalog、同一 seeds、同一 true pairs 上比较：

1. `time_delay + sky_localization`
2. `calibrated surrogate waveform_embedding only`
3. `calibrated surrogate waveform_embedding + time_delay + sky_localization`

observable catalog 复用 `scripts/server_experiments/observable_simulator.py`。time-delay 使用现有 population delay likelihood-ratio；sky-localization 使用 observed sky A90 转换得到的 normalized separation / log-overlap；waveform surrogate 只使用内禀源 summary 生成 embedding，并加入校准噪声，不使用 trigger time 或 observed sky。

组合方法使用预设 waveform-first calibrated fusion：`z(waveform_embedding) + 0.01 * z(time_delay + sky_localization block)`。这样做的原因是 fixed-budget global shortlist 由极端 false tail 决定；time/sky block 在高 density 下容易产生大量 coincidence，因此在 mitigation setting 中作为弱辅助项，而不是覆盖 waveform sequence 信息。

## A. Density Scan

背景密度：1e+02, 1e+03, 1e+04, 1e+05 events yr^-1。每个条件使用 seeds=[0, 1, 2]，每个 catalog 请求 60 个透镜双像系统。

在最高背景密度 1e+05 events yr^-1 下：

- time-delay + sky-localization 的 R@10 = 0.398 ± 0.110
- calibrated surrogate waveform embedding only 的 R@10 = 0.663 ± 0.062
- waveform + time + sky 的 R@10 = 0.475 ± 0.093

结论：高 density 下，time + sky 会退化，因为随机背景中会出现越来越多时间延迟和天空定位都相容的 coincidence。surrogate waveform 通道提供了与时间/天空近似正交的内禀序列信息，因此改善 top-ten companion retrieval。

## B. Rarity / Fixed-Budget Scan

透镜率：1e-02, 1e-03, 1e-04；shortlist budget：[50, 100, 200]。fixed-budget 结果使用 Monte Carlo false-pair sampling，并对高分尾部做 GPD/normal extrapolation，再按全 catalog false-pair 数缩放，输出 true recovered、false candidates、recall、precision 和 enrichment over base rate。这个尾部估计只用于 sandbox，不是 catalog-level detection significance。

在最稀有设置 lens fraction=1e-04、top-50 shortlist 下：

- time + sky precision = 0.000 ± 0.000
- calibrated surrogate waveform only precision = 0.147 ± 0.061
- waveform + time + sky precision = 0.000 ± 0.000
- time + sky recall = 0.000 ± 0.000
- calibrated surrogate waveform only recall = 0.137 ± 0.058
- waveform + time + sky recall = 0.000 ± 0.000
- time + sky enrichment = 0.000 ± 0.000
- calibrated surrogate waveform only enrichment = 112373727.987 ± 47636194.077
- waveform + time + sky enrichment = 0.000 ± 0.000

在中间低透镜率 lens fraction=1e-03、top-50 shortlist 下：

- time + sky precision / recall = 0.000 ± 0.000 / 0.000 ± 0.000
- calibrated surrogate waveform only precision / recall = 0.187 ± 0.110 / 0.173 ± 0.102
- waveform + time + sky precision / recall = 0.300 ± 0.265 / 0.277 ± 0.249

结论：time + sky 在 fixed-budget global shortlist 中被高密度 false coincidence 压垮。加入 calibrated surrogate waveform 后，在 lens fraction=1e-3 时三通道 shortlist 明显改善；在更极端的 1e-4 下，waveform-only 仍能恢复少量真对，但当前弱融合三通道没有进入 top-50，说明真实 1e-4 口径还需要专门的 validation-selected fusion 或两阶段 waveform-first shortlist。

## 文件

- `density_retrieval_by_method.csv`：density scan per-seed 结果
- `fixed_budget_shortlist_by_method.csv`：rarity/fixed-budget per-seed 结果
- `method_summary.csv`：mean ± std summary
- `sequence_mitigation_summary.json`：核心数值摘要
- `figures/fig_sequence_mitigation_sandbox.pdf`
- `figures/fig_sequence_mitigation_sandbox.png`

## 不能说明什么

这个实验不能替代完整 strain-level 3G catalog 实验，也不能证明真实 waveform encoder 在 10^5 events yr^-1 catalog 上已经完成部署。它只能说明：在 observable-summary sandbox 中，time-delay + sky-localization 会受到序列密度和低透镜率压力；加入校准的 waveform-like embedding 后，fixed-budget shortlist 有机制性改善。
