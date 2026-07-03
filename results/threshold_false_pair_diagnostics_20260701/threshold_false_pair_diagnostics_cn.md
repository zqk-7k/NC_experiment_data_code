# 阈值化误配率诊断

本报告把 catalog ranking score 转换成阈值决策：

```text
score >= threshold  -> candidate for Bayesian follow-up
score < threshold   -> rejected as non-candidate
```

核心目的是补充 R@K 召回率之外的 false-pair burden。对构造目录，真对和假对标签已知，因此可以同时报告 recall、precision 和 false-pair exceedance rate。对真实 GWTC catalog，不声称存在真实透镜对，所有 pair 均按 null/background 处理，只报告超过阈值的候选数量和目录尾部比例。

## 数据集摘要

```json
{
  "constructed_et3": {
    "n_true_pairs": 3000,
    "n_false_pairs": 40492500,
    "n_total_pairs": 40495500,
    "true_score_quantiles": {
      "0.0": 4.890731334686279,
      "0.5": 16.297433853149414,
      "0.9": 19.628419494628904,
      "0.99": 22.345118198394758,
      "0.999": 24.74866483879093,
      "0.9999": 28.22435552864079,
      "0.99999": 28.786074621467595,
      "1.0": 28.848487854003906
    },
    "false_score_quantiles": {
      "0.0": -5.237630844116211,
      "0.5": -0.13321670144796371,
      "0.9": 2.0248570442199707,
      "0.99": 4.230506954193103,
      "0.999": 6.481469893932392,
      "0.9999": 9.602170716953466,
      "0.99999": 13.162549309197175,
      "1.0": 26.38656997680664
    }
  },
  "gwtc_injection": {
    "path": "data/gwtc_injection_pair_diagnostics.csv",
    "n_rows": 52530,
    "n_true_rows": 200
  },
  "real_catalogs": {
    "real_gwtc3_null_catalog": {
      "path": "runs/real_gwtc_lensing_search_20260625/results/real_pair_scores_waveform_time_sky.parquet",
      "n_pairs": 1953,
      "score_quantiles": {
        "0.0": -13.693611145019531,
        "0.5": 1.376187801361084,
        "0.9": 3.2135521411895747,
        "0.99": 6.165797328948975,
        "0.999": 9.107046730041505,
        "0.9999": 10.203801913452185,
        "0.99999": 10.261519794006404,
        "1.0": 10.267932891845703
      }
    },
    "real_gwtc4p1_null_catalog": {
      "path": "runs/real_gwtc34_lensing_search_20260629_full_o4/results/gwtc4_pair_scores_waveform_time_sky.parquet",
      "n_pairs": 3486,
      "score_quantiles": {
        "0.0": -27.616792678833008,
        "0.5": 1.3561722040176392,
        "0.9": 3.6410012245178223,
        "0.99": 7.373913097381592,
        "0.999": 11.5842131567001,
        "0.9999": 15.389445597171573,
        "0.99999": 16.52633202614782,
        "1.0": 16.652652740478516
      }
    }
  },
  "interpretation": {
    "labeled_false_rate": "computed after removing true companion pairs",
    "real_catalog_rate": "all real pairs are treated as null/background; exceedances are candidate shortlist entries, not detections",
    "cross_applied_et3_thresholds": "not a calibrated real-catalog significance; included only as a score-scale diagnostic"
  }
}
```

## 1. Constructed ET-3 full pair catalog

ET-3 构造目录包含完整 unordered pair 空间。这里的 false-pair exceedance rate 是在去掉真实透镜 companion pair 后，只对 false pairs 计算：

```text
false_pair_exceedance_rate = # false pairs with score >= threshold / # all false pairs
```

示例阈值表：

