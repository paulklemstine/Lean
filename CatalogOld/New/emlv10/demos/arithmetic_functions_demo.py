#!/usr/bin/env python3
"""
Arithmetic Functions Explorer — v10
=====================================
Explores σ₁, τ, φ, μ and their multiplicative properties.
Demonstrates perfect numbers, abundant/deficient classification,
and Möbius inversion.
"""

import math

def divisors(n):
    divs = []
    for i in range(1, int(math.isqrt(n)) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)

def sigma1(n):
    return sum(divisors(n))

def tau(n):
    return len(divisors(n))

def euler_totient(n):
    count = 0
    for k in range(1, n + 1):
        if math.gcd(k, n) == 1:
            count += 1
    return count

def mobius(n):
    if n == 1: return 1
    d = n
    num_factors = 0
    for p in range(2, int(math.sqrt(n)) + 1):
        if d % p == 0:
            d //= p
            num_factors += 1
            if d % p == 0:
                return 0  # p² divides n
    if d > 1:
        num_factors += 1
    return (-1) ** num_factors

def is_prime(n):
    if n < 2: return False
    for p in range(2, int(math.sqrt(n)) + 1):
        if n % p == 0: return False
    return True

def demo_multiplicativity():
    """Demonstrate multiplicativity of arithmetic functions."""
    print("=" * 60)
    print("  MULTIPLICATIVITY OF ARITHMETIC FUNCTIONS")
    print("=" * 60)
    print()
    print("  For coprime m, n: f(mn) = f(m)·f(n)")
    print()

    pairs = [(3, 5), (4, 9), (7, 11), (8, 15), (6, 25)]

    for m, n in pairs:
        if math.gcd(m, n) != 1:
            continue
        print(f"  m={m}, n={n}, gcd={math.gcd(m,n)}:")
        print(f"    σ₁({m}×{n}={m*n}) = {sigma1(m*n):4d} = "
              f"σ₁({m})·σ₁({n}) = {sigma1(m)}·{sigma1(n)} = {sigma1(m)*sigma1(n)}"
              f"  {'✓' if sigma1(m*n) == sigma1(m)*sigma1(n) else '✗'}")
        print(f"    τ({m}×{n}={m*n})  = {tau(m*n):4d} = "
              f"τ({m})·τ({n})  = {tau(m)}·{tau(n)}  = {tau(m)*tau(n)}"
              f"  {'✓' if tau(m*n) == tau(m)*tau(n) else '✗'}")
        print(f"    φ({m}×{n}={m*n})  = {euler_totient(m*n):4d} = "
              f"φ({m})·φ({n})  = {euler_totient(m)}·{euler_totient(n)}  = "
              f"{euler_totient(m)*euler_totient(n)}"
              f"  {'✓' if euler_totient(m*n) == euler_totient(m)*euler_totient(n) else '✗'}")
        print()

def demo_prime_power_formulas():
    """Show formulas for arithmetic functions at prime powers."""
    print("=" * 60)
    print("  PRIME POWER FORMULAS")
    print("=" * 60)
    print()
    print("  σ₁(p^k) = (p^{k+1} - 1)/(p - 1)")
    print("  τ(p^k)  = k + 1")
    print("  φ(p^k)  = p^k - p^{k-1}")
    print("  μ(p^k)  = -1 if k=1, 0 if k≥2")
    print()

    for p in [2, 3, 5, 7]:
        print(f"  p = {p}:")
        for k in range(1, 5):
            pk = p ** k
            expected_sigma = (p**(k+1) - 1) // (p - 1)
            expected_tau = k + 1
            expected_phi = pk - p**(k-1)
            expected_mu = -1 if k == 1 else 0
            print(f"    {p}^{k} = {pk:5d}: "
                  f"σ₁={sigma1(pk):5d} (exp {expected_sigma:5d}) "
                  f"τ={tau(pk):2d} (exp {expected_tau:2d}) "
                  f"φ={euler_totient(pk):5d} (exp {expected_phi:5d}) "
                  f"μ={mobius(pk):+2d} (exp {expected_mu:+2d})")
        print()

def demo_classification():
    """Classify numbers as perfect, abundant, or deficient."""
    print("=" * 60)
    print("  NUMBER CLASSIFICATION: PERFECT / ABUNDANT / DEFICIENT")
    print("=" * 60)
    print()
    print("  n is perfect:   σ₁(n) = 2n")
    print("  n is abundant:  σ₁(n) > 2n")
    print("  n is deficient: σ₁(n) < 2n")
    print()

    abundant = []
    perfect = []
    deficient_count = 0

    for n in range(1, 101):
        s = sigma1(n)
        if s == 2 * n:
            perfect.append(n)
            label = "PERFECT"
        elif s > 2 * n:
            abundant.append(n)
            label = "ABUNDANT"
        else:
            deficient_count += 1
            label = "deficient"

        if n <= 30 or s == 2 * n:
            print(f"  n = {n:3d}: σ₁(n) = {s:4d}, 2n = {2*n:4d}  → {label}")

    print(f"\n  Summary (1 to 100):")
    print(f"    Perfect:   {perfect}")
    print(f"    Abundant:  {abundant[:15]}...")
    print(f"    Deficient: {deficient_count} numbers")

def demo_multiperfect():
    """Find multiperfect numbers."""
    print("\n" + "=" * 60)
    print("  MULTIPERFECT NUMBERS")
    print("=" * 60)
    print()
    print("  k-perfect: σ₁(n) = k·n")
    print()

    for k in range(2, 6):
        found = []
        for n in range(1, 100001):
            if sigma1(n) == k * n:
                found.append(n)
                if len(found) >= 5:
                    break
        if found:
            print(f"  {k}-perfect numbers: {found}")

def demo_mobius_inversion():
    """Demonstrate Möbius inversion."""
    print("\n" + "=" * 60)
    print("  MÖBIUS INVERSION")
    print("=" * 60)
    print()
    print("  If g(n) = Σ_{d|n} f(d), then f(n) = Σ_{d|n} μ(n/d)·g(d)")
    print()

    # Example: f(n) = n (identity), g(n) = σ₁(n)
    print("  Example: f(n) = n, g(n) = σ₁(n) = Σ_{d|n} d")
    print()

    for n in range(1, 16):
        # Forward: g(n) = Σ f(d)
        g_n = sum(d for d in divisors(n))

        # Inverse: f(n) = Σ μ(n/d) g(d)
        f_recovered = sum(mobius(n // d) * sigma1(d) for d in divisors(n))

        print(f"  n = {n:2d}: g(n) = σ₁(n) = {g_n:4d}, "
              f"Σ μ(n/d)·g(d) = {f_recovered:4d} "
              f"(should be {n})  {'✓' if f_recovered == n else '✗'}")

def main():
    print("\n" + "█" * 60)
    print("  ARITHMETIC FUNCTIONS EXPLORER — v10")
    print("█" * 60 + "\n")

    demo_multiplicativity()
    demo_prime_power_formulas()
    demo_classification()
    demo_multiperfect()
    demo_mobius_inversion()

    print("\n" + "█" * 60)
    print("  DEMO COMPLETE")
    print("█" * 60 + "\n")

if __name__ == "__main__":
    main()
