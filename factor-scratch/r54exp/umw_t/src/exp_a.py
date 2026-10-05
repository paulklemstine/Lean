#!/usr/bin/env python3
"""
exp_a.py -- Vacuity check + t distribution for RANDOM rank-2 gaps.
Predictions in src/PREDICTIONS.md (P1, P2, P3, P5). Seeded, run twice, compare.
"""
import sys, os, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from umw_t_core import rng, band_primes, t_profile, sample_gap_leq_exp, t_size_upper_bound
import numpy as np, math

SEED = 20261004
ALPHA = BETA = 1.0 / 3.0

def main():
    rows = []
    for k in (8, 10):
        L = 2 ** k
        n = L ** 3
        P = band_primes(n)
        lam = sum(1.0 / p for p in P)
        bound = t_size_upper_bound(n, ALPHA, BETA)
        print(f"\n=== n=2^{3*k}=2^{3*k}  L=2^{k}  sqrt(n)={math.isqrt(n)} ===")
        print(f"  band primes |P0| = {len(P)}   lambda=sum 1/p = {lam:.5f}")
        print(f"  rigorous size upper bound on t : {bound:.1f}")
        for rep in range(3):
            r = rng(SEED, f"randA-{k}-{rep}")
            a1, a2, b0 = sample_gap_leq_exp(r, n, ALPHA, L, L)
            tmax, hist, ndiff, dropped = t_profile(a1, a2, L, L, P)
            tot = ndiff
            f0 = hist[0] / tot if tot else 0
            f1 = (hist[1] if len(hist) > 1 else 0) / tot
            f2 = sum(hist[2:]) / tot if len(hist) > 2 else 0.0
            print(f"  rep{rep}: differences={tot}  dropped(p|gcd)={dropped}  t_max={tmax}")
            print(f"        frac t=0: {f0:.4f}   frac t=1: {f1:.5f}   frac t>=2: {f2:.6f}")
            rows.append(dict(k=k, n=n, L=L, nP=len(P), lam=lam, sizebound=bound,
                             rep=rep, ndiff=tot, dropped=dropped, tmax=tmax,
                             frac0=f0, frac1=f1, frac2plus=f2,
                             a1=a1, a2=a2, b0=b0))
    with open(os.path.join(os.path.dirname(__file__), "..", "out", "exp_a.json"), "w") as f:
        json.dump(rows, f, indent=1)
    print("\nwrote out/exp_a.json")

if __name__ == "__main__":
    main()