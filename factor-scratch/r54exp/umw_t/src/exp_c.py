#!/usr/bin/env python3
"""
exp_c.py -- Scaling of the constructed t, and how it compares to the two thresholds
that matter. THIS IS THE HEADLINE TABLE.

Thresholds:
  (1) He-Sahai's own rank-1 bound excludes (1/3,1/3) with L ~ n^{3/4}/sqrt(log n).
      In rank 2, the analogue needs the generalized lemma with t. Round 60 claims
      "if t = polylog(n), the n^{3/4} exponent survives". We test t against that.
  (2) The escape criterion quoted in the task: t = O(1) kills the route;
      t ~ n^{1/6} saves it. Our construction reaches t ~ n^{1/3}/log n >> n^{1/6},
      so on the stated criterion the route is ALIVE. We check this numerically and
      also check the claimed upper bound from He-Sahai's size constraint.

Regime honesty: sizes here are n = 2^15 .. 2^27 (n < 2^40 by the scope guard).
Extrapolation to RSA scale is an ARGUMENT about exponents, not a measurement.
"""
import sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from umw_t_core import band_primes, t_profile, is_degenerate
import numpy as np

def main():
    rows = []
    print(f"{'n':>12} {'L':>6} {'|P|':>6} {'k_built':>7} {'t_meas':>7} "
          f"{'sizeUB':>7} {'n^(1/6)':>8} {'k/n^(1/6)':>9} {'log2 n':>7}")
    seen=set()
    for kb in (15, 18, 21, 24, 27):


        L = 2 ** (kb // 3)
        n = L ** 3
        alpha = 1.0/3.0
        x = math.isqrt(n)
        P = sorted(int(p) for p in band_primes(n))
        P = [p for p in P if p > (2*x)//3]
        budget = n ** alpha - math.log(L)
        M, k, logM = 1, 0, 0.0
        for p in P:
            if logM + math.log(p) <= budget:
                M *= p; logM += math.log(p); k += 1
            else:
                break
        if k < 1:
            continue
        a1, a2 = 1, M-1
        tmax, hist, ndiff, drop = t_profile(a1, a2, L, L, P)
        sizeUB = (n**alpha + math.log(2)) / math.log((2.0/3.0)*x)
        n16 = n ** (1.0/6.0)
        print(f"{n:12d} {L:6d} {len(P):6d} {k:7d} {tmax:7d} {sizeUB:7.1f} "
              f"{n16:8.1f} {k/n16:9.3f} {math.log2(n):7.1f}")
        rows.append(dict(n=n, L=L, nP=len(P), k_built=k, t_meas=int(tmax),
                         sizeUB=sizeUB, n_sixth=n16, ratio=k/n16,
                         log2n=math.log2(n), ndiff=ndiff,
                         maxA_log=n**alpha, k_eq_k=(int(tmax)==k)))

    print("\n--- fit: log(t_meas) vs log2(n) ---")
    xs = np.array([math.log2(r["n"]) for r in rows])
    ys = np.array([math.log2(max(1, r["t_meas"])) for r in rows])
    A = np.vstack([xs, np.ones_like(xs)]).T
    slope, inter = np.linalg.lstsq(A, ys, rcond=None)[0]
    print(f"  fitted slope d log2 t / d log2 n = {slope:.3f}")
    print(f"  predicted by construction: n^(1/3)/log n -> slope ~ 1/3 minus a log term")
    print(f"  reference slopes: n^(1/3) -> 0.333 ; n^(1/6) -> 0.167 ; polylog -> 0")
    print(f"\n  cells fitted: {len(rows)}   (all exact-construction: "
          f"{all(r['k_eq_k'] for r in rows)})")

    # Extrapolation (argument, explicitly labelled). Worked in LOG2 throughout:
    # 2^2048 overflows a double, and float(2.0)**2048 raises OverflowError.
    print("\n--- ARGUMENT, not measurement: extrapolate to n = 2^2048 ---")
    for bits in (2048, 1024, 512):
        # log2 budget for log M:  log2 M <= n^(1/3)*log2(e) - log2 L,  log2 L = bits/3
        lgbudget = (2.0 ** (bits/3.0)) * math.log2(math.e) - bits/3.0
        # each band prime p ~ sqrt(n) has log2 p ~ bits/2
        kpred = lgbudget / (bits/2.0)                       # = k, the built count
        lg_ratio = math.log2(max(kpred, 1e-300)) - bits/6.0   # log2 of k / n^(1/6)
        print(f"  n=2^{bits}: built t ~ {kpred:.4e}   n^(1/6) = 2^{bits/6:.1f}")
        print(f"           log2( t / n^(1/6) ) = {lg_ratio:+.1f}  -> ratio = 2^{lg_ratio:.2e}"
              f"   ({'ABOVE' if lg_ratio > 0 else 'below'} the escape threshold)")
    print("  (This is an argument about exponents from the size budget, NOT a measurement;"
          "\n   no computation at RSA scale was performed. Umans-Wang is CONDITIONAL.)")

    out = os.path.join(os.path.dirname(__file__), "..", "out")
    with open(os.path.join(out, "exp_c.json"), "w") as f:
        json.dump(rows, f, indent=1)
    print("\nwrote out/exp_c.json")

if __name__ == "__main__":
    main()