#!/usr/bin/env python3
"""
churn.py -- THE KILLER TEST ON THE HYPOTHESIS' PREMISE.

Premise under test: "best-k varies per instance, so X < N^(1/4) is a DISTRIBUTION
not a step, and an adaptive rule can exploit it."

Two readings of the below-n/4 tail, opposite in meaning:

 (A) GENUINE -- those instances have a genuinely smaller effective X.  A wider n/4
     lattice should NOT factor them; the n/4 set and the tail stay disjoint.
 (B) CEILING ARTEFACT -- the (m,t) grid was too small, so the lattice failed to
     produce the polynomial Coppersmith (J. Cryptology 10 (1997) Sect. 11, Thm 4)
     GUARANTEES it produces at X = N^(1/4).  Then the same instances should also
     succeed AT n/4 once the grid widens, and the tail should shrink.

DECISION RULE (fixed before running): if >=60% of the mmax=10 tail is also factored
at n/4 by mmax=16, the premise is a CEILING ARTEFACT and the hypothesis is refuted
at its root.

ERRORS IN MY OWN EARLIER ATTEMPTS (r55), all three real:
  v1 -- keyed result dicts by tag AND by N, so the summary iterated tag strings and
        raised KeyError after 622 s.
  v2 -- used a list inside a set (`unhashable type: 'list'`).
  v3 -- created `rng = random.Random(SEED)` believing it controlled instance
        generation.  IT DOES NOT: cell.py -> coppersmith_lattice.gen_prime uses the
        GLOBAL random module.  So the two grids were handed DIFFERENT moduli and the
        comparison was meaningless (assert fired).
FIX: both grids are run INTERLEASED on each instance inside one loop, so identical
moduli are guaranteed by construction rather than by hoping a seed lines up.
"""
import sys, os, json, random, time, argparse
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from cell import make_instance, cell
SEED=20261004

def grid(mmax): return [(m,t) for m in range(2,mmax+1) for t in range(2,mmax+1)]

def collect(nb,T,kspan,cache):
    if os.path.exists(cache):
        r=json.load(open(cache)); print(f"    (loaded cache {os.path.basename(cache)})"); return r
    random.seed(SEED)                      # GLOBAL -- gen_prime reads this
    g10,g16=grid(10),grid(16)
    at10={};bl10={};at16={};bl16={};insts=[]
    t0=time.time()
    for i in range(T):
        N,p,q,nn=make_instance(nb,random); q4=nn//4
        a10=set();b10=set();a16=set();b16=set()
        for d in range(0,kspan+1):
            for (g,a,b) in ((g10,a10,b10),(g16,a16,b16)):
                for m,t in g:
                    f,_,_=cell(N,p,nn,q4-d,m,t)
                    if f:
                        assert N%f==0 and f in (p,q), "unverified factor"
                        (a if d==0 else b).add((d,m,t))
        at10[N]=sorted(map(list,a10)); bl10[N]=sorted(map(list,b10))
        at16[N]=sorted(map(list,a16)); bl16[N]=sorted(map(list,b16))
        insts.append(N)
        if (i+1)%10==0: print(f"    {i+1}/{T} ({time.time()-t0:.0f}s)",flush=True)
    r=dict(at10=at10,bl10=bl10,at16=at16,bl16=bl16,insts=insts,nb=nb,T=T,kspan=kspan)
    json.dump(r,open(cache,"w")); return r

def main(nb,T,kspan):
    R=collect(nb,T,kspan,f"churn_n{nb}_T{T}_k{kspan}.json")
    Ns=R["insts"]
    print(f"\n### n={nb} T={T} kspan={kspan}  (SAME instances for both grids)")
    for tag,ak,bk in (("mmax=10",'at10','bl10'),("mmax=16",'at16','bl16')):
        na=sum(1 for N in Ns if R[ak][N]); nbb=sum(1 for N in Ns if R[bk][N])
        print(f"  {tag}: factored AT n/4 {na}/{T} ({na/T:5.1%}); "
              f"at some k below n/4 {nbb}/{T} ({nbb/T:5.1%})")
    tail10={N for N in Ns if R["bl10"][N] and not R["at10"][N]}
    tail16={N for N in Ns if R["bl16"][N] and not R["at16"][N]}
    resc={N for N in tail10 if R["at16"][N]}
    print(f"\n  mmax=10 TAIL (factored ONLY below n/4)      : {len(tail10)}/{T} = {len(tail10)/T:.1%}")
    print(f"  ...also factored AT n/4 once mmax=16         : {len(resc)}/{len(tail10)}"
          f" = {len(resc)/len(tail10) if tail10 else 0:.0%}")
    print(f"  mmax=16 TAIL (survivors)                     : {len(tail16)}/{T} = {len(tail16)/T:.1%}")
    frac=len(resc)/len(tail10) if tail10 else 0.0
    print(f"  ==> {'CEILING ARTEFACT -- PREMISE REFUTED' if frac>=0.6 else 'GENUINE distribution survives'}"
          f"   (rule >=60%, observed {frac:.0%})")

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--n",type=int,required=True); ap.add_argument("--T",type=int,default=60)
    ap.add_argument("--kspan",type=int,default=3)
    a=ap.parse_args(); main(a.n,a.T,a.kspan)
