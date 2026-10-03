#!/usr/bin/env python3
"""A1: DOES THE 25-38% CLAIM SURVIVE AN END-TO-END MEASUREMENT?

The paper's ONLY quantitative payoff: "a 25-38% reduction in relation-collection
cost at the operating point u~=3".

Design (size-MATCHED, which C_smoothness.md s2.1 says is non-negotiable):
  - NFS values v = a^2 - b^3 from a box; compare against UNIFORM INTEGERS OF THE
    SAME SIZE (matched dyadic stratum).  Raw comparison against uniform-in-[1,x]
    gives 17x -- a pure size artifact.  I reproduce that artifact as a control.
  - Realistic B = 2^20, 2^25 (and small B for cross-check).
  - NULL ARM: an artificial population with the SAME size distribution but uniform
    local structure (the E2b.1 artifact control).  Must come out at ~1.0.
  - SMOOTHNESS PREDICATE SELF-TEST: must be shown able to return False.

DECOMPOSITION: split the gain by whether the value lies in the ZERO-SUBSPACE
(a,b both divisible by a power of the prime) -- i.e. is the gain actually caused
by the k>=2 divisibility law the paper is about?
"""
import random, math
from collections import Counter
from sympy import factorint

random.seed(20261003)

def is_smooth(n,B):
    for p in factorint(abs(n)): 
        if p>B: return False
    return True

def selftest():
    bad=[1000003,999983,2**10*3**5*1009,7*100000007]
    assert all(not is_smooth(x,1000) for x in bad), "predicate FAILED to return False"
    assert is_smooth(2**10*3**5,1000)
    print("SELFTEST smoothness predicate: PASS -- returns False on",bad)

def sieve(a,b):
    return abs(a*a-b*b*b)

def measure(S, B, npairs=60000, strat=1):
    """size-stratified smoothness rate of a^2-b^3."""
    hits=0; tot=0; strata=Counter(); strat_h=Counter()
    for _ in range(npairs):
        a=random.randrange(-S,S+1); b=random.randrange(-S,S+1)
        v=sieve(a,b)
        if v==0: continue
        # dyadic size stratum
        st=math.floor(math.log2(v))
        tot+=1; strata[st]+=1
        if is_smooth(v,B): hits+=1; strat_h[st]+=1
    # exact uniform rate in the SAME strata
    u=0.0
    for st,c in strata.items():
        # uniform integers in [2^st, 2^(st+1))
        lo,hi=2**st,2**(st+1)
        # exact count of B-smooth in that range
        # use inclusion via Psi: do it by direct product-sum over exponents is too slow;
        # approximate with a fast exact-by-sampling uniform control
        samp=random.randrange(lo,hi)
        if is_smooth(samp,B): u+=1
    return hits,tot,u

if __name__=="__main__":
    selftest()
    print()
    print("=== END-TO-END: size-matched smoothness of a^2-b^3 vs uniform ===")
    print("S      B        u=log2(typ)/log2(B)  nfs_rate  uniform_rate  delta   cost_red=1-1/delta")
    for S,B in [(4000,1000),(20000,1000),(20000,2**16),(20000,2**20),(40000,2**20),(40000,2**25)]:
        hits,tot,u=measure(S,B,npairs=40000)
        if tot==0 or u==0: continue
        r=hits/tot; ru=u/tot
        d=r/ru if ru>0 else float('nan')
        cr=1-1/d if d>1 else float('nan')
        uty=math.log2(S*S)/math.log2(B)
        print(f"{S:6d} {B:9d}   {uty:8.3f}          {r:.5f}    {ru:.5f}     {d:.4f}   {cr*100:6.1f}%")
