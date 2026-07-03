# SNR<8 / SNR>=8 分层诊断

本报告把当前 catalog-level lensing search 结果按 SNR 分层，重点区分：

```text
low_snr_lt8  : SNR < 8
high_snr_ge8: SNR >= 8
```

对 ET-3 构造目录，有真实 companion pair，因此可以报告 R@K。对真实 GWTC-3/GWTC-4，没有真实透镜标签，因此只报告 null/background candidate 分布，不能解释为 detection 或真实 FDR。

## 数据摘要

```json
{
  "snr_cut": 8.0,
  "et3": {
    "n_events": 9000,
    "n_events_snr_lt8": 21,
    "n_events_snr_ge8": 8979,
    "n_true_pairs": 3000,
    "n_true_pairs_min_snr_lt8": 2,
    "n_true_pairs_min_snr_ge8": 2998,
    "snr_quantiles": {
      "0.0": 4.80859210891185,
      "0.01": 11.161948262544744,
      "0.05": 18.073204851114237,
      "0.1": 23.524466541136274,
      "0.5": 67.3818890034027,
      "0.9": 223.72673221771285,
      "0.99": 684.985313925805,
      "1.0": 5192.460534799287
    }
  },
  "real_catalogs": {
    "real_gwtc3_null_catalog:all": 1953,
    "real_gwtc3_null_catalog:low_snr_lt8": 0,
    "real_gwtc3_null_catalog:high_snr_ge8": 1953,
    "real_gwtc4p1_null_catalog:all": 3486,
    "real_gwtc4p1_null_catalog:low_snr_lt8": 0,
    "real_gwtc4p1_null_catalog:high_snr_ge8": 3486
  },
  "notes": [
    "ET-3 SNR<8 true-pair group is very small; recall estimates are unstable and should be reported as an audit only.",
    "Real GWTC has no confirmed true lens labels here; SNR-stratified real results are null-catalog candidate composition, not recall or detection significance.",
    "GWTC injection pair diagnostics currently contain snr_ratio but not absolute injected-event SNR, so absolute SNR<8/>=8 injection stratification is not reported here."
  ]
}
```

## ET-3 final_score: 按 pair_min_snr 分层

`pair_min_snr` 是真实 pair 两幅像中较弱一幅的 SNR，反映 pair 是否受弱像限制。

| snr_group    |   n_queries |   recall_at_1 |   recall_at_5 |   recall_at_10 |   recall_at_50 |   median_rank |
|:-------------|------------:|--------------:|--------------:|---------------:|---------------:|--------------:|
| all          |        6000 |      0.9735   |      0.998333 |       0.999167 |       0.999667 |           1   |
| low_snr_lt8  |           4 |      0.25     |      0.75     |       0.75     |       1        |           3.5 |
| high_snr_ge8 |        5996 |      0.973983 |      0.998499 |       0.999333 |       0.999666 |           1   |

## ET-3 final_score: 按 query_snr 分层

`query_snr` 是 directed retrieval 中当前 query image 的 SNR。

| snr_group    |   n_queries |   recall_at_1 |   recall_at_5 |   recall_at_10 |   recall_at_50 |   median_rank |
|:-------------|------------:|--------------:|--------------:|---------------:|---------------:|--------------:|
| all          |        6000 |      0.9735   |      0.998333 |       0.999167 |       0.999667 |           1   |
| low_snr_lt8  |           2 |      0.5      |      0.5      |       0.5      |       1        |           8.5 |
| high_snr_ge8 |        5998 |      0.973658 |      0.998499 |       0.999333 |       0.999667 |           1   |

## ET-3 final_score 阈值误配率: 按 pair_min_snr 分层

低 SNR 组真对数量很小，因此阈值结果只作 sanity check，不应作为稳定统计结论。

