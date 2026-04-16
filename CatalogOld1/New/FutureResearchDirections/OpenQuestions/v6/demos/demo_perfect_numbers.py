#!/usr/bin/env python3
"""
Perfect Number Theory Demo (Research Directions B7, E19)

Demonstrates the Euclid-Euler theorem and divisor sum classification.
Every even perfect number has the form 2^(p-1)(2^p - 1) where 2^p - 1 is prime.
"""

import math


def sigma1(n):
    """Compute σ₁(n) = sum of all divisors of n."""
    if n <= 0:
        return 0
    total = 0
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
    return total


def is_prime(n):
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    for i in range(3, int(math.isqrt(n)) + 1, 2):
        if n % i == 0:
            return False
    return True


def classify(n):
    s = sigma1(n)
    if s == 2 * n:
        return "PERFECT"
    elif s > 2 * n:
        return "abundant"
    else:
        return "deficient"


def euclid_euler_candidates(max_p=30):
    """Find even perfect numbers using the Euclid-Euler theorem."""
    perfects = []
    for p in range(2, max_p):
        mersenne = 2**p - 1
        if is_prime(mersenne):
            N = 2**(p-1) * mersenne
            perfects.append((p, mersenne, N))
    return perfects


if __name__ == "__main__":
    print("=" * 70)
    print("PERFECT NUMBER THEORY DEMO")
    print("Euclid-Euler Theorem and Divisor Sum Classification")
    print("=" * 70)

    # Demo 1: Euclid-Euler theorem
    print("\n--- Even Perfect Numbers via Euclid-Euler ---")
    print("  Form: 2^(p-1) × (2^p - 1) where M_p = 2^p - 1 is prime")
    print()

    candidates = euclid_euler_candidates(25)
    for p, mersenne, N in candidates:
        s = sigma1(N)
        is_perf = s == 2 * N
        print(f"  p = {p:>2}: M_p = {mersenne:>8}, "
              f"N = 2^{p-1} × M_p = {N:>10}, "
              f"σ₁(N) = {s:>10}, 2N = {2*N:>10} "
              f"{'✓ PERFECT' if is_perf else '✗'}")

    # Demo 2: σ₁ verification
    print("\n--- σ₁ Verification ---")
    print("  σ₁(2^n) = 2^(n+1) - 1")
    for n in range(1, 12):
        s = sigma1(2**n)
        expected = 2**(n+1) - 1
        print(f"  σ₁(2^{n:>2}) = σ₁({2**n:>5}) = {s:>5}, "
              f"2^{n+1} - 1 = {expected:>5} {'✓' if s == expected else '✗'}")

    # Demo 3: σ₁ multiplicativity
    print("\n--- σ₁ Multiplicativity: σ₁(mn) = σ₁(m)σ₁(n) for gcd(m,n)=1 ---")
    pairs = [(3, 4), (5, 7), (8, 9), (11, 13), (4, 25), (7, 16)]
    for m, n in pairs:
        g = math.gcd(m, n)
        s_mn = sigma1(m * n)
        s_m = sigma1(m)
        s_n = sigma1(n)
        product = s_m * s_n
        print(f"  σ₁({m}×{n}) = σ₁({m*n}) = {s_mn}, "
              f"σ₁({m})×σ₁({n}) = {s_m}×{s_n} = {product} "
              f"{'✓' if s_mn == product else '✗'} (gcd={g})")

    # Demo 4: Classification table
    print("\n--- Number Classification (1-100) ---")
    counts = {"PERFECT": 0, "abundant": 0, "deficient": 0}
    perfects = []
    abundants = []
    for n in range(1, 101):
        cls = classify(n)
        counts[cls] += 1
        if cls == "PERFECT":
            perfects.append(n)
        elif cls == "abundant" and len(abundants) < 10:
            abundants.append(n)

    print(f"  Perfect numbers ≤ 100: {perfects}")
    print(f"  First abundant numbers: {abundants}")
    print(f"  Counts: {counts}")
    print(f"  Density: deficient {counts['deficient']}%, "
          f"abundant {counts['abundant']}%, "
          f"perfect {counts['PERFECT']}%")

    # Demo 5: σ₁ + φ = 2p for primes
    print("\n--- σ₁(p) + φ(p) = 2p for Primes (Formally Verified) ---")
    def euler_totient(n):
        count = 0
        for i in range(1, n + 1):
            if math.gcd(i, n) == 1:
                count += 1
        return count

    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        s1 = sigma1(p)
        phi = euler_totient(p)
        print(f"  p={p:>2}: σ₁(p)={s1:>3}, φ(p)={phi:>3}, "
              f"sum={s1+phi:>3}, 2p={2*p:>3} "
              f"{'✓' if s1 + phi == 2*p else '✗'}")

    # Demo 6: Mersenne primes and known perfect numbers
    print("\n--- Known Mersenne Primes (p ≤ 31) ---")
    mersenne_ps = [2, 3, 5, 7, 13, 17, 19, 31]
    for p in range(2, 32):
        m = 2**p - 1
        prime = is_prime(m)
        if prime:
            N = 2**(p-1) * m
            print(f"  p = {p:>2}: M_p = {m:>12} is PRIME → "
                  f"Perfect number = {N:>15}")

    print("\n" + "=" * 70)
    print("FORMALLY VERIFIED RESULTS:")
    print("1. σ₁(2^n) = 2^(n+1) - 1  (geometric sum)")
    print("2. If 2^p-1 is prime, then 2^(p-1)(2^p-1) is perfect  (Euclid)")
    print("3. σ₁ is multiplicative for coprime arguments")
    print("4. All primes are deficient: σ₁(p) = p+1 < 2p")
    print("5. 6, 28 are perfect (verified by computation)")
    print("6. 12 is abundant: σ₁(12) = 28 > 24")
    print("=" * 70)
