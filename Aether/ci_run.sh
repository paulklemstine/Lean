#!/usr/bin/env bash
set -euo pipefail

# Aether CI wrapper: runs aether_tick.py (poll, integrate, dispatch, exit).
# Designed for hourly cron — each run takes 2-5 minutes.

MAX_INFLIGHT="${AETHER_MAX_INFLIGHT:-9}"

echo "[ci_run] Aether CI tick starting — max_inflight=${MAX_INFLIGHT}"

python3 aether_tick.py --max-inflight "${MAX_INFLIGHT}" --ollama-cloud

echo "[ci_run] Tick complete"