| dataset                           | score_name   | threshold_source                  |   target_value |   threshold |   n_true_pairs |   n_false_pairs |   true_pair_count_above_threshold |   false_pair_count_above_threshold |   candidate_count_above_threshold |      recall |   precision |   false_pair_exceedance_rate |   false_per_true_recovered |
|:----------------------------------|:-------------|:----------------------------------|---------------:|------------:|---------------:|----------------:|----------------------------------:|-----------------------------------:|----------------------------------:|------------:|------------:|-----------------------------:|---------------------------:|
| constructed_et3_full_pair_catalog | final_score  | target_false_pair_exceedance_rate |         0.01   |     4.23051 |           3000 |        40492500 |                              3000 |                             404925 |                            407925 | 1           |  0.00735429 |                  0.01        |                 134.975    |
| constructed_et3_full_pair_catalog | final_score  | target_false_pair_exceedance_rate |         0.001  |     6.48148 |           3000 |        40492500 |                              2998 |                              40493 |                             43491 | 0.999333    |  0.0689338  |                  0.00100001  |                  13.5067   |
| constructed_et3_full_pair_catalog | final_score  | target_false_pair_exceedance_rate |         0.0001 |     9.6022  |           3000 |        40492500 |                              2963 |                               4050 |                              7013 | 0.987667    |  0.422501   |                  0.000100019 |                   1.36686  |
| constructed_et3_full_pair_catalog | final_score  | target_false_pair_exceedance_rate |         1e-05  |    13.1629  |           3000 |        40492500 |                              2619 |                                405 |                              3024 | 0.873       |  0.866071   |                  1.00019e-05 |                   0.154639 |
| constructed_et3_full_pair_catalog | final_score  | target_false_pair_exceedance_rate |         1e-06  |    20.7931  |           3000 |        40492500 |                               131 |                                 41 |                               172 | 0.0436667   |  0.761628   |                  1.01253e-06 |                   0.312977 |
| constructed_et3_full_pair_catalog | final_score  | target_recall                     |         0.1    |    19.6262  |           3000 |        40492500 |                               301 |                                 85 |                               386 | 0.100333    |  0.779793   |                  2.09915e-06 |                   0.282392 |
| constructed_et3_full_pair_catalog | final_score  | target_recall                     |         0.5    |    16.2958  |           3000 |        40492500 |                              1501 |                                201 |                              1702 | 0.500333    |  0.881904   |                  4.96388e-06 |                   0.133911 |
| constructed_et3_full_pair_catalog | final_score  | target_recall                     |         0.9    |    12.7332  |           3000 |        40492500 |                              2701 |                                505 |                              3206 | 0.900333    |  0.842483   |                  1.24714e-05 |                   0.186968 |
| constructed_et3_full_pair_catalog | final_score  | top_k_candidates                  |         1      |    28.8485  |           3000 |        40492500 |                                 1 |                                  0 |                                 1 | 0.000333333 |  1          |                  0           |                   0        |
| constructed_et3_full_pair_catalog | final_score  | top_k_candidates                  |         5      |    24.9335  |           3000 |        40492500 |                                 3 |                                  2 |                                 5 | 0.001       |  0.6        |                  4.93919e-08 |                   0.666667 |
| constructed_et3_full_pair_catalog | final_score  | top_k_candidates                  |        10      |    24.377   |           3000 |        40492500 |                                 7 |                                  3 |                                10 | 0.00233333  |  0.7        |                  7.40878e-08 |                   0.428571 |
| constructed_et3_full_pair_catalog | final_score  | top_k_candidates                  |        20      |    23.4921  |           3000 |        40492500 |                                14 |                                  6 |                                20 | 0.00466667  |  0.7        |                  1.48176e-07 |                   0.428571 |

## 2. GWTC real background + synthetic injected pairs

该构造数据把真实 GWTC 背景事件作为 null catalog，再注入 synthetic lensed pairs。它用于估计真实背景下的 candidate burden，但 injected pairs 仍是 synthetic，不能解释为真实透镜发现。

示例阈值表：

| dataset                                         | score_name        | threshold_source                  |   target_value |   threshold |   n_true_pairs |   n_false_pairs |   true_pair_count_above_threshold |   false_pair_count_above_threshold |   candidate_count_above_threshold |   recall |   precision |   false_pair_exceedance_rate |   false_per_true_recovered |
|:------------------------------------------------|:------------------|:----------------------------------|---------------:|------------:|---------------:|----------------:|----------------------------------:|-----------------------------------:|----------------------------------:|---------:|------------:|-----------------------------:|---------------------------:|
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | target_false_pair_exceedance_rate |         0.01   |     2.98789 |            200 |           52330 |                               121 |                                524 |                               645 |    0.605 |   0.187597  |                  0.0100134   |                   4.33058  |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | target_false_pair_exceedance_rate |         0.001  |     4.12679 |            200 |           52330 |                                47 |                                 53 |                               100 |    0.235 |   0.47      |                  0.0010128   |                   1.12766  |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | target_false_pair_exceedance_rate |         0.0001 |     4.90466 |            200 |           52330 |                                 7 |                                  6 |                                13 |    0.035 |   0.538462  |                  0.000114657 |                   0.857143 |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | target_false_pair_exceedance_rate |         1e-05  |     5.4128  |            200 |           52330 |                                 4 |                                  1 |                                 5 |    0.02  |   0.8       |                  1.91095e-05 |                   0.25     |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | target_false_pair_exceedance_rate |         1e-06  |     5.4128  |            200 |           52330 |                                 4 |                                  1 |                                 5 |    0.02  |   0.8       |                  1.91095e-05 |                   0.25     |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | target_recall                     |         0.1    |     4.6136  |            200 |           52330 |                                21 |                                 14 |                                35 |    0.105 |   0.6       |                  0.000267533 |                   0.666667 |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | target_recall                     |         0.5    |     3.24805 |            200 |           52330 |                               101 |                                328 |                               429 |    0.505 |   0.235431  |                  0.00626792  |                   3.24752  |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | target_recall                     |         0.9    |     1.58683 |            200 |           52330 |                               181 |                               5745 |                              5926 |    0.905 |   0.0305434 |                  0.109784    |                  31.7403   |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | top_k_candidates                  |         1      |     5.95042 |            200 |           52330 |                                 1 |                                  0 |                                 1 |    0.005 |   1         |                  0           |                   0        |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | top_k_candidates                  |         5      |     5.4128  |            200 |           52330 |                                 4 |                                  1 |                                 5 |    0.02  |   0.8       |                  1.91095e-05 |                   0.25     |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | top_k_candidates                  |        10      |     5.09904 |            200 |           52330 |                                 7 |                                  3 |                                10 |    0.035 |   0.7       |                  5.73285e-05 |                   0.428571 |
| gwtc3_real_background_plus_synthetic_injections | combined_time_sky | top_k_candidates                  |        20      |     4.75643 |            200 |           52330 |                                12 |                                  8 |                                20 |    0.06  |   0.6       |                  0.000152876 |                   0.666667 |

