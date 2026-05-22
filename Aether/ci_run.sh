#!/usr/bin/env bash
set -euo pipefail

# Aether CI wrapper: runs research_loop.py with a time budget,
# then handles cleanup for the next CI run.

MAX_CYCLES="${AETHER_MAX_CYCLES:-3}"
RUN_MINUTES="${AETHER_RUN_MINUTES:-30}"
MARKER_DIR=".aether_workspace"

echo "[ci_run] Aether CI wrapper starting"
echo "[ci_run] max_cycles=${MAX_CYCLES}, run_minutes=${RUN_MINUTES}"

# Remove stale marker files
rm -f "${MARKER_DIR}/.ci_completed_early" "${MARKER_DIR}/.ci_timeout"

# Run research_loop.py under a timeout.
# 'timeout' sends SIGTERM, then SIGKILL after grace period.
# Python asyncio handles SIGTERM gracefully.
timeout --signal=SIGTERM --kill-after=60 "${RUN_MINUTES}m" \
  python3 research_loop.py \
    --continuous \
    --max-inflight 9 \
    --max-cycles "${MAX_CYCLES}" \
    --ollama-cloud \
  && EXIT_CODE=$? || EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "[ci_run] research_loop.py completed all cycles"
  touch "${MARKER_DIR}/.ci_completed_early"
elif [ $EXIT_CODE -eq 124 ]; then
  echo "[ci_run] research_loop.py timed out after ${RUN_MINUTES}m (expected)"
  touch "${MARKER_DIR}/.ci_timeout"
else
  echo "[ci_run] research_loop.py exited with code ${EXIT_CODE}"
fi

# Summary
echo "[ci_run] Research memory entries: $(grep -c '^\{' "${MARKER_DIR}/research_memory.jsonl" 2>/dev/null || echo 'N/A')"
echo "[ci_run] Inflight jobs: $(python3 -c "import json; d=json.load(open('${MARKER_DIR}/inflight_jobs.json')); print(len(d) if isinstance(d, dict) else len(d))" 2>/dev/null || echo 'N/A')"
echo "[ci_run] Done — always exit 0 so workflow continues to commit/push"
exit 0