| dataset                           | score_name   | snr_group   | threshold_source                                   |   target_value |   threshold |   n_true_pairs |   n_false_pairs |   true_pair_count_above_threshold |   false_pair_count_above_threshold |   candidate_count_above_threshold |   recall |   precision |   false_pair_exceedance_rate |
|:----------------------------------|:-------------|:------------|:---------------------------------------------------|---------------:|------------:|---------------:|----------------:|----------------------------------:|-----------------------------------:|----------------------------------:|---------:|------------:|-----------------------------:|
| constructed_et3_full_pair_catalog | final_score  | all         | target_false_pair_exceedance_rate_within_snr_group |         0.01   |     4.23051 |           3000 |        40492500 |                              3000 |                             404925 |                            407925 | 1        |  0.00735429 |                  0.01        |
| constructed_et3_full_pair_catalog | final_score  | all         | target_false_pair_exceedance_rate_within_snr_group |         0.001  |     6.48148 |           3000 |        40492500 |                              2998 |                              40493 |                             43491 | 0.999333 |  0.0689338  |                  0.00100001  |
| constructed_et3_full_pair_catalog | final_score  | all         | target_false_pair_exceedance_rate_within_snr_group |         0.0001 |     9.6022  |           3000 |        40492500 |                              2963 |                               4050 |                              7013 | 0.987667 |  0.422501   |                  0.000100019 |
| constructed_et3_full_pair_catalog | final_score  | all         | target_false_pair_exceedance_rate_within_snr_group |         1e-05  |    13.1629  |           3000 |        40492500 |                              2619 |                                405 |                              3024 | 0.873    |  0.866071   |                  1.00019e-05 |
| constructed_et3_full_pair_catalog | final_score  | all         | target_recall_within_snr_group                     |         0.1    |    19.6262  |           3000 |        40492500 |                               301 |                                 85 |                               386 | 0.100333 |  0.779793   |                  2.09915e-06 |
| constructed_et3_full_pair_catalog | final_score  | all         | target_recall_within_snr_group                     |         0.5    |    16.2958  |           3000 |        40492500 |                              1501 |                                201 |                              1702 | 0.500333 |  0.881904   |                  4.96388e-06 |
| constructed_et3_full_pair_catalog | final_score  | all         | target_recall_within_snr_group                     |         0.9    |    12.7332  |           3000 |        40492500 |                              2701 |                                505 |                              3206 | 0.900333 |  0.842483   |                  1.24714e-05 |
| constructed_et3_full_pair_catalog | final_score  | low_snr_lt8 | target_false_pair_exceedance_rate_within_snr_group |         0.01   |     5.31024 |              2 |          188767 |                                 2 |                               1888 |                              1890 | 1        |  0.0010582  |                  0.0100017   |
| constructed_et3_full_pair_catalog | final_score  | low_snr_lt8 | target_false_pair_exceedance_rate_within_snr_group |         0.001  |     8.97756 |              2 |          188767 |                                 1 |                                189 |                               190 | 0.5      |  0.00526316 |                  0.00100123  |
| constructed_et3_full_pair_catalog | final_score  | low_snr_lt8 | target_false_pair_exceedance_rate_within_snr_group |         0.0001 |    11.9738  |              2 |          188767 |                                 0 |                                 19 |                                19 | 0        |  0          |                  0.000100653 |
| constructed_et3_full_pair_catalog | final_score  | low_snr_lt8 | target_false_pair_exceedance_rate_within_snr_group |         1e-05  |    14.6369  |              2 |          188767 |                                 0 |                                  2 |                                 2 | 0        |  0          |                  1.05951e-05 |
| constructed_et3_full_pair_catalog | final_score  | low_snr_lt8 | target_recall_within_snr_group                     |         0.1    |     7.6012  |              2 |          188767 |                                 2 |                                468 |                               470 | 1        |  0.00425532 |                  0.00247925  |
| constructed_et3_full_pair_catalog | final_score  | low_snr_lt8 | target_recall_within_snr_group                     |         0.5    |     7.6012  |              2 |          188767 |                                 2 |                                468 |                               470 | 1        |  0.00425532 |                  0.00247925  |
| constructed_et3_full_pair_catalog | final_score  | low_snr_lt8 | target_recall_within_snr_group                     |         0.9    |     7.6012  |              2 |          188767 |                                 2 |                                468 |                               470 | 1        |  0.00425532 |                  0.00247925  |

