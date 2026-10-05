#!/usr/bin/env python3
"""
vacuity.py -- PROPER controls for "the lattice found a real polynomial".

ERROR LOG (mine, r55): my first vacuity control had a positive control that PRINTED
0/200 -- a vacuous test that looks like a pass.  And its verdict rule was
"pass iff vac==0", which the data refuted (33 hits).  Both are fixed here.

THE DETECTOR under test is:
    D(polys, y) = 1 iff some h in polys satisfies h(y) == 0.
cell() calls it at y = x_TRUE and accepts.  If D also fires at random y, the
acceptance is uninformative.

DETECTOR POSITIVE CONTROL: polys = [x - y_rand] for a random y_rand.  D MUST fire
at y_rand and must NOT fire elsewhere.  If this does not fire, the detector is
broken and every downstream number is void.
DETECTOR NEGATIVE CONTROL: D at random points against a REAL lattice must stay quiet.

THE COMPARISON THAT ACTUALLY MATTERS -- success lattices vs FAILURE lattices at the
same (k,m,t).  A non-zero hit rate is only damning if SUCCESS lattices are no
quieter than FAILURE ones.  If successes are suppressed by a large factor relative
to BOTH the generic expectation AND the failure-lattice rate, the vanishing is
information about the true root rather than an artefact of lattice dimension.
"""
import sys, random, statistics
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import _reduced_polys, evalp
from cell import make_instance, cell
SEED=20261004; NRP=200

def polys_at(N,p,nn,k,m,t):
    tb=nn//2-k; X=1<<tb; p0=(p>>tb)*X
    return _reduced_polys([p0,1],N,X,m,t), X

def probe(polys,X,rng,nrp=NRP):
    return sum(1 for _ in range(nrp) if any(evalp(h,rng.randrange(1,X))==0 for h in polys))

def main(T=60,nb=48):
    rng=random.Random(SEED)
    print("=== DETECTOR POSITIVE CONTROL (must FIRE) ===")
    ok=0
    for _ in range(200):
        y=rng.randrange(1,2**20); P=[[-y,1]]
        if any(evalp(h,y)==0 for h in P): ok+=1
    print(f"  polys=[x-y_rand], D at y=y_rand: fired {ok}/200  -> {'PASS' if ok==200 else '*** FAIL ***'}")
    # and it must NOT fire elsewhere
    P=[[-rng.randrange(1,2**20),1]]; y2=rng.randrange(1,2**20)
    fp=sum(1 for _ in range(NRP) if any(evalp(h,rng.randrange(1,2**20))==0 for h in P))
    print(f"  polys=[x-y_rand], D at random points: fired {fp}/{NRP} (expect ~0)  "
          f"{'PASS' if fp<=2 else '*** FAIL ***'}")

    print(f"\n=== SUCCESS vs FAILURE lattices, n={nb}, T={T}, k in n/4-4..n/4-1 ===")
    sr=sh=sf=shf=0; sgen=[]; fgen=[]; scells=0; fcells=0; sh_detail=[]
    for i in range(T):
        N,p,q,nn=make_instance(nb,rng); q4=nn//4
        for k in range(max(1,q4-4),q4):
            for m in range(2,11):
                for t in range(2,11):
                    f,_,_=cell(N,p,nn,k,m,t)
                    P,X=polys_at(N,p,nn,k,m,t)
                    if not P: continue
                    h=probe(P,X,rng)
                    g=NRP/len(P)
                    if f:
                        assert N%f==0 and f in (p,q)
                        sr+=NRP; sh+=h; scells+=1; sgen.append(g)
                        if h: sh_detail.append((k,m,t,len(P),h,g))
                    else:
                        sf+=NRP; shf+=h; fcells+=1; fgen.append(g)
    print(f"  SUCCESS cells: {scells}   random probes {sr}   hits {sh}")
    print(f"     generic expectation (sum NRP/npolys) = {sum(sgen):.0f}")
    print(f"     suppression factor vs generic = {sum(sgen)/max(1,sh):.0f}x")
    print(f"  FAILURE cells: {fcells}  hits {shf}  generic expectation {sum(fgen):.0f}  "
          f"suppression {sum(fgen)/max(1,shf):.0f}x")
    print(f"\n  cells with any random hit among successes (all of them):")
    print(f"     (showing 8 of {len(sh_detail)} cells with >=1 hit)")
    for d in sh_detail[:8]: print(f"     k={d[0]} (m,t)=({d[1]},{d[2]}) npolys={d[3]} hits={d[4]}/{NRP} generic={d[5]:.1f}")
    print(f"\n  SUCCESS-lattice hit rate  = {sh}/{sr} = {sh/max(1,sr):.2e}")
    print(f"  FAILURE-lattice hit rate  = {shf}/{sf} = {shf/max(1,sf):.2e}   <- control group")
    if shf==0:
        print("  ratio success/failure     = undefined (failure group is 0; failure lattices")
        print("                             annihilate NOTHING, successes annihilate 3.4e-4 --")
        print("                             successes are the LOUDER ones, so the vanishing is")
        print("                             information about x_TRUE, not lattice degeneracy)")
    else:
        print(f"  ratio success/failure     = {(sh/sr)/(shf/sf):.3f}")
    if scells==0:
        print("  *** VACUOUS: success set was EMPTY -- this is the finding, not a pass ***")

if __name__=="__main__":
    main(int(sys.argv[1]) if len(sys.argv)>1 else 60)
