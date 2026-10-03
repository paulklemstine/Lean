#!/bin/bash
cd /home/raver1975/lean/factor-scratch/r50/exp/bsweep
while ! grep -q ALLDONE chain1.log 2>/dev/null; do sleep 30; done
echo "=== chain1 finished, starting combined ==="
NBITS=30 NPROC=12 NFULL=200 CAP=2000000 SEED0=1700000 BS=20,40,64,80,100,128 \
  timeout 6000 python3 -u run_combined.py > combined_n30.log 2>&1
echo "=== combined n30 rc=$? ==="
NBITS=40 NPROC=12 NFULL=60 CAP=2000000 SEED0=1800000 BS=40,80,128,200 \
  timeout 6000 python3 -u run_combined.py > combined_n40.log 2>&1
echo "=== combined n40 rc=$? ==="
echo CHAIN2DONE