## 真实 GWTC null catalog: 按 pair_min_snr 分层

真实 GWTC 默认所有 pair 视为 null/background。这里统计的是不同 SNR 组在 final_score 分布和 top-k candidate 中的占比。

| dataset                   | snr_group    |   n_null_pairs |   final_score_min |   final_score_median |   final_score_p90 |   final_score_p99 |   final_score_max |
|:--------------------------|:-------------|---------------:|------------------:|---------------------:|------------------:|------------------:|------------------:|
| real_gwtc3_null_catalog   | all          |           1953 |          -13.6936 |              1.37619 |           3.21355 |           6.1658  |           10.2679 |
| real_gwtc3_null_catalog   | low_snr_lt8  |              0 |          nan      |            nan       |         nan       |         nan       |          nan      |
| real_gwtc3_null_catalog   | high_snr_ge8 |           1953 |          -13.6936 |              1.37619 |           3.21355 |           6.1658  |           10.2679 |
| real_gwtc4p1_null_catalog | all          |           3486 |          -27.6168 |              1.35617 |           3.641   |           7.37391 |           16.6527 |
| real_gwtc4p1_null_catalog | low_snr_lt8  |              0 |          nan      |            nan       |         nan       |         nan       |          nan      |
| real_gwtc4p1_null_catalog | high_snr_ge8 |           3486 |          -27.6168 |              1.35617 |           3.641   |           7.37391 |           16.6527 |

Top-k 组成：

| dataset                   |   top_k | snr_group    |   candidate_count_in_top_k |   fraction_of_top_k |
|:--------------------------|--------:|:-------------|---------------------------:|--------------------:|
| real_gwtc3_null_catalog   |       1 | high_snr_ge8 |                          1 |                   1 |
| real_gwtc3_null_catalog   |       5 | high_snr_ge8 |                          5 |                   1 |
| real_gwtc3_null_catalog   |      10 | high_snr_ge8 |                         10 |                   1 |
| real_gwtc3_null_catalog   |      20 | high_snr_ge8 |                         20 |                   1 |
| real_gwtc3_null_catalog   |      50 | high_snr_ge8 |                         50 |                   1 |
| real_gwtc3_null_catalog   |     100 | high_snr_ge8 |                        100 |                   1 |
| real_gwtc3_null_catalog   |     200 | high_snr_ge8 |                        200 |                   1 |
| real_gwtc4p1_null_catalog |       1 | high_snr_ge8 |                          1 |                   1 |
| real_gwtc4p1_null_catalog |       5 | high_snr_ge8 |                          5 |                   1 |
| real_gwtc4p1_null_catalog |      10 | high_snr_ge8 |                         10 |                   1 |
| real_gwtc4p1_null_catalog |      20 | high_snr_ge8 |                         20 |                   1 |
| real_gwtc4p1_null_catalog |      50 | high_snr_ge8 |                         50 |                   1 |
| real_gwtc4p1_null_catalog |     100 | high_snr_ge8 |                        100 |                   1 |
| real_gwtc4p1_null_catalog |     200 | high_snr_ge8 |                        200 |                   1 |

## 论文建议

可以写：

> We further stratified retrieval and candidate-burden diagnostics by SNR. In the ET-3 synthetic catalog, almost all true lensed pairs have both images above SNR 8, so the SNR<8 stratum contains too few true pairs for stable recall estimates. For real GWTC deployments, SNR stratification is reported only as a null-catalog audit of candidate composition and is not interpreted as a detection significance.

不要写：

> SNR<8 组已经被充分验证。

因为当前 ET-3 SNR<8 true-pair 样本极少。
