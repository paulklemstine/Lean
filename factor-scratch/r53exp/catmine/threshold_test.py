# DECISIVE TEST for the Round-97f "measured n/4 wall".
#
# 97f reports ONE instance per (n,k) with a sweep over m,t in 2..9, reporting
# success if ANY (m,t) works.  Two threats to that being a *wall* measurement:
#   (A) the parameter ceiling  -- if widening m,t moves the threshold, the
#       measured wall is the sweep's ceiling, not the mathematics;
#   (B) best-of-many           -- sweeping ~O(500) lattices per cell and
#       reporting the best is a multiple-comparisons leak.  Coppersmith's
#       X < N^{1/4} is a GUARANTEE (sufficient), not a hard barrier, so a
#       particular (m,t) can succeed above it.
# Test: per-instance rate, and the distribution of the best threshold.
import sys, random, statistics
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, factor_with_top_bits

# SEEDED.  This script was originally unseeded, so its counts moved between runs
# (13/40 on one invocation, 12/40 on the next) -- which makes every number it
# prints uncitable, and this is the experiment the paper's headline rests on.
# Fixed so the published figures are the figures.
random.seed(20261004)

def best_k(N,p,nn,klo,khi,mhi=10):
    """smallest k (most known bits) is easier; we want the SMALLEST k that works"""
    best=None
    for k in range(klo,khi):
        for m in range(2,mhi):
            for t in range(2,mhi):
                if factor_with_top_bits(N,p,nn,k,m,t): return k
    return None

print("=== per-instance best threshold over %d trials per n ===" % 40)
for n in [48,64]:
    ks=[]
    for trial_i in range(40):
        while True:
            p=gen_prime(n//2); q=gen_prime(n//2); N=p*q
            if 2**(n-1)<=N<2**n: break
        nn=N.bit_length(); quarter=nn//4
        k=best_k(N,p,nn,max(1,quarter-8),quarter+1)
        ks.append(k)
    ok=[x for x in ks if x is not None]
    print(f"n={nn} n/4={quarter}: best-k over 40 instances: min={min(ok)} "
          f"max={max(ok)} mean={statistics.mean(ok):.2f}")
    print(f"   distribution: {sorted(ok)}")
    below=[x for x in ok if x<quarter]
    print(f"   >>> instances succeeding with k < n/4 : {len(below)}/40  {sorted(below)}")
