#!/usr/bin/env python3
"""
headtohead.py -- THE DECISIVE COMPARISON.  Two adaptive axes, one lattice family:

  AXIS K : go BELOW n/4 (the hypothesis).  Licensed by NOTHING in Coppersmith --
           J. Cryptology 10 (1997) Sect. 11 guarantees X < N^(1/4); k < n/4 means
           X > N^(1/4), outside the guarantee.
  AXIS M : stay AT n/4, spend more (m,t).  Licensed BY the theorem -- the bound is
           on X, not on m.

FAIRNESS (my r55 v1 was unfair twice over, both recorded below):
  * every axis is run in ONE process on the SAME instances, sharing ONE measured
    cost model, so machine state cannot favour either;
  * each axis gets its BEST ordering, chosen by the measured index q_j/c_j
    (success prob per second) rather than an arbitrary one.  A strategy is not
    allowed to lose merely because I ordered its cells badly.

ERRORS IN MY OWN v1: (i) passed the whole result LIST where a per-instance dict was
  expected, so AXIS M scored 0.0%; (ii) skipped re-recording the d==0 cells, so AXIS K
  lost its entire n/4 level and reported 25% where the real figure is ~63%.
"""
import sys, time, random, statistics, argparse
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from cell import make_instance, cell
SEED=20261004

def cells_of(mmax):
    cs=[(m,t) for m in range(2,mmax+1) for t in range(2,mmax+1)]
    cs.sort(key=lambda z:(z[0]*z[1],z[0],z[1]))
    return cs

def main(nb,T,mk,md,kspan=2):
    rng=random.Random(SEED)
    cK=cells_of(mk); cM=cells_of(md)
    cost={}
    insts=[make_instance(nb,rng) for _ in range(T)]
    recM=[]; recK=[]
    t0=time.time()
    for (N,p,q,nn) in insts:
        q4=nn//4
        rM={}
        for m,t in cM:                                   # AXIS M: k = n/4 only
            f,dt,_=cell(N,p,nn,q4,m,t); cost.setdefault((m,t),[]).append(dt)
            if f:
                assert N%f==0 and f in (p,q); rM[(m,t)]=True
        rK={d:{} for d in range(kspan+1)}
        for d in range(kspan+1):                         # AXIS K: k = n/4 .. n/4-kspan
            k=q4-d
            for m,t in cK:
                if d==0 and (m,t) in rM:                 # reuse, but STILL record
                    if (m,t) in rM: rK[0][(m,t)]=True
                    continue
                f,dt,_=cell(N,p,nn,k,m,t); cost.setdefault((m,t),[]).append(dt)
                if f:
                    assert N%f==0 and f in (p,q); rK[d][(m,t)]=True
        recM.append(rM); recK.append(rK)
    med={kk:statistics.median(v) for kk,v in cost.items()}
    print(f"  n={nb} T={T}  AXIS-K: {len(cK)} cells/k over k=n/4..n/4-{kspan}"
          f"   AXIS-M: {len(cM)} cells at k=n/4   ({time.time()-t0:.0f}s)")

    def run(order, hitfn):
        cs=[];sc=[]
        for i in range(T):
            c=0.0;done=False
            for mt in order:
                c+=med[mt]
                if hitfn(i,mt): done=True;break
            cs.append(c);sc.append(done)
        r=sum(sc)/T; mc=statistics.mean(cs)
        return r, mc, (mc/r if r else float("inf"))

    def best_order(cells, hitfn, pool):
        """order by measured index q_j/c_j, descending -- the cost-optimal static
        order when trials are independent."""
        def q(mt):
            return sum(1 for i in pool if hitfn(i,mt))/len(pool)
        idx=[(q(mt)/max(med[mt],1e-12), mt) for mt in cells]
        idx.sort(key=lambda z:-z[0])
        return [mt for _,mt in idx]

    poolM=list(range(T))
    poolK=[i for i in range(T)]
    oM=best_order(cM, lambda i,mt: mt in recM[i], poolM)
    # AXIS K order: within each k, by index; k tried n/4, n/4-1, ...
    def hitK(i,mt):
        return any(mt in recK[i][d] for d in range(kspan+1))
    oKin={d: best_order(cK, lambda i,mt,d=d: mt in recK[i][d], poolK)
          for d in range(kspan+1)}
    def runK():
        cs=[];sc=[]
        for i in range(T):
            c=0.0;done=False
            for d in range(kspan+1):
                for mt in oKin[d]:
                    c+=med[mt]
                    if mt in recK[i][d]: done=True;break
                if done: break
            cs.append(c);sc.append(done)
        r=sum(sc)/T; mc=statistics.mean(cs)
        return r, mc, (mc/r if r else float("inf"))
    rM,mcM,cpfM=run(oM, lambda i,mt: mt in recM[i])
    rK,mcK,cpfK=runK()
    n_add=sum(1 for i in range(T) if not recK[i][0] and any(recK[i][d] for d in range(1,kspan+1)))
    print(f"     AXIS M  stay at n/4, larger lattice (d<={md*md:3d}): rate {rM:6.1%}  "
          f"mean {mcM:8.4f}s  cost/factored {cpfM:9.6f}s")
    print(f"     AXIS K  below n/4 (mmax={mk}, d<={kspan})        : rate {rK:6.1%}  "
          f"mean {mcK:8.4f}s  cost/factored {cpfK:9.6f}s   (+{n_add}/{T} below n/4)")
    v = "AXIS M WINS -> hypothesis REFUTED" if cpfM<cpfK else "AXIS K wins"
    print(f"     ==> {v}   cost ratio K/M = {cpfK/cpfM:.3f}")

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--n",type=int,required=True); ap.add_argument("--T",type=int,default=60)
    ap.add_argument("--mk",type=int,default=10); ap.add_argument("--md",type=int,default=16)
    ap.add_argument("--kspan",type=int,default=2)
    a=ap.parse_args()
    main(a.n,a.T,a.mk,a.md,a.kspan)
