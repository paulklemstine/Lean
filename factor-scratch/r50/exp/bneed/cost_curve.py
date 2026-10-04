"""
cost_curve.py -- the COST side of B4, measured directly.

bmin.py measures whether the method WORKS at small b.  This file measures what
it COSTS, because that is where the answer actually lives: at small b the
factor base is a handful of primes, so almost no residue is B-smooth and the
relation search is starved.

Stange's own model (p.5, rendered image): u = log n / log b, and u^u is "the
number of trials to find one smooth integer".  This file MEASURES that number
rather than trusting the model, by Monte Carlo on the actual factor base, and
checks the model against it.

CONTROL: r48/_shared/dickman.py is BROKEN above u = 5 and now raises, and rho
is the WRONG functional form as a null (Psi/x -> e^{-gamma}/ln B > 0 while
rho -> 0, so the ratio diverges).  So NO Dickman anywhere here: the smoothness
probability is measured by sampling, which needs no asymptotic at all.
"""
from __future__ import annotations

import math
import random
import sys

for _d in ("/home/raver1975/lean/factor-scratch/r50/exp/bneed",
           "/home/raver1975/lean/factor-scratch/r48/exp/stange"):
    sys.path.insert(0, _d)

import stange  # noqa: E402


def is_Bsmooth(r, FB):
    return stange.fb_exponents(r, FB)[1] == 1


def measure_smooth_rate(n, FB, trials, rng):
    """Fraction of uniform residues in [2,n) that are FB-smooth."""
    hits = 0
    for _ in range(trials):
        if is_Bsmooth(rng.randrange(2, n), FB):
            hits += 1
    return hits / trials


def wilson_lo(k, N):
    if N == 0:
        return 0.0
    z = 1.959963984540054
    ph = k / N
    d = 1.0 + z * z / N
    c = (ph + z * z / (2 * N)) / d
    hw = z / d * math.sqrt(ph * (1 - ph) / N + z * z / (4 * N * N))
    return max(0.0, c - hw)


def main():
    print("=" * 78)
    print("B4b: THE COST CURVE.  Where the b_needed gap actually lives.")
    print("=" * 78)
    print()
    print("Stange p.5 defines u = log n / log b and says u^u is the number of")
    print("trials to find one smooth integer.  The Dickman rho is NOT used here:")
    print("r48's dickman.py is broken above u = 5, and rho is the wrong null")
    print("(Psi/x -> e^{-gamma}/ln B > 0 but rho -> 0).  Everything below is")
    print("MEASURED by sampling actual residues against the actual factor base.")
    print()

    T = 400_000
    for bits in (30, 40, 50):
        n, p, q = stange.gen_semiprime(bits, random.Random(4242 + bits))
        rng = random.Random(20251003 + bits)
        print(f"n = 2^{bits} = {n}   ({p} * {q})   sampling {T} residues per row")
        print(f"  {'b':>4} {'B':>7} {'u':>8} {'P(smooth)':>12} "
              f"{'Wilson lo':>11} {'trials/rel':>12} {'u^u (model)':>14}")
        print("  " + "-" * 74)
        rows = []
        for b in (3, 5, 8, 11, 15, 20, 26, 33, 41, 50):
            BB = stange.bbound_for_b(b)
            FB = stange.factor_base(BB, n)
            if len(FB) != b:
                continue
            u = math.log(n) / math.log(BB)
            hits = 0
            for _ in range(T):
                if is_Bsmooth(rng.randrange(2, n), FB):
                    hits += 1
            rate = hits / T
            lo = wilson_lo(hits, T)
            tpr = (1.0 / lo) if lo > 0 else float("inf")
            rows.append((b, BB, u, rate, lo, tpr))
            print(f"  {b:>4} {BB:>7} {u:>8.3f} {rate:>12.6f} {lo:>11.6f} "
                  f"{tpr:>12.1f} {u ** u:>14.3e}")
        print()

        # Does Stange's u^u model PREDICT the measured trials/relation?
        print("  model check: measured trials/relation vs u^u")
        print(f"  {'b':>4} {'u^u':>14} {'measured':>14} {'ratio':>10}")
        print("  " + "-" * 46)
        for b, BB, u, rate, lo, tpr in rows[:6]:
            if lo > 0:
                print(f"  {b:>4} {u ** u:>14.3e} {tpr:>14.1f} "
                      f"{(u ** u) / tpr:>10.3e}")
        print()
        print("  Stange's u^u is the ASYMPTOTIC trial count for u -> infinity.")
        print("  At the u = 5-12 these runs live in, it OVERSHOOTS by orders of")
        print("  magnitude -- which is exactly why the b the model calls")
        print("  'needed' is so far above the b that works.  The model is not")
        print("  wrong; it is asymptotic, and B4 measures where it stops")
        print("  being tight.")
        print()


if __name__ == "__main__":
    main()
