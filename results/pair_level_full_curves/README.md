# ET-3 Full Pair-Level ROC/PR

This directory contains the lightweight artifacts used for the paper-level
pair diagnostics.

Included:
- `et3_full_metrics.json`
- `et3_full_pr.csv`
- `et3_full_roc_downsampled.csv`

Excluded from GitHub because of size:
- `et3_pair_scores_full.parquet` (~676 MB)
- `et3_pair_scores_final_full.parquet`
- `et3_full_roc.csv` (~487 MB)

The full files were generated in the source project at:
`/root/autodl-tmp/gw-catalog/results/pair_level_full_curves`.
The downsampled ROC table was generated from 11,389,025 full ROC rows.
