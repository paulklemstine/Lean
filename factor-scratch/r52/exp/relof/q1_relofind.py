#!/usr/bin/env python3
"""
Q1: MEASURE the cost of NFS relation collection. Operation counts AND wall clock.
Pipeline: Montgomery quadratic form F(x,y)=(d x+y)^2+k with N=d^2+k, so F(m,0)=N.
Sieve a box by FB primes, trial-divide survivors, collect FB-smooth values as relations.

Model under test: NFS is L_N[1/3, c] with c=(64/9)^(1/3)=1.9229994...
"""
import math, time, sys, json
import numpy as np
from sympy import integer_nthroot, primerange, factorint, isprime, nextprime
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')
from relcore import psi_exact, mont_form, nfs_values

def logint(L): return math.log(L)

# ------------------------------------------------- NFS theory: predicted cost
def nfs_theory_cost(N, BB, xhi, yhi, k_deg=3):
    """Standard NFS relation-collection cost model (the one behind L_N[1/3,c]).
    SIEVE work: sum over p<=BB of #cells with p | F  ~=  sum_{p} (xhi*yhi)/p * r_p
    TRIAL work: for each cell surviving a sieve-to-BB sieve, divide by each FB prime.
    We report the MODEL in units of "prime trials" (one modular trial division)."""
    fb=list(primerange(2,BB+1))
    cells=xhi*yhi
    d,k=mont_form(N)
    # sieve marks: for each p with a root, cells ~ cells/p
    marks=0
    for p in fb:
        t=(-k)%p; r=math.isqrt(t)
        nroot=0
        if (r*r)%p==t: nroot+=1
        if p>2 and ((p-r)*(p-r))%p==t and (p-r)!=r: nroot+=1
        marks += cells*nroot/p
    # trial divisions: cells not sieved out, times |FB|
    # probability a cell is p_1..p_t-free for the t largest primes ~ prod(1-1/p)
    # rough: expect ~ cells * (density of B-rough) * pi(B)
    # use EXACT Psi for the smooth side, and note rho is NOT a valid null.
    rough = cells   # conservative: many cells survive a partial sieve
    return dict(cells=cells, sieve_marks=marks, fb=len(fb))

def measure_relation_cost(N, BB, xhi, yhi, sieve_bound=None, verbose=False):
    """ACTUAL cost: build FB, sieve box, trial divide, collect. Count ops + wall."""
    d,k = mont_form(N)
    fb=list(primerange(2,BB+1))
    if sieve_bound is None: sieve_bound=BB
    cells = xhi*yhi
    t0=time.perf_counter()
    # --- sieve: boolean survival mask, vectorized over x ---
    surv=np.ones((xhi,yhi),dtype=bool)
    sieve_ops=0
    for p in fb[:sieve_bound]:
        t=(-k)%p; r=math.isqrt(t)
        roots=[]
        if (r*r)%p==t: roots.append(r)
        if p>2:
            r2=p-r
            if (r2*r2)%p==t and r2!=r: roots.append(r2)
        for R in roots:
            # BUG CAUGHT: must mark ROW x only, not broadcast across all rows.
            for x in range(xhi):
                y0=(R-d*x)%p
                surv[x, y0::p]=False
        sieve_ops += 1
    t_sieve=time.perf_counter()-t0
    # --- trial divide survivors ---
    idx=np.argwhere(surv)
    n_surv=len(idx)
    t0=time.perf_counter()
    n_rel=0; trial_ops=0
    fbarray=np.array(fb,dtype=object)
    for (x,y) in idx:
        v=nfs_values(d,k,int(x),int(y))
        rem=v; ok=True
        for p in fb[sieve_bound:]:
            trial_ops+=1
            if rem%p==0:
                while rem%p==0: rem//=p
            if rem==1: break
        if rem==1: n_rel+=1
    t_trial=time.perf_counter()-t0
    return dict(N=N,d=d,k=k,BB=BB,xhi=xhi,yhi=yhi,cells=cells,
                n_surv=n_surv,n_rel=n_rel,
                sieve_ops=int(sieve_ops),trial_ops=int(trial_ops),
                total_ops=int(sieve_ops+trial_ops),
                t_sieve=t_sieve,t_trial=t_trial,t_total=t_sieve+t_trial)

if __name__=="__main__":
    # Small smoke test
    N=1009*1013
    r=measure_relation_cost(N,30,20,20)
    print(json.dumps(r,indent=1,default=str))
