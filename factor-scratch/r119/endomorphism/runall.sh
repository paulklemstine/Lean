#!/bin/bash
# runall.sh -- full reproduction of the round-119 omega/lambda result.
cd "$(dirname "$0")"
SAGE=/home/raver1975/sage_mamba/envs/sage/bin/sage
for f in h1_control h2_related h3_cost h4_stats omega_size verify; do
  printf "%-14s " "$f"
  if timeout 2400 $SAGE $f.sage > $f.log 2>&1; then echo "OK  (log: $f.log)"; else echo "FAIL (log: $f.log)"; fi
done
echo "--- see RESULT.md ---"
