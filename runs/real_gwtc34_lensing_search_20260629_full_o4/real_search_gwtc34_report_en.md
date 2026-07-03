# GWTC-3/GWTC-4.1 real catalog lens-candidate refinement 报告

生成时间：2026-06-29T17:50:20.609679+00:00

## Executive Summary

本结果是 candidate shortlist for Bayesian follow-up，不是透镜探测声明。主排序严格使用三通道：waveform score、time-delay score、real HEALPix sky-overlap score。SNR/amplitude 只作为 audit column 保留，没有进入 final_score。

GWTC-3 使用已有 O3-noise encoder 和既有权威结果，不重跑主结果。GWTC-4.1 使用 O4a off-source public H1/L1 strain 注入训练的 run-matched encoder；O3->O4a 只作为 transfer ablation。

GWTC-4.1 的主融合采用 constrained three-channel validation selection：waveform、time-delay、HEALPix sky 三个通道权重均必须为正，避免把某一主通道在真实部署中关闭。

## GWTC-4.1 数据口径

- 初始 GWTC-4.1 event API 事件数：140
- PE-supported + HEALPix skymap available primary events：84
- primary unordered pairs：3486
- H1-L1 且 BBH waveform-eligible events：81
- full-waveform-scored BBH pairs：3240
- OOD/NSBH/低质量或未知事件数：1

## Waveform Gate-1

- GWTC-4 O4-noise run-matched Gate-1 passed：True
- macro test R@10：0.8583333333333334
- min-family test R@10：0.8444444444444444
- O3->O4a transfer ablation passed：True
- O3->O4a macro test R@10：0.9027777777777778

## GWTC-4.1 主排序

- final weights：`{"waveform": 1.0, "time": 0.25, "sky": 4.0}`
- waveform policy：validation_selected_waveform_time_sky_constrained_positive_three_channel
- 榜首：GW230726_002940 -- GW230814_230901
- 榜首是否 full-waveform-scored：True
- 榜首是否含 OOD：False

## GWTC-4.1 Top 10

|   rank | event_i         | event_j         |   final_score |   waveform_score |   time_score |   healpix_sky_score |   delta_t_days |   healpix_overlap | waveform_available   | full_waveform_scored   | pair_has_ood   | object_class_i   | object_class_j   | detector_coverage   |   snr_ratio |   snr_score |   empirical_catalog_tail_rank_fraction |
|-------:|:----------------|:----------------|--------------:|-----------------:|-------------:|--------------------:|---------------:|------------------:|:---------------------|:-----------------------|:---------------|:-----------------|:-----------------|:--------------------|------------:|------------:|---------------------------------------:|
|      1 | GW230726_002940 | GW230814_230901 |      16.6527  |         0.99999  |     0.144965 |          -0.0290824 |       19.944   |          0.971336 | True                 | True                   | False          | BBH              | BBH              | H1,L1 | H1,L1       |     4.09524 |   0.49846   |                            0.000286862 |
|      2 | GW231231_154016 | GW240104_164932 |      13.028   |         0.948349 |     0.723715 |          -0.0622028 |        4.0481  |          0.939692 | True                 | True                   | False          | BBH              | BBH              | H1,L1 | H1,L1       |     1.10448 |  -0.752013  |                            0.000573723 |
|      3 | GW231223_202619 | GW240104_164932 |      11.7216  |         0.998495 |     0.509143 |          -0.161906  |       11.8495  |          0.850521 | True                 | True                   | False          | BBH              | BBH              | H1,L1 | H1,L1       |     1.46535 |   0.335632  |                            0.000860585 |
|      4 | GW230911_195324 | GW231231_154016 |      11.7177  |         0.960968 |    -0.987858 |          -0.190355  |      110.824   |          0.826665 | True                 | True                   | False          | BBH              | BBH              | H1,L1 | H1,L1       |     1.20721 |  -0.652556  |                            0.00114745  |
|      5 | GW231223_202619 | GW231231_154016 |      11.4425  |         0.960548 |     0.306486 |          -0.340476  |        7.80136 |          0.711431 | True                 | True                   | False          | BBH              | BBH              | H1,L1 | H1,L1       |     1.32673 |  -0.329917  |                            0.00143431  |
|      6 | GW230911_195324 | GW240104_164932 |      10.8341  |         0.998512 |    -1.05409  |          -0.308529  |      114.872   |          0.734526 | True                 | True                   | False          | BBH              | BBH              | H1,L1 | H1,L1       |     1.33333 |  -0.329917  |                            0.00172117  |
|      7 | GW230630_125806 | GW230707_124047 |      10.5968  |         0.958912 |     0.608552 |          -0.159477  |        6.98797 |          0.85259  | True                 | True                   | False          | BBH              | BBH              | H1,L1 | H1,L1       |     1.32222 |  -0.329917  |                            0.00200803  |
|      8 | GW230911_195324 | GW231029_111508 |      10.1776  |       nan        |    -0.464705 |          -0.217728  |       47.6401  |          0.804344 | False                | False                  | False          | BBH              | BBH              | H1,L1 | L1          |     1.02778 |  -0.791544  |                            0.00229489  |
|      9 | GW231029_111508 | GW240109_050431 |       9.65124 |       nan        |    -0.764589 |          -0.276779  |       71.7426  |          0.758222 | False                | False                  | False          | BBH              | BBH              | L1 | H1             |     1.03846 |  -0.791544  |                            0.00258176  |
|     10 | GW230726_002940 | GW240104_164932 |       9.25449 |         0.546359 |    -0.912691 |          -0.0684755 |      162.68    |          0.933816 | True                 | True                   | False          | BBH              | BBH              | H1,L1 | H1,L1       |     1.40952 |   0.0493245 |                            0.00286862  |

