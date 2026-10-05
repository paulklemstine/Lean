#!/usr/bin/env python3
"""PILOT: shape of the per-(k,m,t) success matrix. Decides the grid for the real run.

PREDICTION (written before running):
 P1  At k = n/4 EXACTLY (X = 2^(n/2-k) = 2^(n/4) = N^(1/4), no epsilon margin)
     a SINGLE (m,t) does NOT succeed with probability ~1, so a (m,t) sweep is
     needed.  If a single (m,t) does hit ~1.0 the adaptive question is vacuous.
 P2  Sub-n/4 hits need LARGE m (theory: m must grow like log N for the epsilon
     margin), so the extra lattices are the EXPENSIVE ones.
"""
import sys, random, time
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, _reduced_polys, evalp
random.seed(20261004)

MT=[(m,t) for m in range(2,13) for t in range(2,13)]
for n in (48,64,80):
    succ={}; tot=0
    t0=time.time()
    for _ in range(12):
        while True:
            p=gen_prime(n//2); q=gen_prime(n//2); N=p*q
            if 2**(n-1)<=N<2**n: break
        nn=N.bit_length(); q4=nn//4
        for k in range(max(1,q4-6), q4+1):
            tb=nn//2-k; X=1<<tb; p0=(p>>tb)*X; f=[p0,1]; xt=p-p0
            for (m,t) in MT:
                ok=any(evalp(h,xt)==0 for h in _reduced_polys(f,N,X,m,t))
                succ.setdefault((k,m,t),0); succ[(k,m,t)]+=ok; tot+=1
    print(f"n={n}  ({time.time()-t0:.0f}s, {tot} lattice solves)")
    for k in sorted(set(kk for kk,_,_ in succ)):
        good=[(m,t) for (m2,t2) in MT for (kk,mm,tt) in [(k,m2,t2)] if succ[(kk,mm,tt)]>0]
        cnt=sum(1 for (kk,mm,tt) in succ if kk==k and succ[(kk,mm,tt)]>0)
        print(f"   k={k:3d} (n/4={q4}, X/N^0.25=2^{k and 0 or 0}{k-q4:+.0f}): {cnt:2d}/12 instances hit; "
              f"any (m,t) hitting: {sorted(good)[:10]}")
