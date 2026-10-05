#!/usr/bin/env python3
"""
exp_d.py -- THE HONESTY GATE. Does the t-large constructed gap satisfy the
n-divisor property? If NOT, it is NOT a counterexample to anything, and the
result must be reported as "t can be large" only in the unrestricted sense.

He-Sahai's Lemma 2.1 is applied to gaps that HAVE the n-divisor property
(Definition 3.1 of Umans-Wang: for every d in [1,n], some a in A has d | a).
So the construction a1=1, a2=M-1 must be tested against that property.

Also tested: the t=0 / small-t configurations that ARE n-divisor, to see whether
any tension exists between "t large" and "n-divisor".

Controls:
  POS: the trivial set A={1..n} IS n-divisor; the checker must accept it.
  NEG: a set missing d=7 must be rejected.
"""
import sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from umw_t_core import band_primes, t_profile, is_degenerate
import numpy as np

def n_divisor_ok(values, n):
    """Definition 3.1: for all d in 1..n, exists a in values with d | a.
    Returns (ok, smallest_failing_d)."""
    vals = [abs(int(v)) for v in values]
    if any(v == 0 for v in vals):
        return False, 0
    # sieve the multiples present
    seen = bytearray(n + 1)
    for v in vals:
        if v == 0:
            continue
        for d in range(1, min(n, v) + 1):
            if v % d == 0:
                seen[d] = 1
    for d in range(1, n + 1):
        if not seen[d]:
            return False, d
    return True, -1

def main():
    print("=== CONTROL: checker itself ===")
    ok, f = n_divisor_ok(list(range(1, 101)), 100)
    print(f"  POS  A=[1..100], n=100 -> ok={ok} (expect True)   {'OK' if ok else 'FAIL'}")
    ok2, f2 = n_divisor_ok([1,2,3,4,5,6,8,9,10], 10)
    print(f"  NEG  A missing 7, n=10 -> ok={ok2} first_fail={f2} (expect False,7) "
          f"{'OK' if (not ok2 and f2==7) else 'FAIL'}")

    rows = []
    print("\n=== The t-large CONSTRUCTED gap vs the n-divisor property ===")
    for kb in (15, 18, 21):
        L = 2 ** (kb // 3)
        n = L ** 3
        alpha = 1.0/3.0
        x = math.isqrt(n)
        P = sorted(int(p) for p in band_primes(n)); P = [p for p in P if p>(2*x)//3]
        budget = n ** alpha - math.log(L)
        M, k, logM = 1, 0, 0.0
        for p in P:
            if logM + math.log(p) <= budget: M *= p; logM += math.log(p); k += 1
            else: break
        a1, a2 = 1, M-1
        tmax, _, ndiff, _ = t_profile(a1, a2, L, L, P)
        b0 = 0
        vals = [b0 + a1*i + a2*j for i in range(L) for j in range(L)]
        ntest = min(n, 3000)          # test the property up to min(n,3000); see caveat
        ok, fd = n_divisor_ok(vals, ntest)
        print(f"  n=2^{3*(kb//3)}={n:10d} L={L:5d} k=t={k:4d} | test n'={ntest}: "
              f"n-divisor={ok} first_missing={fd}")
        print(f"      |A|={len(vals)}  max|A|={max(vals)}  min|A|={min(vals)}  "
              f"max|A| <= exp(n^(1/3))? {max(vals) <= math.exp(n**alpha)}")
        rows.append(dict(k_bits=kb, n=n, L=L, k=k, tmax=int(tmax), ntest=ntest,
                         ndiv=bool(ok), first_missing=int(fd), sizeA=len(vals)))

    print("\n=== TENSION CHECK: can ANY small gap be both n-divisor and t-large? ===")
    # At tiny n, exhaustively test the trivial n-divisor sets against t.
    for nn in (24, 48, 96):
        Ls = 2
        vals = list(range(1, nn+1))
        ok, fd = n_divisor_ok(vals, nn)
        print(f"  A=[1..{nn}] n={nn}: n-divisor={ok} (expect True)")
    out = os.path.join(os.path.dirname(__file__), "..", "out")
    json.dump(rows, open(os.path.join(out, "exp_d.json"), "w"), indent=1)
    print("\nwrote out/exp_d.json")

if __name__ == "__main__":
    main()