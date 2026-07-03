#!/usr/bin/env bash
set -euo pipefail

# This lightweight repository contains selected scripts and result artifacts.
# Full regeneration requires the original gw-catalog environment and large data
# files that are intentionally not stored in GitHub.

echo "Main scripts:"
echo "  scripts/experiments/90_et3_full_experiment_runner.py"
echo "  scripts/experiments/91_et3_modality_combinations.py"
echo "  scripts/experiments/97_export_et3_full_pair_curves.py"
echo "  scripts/experiments/sequence_mitigation_sandbox.py"
echo "  scripts/real_search/"

echo "For the sequence mitigation sandbox:"
echo "  python scripts/experiments/sequence_mitigation_sandbox.py"
