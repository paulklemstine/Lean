#!/usr/bin/env python3
"""
Perfect Number Theory and Euler Direction Demo (B9)

Demonstrates the Euclid-Euler theorem: even perfect numbers have the form
2^(p-1) * (2^p - 1) where 2^p - 1 is a Mersenne prime.
"""

from sympy import isprime, divisor_sigma

def sigma1(n):
    return int(divisor_sigma(n, 1))

def is_perfect(n):
    return sigma1(n) == 2 * n

def demo_known_perfects():
    """Display known even perfect numbers."""
    print("=" * 65)
    print("KNOWN EVEN PERFECT NUMBERS (Euclid-Euler Form)")
    print("=" * 65)
    print(f"\n  {'p':>4} {'2^p - 1':>12} {'Prime?':>8} {'2^(p-1)·(2^p-1)':>20} {'Perfect?':>10}")
    print("  " + "-" * 60)

    mersenne_primes = []
    for p in range(2, 32):
        mp = 2**p - 1
        is_mp = isprime(mp)
        if is_mp:
            n = 2**(p-1) * mp
            perf = is_perfect(n)
            mersenne_primes.append((p, mp, n))
            print(f"  {p:4d} {mp:12d} {'✓':>8} {n:20d} {'✓' if perf else '✗':>10}")

    print(f"\n  Found {len(mersenne_primes)} Mersenne primes with p < 32")

def demo_euler_key_equation():
    """Verify the Euler key equation for even perfect numbers."""
    print("\n" + "=" * 65)
    print("EULER KEY EQUATION VERIFICATION")
    print("=" * 65)
    print("\n  For even perfect n = 2^k · m (m odd):")
    print("  (2^(k+1) - 1) · σ₁(m) = 2^(k+1) · m")

    for n in [6, 28, 496, 8128]:
        # Decompose n = 2^k * m
        k = 0
        m = n
        while m % 2 == 0:
            m //= 2
            k += 1

        lhs = (2**(k+1) - 1) * sigma1(m)
        rhs = 2**(k+1) * m

        print(f"\n  n = {n} = 2^{k} × {m}")
        print(f"    LHS: (2^{k+1} - 1) · σ₁({m}) = {2**(k+1)-1} × {sigma1(m)} = {lhs}")
        print(f"    RHS: 2^{k+1} · {m} = {rhs}")
        print(f"    Equal: {'✓' if lhs == rhs else '✗'}")
        print(f"    m = 2^{k+1} - 1 = {2**(k+1)-1}: {'✓' if m == 2**(k+1)-1 else '✗'}")
        print(f"    m prime: {'✓' if isprime(m) else '✗'}")

def demo_no_odd_perfects():
    """Verify no small odd numbers are perfect."""
    print("\n" + "=" * 65)
    print("ODD PERFECT NUMBER SEARCH (up to 10,000)")
    print("=" * 65)

    count = 0
    odd_perfects = []
    for n in range(1, 10001, 2):
        if is_perfect(n):
            odd_perfects.append(n)
            count += 1

    if odd_perfects:
        print(f"  Found odd perfect numbers: {odd_perfects}")
    else:
        print(f"  No odd perfect numbers found below 10,000 ✓")
        print(f"  (The existence of odd perfect numbers remains open —")
        print(f"   the oldest unsolved problem in mathematics!)")

def demo_abundant_deficient():
    """Classify numbers as perfect, abundant, or deficient."""
    print("\n" + "=" * 65)
    print("NUMBER CLASSIFICATION: Perfect / Abundant / Deficient")
    print("=" * 65)
    print(f"\n  {'n':>6} {'σ₁(n)':>8} {'2n':>8} {'Class':>12} {'s(n)=σ₁-n':>12}")
    print("  " + "-" * 50)

    for n in range(2, 31):
        s = sigma1(n)
        cls = "PERFECT" if s == 2*n else ("ABUNDANT" if s > 2*n else "deficient")
        print(f"  {n:6d} {s:8d} {2*n:8d} {cls:>12} {s-n:12d}")

def demo_sigma1_formulas():
    """Verify σ₁ formulas from the formal proofs."""
    print("\n" + "=" * 65)
    print("σ₁ FORMULA VERIFICATION")
    print("=" * 65)

    # σ₁(2^k) = 2^(k+1) - 1
    print("\n  σ₁(2^k) = 2^(k+1) - 1:")
    for k in range(1, 11):
        computed = sigma1(2**k)
        expected = 2**(k+1) - 1
        print(f"    σ₁(2^{k:2d}) = {computed:6d} = 2^{k+1:2d} - 1 = {expected:6d} {'✓' if computed==expected else '✗'}")

    # σ₁(p) = p + 1 for prime p
    print("\n  σ₁(p) = p + 1 for primes:")
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]:
        computed = sigma1(p)
        expected = p + 1
        print(f"    σ₁({p:2d}) = {computed:4d} = {p}+1 = {expected:4d} {'✓' if computed==expected else '✗'}")

if __name__ == "__main__":
    print("╔" + "═" * 63 + "╗")
    print("║  PERFECT NUMBER THEORY (EULER) — Gravitational Factoring v7  ║")
    print("╚" + "═" * 63 + "╝")

    demo_known_perfects()
    demo_euler_key_equation()
    demo_no_odd_perfects()
    demo_abundant_deficient()
    demo_sigma1_formulas()
