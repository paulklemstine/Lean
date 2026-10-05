#!/usr/bin/env python3
"""
widensweep.py -- THE CEILING CONTROL, and the test of the RIGHT adaptive axis.

OBSERVATION THAT FORCES THIS: with m,t <= 10 the "n/4 sweep" only factors
58.5%/36.5%/17.5% at n=48/64/80, NOT the ~100% Coppersmith guarantees.  So my grid is
the binding constraint at n/4, and the sub-n/4 "successes" may be a grid artefact.
Two questions:

 Q-C  Does widening m,t (10 -> 16 -> 20) raise the n/4 success rate toward 1?  Does
       it also raise the SUB-n/4 rate?  If it raises both equally, the sub-n/4 rate
       is a fixed property of the lattice, not something a bigger grid manufactures.

 Q-A  THE OTHER AXIS.  Coppersmith (J. Cryptology 10 (1997) Sect. 11) guarantees
       X < N^(1/4) at ANY lattice size; the bound is on X, not on m.  So the
       adaptivity that is actually licensed by theory is "spend more (m,t) at k=n/4",
       NOT "go below n/4".  If a wider (m,t) sweep at n/4 dominates the adaptive
       rule, the hypothesis is refuted on its own terms -- the win, if any, is in
       the lattice-size axis, which is a different (and much less interesting) claim.
"""
import sys, time, random, statistics, argparse
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from cell import make_instance, cell
SEED=20261004

def cells_of(mmax):
    cs=[(m,t) for m in range(2,mmax+1) for t in range(2,mmax+1)]
    cs.sort(key=lambda z:(z[0]*z[1],z[0],z[1]))
    return cs

def trial(nb,T,mmax,kspan):
    rng=random.Random(SEED); cs=cells_of(mmax)
    per_k={}; cost={}; base=[]; full=[]
    t0=time.time()
    for i in range(T):
        N,p,q,nn=make_instance(nb,rng); q4=nn//4
        hitk={}; anyhit=False
        for d in range(0,kspan+1):
            k=q4-d; got=False
            for (m,t) in cs:
                f,dt,_=cell(N,p,nn,k,m,t)
                cost.setdefault(m*t,[]).append(dt)
                if f:
                    assert N%f==0 and f in (p,q)
                    got=True; anyhit=True
            hitk[d]=got
            if d==0: base.append(got)
        full.append(anyhit)
        for d,g in hitk.items(): per_k.setdefault(d,[]).append(g)
    mc={kk:statistics.median(v) for kk,v in cost.items()}
    return dict(mmax=mmax,T=T,nb=nb,secs=time.time()-t0,
                n_cells=len(cs), per_k={d:sum(v) for d,v in sorted(per_k.items())},
                base=sum(base), full=sum(full), mcosts=mc, perk=per_k, cells=cs)

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--n",type=int,required=True); ap.add_argument("--T",type=int,default=60)
    ap.add_argument("--kspan",type=int,default=3)
    ap.add_argument("--mmax",type=int,nargs="+",default=[10,16])
    a=ap.parse_args()
    print(f"### n={a.n}  T={a.T}  k span = n/4-{a.kspan}..n/4")
    for mmax in a.mmax:
        r=trial(a.n,a.T,mmax,a.kspan)
        print(f"  mmax={r['mmax']:2d} ({r['n_cells']:3d} cells/k, {r['secs']:.0f}s): "
              f"k=n/4 {r['base']}/{r['T']} ({r['base']/r['T']:.1%})   "
              f"ANY k {r['full']}/{r['T']} ({r['full']/r['T']:.1%})   "
              f"ADDED below n/4 {r['full']-r['base']}/{r['T']}", flush=True)
        print(f"      per-depth hits: " + "  ".join(
            f"d={d}:{c}/{r['T']}" for d,c in r['per_k'].items()))
