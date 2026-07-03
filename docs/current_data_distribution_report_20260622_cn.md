# 当前数据分布展示包

生成日期：2026-06-22

## 数据范围

本展示包按 `/root/work/create data/展示内容与展示原因.docx` 的最小展示要求生成，覆盖当前代码实际使用的 ET/LIGO、SIS/PM 数据根。

| detector | family | root | lensed pairs | unlensed events |
|---|---|---|---:|---:|
| ET | SIS | `/root/autodl-tmp/gw_et_10000_matchstyle_20260527_091859` | 10000 | 10000 |
| ET | PM | `data_generation/pm_mass_1e4_1e10_td_min24s_matchroots/ET` | 10000 | 10000 |
| LIGO | SIS | `/root/autodl-tmp/gw_ligo_10000_matchstyle_20260527_091859` | 10000 | 10000 |
| LIGO | PM | `data_generation/pm_mass_1e4_1e10_td_min24s_matchroots/LIGO` | 10000 | 10000 |

## 输出文件

| 文件 | 内容 |
|---|---|
| `figures/Fig1_lensed_pair_example_<detector>_<family>.pdf/png` | 每组一个代表性双像 waveform 与 0.3 s zoom |
| `figures/Fig2_SNR_distribution.pdf/png` | image1、image2、unlensed 的 SNR histogram 与 CDF |
| `figures/Fig3_magnification_distribution.pdf/png` | abs(mu_0)、abs(mu_1)、mu_total 分布和关键 fraction |
| `figures/Fig4_time_delay_distribution.pdf/png` | delta_t 分布、delta_t vs M_L/sigma_v、delta_t vs y |
| `figures/Fig5_lens_parameter_distribution.pdf/png` | PM: M_L/y/z_l/z_s；SIS: sigma_v/y/z_l/z_s |
| `tables/Table1_representative_event_parameters.csv` | 每组代表性双像事件参数 |
| `tables/Table2_population_summary.csv` | 群体统计量和质量检查 fraction |

## 注意

- LIGO 当前 trigger 表中只有每个 image 的 network/available SNR 字段，没有单独 H1/L1 SNR 列；因此本展示包按现有 `snr_1/snr_2` 和 unlensed `snr` 展示。
- waveform 图使用当前 noisy `data_strain`，并做标准化显示，用于形态 sanity check；物理统计以 CSV 元数据为准。