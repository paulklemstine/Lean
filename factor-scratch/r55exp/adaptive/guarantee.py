#!/usr/bin/env python3
"""
guarantee.py -- Is the n/4 sweep's 58.5%/36.5%/17.5% a bug, or the expected cost of
an undersized lattice?

Coppersmith (J. Cryptology 10 (1997) Sect. 11, Thm 4) guarantees factoring from the
high-order (1/4)log2 N bits of P.  If my mmax=10 grid only reaches 58.5% at n=48,
either (a) the grid is too small and more lattice size fixes it, or (b) my lattice
is subtly wrong and no lattice size will.

Distinguisher: sweep m,t ever larger on the SAME instances and watch the rate.  If it
climbs toward 1, (a) -- and that is exactly the ceiling artefact this round must
report.  If it plateaus well below 1, (b), and my positive control is broken.

PREDICTION: (a).  Coppersmith needs m,t growing with log N for the epsilon margin, and
N=2^48 is far too small for m=t=10 to be in the asymptotic regime -- but it should
still be well above chance.
"""
import sys, time, random, argparse
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from cell import make_instance, cell
SEED=20261004

def main(nb,T,ms):
    rng=random.Random(SEED)
    insts=[make_instance(nb,rng) for _ in range(T)]
    for m in ms:
        t0=time.time(); hit=0; ncells=0
        for (N,p,q,nn) in insts:
            q4=nn//4
            for tt in range(2,m+1):
                ncells+=1
                f,_,_=cell(N,p,nn,q4,m,tt)
                if f:
                    assert N%f==0 and f in (p,q); hit+=1; break
        print(f"  n={nb} m={m:2d}, t=2..{m} ({ncells} solves, {time.time()-t0:5.0f}s): "
              f"factored at k=n/4  {hit}/{T} = {hit/T:5.1%}",flush=True)

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--n",type=int,required=True); ap.add_argument("--T",type=int,default=30)
    ap.add_argument("--ms",type=int,nargs="+",default=[4,8,12,16,20,26])
    a=ap.parse_args(); main(a.n,a.T,a.ms)
