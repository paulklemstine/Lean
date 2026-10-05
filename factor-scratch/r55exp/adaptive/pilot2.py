#!/usr/bin/env python3
"""PILOT v2 -- PER-INSTANCE. Fixes pilot.py's miscount (it counted (m,t) pairs,
not instances). Reports, per k: how many of T instances are hit by AT LEAST ONE
(m,t); and the CHEAPEST (m,t) that hits, per instance.

Also tests the PARAMETER-CEILING threat: is the sub-n/4 wall a wall or the edge of
the (m,t) grid?  Compare grid 2..12 against 2..20 on a few instances.
"""
import sys, random, time
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, _reduced_polys, evalp
random.seed(20261004)
T=12
def probe(p,N,nn,k,MT):
    tb=nn//2-k; X=1<<tb; p0=(p>>tb)*X; f=[p0,1]; xt=p-p0
    hits=[]
    for (m,t) in MT:
        if any(evalp(h,xt)==0 for h in _reduced_polys(f,N,X,m,t)): hits.append((m,t))
    return hits
for n in (48,64,80):
    MT=[(m,t) for m in range(2,13) for t in range(2,13)]
    insts=[]; 
    while len(insts)<T:
        p=gen_prime(n//2); q=gen_prime(n//2); N=p*q
        if 2**(n-1)<=N<2**n: insts.append((p,q,N))
    t0=time.time(); print(f"### n={n}  T={T}  grid m,t in 2..12 ({len(MT)} cells)")
    for kk in range(-4,1):
        anyhit=0; cheapest=[]
        for (p,q,N) in insts:
            nn=N.bit_length(); q4=nn//4; k=q4+kk
            h=probe(p,N,nn,k,MT)
            if h:
                anyhit+=1; cheapest.append(min(m*t for m,t in h))
        tag="n/4" if kk==0 else f"n/4{kk:+d}"
        cs = f" min-dim {min(cheapest)} med-dim {sorted(cheapest)[len(cheapest)//2]}" if cheapest else ""
        print(f"   k={q4+kk:3d} ({tag:6s}, X=2^{n//2-q4-kk}): {anyhit:2d}/{T} instances hit any cell{cs}")
    print(f"   ({time.time()-t0:.0f}s)")
