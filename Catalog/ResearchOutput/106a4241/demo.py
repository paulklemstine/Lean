#!/usr/bin/env python3
"""
Non-Archimedean Factoring Oracle — Numerical Demonstration

This script illustrates the corrected factoring oracle theorem:
  Every composite integer n > 1 can be written as a * b with a > 1 and b > 1.

It also demonstrates why the original (uncorrected) claim is false:
  Primes cannot be so factored.

The script:
1. Tests the theorem on composite numbers, finding non-trivial factorizations.
2. Shows that primes are counterexamples to the original (false) statement.
3. Visualizes the density of primes vs composites up to N.
"""

import math


def find_nontrivial_factor(n: int) -> tuple[int, int] | None:
    """
    If n is composite (n > 1 and not prime), return (a, b) with a > 1, b > 1, a*b = n.
    If n is prime, return None.

    This mirrors the Lean proof which uses Nat.exists_dvd_of_not_prime2 to extract
    a divisor k with 1 < k < n, then sets a = k, b = n // k.
    """
    if n <= 1:
        return None
    for k in range(2, int(math.isqrt(n)) + 1):
        if n % k == 0:
            return (k, n // k)
    return None  # n is prime


def is_prime(n: int) -> bool:
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


def main():
    print("=" * 65)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — NUMERICAL DEMONSTRATION")
    print("=" * 65)
    print()

    # --- Part 1: Corrected theorem (composite numbers) ---
    print("PART 1: Corrected Theorem — Composites Always Factor")
    print("-" * 55)
    print()
    print("Theorem: For every composite n > 1, there exist a, b > 1")
    print("         such that a * b = n.")
    print()

    composites = [n for n in range(4, 51) if not is_prime(n)]
    for n in composites:
        result = find_nontrivial_factor(n)
        assert result is not None, f"Bug: {n} is composite but no factor found"
        a, b = result
        assert a * b == n and a > 1 and b > 1
        print(f"  n = {n:3d}  →  {a} × {b} = {n}  ✓")

    print()
    print(f"  All {len(composites)} composite numbers in [4, 50] verified. ✓")
    print()

    # --- Part 2: Counterexample (primes) ---
    print("PART 2: Counterexample — The Original Statement is FALSE")
    print("-" * 55)
    print()
    print("The original theorem claimed ALL n > 1 can be factored.")
    print("Primes disprove this:")
    print()

    primes = [n for n in range(2, 51) if is_prime(n)]
    for p in primes:
        result = find_nontrivial_factor(p)
        assert result is None, f"Bug: {p} is prime but a factor was found"
        # Verify: any a, b > 1 would give a*b >= 4 (for p=2,3)
        # or more generally, the smallest product of two numbers > 1 is 2*2 = 4
        print(f"  n = {p:3d}  →  PRIME (no a, b > 1 with a × b = {p})  ✗")

    print()
    print(f"  {len(primes)} primes in [2, 50] confirm the original statement is false.")
    print()

    # --- Part 3: Key insight ---
    print("PART 3: The Key Insight")
    print("-" * 55)
    print()
    print("The Lean proof of the counterexample for n = 2 is beautifully simple:")
    print("  If a > 1 and b > 1, then a ≥ 2 and b ≥ 2, so a × b ≥ 4 > 2. ⊥")
    print()
    print("The corrected theorem uses Nat.exists_dvd_of_not_prime2 from Mathlib:")
    print("  Given n > 1 and ¬Prime(n), extract k with 1 < k < n and k | n.")
    print("  Then (k, n/k) is the non-trivial factorization.")
    print()

    # --- Part 4: Statistics ---
    N = 1000
    n_primes = sum(1 for n in range(2, N + 1) if is_prime(n))
    n_composites = N - 1 - n_primes  # numbers from 2 to N: N-1 total
    print(f"STATISTICS up to N = {N}:")
    print(f"  Primes (counterexamples to original):    {n_primes}")
    print(f"  Composites (instances of corrected thm): {n_composites}")
    print(f"  Prime density ≈ {n_primes / (N - 1):.3f}")
    print(f"  (Prime Number Theorem predicts ≈ {1 / math.log(N):.3f})")
    print()
    print("=" * 65)
    print("  CONCLUSION: Formal verification caught a false conjecture!")
    print("  The corrected theorem is proven in Lean 4 with Mathlib.")
    print("=" * 65)


if __name__ == "__main__":
    main()
