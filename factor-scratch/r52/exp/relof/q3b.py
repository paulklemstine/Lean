#!/usr/bin/env python3
"""
Q3 (fast): cost split GENERATE vs SMOOTHNESS-TEST at realistic FB sizes.
The smoothness test is trial division of a candidate by every FB prime.
We count OPS (deterministic, machine-independent) and also time a sample.
"""
import math, sys, time, random
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')
from sympy import primerange
from relcore import psi_exact

def split(BB, n_bits=60, n_cand=20000, rng_seed=1):
    fb=list(primerange(2,BB+1))
    V=2**n_bits
    frac=psi_exact(V,BB)/V if BB<=5000 else None
    random.seed(rng_seed)
    # GENERATE: evaluating the cubic relation value = 3 multiplies + adds
    gen_ops = 3*n_cand
    # TEST: every candidate that survives the sieve must be trial divided.
    # In NFS the sieve removes all but ~n_cand * (yield); survivors carry a large
    # prime factor. Trial division by |FB| primes is the standard cost model.
    test_ops = n_cand*len(fb)
    return dict(BB=BB, fb=len(fb), gen_ops=gen_ops, test_ops=test_ops,
                test_share=test_ops/(test_ops+gen_ops), frac=frac)

if __name__=="__main__":
    print("Q3 -- the smoothness TEST as a share of relation-collection cost")
    print("model: cost = 3 multiplies to GENERATE a value + |FB| trial divisions to TEST it")
    print()
    print(f"{'BB':>10} {'|FB|':>9} {'gen ops':>10} {'test ops':>14} {'TEST SHARE':>12} {'max batch speedup':>20}")
    for BB in [10**3,10**4,10**5,10**6,10**7,10**8]:
        r=split(BB)
        print(f"{BB:>10} {r['fb']:>9} {r['gen_ops']:>10} {r['test_ops']:>14} "
              f"{r['test_share']:>12.6f} {1/(1-r['test_share']):>20.6f}x")
    print()
    print("INTERPRETATION")
    print("  The dominant cost is the SIEVE+trial division, not the test per se.")
    print("  Round 52 measured the TEST alone at 0.1% of cost (Stange regime).")
    print("  Here the trial-division share is |FB|/(3+|FB|) -> 1 as BB grows.")
    print("  So in NFS the smoothness TEST IS essentially the whole cost, and")
    print("  Bernstein batch smoothness is precisely the tool that attacks THAT term.")
    print()
    print("  BUT: batch smoothness changes the CONSTANT multiplying |FB| (by ~ln B in")
    print("  the best case), not the fact that |FB| tests are needed. The L[1/3]")
    print("  constant is set by (number of candidates) x (cost per candidate), and")
    print("  batch smoothness reduces the per-candidate cost by a bounded factor.")
    print()
    print("  Q3 VERDICT: quantified below -- a factor f in per-candidate cost maps to")
    print("  a constant c -> c / f^(1/3) ONLY if the savings is a per-candidate factor")
    print("  applied to the (ln N)^(1/3) term. Here the saving is on |FB| = e^(lnB),")
    print("  and ln B is itself L^(1/3)-scale, so the two DO interact.")
    for BB in [10**3,10**4,10**5,10**6,10**7]:
        r=split(BB)
        s=r['test_share']
        # a batch method giving factor f reduction in trial-division cost:
        for f in [2,10,100]:
            new_test = r['test_ops']/f
            ns = new_test/(new_test+r['gen_ops'])
            print(f"   BB={BB:<9} f={f:<4} test share {s:.4f} -> {ns:.4f}, "
                  f"total speedup {1/(1-ns)/(1/(1-s)):.4f}x")
        break
