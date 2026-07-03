# NC gating P3-A PE scatter audit

日期：2026-06-20
项目：`/root/autodl-tmp/gw-catalog`

本报告修正 `nc_gating_p3_corrected_results_20260620_cn.md` 中 P3-A posterior shortlist 的过强口径。结论先行：

1. `posterior` shortlist 在无 PE 散射的 simulator 中能得到近乎完美 precision，但这是因为同一透镜系统两像共享完全相同的 intrinsic parameters。
2. 加入每个事件独立的 realistic PE summary scatter 后，posterior-summary shortcut 失效。
3. realistic PE 下，闭环应回到 physical time/sky/SNR 主导；posterior summary 只能以很小权重作为辅助，不能作为 first shortlist 主信号。

## 1. 新增脚本

脚本：

```text
scripts/server_experiments/p3a_pe_scatter_sweep.py
```

设计原则：

- 不修改 `observable_simulator.py`，避免污染历史复现。
- 在 simulator 生成 catalog 后，对每个事件独立加入 PE summary scatter：
  - `log chirp_mass sigma = 0.03`
  - `mass_ratio sigma = 0.15`
  - `log luminosity_distance sigma = 0.40`
- 在同一 HNSW candidate set 上扫描：
  - shortlist score: `physical`、`posterior_pe`、`physical + w * posterior_pe`
  - final rank score: `physical`、`posterior_pe`、`physical + w * posterior_pe`、`confirm_pe`
- 自动按指定 follow-up budget 的 mean recall/precision harmonic score 选择 best mode。

运行命令：

```bash
cd /root/autodl-tmp/gw-catalog
/root/miniconda3/bin/python scripts/server_experiments/p3a_pe_scatter_sweep.py \
  --seeds 0 1 2 \
  --n-true-pairs 60 \
  --lens-fraction 1e-3 \
  --n-background 110000 \
  --topk 100 \
  --shortlist-budget 5000 \
  --pe-log-mc-sigma 0.03 \
  --pe-q-sigma 0.15 \
  --pe-log-dl-sigma 0.40 \
  --out runs/p3a_pe_scatter_realistic_20260620
```

输出：

```text
runs/p3a_pe_scatter_realistic_20260620/
  best_mode.json
  p3a_pe_scatter_curve.csv
  p3a_pe_scatter_curve_mean.csv
  p3a_pe_scatter_summary.csv
  p3a_pe_scatter_shortlist_mean.csv
  p3a_pe_scatter_diagnostics.csv
  p3a_pe_scatter_diagnostics_mean.csv
```

## 2. 自动选择结果

以 50 次 follow-up 为优化目标，3 seeds mean 的 best mode 为：

```text
shortlist=physical | rank=physical_plus_0.1post
```

| follow-up budget | recall | precision | FDR | mean true pairs |
| ---: | ---: | ---: | ---: | ---: |
| 50 | 0.1872 | 0.2000 | 0.8000 | 10.0 |
| 100 | 0.2059 | 0.1100 | 0.8900 | 11.0 |
| 200 | 0.2374 | 0.0633 | 0.9367 | 12.7 |
| 500 | 0.3185-0.3266 | 0.0340-0.0347 | 0.9653-0.9660 | 17.0-17.3 |
| 1000 | 0.4673-0.4731 | 0.0250-0.0253 | 0.9747-0.9750 | 25.0-25.3 |
| 5000 | 0.5355 | 0.0057 | 0.9943 | 28.7 |

解释：

- 在 realistic PE scatter 下，50 次 follow-up 不再有 near-perfect precision。
- 最优模式仍以 physical score 为主，只允许 `0.1 * posterior_pe` 的小权重修正。
- 200 次 follow-up 的 precision 约 0.063，不应继续引用无散射 posterior 模式下的 0.265 或 50 次 precision=1.0。

## 3. 关键对照

3 seeds mean：

| mode | budget | recall | precision | FDR |
| --- | ---: | ---: | ---: | ---: |
| `shortlist=physical, rank=physical` | 50 | 0.1803 | 0.1933 | 0.8067 |
| `shortlist=physical, rank=physical_plus_0.1post` | 50 | 0.1872 | 0.2000 | 0.8000 |
| `shortlist=physical, rank=confirm_pe` | 50 | 0.1195 | 0.1267 | 0.8733 |
| `shortlist=posterior_pe, rank=posterior_pe` | 50 | 0.0000 | 0.0000 | 1.0000 |
| `shortlist=posterior_pe, rank=physical` | 50 | 0.0064 | 0.0067 | 0.9933 |

Posterior-only 在 realistic PE scatter 下基本崩溃，说明无散射 corrected P3-A 的 near-perfect result 是 simulator shortcut，而不是可投稿的 final precision。

## 4. 真对排名诊断

3 seeds mean：

| shortlist score | median true-pair rank | p90 true-pair rank | max true-pair rank |
| --- | ---: | ---: | ---: |
| `physical` | 2644 | 17277 | 94244 |
| `physical_plus_0.1post` | 2600 | 17018 | 118248 |
| `physical_plus_0.5post` | 2478 | 17080 | 200806 |
| `confirm_pe` | 142754 | 993745 | 2944630 |
| `posterior_pe` | 1428774 | 3224782 | 3726433 |

结论：

- `posterior_pe` 已不具备 shortlist 能力。
- `confirm_pe` 如果把 noisy posterior 权重大幅放入 final ranking，也会显著伤害 early precision。
- physical score 是 realistic PE scatter 下唯一稳定的 first-stage signal；posterior summary 只能小权重融合。

## 5. 代码口径更新

已将 `p3a_end_to_end_confirmation.py` 的默认 `--shortlist-mode` 改回 `physical`，并在脚本说明中注明：

```text
plain posterior shortlist uses exact simulator intrinsic parameters unless PE scatter is added externally.
For realistic PE-uncertainty audits, use p3a_pe_scatter_sweep.py.
```

这避免后续默认运行继续产出 artifact-like posterior shortcut 结果。

## 6. 投稿建议

不建议写：

```text
50 次 follow-up recall=0.933, precision=1.000
```

该数字只适用于无 PE 散射的 idealized simulator，不代表真实 PE 条件。

建议写：

```text
In an idealized no-PE-scatter sanity check, posterior-summary consistency can nearly identify injected true pairs, revealing that intrinsic-parameter identity is a powerful but simulator-specific shortcut. After injecting realistic per-event PE summary scatter, this shortcut collapses, and the robust closure is driven by physical time/sky/SNR ranking with only weak posterior-summary fusion. Under this realistic stress test, the best 50-follow-up setting recovers about 19% of true pairs at about 20% precision, while reducing the all-pairs space by more than seven orders of magnitude.
```

更保守的中文表述：

```text
无散射 posterior-summary 结果只能作为机制 sanity check，不能作为最终 discovery precision。加入真实 PE 测量散射后，闭环 precision 降至更现实的水平；这表明当前 sparse triage 已经证明计算可行性，但要达到 NC-ready discovery claim，还需要真实 posterior-overlap / fast Bayes factor / phase-Morse consistency 作为 confirmation。
```

