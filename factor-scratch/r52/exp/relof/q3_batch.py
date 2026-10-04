#!/usr/bin/env python3
"""
Q3: Bernstein batch smoothness -- quantify the achievable saving at realistic FB sizes.
CONTEXT (measured by round 52, notes/BB_smoothpow.md S1): the smoothness TEST is
0.1% of cost.  Batch methods amortise the test, not the GENERATION.
So the ceiling on any batch saving is bounded by the test's share of total cost.
This script MEASURES that share directly, with exact Psi as the null.
"""
import math, time, sys
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')
from sympy import primerange
from relcore import psi_exact

def cost_split(BB, n_bits=40, n_vals=20000, rng_seed=0):
    """Split NFS relation-collection cost into GENERATE vs TEST at FB size BB."""
    import random
    random.seed(rng_seed)
    fb=list(primerange(2,BB+1))
    # realistic NFS values: n_bits-bit integers (relation values in a real sieve)
    V=2**n_bits
    smooth_frac=psi_exact(V,BB)/V          # EXACT null, not Dickman
    expected=n_vals*smooth_frac
    # --- GENERATE cost: computing the value (a cubic evaluation) ---
    t0=time.perf_counter()
    vals=[random.getrandbits(n_bits)|(1<<(n_bits-1)) for _ in range(n_vals)]
    t_gen=time.perf_counter()-t0
    # --- TEST cost: trial division by every FB prime, worst realistic case ---
    t0=time.perf_counter()
    ops=0
    for v in vals[:int(min(n_vals,max(expected*20,50)))]:
        rem=v
        for p in fb:
            ops+=1
            if rem%p==0:
                while rem%p==0: rem//=p
            if rem==1: break
    t_test=time.perf_counter()-t0
    ntested=int(min(n_vals,max(expected*20,50)))
    return dict(BB=BB, fb=len(fb), n_vals=n_vals, smooth_frac=smooth_frac,
                expected_smooth=expected, n_tested=ntested,
                t_gen=t_gen, t_test=t_test, test_ops=ops,
                test_share=t_test/(t_test+t_gen) if (t_test+t_gen)>0 else 0)

if __name__=="__main__":
    print("Q3 -- cost split GENERATE vs SMOOTHNESS-TEST at realistic FB sizes")
    print(f"{'BB':>8} {'|FB|':>8} {'exact Psi/V':>13} {'E[smooth]':>11} "
          f"{'t_gen(s)':>9} {'t_test(s)':>10} {'TEST SHARE':>12} {'max saving':>11}")
    res=[]
    for BB in [10**3, 3*10**3, 10**4, 3*10**4, 10**5, 3*10**5, 10**6]:
        r=cost_split(BB, n_bits=40, n_vals=20000)
        res.append(r)
        print(f"{BB:>8} {r['fb']:>8} {r['smooth_frac']:>13.4e} {r['expected_smooth']:>11.2f} "
              f"{r['t_gen']:>9.4f} {r['t_test']:>10.4f} {r['test_share']:>12.6f} "
              f"{r['test_share']:>10.4%}")
    print()
    print("CEILING: a batch method removes AT MOST the test share. Even a PERFECT")
    print("batch smoothness test (share -> 0) cannot beat the model constant by more")
    print("than 1/(1 - test_share).")
    for r in res:
        s=r['test_share']
        print(f"   BB={r['BB']:<8} max speedup = {1/(1-s):.6f}x   (ln B = {math.log(r['BB']):.3f})")