## GWTC-3/GWTC-4.1 并排摘要

| catalog   |   n_events |   n_pairs |   waveform_available_events |   waveform_available_pairs |   gate1_macro_r_at_10 |   gate1_min_family_r_at_10 | selected_weights                             | top_pair                         | top_pair_waveform_available   | top_pair_ood   |   gw170104_gw170814_rank |
|:----------|-----------:|----------:|----------------------------:|---------------------------:|----------------------:|---------------------------:|:---------------------------------------------|:---------------------------------|:------------------------------|:---------------|-------------------------:|
| GWTC-3    |         63 |      1953 |                          55 |                       1485 |              0.913889 |                   0.911111 | {"waveform": 0.25, "time": 0.25, "sky": 4.0} | GW191219_163120--GW191230_180458 | True                          | False          |                      272 |
| GWTC-4.1  |         84 |      3486 |                          81 |                       3240 |              0.858333 |                   0.844444 | {"waveform": 1.0, "time": 0.25, "sky": 4.0}  | GW230726_002940--GW230814_230901 | True                          | False          |                      nan |

## 为什么不合并目录作为主结果

GWTC-3 和 GWTC-4.1 采用 run-matched encoder。O3 与 O4a 的噪声域、搜索管线和 PE release 口径不同。除非使用单一 shared encoder 重新嵌入全部事件，并完成跨 run score calibration 的 QQ/KS 检查，否则 merged catalog 只能作为 future work 或 diagnostic，不作为主结果。

## 输出

- 主图：`figures/fig_real_gwtc34_search.pdf`
- GWTC-4 candidate shortlist：`results/gwtc4_candidate_shortlist_waveform_time_sky.csv`
- GWTC-4 pair scores：`results/gwtc4_pair_scores_waveform_time_sky.parquet`
- 跨 run 摘要：`results/gwtc34_cross_run_summary.csv`
- deliverables package：`/root/autodl-tmp/gw-catalog/packages/real_gwtc34_lensing_search_20260629_full_o4_deliverables.tar.gz`
