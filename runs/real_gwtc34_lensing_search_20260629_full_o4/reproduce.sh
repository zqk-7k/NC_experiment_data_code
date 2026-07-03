#!/usr/bin/env bash
set -euo pipefail
cd /root/autodl-tmp/gw-catalog
/root/miniconda3/bin/python scripts/real_search/15_gwtc34_real_deployment.py --run-dir /root/autodl-tmp/gw-catalog/runs/real_gwtc34_lensing_search_20260629_full_o4 --all
