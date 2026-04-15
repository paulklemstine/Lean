#!/usr/bin/env python3
"""
Carmichael Number Detector and Korselt's Criterion Verifier

This demo identifies Carmichael numbers using Korselt's criterion:
  n is Carmichael ⟺ n is squarefree AND (p-1)|(n-1) for all prime p|n

It also demonstrates the Miller-Rabin test's advantage over Fermat's test
for catching Carmichael numbers.

Usage:
    python carmichael_detector.py [max_n]
"""

import sys
import math
from collections import defaultdict

def is_prime(n):
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def prime_factors(n):
    """Return the set of prime factors of n."""
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors

def is_squarefree(n):
    """Check if n is squarefree (no prime factor appears more than once)."""
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        d += 1
    return True

def satisfies_korselt(n):
    """Check if n satisfies Korselt's criterion."""
    if n < 2 or is_prime(n):
        return False
    if not is_squarefree(n):
        return False
    for p in prime_factors(n):
        if (n - 1) % (p - 1) != 0:
            return False
    return True

def fermat_test(n, a):
    """Fermat primality test: check if a^(n-1) ≡ 1 (mod n)."""
    if math.gcd(a, n) > 1:
        return False  # a not coprime to n
    return pow(a, n - 1, n) == 1

def miller_rabin_test(n, a):
    """Miller-Rabin primality test for base a."""
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False

    # Write n-1 = 2^s * d with d odd
    d = n - 1
    s = 0
    while d % 2 == 0:
        d //= 2
        s += 1

    x = pow(a, d, n)
    if x == 1 or x == n - 1:
        return True  # probably prime

    for _ in range(s - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return True
    return False

def find_carmichael_numbers(max_n):
    """Find all Carmichael numbers up to max_n."""
    carmichaels = []
    for n in range(3, max_n + 1, 2):  # Carmichael numbers are always odd
        if not is_prime(n) and satisfies_korselt(n):
            carmichaels.append(n)
    return carmichaels

def analyze_carmichael(n):
    """Detailed analysis of a Carmichael number."""
    factors = sorted(prime_factors(n))
    factorization = " × ".join(str(p) for p in factors)

    print(f"\n{'='*60}")
    print(f"  Carmichael Number: {n} = {factorization}")
    print(f"{'='*60}")

    # Korselt's criterion
    print(f"\n  Korselt's Criterion:")
    print(f"    Squarefree: {'✓' if is_squarefree(n) else '✗'}")
    for p in factors:
        divides = (n - 1) % (p - 1) == 0
        quotient = (n - 1) // (p - 1) if divides else "N/A"
        print(f"    ({p}-1) = {p-1} | {n-1}: {'✓' if divides else '✗'} (quotient = {quotient})")

    # Fermat test — Carmichael numbers fool it
    print(f"\n  Fermat Test (bases 2-20 coprime to {n}):")
    fermat_fooled = 0
    fermat_total = 0
    for a in range(2, min(21, n)):
        if math.gcd(a, n) == 1:
            fermat_total += 1
            result = fermat_test(n, a)
            if result:
                fermat_fooled += 1
    print(f"    Fooled {fermat_fooled}/{fermat_total} bases (Fermat says 'probably prime')")

    # Miller-Rabin test — catches Carmichael numbers
    print(f"\n  Miller-Rabin Test (bases 2-20):")
    mr_witnesses = []
    for a in range(2, min(21, n)):
        if math.gcd(a, n) == 1:
            if not miller_rabin_test(n, a):
                mr_witnesses.append(a)
    if mr_witnesses:
        print(f"    Witnesses found: {mr_witnesses}")
        print(f"    Miller-Rabin correctly identifies {n} as composite!")
    else:
        print(f"    No witnesses found in range 2-20")

    return factors

def main():
    max_n = int(sys.argv[1]) if len(sys.argv) > 1 else 10000

    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Carmichael Number Detector & Korselt Verifier       ║")
    print("║     Gravitational Factoring Project — v12               ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print(f"\nSearching for Carmichael numbers up to {max_n}...")

    carmichaels = find_carmichael_numbers(max_n)

    print(f"\nFound {len(carmichaels)} Carmichael numbers: {carmichaels}")

    # Analyze each one
    for n in carmichaels[:10]:  # Show details for first 10
        analyze_carmichael(n)

    # Statistics
    print(f"\n{'='*60}")
    print(f"  Summary Statistics")
    print(f"{'='*60}")
    print(f"  Carmichael numbers ≤ {max_n}: {len(carmichaels)}")

    # Count by number of prime factors
    factor_counts = defaultdict(int)
    for n in carmichaels:
        k = len(prime_factors(n))
        factor_counts[k] += 1
    for k in sorted(factor_counts):
        print(f"  With {k} prime factors: {factor_counts[k]}")

    print(f"\n  Key insight: Carmichael numbers fool Fermat's test")
    print(f"  but Miller-Rabin catches them with high probability!")
    print(f"\n  Formally verified in Lean 4:")
    print(f"    • carmichael_561_factors: 561 = 3 × 11 × 17")
    print(f"    • carmichael_561_squarefree: Squarefree 561")
    print(f"    • korselt_561_divs: (2|560) ∧ (10|560) ∧ (16|560)")
    print(f"    • carmichael_561_witness: base 7 catches 561 via MR")

if __name__ == "__main__":
    main()