## 3. Real GWTC-3/GWTC-4 null catalogs

真实 GWTC 部署没有已知真透镜标签。默认口径是：所有真实事件对均为 background/null coincidence。阈值以上的 pair 只能叫 candidate shortlist for Bayesian follow-up。

示例阈值表：

| dataset                 | score_name   | threshold_source                          |   target_value |   threshold |   n_null_pairs |   candidate_count_above_threshold |   null_pair_exceedance_rate |
|:------------------------|:-------------|:------------------------------------------|---------------:|------------:|---------------:|----------------------------------:|----------------------------:|
| real_gwtc3_null_catalog | final_score  | top_k_candidates_within_real_catalog      |          1     |    10.2679  |           1953 |                                 1 |                 0.000512033 |
| real_gwtc3_null_catalog | final_score  | top_k_candidates_within_real_catalog      |          5     |     7.8764  |           1953 |                                 5 |                 0.00256016  |
| real_gwtc3_null_catalog | final_score  | top_k_candidates_within_real_catalog      |         10     |     7.03132 |           1953 |                                10 |                 0.00512033  |
| real_gwtc3_null_catalog | final_score  | top_k_candidates_within_real_catalog      |         20     |     6.17681 |           1953 |                                20 |                 0.0102407   |
| real_gwtc3_null_catalog | final_score  | top_k_candidates_within_real_catalog      |         50     |     4.72918 |           1953 |                                50 |                 0.0256016   |
| real_gwtc3_null_catalog | final_score  | top_k_candidates_within_real_catalog      |        100     |     3.79251 |           1953 |                               100 |                 0.0512033   |
| real_gwtc3_null_catalog | final_score  | top_k_candidates_within_real_catalog      |        200     |     3.19278 |           1953 |                               200 |                 0.102407    |
| real_gwtc3_null_catalog | final_score  | top_k_candidates_within_real_catalog      |        500     |     2.06529 |           1953 |                               500 |                 0.256016    |
| real_gwtc3_null_catalog | final_score  | catalog_tail_fraction_within_real_catalog |          0.1   |     3.21562 |           1953 |                               196 |                 0.100358    |
| real_gwtc3_null_catalog | final_score  | catalog_tail_fraction_within_real_catalog |          0.05  |     3.80499 |           1953 |                                98 |                 0.0501792   |
| real_gwtc3_null_catalog | final_score  | catalog_tail_fraction_within_real_catalog |          0.01  |     6.17681 |           1953 |                                20 |                 0.0102407   |
| real_gwtc3_null_catalog | final_score  | catalog_tail_fraction_within_real_catalog |          0.005 |     7.03132 |           1953 |                                10 |                 0.00512033  |

## 推荐论文表述

可以写：

> We report retrieval recall for known injected/simulated lensed pairs and separately quantify false-association burden by thresholding the final pair score. For labeled synthetic catalogs, false-pair exceedance is computed after removing true companion pairs. For real GWTC deployments, all catalog pairs are treated as a null/background population; threshold exceedances define a candidate shortlist for Bayesian follow-up and are not interpreted as detections.

不要写：

> thresholded GWTC pairs are confirmed lenses.

## 解释

- R@K 回答“真透镜 pair 能否被找回”。
- false-pair exceedance 回答“如果设置阈值，会留下多少假候选”。
- 真实 GWTC 只能报告 null/background exceedance 和 shortlist rank，不能计算真实 precision 或 FDR。
