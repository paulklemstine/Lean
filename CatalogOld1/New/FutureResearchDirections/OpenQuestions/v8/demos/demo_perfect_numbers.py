#!/usr/bin/env python3
"""
Even Perfect Number Theory and Euler Direction Demo

Demonstrates the Euclid-Euler theorem: every even perfect number has the form
2^(p-1) * (2^p - 1) where 2^p - 1 is a Mersenne prime.

Formally verified foundations:
- euclid_direction: If 2^p - 1 prime, then 2^(p-1)(2^p-1) is perfect
- euler_key_equation: (2^(k+1)-1) * σ₁(m) = 2^(k+1) * m
- euler_m_equals_mersenne: m = 2^(k+1) - 1 (NEW in v8)
- mersenne_prime_exponent_prime: If 2^p - 1 prime, then p prime (NEW in v8)
"""

import math

def sigma1(n):
    """Compute the sum of divisors σ₁(n)."""
    if n == 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += d
    return total

def sigma1_fast(n):
    """Compute σ₁(n) efficiently."""
    if n == 0:
        return 0
    total = 0
    for d in range(1, int(math.sqrt(n)) + 1):
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
    return total

def is_perfect(n):
    """Check if n is perfect: σ₁(n) = 2n."""
    return sigma1_fast(n) == 2 * n

def is_prime(n):
    """Miller-Rabin primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True

def demo_euclid_direction():
    """Demonstrate the Euclid direction: Mersenne primes → perfect numbers."""
    print("=" * 70)
    print("EUCLID DIRECTION (Formally Verified)")
    print("If 2^p - 1 is prime, then 2^(p-1) * (2^p - 1) is perfect")
    print("=" * 70)

    mersenne_exponents = [2, 3, 5, 7, 13, 17, 19, 31]

    for p in mersenne_exponents:
        M = 2**p - 1
        if is_prime(M):
            perfect = 2**(p-1) * M
            sigma = sigma1_fast(perfect)
            is_perf = sigma == 2 * perfect
            print(f"\n  p = {p}:")
            print(f"    M_{p} = 2^{p} - 1 = {M} {'(prime)' if is_prime(M) else '(NOT prime)'}")
            print(f"    P = 2^{p-1} × M_{p} = {perfect}")
            print(f"    σ₁(P) = {sigma}")
            print(f"    2P = {2*perfect}")
            print(f"    Perfect: {'✓' if is_perf else '✗'}")

def demo_euler_direction():
    """Demonstrate the Euler direction: even perfect → Euclid's form."""
    print("\n" + "=" * 70)
    print("EULER DIRECTION (Key Steps Formally Verified)")
    print("Every even perfect number has the form 2^(p-1) * (2^p - 1)")
    print("=" * 70)

    # Check all even perfect numbers up to 10^7
    even_perfects = []
    for n in range(2, 10**5, 2):
        if is_perfect(n):
            even_perfects.append(n)

    print(f"\nEven perfect numbers up to 10^5: {even_perfects}")

    for n in even_perfects:
        # Decompose: n = 2^k * m, m odd
        k = 0
        m = n
        while m % 2 == 0:
            m //= 2
            k += 1

        print(f"\n  n = {n}:")
        print(f"    Decomposition: 2^{k} × {m}")
        print(f"    m odd: {'✓' if m % 2 == 1 else '✗'}")

        # Verify Euler key equation
        lhs = (2**(k+1) - 1) * sigma1_fast(m)
        rhs = 2**(k+1) * m
        print(f"    Key equation: (2^{k+1}-1) × σ₁({m}) = {lhs}")
        print(f"                  2^{k+1} × {m} = {rhs}")
        print(f"    Equation holds: {'✓' if lhs == rhs else '✗'}")

        # Verify m = 2^(k+1) - 1
        expected_m = 2**(k+1) - 1
        print(f"    m = 2^{k+1} - 1 = {expected_m}: {'✓' if m == expected_m else '✗'}")
        print(f"    m is prime: {'✓' if is_prime(m) else '✗'}")

        # Verify k+1 is prime (Mersenne prime exponent must be prime)
        print(f"    k+1 = {k+1} is prime: {'✓' if is_prime(k+1) else '✗'}")

def demo_odd_perfect_search():
    """Search for odd perfect numbers (none are expected to exist)."""
    print("\n" + "=" * 70)
    print("ODD PERFECT NUMBER SEARCH")
    print("Formally verified: no odd perfect < 100 (no_small_odd_perfect)")
    print("=" * 70)

    limit = 10000
    print(f"\nSearching odd numbers up to {limit}...")
    found = False
    checked = 0

    for n in range(3, limit, 2):
        checked += 1
        if is_perfect(n):
            print(f"  ODD PERFECT FOUND: {n}")
            found = True

    if not found:
        print(f"  No odd perfect numbers found below {limit}")
        print(f"  ({checked} odd numbers checked)")
        print(f"  Known lower bound: 10^{1500} (Ochem & Rao, 2012)")

def demo_abundancy():
    """Analyze abundancy index σ₁(n)/n."""
    print("\n" + "=" * 70)
    print("ABUNDANCY INDEX ANALYSIS")
    print("σ₁(n)/n = 2 for perfect, > 2 for abundant, < 2 for deficient")
    print("=" * 70)

    # Perfect numbers
    print("\nPerfect numbers and their abundancy:")
    for n in [6, 28, 496, 8128]:
        ratio = sigma1_fast(n) / n
        print(f"  σ₁({n})/{n} = {sigma1_fast(n)}/{n} = {ratio:.6f}")

    # Most abundant small numbers
    print("\nMost abundant small numbers:")
    numbers = [(sigma1_fast(n)/n, n) for n in range(2, 1000)]
    numbers.sort(reverse=True)
    for ratio, n in numbers[:15]:
        status = "PERFECT" if abs(ratio - 2.0) < 1e-10 else ("abundant" if ratio > 2 else "deficient")
        print(f"  n = {n:4d}, σ₁(n)/n = {ratio:.4f} ({status})")

    # Multiply perfect numbers
    print("\nMultiply perfect numbers (σ₁(n) = kn):")
    for n in range(2, 10000):
        s = sigma1_fast(n)
        if s % n == 0 and s // n >= 2:
            print(f"  n = {n}, σ₁(n) = {s} = {s//n} × n")

def demo_mersenne_hunt():
    """Demonstrate the search for Mersenne primes."""
    print("\n" + "=" * 70)
    print("MERSENNE PRIME SEARCH")
    print("Formally verified: if 2^n-1 prime, then n is prime")
    print("=" * 70)

    print(f"\n{'p':>4s} {'2^p - 1':>20s} {'Prime?':>8s} {'Perfect Number':>20s}")
    print("-" * 60)

    for p in range(2, 65):
        if not is_prime(p):
            continue
        M = 2**p - 1
        is_M_prime = is_prime(M)
        perfect = 2**(p-1) * M if is_M_prime else ""
        M_str = str(M) if M < 10**15 else f"~10^{int(math.log10(M))}"
        P_str = str(perfect) if perfect and perfect < 10**15 else (f"~10^{int(math.log10(perfect))}" if perfect else "")
        print(f"{p:4d} {M_str:>20s} {'✓' if is_M_prime else '✗':>8s} {P_str:>20s}")

if __name__ == "__main__":
    demo_euclid_direction()
    demo_euler_direction()
    demo_odd_perfect_search()
    demo_abundancy()
    demo_mersenne_hunt()
