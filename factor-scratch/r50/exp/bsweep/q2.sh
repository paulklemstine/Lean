#!/bin/bash
cd /home/raver1975/lean/factor-scratch/r50/exp/bsweep
NBITS=30 NPROC=12 NFULL=120 CAP=2000000 SEED0=1700000 BS=20,40,64,100 timeout 3000 python3 -u run_combined.py > combined_n30.log 2>&1
echo "CN30 rc=$?"
NBITS=40 NPROC=12 NFULL=50 CAP=2000000 SEED0=1800000 BS=40,80,128 timeout 3000 python3 -u run_combined.py > combined_n40.log 2>&1
echo "CN40 rc=$?"
echo Q2DONE
