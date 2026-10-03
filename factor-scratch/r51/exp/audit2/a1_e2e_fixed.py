#!/usr/bin/env python3
"""A1 end-to-end, CORRECTED. The first version was broken (1 uniform sample per
stratum). This version uses a PAIRED design: for every NFS value, draw K uniform
integers from the SAME dyadic stratum.  The null arm (a population with the same
size distribution but uniform local structure) MUST come out at delta ~ 1.0.
"""
import random, math
from sympy import factorint

random.seed(20261003)
K = 60   # paired uniform draws per NFS value

def is_smooth(n,B):
    for p in factorint(abs(n)):
        if p>B: return False
    return True

def selftest():
    bad=[1000003,999983,2**10*3**5*1009,7*100000007,9999999967]
    for x in bad: assert not is_smooth(x,1000), f"predicate FAILED on {x}"
    assert is_smooth(2**10*3**5,1000) and is_smooth(1,1000)
    print("SELFTEST predicate: PASS (returns False where it must)")
    # NULL ARM control: uniform random integers vs uniform random integers -> must be 1.0
    h=t=0
    for _ in range(20000):
        x=random.randrange(1,2**40); t+=1; h+= is_smooth(x,1000)
    print(f"  NULL (uniform vs uniform): {h}/{t} = {h/t:.5f}  <- must be a plain rate, not a ratio")

def run(S,B,npairs=25000):
    h=t=u=0
    for _ in range(npairs):
        a=random.randrange(-S,S+1); b=random.randrange(-S,S+1)
        v=abs(a*a-b*b*b)
        if v==0: continue
        t+=1; h+=is_smooth(v,B)
        st=v.bit_length(); lo,hi=1<<(st-1),1<<st
        for _ in range(K):
            u+=is_smooth(random.randrange(lo,hi),B)
    return h,t,u

if __name__=="__main__":
    selftest(); print()
    print("=== PAIRED, size-matched end-to-end smoothness: a^2-b^3 vs uniform ===")
    print(f"{'S':>7} {'B':>10} {'u=log2(V)/log2(B)':>18} {'nfs':>8} {'unif':>8} {'delta':>8} {'cost_red':>9}")
    for S,B in [(4000,1000),(20000,1000),(20000,65536),(40000,2**20),(40000,2**25)]:
        h,t,u=run(S,B)
        r=h/t; ru=u/t; d=r/ru
        V=S*S; uty=math.log2(V)/math.log2(B)
        print(f"{S:>7} {B:>10} {uty:>18.3f} {r:>8.5f} {ru:>8.5f} {d:>8.4f} {(1-1/d)*100:>8.1f}%")
