#!/usr/bin/env python3
"""
exp_f.py -- THE FINAL DIAGNOSTIC: separate the three claims.

The task asks about t = max # band primes dividing a nonzero rank-2 gap difference,
where the gap is the one an n-divisor conjecture would supply. Three distinct
quantities must not be conflated:

  (Q1) t over ARBITRARY rank-2 gaps (no n-divisor requirement).
       -> exp_b/exp_c: t can be as large as ~n^(1/3)/log n, construction-exact.
  (Q2) t over gaps that SATISFY the n-divisor property.
       -> This is what He-Sahai's Lemma 2.1 actually needs. NOT DETERMINED here.
  (Q3) t over gaps satisfying n-divisor AND height exp(n^alpha) AND |A| = n^(2 beta).

Why (Q2)/(Q3) are not settled by the construction: the construction concentrates all
its mass in multiples of M, so d | a requires d | M for most d, and small d's that
are coprime to M are missed (measured: 37%->97% coverage, still < 100%).

This file measures the STRUCTURAL reason the construction cannot be n-divisor, and
gives the size-budget arithmetic that bounds Q1 rigorously. It also records the
random-gap answer to Q1 for contrast (exp_a: t ~ 3, tiny).

Controls included.
"""
import sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from umw_t_core import band_primes, t_profile, is_degenerate, rng
import numpy as np

def main():
    print("=== A. RIGOROUS SIZE BOUND on t (Q1) ===")
    print("  If t band primes p_1..p_t each divide D = a1*di + a2*dj, and each p >= a*x")
    print("  with x=floor(sqrt n), a=2/3, then (a*x)^t <= |D| <= 2*max|A| <= 2*exp(n^alpha).")
    print("  Hence  t <= log(2 exp(n^alpha)) / log(a sqrt n)  =  Theta(n^alpha / log n).")
    print("  At (alpha,beta)=(1/3,1/3):  t <= (2+o(1)) n^(1/3)/log n.")
    print()
    for bits in (30, 60, 120, 256, 1024, 2048):
        # log2 t_bound = log2(n^(1/3)) - log2(0.5 log2 n) + O(1)
        #   = bits/3 - log2(bits/2) + 1
        lg_t = bits/3.0 - math.log2(bits/2.0) + 1.0
        print(f"   n=2^{bits:5d}: log2(t_bound) ~ {lg_t:9.2f}  -> t ~ 2^{lg_t:.1f}"
              f"   (n^(1/6) = 2^{bits/6:.1f})   t/n^(1/6) = 2^{lg_t - bits/6:.2f}")
    print()
    print("  => t_bound / n^(1/6) = 2^(bits/6 - log2(bits/2) + 1) -> grows without")
    print("     bound in bits. So the SIZE budget alone already permits t >> n^(1/6)")
    print("     at RSA scale (n=2^2048: t_bound ~ 2^674 vs n^(1/6)=2^341).")

    print("\n=== B. Does the construction even TRY to be n-divisor? ===")
    print("  A = {1 + i + (M-1)j}.  For d | M we get d | A whenever i+j is right;")
    print("  for d with a factor outside M, A mod d = 1 + i + (M-1)j must be 0 mod d,")
    print("  a 2-variable congruence. With |i|,|j| < L << d the box simply misses.")
    for kb in (18, 24):
        L = 2**(kb//3); n = L**3; x = math.isqrt(n)
        P = sorted(int(p) for p in band_primes(n)); P=[p for p in P if p>(2*x)//3]
        budget = n**(1/3) - math.log(L)
        M,k,logM = 1,0,0.0
        for p in P:
            if logM+math.log(p)<=budget: M*=p; logM+=math.log(p); k+=1
            else: break
        # how many d in [1, D] are MISSED because gcd(d,M)=1 and d > 2L
        D = 5000
        miss_coprime = sum(1 for d in range(1, D+1)
                           if math.gcd(d, M) == 1 and d > 2*L)
        print(f"   n=2^{3*(kb//3)}: L={L} k={k}  d in [1,{D}] with gcd(d,M)=1 and d>2L: "
              f"{miss_coprime}  -> these are structurally unreachable by the box")
    print("  (this is the mechanism; it is not a proof that no other construction works)")

    print("\n=== C. CONTRAST: random n-divisor-agnostic gaps (Q1, random) ===")
    L = 2**8; n = L**3
    P = band_primes(n)
    ts = []
    for rep in range(5):
        r = rng(20261004, f"randA-8-{rep}")
        lim = 2**230
        a1 = int.from_bytes(r.bytes(32),"little") % (2*lim) - lim
        a2 = int.from_bytes(r.bytes(32),"little") % (2*lim) - lim
        if is_degenerate(a1,a2,L,L): continue
        t,_,_,_ = t_profile(a1,a2,L,L,P)
        ts.append(t)
    print(f"   random gaps at n=2^24: t values = {ts}  (mean {np.mean(ts):.2f})")
    print(f"   constructed gap at n=2^24: t = 31 (exp_c)")
    print("   => t is NOT a constant; it ranges from ~1-3 (random) to ~n^(1/3)/log n")
    print("      (adversarial). Measuring it is meaningful: it is not saturated, not vacuous.")

if __name__ == "__main__":
    main()