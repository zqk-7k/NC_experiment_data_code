# NC Experiment Data and Code

This repository is a lightweight, GitHub-sized release bundle for the paper
`main.pdf` from the `gw-catalog` project. It collects the paper-facing code,
tables, figures and diagnostic reports needed to audit the main experimental
claims.

## Paper Main Line

The paper studies catalog-level retrieval of strongly lensed gravitational-wave
pairs. The method has three scoring channels:

1. waveform embedding from an InceptionTime encoder,
2. time-delay likelihood-ratio score,
3. observed-sky / HEALPix sky-localization score.

The main simulated ET-3 catalog contains 9,000 events: 3,000 two-image lensed
systems and 3,000 isolated events. The headline retrieval result is that
waveform-only retrieval reaches roughly R@1=0.625 and R@10=0.854, while the
catalog ranking score reaches roughly R@1=0.976 and R@10=0.999.

The real-catalog part treats GWTC-3 and GWTC-4.0/O4a as empirical null
backgrounds and outputs candidate shortlists for Bayesian follow-up. These are
not lensing detections.

## Repository Layout

- `paper/`: `main.pdf` and extracted text.
- `scripts/`: selected experiment, server-experiment, GWTC and real-search code.
- `docs/`: paper-facing technical reports and experiment summaries.
- `results/`: lightweight result tables, metrics, figures and reports.
- `runs/`: selected run outputs for ET-3 and GWTC real-catalog deployment.
- `data/`: small derived CSV tables used by the paper diagnostics.
- `figures/`: rendered paper/diagnostic figures.
- `FILE_MANIFEST.csv`: file inventory with sizes.
- `LARGE_FILES_EXCLUDED.md`: explicit list of files excluded from GitHub.

## Key Result Groups

### ET-3 Companion Retrieval

Relevant files:

- `runs/et3_liao_realistic_p1_p2_rerank_20260616/`
- `docs/et3_full_experiment_report_20260616_cn.md`
- `docs/et3_stage7_modality_combinations_report_20260616_cn.md`
- `scripts/experiments/90_et3_full_experiment_runner.py`
- `scripts/experiments/91_et3_modality_combinations.py`

### Pair-Level ROC/PR and False-Pair Burden

Relevant files:

- `results/pair_level_full_curves/et3_full_metrics.json`
- `results/pair_level_full_curves/et3_full_pr.csv`
- `results/pair_level_full_curves/et3_full_roc_downsampled.csv`
- `results/threshold_false_pair_diagnostics_20260701/`
- `scripts/experiments/97_export_et3_full_pair_curves.py`
- `scripts/experiments/threshold_false_pair_diagnostics.py`

The full pair-score parquet and full ROC CSV are too large for GitHub and are
listed in `LARGE_FILES_EXCLUDED.md`.

### Sequence Mitigation Sandbox

Relevant files:

- `results/sequence_mitigation_sandbox_20260703/`
- `scripts/experiments/sequence_mitigation_sandbox.py`

Important boundary: the waveform channel here is a calibrated surrogate waveform
embedding, not a full strain-level encoder over 10^5-event catalogs.

### GWTC-3 / GWTC-4 Real-Catalog Deployment

Relevant files:

- `runs/real_gwtc34_lensing_search_20260629_full_o4/`
- `scripts/real_search/`
- `results/gwtc_download_links_20260702/`

The real-catalog outputs are candidate shortlists for follow-up. They do not
claim a lensing detection.

## Reproducibility Notes

This repository intentionally excludes raw strain arrays, large model
checkpoints, and full all-pair score tables. The included scripts point back to
the original generation paths and can regenerate these artifacts in the full
`gw-catalog` environment.

Generated at: 2026-07-03T10:08:32.752874+00:00
Source project: `/root/autodl-tmp/gw-catalog`
