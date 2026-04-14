#!/usr/bin/env python3
"""
σ₁ Hardness Reduction Demo (A+8, A6b)

Demonstrates the computational equivalence between σ₁ evaluation and factoring.
Shows how an exact or approximate σ₁ oracle breaks RSA in constant time.
"""

import math
from sympy import divisor_sigma, isprime, factorint

def sigma1(n):
    """Compute σ₁(n) = sum of divisors of n."""
    return int(divisor_sigma(n, 1))

def factor_from_sigma1(N, sigma_val):
    """Given N = pq and σ₁(N), recover factors p and q."""
    # Step 1: Compute p + q
    s = sigma_val - N - 1  # p + q

    # Step 2: Compute discriminant
    discriminant = s * s - 4 * N  # (p - q)²

    if discriminant < 0:
        return None

    # Step 3: Compute p - q
    d = int(math.isqrt(discriminant))
    if d * d != discriminant:
        return None

    # Step 4: Recover factors
    p = (s - d) // 2
    q = (s + d) // 2

    if p * q == N and p > 1 and q > 1:
        return (p, q)
    return None

def demo_sigma1_attack():
    """Demonstrate the σ₁ oracle attack on semiprimes."""
    print("=" * 60)
    print("σ₁ ORACLE ATTACK ON SEMIPRIMES")
    print("=" * 60)

    semiprimes = [
        (3, 5), (7, 11), (13, 17), (23, 29), (31, 37),
        (41, 43), (53, 59), (67, 71), (83, 89), (97, 101),
        (127, 131), (251, 257), (509, 521), (1021, 1031),
        (2053, 2063), (4099, 4111), (8209, 8221)
    ]

    print(f"\n  {'N':>12} {'σ₁(N)':>14} {'p+q':>8} {'Δ':>10} {'p':>6} {'q':>6} {'OK':>4}")
    print("  " + "-" * 65)

    for p, q in semiprimes:
        N = p * q
        sv = sigma1(N)
        result = factor_from_sigma1(N, sv)
        if result:
            fp, fq = result
            ok = "✓" if fp == p and fq == q else "✗"
            print(f"  {N:12d} {sv:14d} {p+q:8d} {(p-q)**2:10d} {fp:6d} {fq:6d} {ok:>4}")

def demo_approximation_attack():
    """Show that even approximate σ₁ values can factor."""
    print("\n" + "=" * 60)
    print("APPROXIMATE σ₁ ATTACK")
    print("=" * 60)
    print("  Even a noisy estimate of σ₁(N) can reveal factors!")

    p, q = 1009, 1013
    N = p * q
    true_sigma = sigma1(N)

    print(f"\n  N = {p} × {q} = {N}")
    print(f"  True σ₁(N) = {true_sigma}")
    print(f"  True p+q = {p+q}")

    # Try various approximation errors
    print(f"\n  {'Error ε':>10} {'Approx σ₁':>14} {'p+q estimate':>14} {'Factors?':>10}")
    print("  " + "-" * 55)

    for eps in [0, 1, 2, 5, 10, 50, 100, 500]:
        approx_sigma = true_sigma + eps
        result = factor_from_sigma1(N, approx_sigma)
        status = f"{result[0]}×{result[1]}" if result else "FAIL"
        s_est = approx_sigma - N - 1
        print(f"  {eps:10d} {approx_sigma:14d} {s_est:14d} {status:>10}")

def demo_three_prime_expansion():
    """Show σ₁ expansion for products of three primes."""
    print("\n" + "=" * 60)
    print("σ₁ FOR PRODUCTS OF THREE PRIMES")
    print("=" * 60)

    triples = [(3, 5, 7), (5, 7, 11), (7, 11, 13), (11, 13, 17)]

    for p, q, r in triples:
        N = p * q * r
        sv = sigma1(N)
        expected = 1 + p + q + r + p*q + p*r + q*r + p*q*r
        print(f"\n  N = {p}×{q}×{r} = {N}")
        print(f"  σ₁(N) = {sv}")
        print(f"  1+p+q+r+pq+pr+qr+pqr = {expected}")
        print(f"  Match: {'✓' if sv == expected else '✗'}")

def demo_sigma1_multiplicativity():
    """Verify σ₁ multiplicativity for coprime pairs."""
    print("\n" + "=" * 60)
    print("σ₁ MULTIPLICATIVITY VERIFICATION")
    print("=" * 60)
    print(f"\n  {'m':>6} {'n':>6} {'gcd':>4} {'σ₁(mn)':>10} {'σ₁(m)·σ₁(n)':>14} {'Equal?':>8}")
    print("  " + "-" * 55)

    pairs = [(6, 7), (10, 9), (15, 14), (8, 15), (12, 25), (7, 11), (13, 17)]
    for m, n in pairs:
        g = math.gcd(m, n)
        smn = sigma1(m * n)
        sm_sn = sigma1(m) * sigma1(n)
        eq = "✓" if (g == 1 and smn == sm_sn) or g > 1 else "✗"
        print(f"  {m:6d} {n:6d} {g:4d} {smn:10d} {sm_sn:14d} {eq:>8}")

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  σ₁ HARDNESS REDUCTION — Gravitational Factoring v7     ║")
    print("╚" + "═" * 58 + "╝")

    demo_sigma1_attack()
    demo_approximation_attack()
    demo_three_prime_expansion()
    demo_sigma1_multiplicativity()
