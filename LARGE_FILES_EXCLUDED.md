# Large Files Excluded From GitHub

The following files are intentionally excluded because they exceed normal GitHub
repository limits or are raw/generated strain artifacts:

- `results/pair_level_full_curves/et3_pair_scores_full.parquet` (~676 MB)
- `results/pair_level_full_curves/et3_pair_scores_final_full.parquet`
- `results/pair_level_full_curves/et3_full_roc.csv` (~487 MB)
- `runs/real_gwtc34_lensing_search_20260629_full_o4/data/real_noise_injections/**`
- raw GWTC strain/skymap cache directories under `data/gwtc*_raw/`
- large model checkpoints unless explicitly copied as lightweight audit context

The GitHub bundle includes CSV/JSON summaries, small parquet diagnostics,
figures, scripts, and reports sufficient to audit the paper claims. Full all-pair
tables should be regenerated or archived via a data repository such as Zenodo.
