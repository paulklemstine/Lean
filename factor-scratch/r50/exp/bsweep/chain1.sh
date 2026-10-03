#!/bin/bash
cd /home/raver1975/lean/factor-scratch/r50/exp/bsweep
while pgrep -f "python3 -u run_sweep.py" >/dev/null; do sleep 15; done
echo "=== main sweep finished ==="
NPROC=12 WHAT=E1 N=20 CAP=2000000 timeout 4000 python3 -u run_extra.py > extra_E1.log 2>&1
echo "=== E1 done rc=$? ==="
NPROC=12 WHAT=E2 N2=600 BS2=4,6,8,12 CAP=2000000 timeout 4000 python3 -u run_extra.py > extra_E2.log 2>&1
echo "=== E2 done rc=$? ==="
NPROC=12 NBITS=30 NFULL=400 BS=6,12,20,40 timeout 3000 python3 -u diag_Gzero.py > gzero.log 2>&1
echo "=== gzero done rc=$? ==="
echo ALLDONE
