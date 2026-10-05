#!/usr/bin/env python3
"""
ceiling.py -- THE PARAMETER-CEILING CONTROL. Two threats to every claim that a
sub-n/4 lattice "works":

 (1) VACUITY.  cell() accepts when h(x_TRUE)==0.  If the same lattice also vanishes
     at a RANDOM point of the same size, the test is vacuous.  Generically T/|polys|
     random probes SHOULD hit; observed ~0 means the vanishing is real information.
     POSITIVE control: a deliberately trivial lattice (h = x - x_rand) MUST fire.
     NEGATIVE control: the real lattices must stay quiet.

 (2) CEILING.  If widening m,t moves the sub-n/4 wall down, then the "wall" is the
     edge of the parameter grid, not the mathematics, and the whole distribution is
     an artefact of mmax.  We compare mmax=10 against mmax=16 on the SAME instances.

PREDICTION: vacuity ~0 (confirming the prior 0/200 independently); and the best-k
distribution SHIFTS DOWN as mmax grows, i.e. the sub-n/4 successes are partly a
ceiling artefact -- which would be a REFUTATION-GATE kill of the hypothesis's premise.
"""
import sys, random, time, statistics
sys.path.insert(0, '/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import _reduced_polys, evalp
from cell import make_instance, cell
SEED = 20261004
NRP = 200          # random probes per lattice (the prior work's denominator)

def vacuity_probe(N,p,nn,k,m,t,rng,nrp=NRP):
    tb=nn//2-k; X=1<<tb; p0=(p>>tb)*X
    polys=_reduced_polys([p0,1],N,X,m,t)
    if not polys: return 0,0,0
    h=sum(1 for _ in range(nrp) if any(evalp(hh,rng.randrange(1,X))==0 for hh in polys))
    return nrp,h,len(polys)

if __name__=="__main__":
    mode=sys.argv[1]
    if mode=="vac":
        rng=random.Random(SEED); T=int(sys.argv[2])
        print("POSITIVE CONTROL: a trivially-constructed h=x-x_rand MUST fire.")
        xt=rng.randrange(1,2**20)
        print(f"   h(x) = x - {xt}; probes at random x: hits = "
              f"{sum(1 for _ in range(NRP) if (lambda z: z-xt==0)(rng.randrange(1,2**20)))}/{NRP} (expect ~1 total, i.e. it fires only at its own root)")
        print("   -- better positive control: a DEGENERATE lattice with a huge m,t --")
        N,p,q,nn=make_instance(48,rng); q4=nn//4; k=q4-1
        tb=nn//2-k; X=1<<tb; p0=(p>>tb)*X
        for (m,t) in [(2,2),(12,12),(16,16)]:
            npoly=_reduced_polys([p0,1],N,X,m,t)
            hits=sum(1 for _ in range(NRP) if any(evalp(hh,rng.randrange(1,X))==0 for hh in npoly))
            gen=NRP/max(1,len(npoly))
            print(f"   (m,t)=({m},{t}) npolys={len(npoly)} random-hits {hits}/{NRP} "
                  f"(generic expectation {gen:.1f})  {'*** VACUOUS ***' if hits>3*gen else 'ok'}")
        print("\nNEGATIVE CONTROL: every REAL sub-n/4 success, probed at random points.")
        tot=0; vac=0; ncell=0
        for i in range(T):
            N,p,q,nn=make_instance(48,rng); q4=nn//4
            for k in range(max(1,q4-4),q4):
                for m in range(2,11):
                    for t in range(2,11):
                        f,dt,_=cell(N,p,nn,k,m,t)
                        if not f: continue
                        assert N%f==0 and f in (p,q)
                        ncell+=1
                        np_,h,npo=vacuity_probe(N,p,nn,k,m,t,rng)
                        tot+=np_; vac+=h
        print(f"   sub-n/4 success cells examined: {ncell}")
        print(f"   random-point annihilations: {vac}/{tot}")
        print(f"   => vacuity rate {vac/tot if tot else float('nan'):.4f}  "
              f"{'PASS (real information)' if vac==0 else 'FAIL'}")
        if ncell==0: print("   *** VACUOUS TEST: iterated an EMPTY set -- this is the finding ***")
    elif mode=="ceiling":
        rng=random.Random(SEED); T=int(sys.argv[2]); nb=int(sys.argv[3])
        for mmax in (10,16):
            cells=[(m,t) for m in range(2,mmax+1) for t in range(2,mmax+1)]
            bk=[]; t0=time.time()
            for i in range(T):
                N,p,q,nn=make_instance(nb,rng); q4=nn//4; best=None
                for k in range(max(1,q4-6),q4+1):
                    if any(cell(N,p,nn,k,m,t)[0] for m,t in cells):
                        best=k; break
                bk.append(best)
            got=[b for b in bk if b is not None]
            sub=[b for b in got if b<q4]
            print(f"  n={nb} mmax={mmax} ({len(cells)} cells/k, {time.time()-t0:.0f}s): "
                  f"any-hit {len(got)}/{T}; best-k dist {sorted(got)}")
            print(f"      sub-n/4 (best < {q4}): {len(sub)}/{T}  values {sorted(sub)}")
