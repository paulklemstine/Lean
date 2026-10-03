#!/usr/bin/env python3
"""A1 KEY QUESTION: the paper says 'u~3-5 and the events that matter are at small k'.
WHICH k DOMINATES for B-smooth NFS values at realistic B?

Method: the excess in P(p^k | v) is (2-1/p) [for k in 2..5] etc.  For a value v that is
B-smooth, what is the distribution of v_p(v)?  The smoothness criterion is
v_p(v) >= 0 for all p <= B and p | v only for p <= B.  The EXTRA divisibility by p^k
events matters only insofar as it changes P(v is B-smooth).

Decisive test: measure the ACTUAL smoothness rate of a^2-b^3 vs a uniform integer
of the SAME size, at realistic B = 2^20 and 2^25 -- i.e. u = log2(x)/log2(B).
Then: what FRACTION of that smoothness bias comes from k>=2 divisibility at all?

DIRECT DECOMPOSITION: for each (a,b), compute v=a^2-b^3.  Compare
  P(v is B-smooth)  vs  P(v is B-smooth AND gcd-squarefree-kernel...)  -- no.
Better: split the smooth values by their largest prime factor index / by whether
the excess can be attributed to k>=2 at all.

Cleanest: measure smoothness rate conditioned on the ZERO-subspace vs not.
"""
import math, random
from sympy import factorint

def is_smooth(n,B):
    """EXACT integer smoothness. No float comparison. MUST be able to return False."""
    for p,e in factorint(abs(n)).items():
        if p>B: return False
    return True

def selftest():
    # THE predicate must be shown able to return False
    assert not is_smooth(1_000_003, 1000), "predicate never returns False"
    assert not is_smooth(999983, 1000)
    assert is_smooth(2**10*3**5, 1000)
    assert not is_smooth(2**10*3**5*1009, 1000)
    print("SELF-TEST smoothness predicate: PASS (returns False where it must)")

def dickman_rho(u):
    if u<=0: return 1.0
    if u<1: return 1.0
    if u==1: return 1.0
    import scipy.integrate as si
    # solve rho' = -rho(u-1)/u on a grid
    grid=[i*1e-4 for i in range(0,int(u/1e-4)+1)]
    rho=[1.0 if x<=1 else 0.0 for x in grid]
    # rho(x) = 1 - int_1^x rho(t-1)/t dt
    acc=0.0
    for i in range(1,len(grid)):
        t=grid[i]
        if t<=1: rho[i]=1.0; continue
        rho[i]=1.0-acc
        acc+= rho[i-1]/t*1e-4
    return rho[-1]

if __name__=="__main__":
    selftest()
    print()
    print("=== WHICH k DOMINATES: distribution of v_p(v) for a^2-b^3, p=2,3,5 ===")
    print("(S is the sieving box half-width; values ~S^2)")
    random.seed(20261003)
    S=4000
    from collections import Counter
    for p in [2,3,5,7]:
        cnt=Counter()
        M=200000
        for _ in range(M):
            a=random.randrange(-S,S+1); b=random.randrange(-S,S+1)
            v=abs(a*a-b*b*b)
            if v==0: continue
            k=0; t=v
            while t%p==0: t//=p; k+=1
            cnt[k]+=1
        tot=sum(cnt.values())
        print(f"  p={p}: " + "  ".join(f"k={k}:{cnt[k]/tot:.5f}" for k in sorted(cnt)[:8]))
        uni={k:(1-1/p)/p**k for k in range(8)}
        print(f"         uniform: " + "  ".join(f"k={k}:{uni[k]:.5f}" for k in range(8)))
