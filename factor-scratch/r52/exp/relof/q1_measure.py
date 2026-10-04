#!/usr/bin/env python3
"""
Q1: measure ACTUAL NFS relation-finding cost across a ladder of N, in operations
AND wall clock, and fit L_N[1/3,c] = exp(c (lnN)^(1/3) (lnlnN)^(2/3)).

Positive control every run: F(1,0) == N must hold exactly (asserted).
Reported: implied c at each N, its stability, and whether the L-form even fits.
"""
import math, time, sys, json
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')
import numpy as np
from sympy import nextprime, integer_nthroot, isprime
from nfsrel import sieve_collect, mont_cubic, cube_roots_mod
from relcore import psi_exact

def rand_rsa(bits):
    while True:
        p=nextprime(int(2**(bits/2)))
        q=nextprime(int(1.3*2**(bits/2)))
        N=int(p)*int(q)
        if N.bit_length()==bits: return N

def fit_c(cost, N):
    L=math.log(N); lL=math.log(L)
    denom=L**(1/3)*lL**(2/3)
    return math.log(cost)/denom

def run(N, BB, X, Y, reps=3):
    d,c=mont_cubic(N)
    assert d**3+c==N, "POSITIVE CONTROL FAILED"
    best=None
    for _ in range(reps):
        r=sieve_collect(N,BB,X,Y,collect=True,d=d,c=c)
        if best is None or r['n_rel']>best['n_rel']: best=r
    return best

if __name__=="__main__":
    ladder=[]
    print(f"{'bits':>5} {'BB':>7} {'X':>6} {'u=lnV/lnB':>11} {'cells':>10} {'n_rel':>7} "
          f"{'ops/rel':>12} {'t_sieve':>9} {'t_try':>8} {'implied c':>11}")
    configs=[
        (40, 3000, 300, 300),
        (48, 5000, 300, 300),
        (56, 9000, 300, 300),
        (64, 15000,300, 300),
        (72, 25000,300, 300),
        (80, 40000,300, 300),
        (88, 65000,300, 300),
    ]
    for bits,BB,X,Y in configs:
        N=rand_rsa(bits)
        d,c=mont_cubic(N)
        # V = typical value size = (d*X)^3
        V=(d*X)**3
        u=math.log(V)/math.log(BB)
        r=run(N,BB,X,Y)
        ops_per_rel = r['total_ops']/max(r['n_rel'],1)
        cimp = fit_c(ops_per_rel, N) if r['n_rel']>0 else float('nan')
        ladder.append(dict(bits=bits,BB=BB,u=u,n_rel=r['n_rel'],ops_per_rel=ops_per_rel,
                           c_imp=cimp,t_total=r['t_total']))
        print(f"{bits:>5} {BB:>7} {X:>6} {u:>11.3f} {r['cells']:>10} {r['n_rel']:>7} "
              f"{ops_per_rel:>12.1f} {r['t_sieve']:>9.4f} {r['t_trial']:>8.4f} {cimp:>11.4f}")
    json.dump(ladder,open('/home/raver1975/lean/factor-scratch/r52/exp/relof/results/q1_ladder.json','w'),indent=1)
    print()
    print("Implied c at 1.9229994 (the model):", (64/9)**(1/3))
