#!/usr/bin/env python3
"""
demo.py — Numerical illustration of the Non-Archimedean Factoring Oracle theorem.

The theorem (corrected) states:
  For every composite n > 1, there exist a, b > 1 such that a * b = n.

This script demonstrates the theorem by:
1. Finding nontrivial factorizations of composite numbers.
2. Showing why the original (uncorrected) statement fails for primes.
3. Illustrating the minimum-factor decomposition used in the formal proof.
"""

import math


def min_factor(n: int) -> int:
    """
    Compute the minimum factor of n greater than 1.
    This mirrors Mathlib's Nat.minFac used in the formal proof.
    For prime n, minFac(n) = n. For composite n, minFac(n) < n.
    """
    if n <= 1:
        return n
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n


def factoring_oracle(n: int):
    """
    The factoring oracle: given composite n > 1, return (a, b) with a*b = n, a > 1, b > 1.

    This directly mirrors the Lean proof:
      a = minFac(n)          -- the smallest nontrivial divisor
      b = n / minFac(n)      -- the complementary factor

    The formal proof uses Nat.exists_dvd_of_not_prime2 to extract the divisor,
    then Nat.mul_div_cancel' to verify a * b = n.
    """
    a = min_factor(n)
    b = n // a
    assert a * b == n, f"Factorization failed: {a} * {b} != {n}"
    assert a > 1, f"Factor a = {a} is not > 1"
    assert b > 1, f"Factor b = {b} is not > 1"
    return a, b


def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    return all(n % d != 0 for d in range(3, int(math.isqrt(n)) + 1, 2))


def main():
    print("=" * 70)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 70)
    print()

    # --- Key Insight ---
    print("KEY INSIGHT:")
    print("  The original theorem claimed every n > 1 has a nontrivial")
    print("  factorization. This is FALSE for primes. The corrected theorem")
    print("  adds the hypothesis that n is composite (not prime).")
    print()

    # --- Demonstrate failure for primes ---
    print("--- Why the original statement fails (primes have no nontrivial factorization) ---")
    primes = [p for p in range(2, 30) if is_prime(p)]
    for p in primes:
        mf = min_factor(p)
        print(f"  n = {p:>2} (prime):  minFac = {mf:>2}, n/minFac = {p // mf:>2}  "
              f"→ {'FAILS' if mf == p else 'ok'} (factor = n itself)")
    print()

    # --- Demonstrate success for composites ---
    print("--- The corrected theorem works for all composites ---")
    composites = [n for n in range(4, 50) if n > 1 and not is_prime(n)]
    for n in composites:
        a, b = factoring_oracle(n)
        print(f"  n = {n:>2}:  {a} × {b} = {n}  ✓  (a > 1: {a > 1}, b > 1: {b > 1})")
    print()

    # --- Large composite examples (RSA-style) ---
    print("--- Large composite examples ---")
    large_composites = [
        101 * 103,       # Product of two primes
        997 * 991,       # Larger semiprime
        2**20 - 3,       # A large composite
        12345678,        # Arbitrary composite
    ]
    for n in large_composites:
        if not is_prime(n):
            a, b = factoring_oracle(n)
            print(f"  n = {n:>10}:  {a} × {b} = {n}  ✓")
    print()

    # --- The minimum-factor approach mirrors the formal proof ---
    print("--- Connection to the Lean proof ---")
    print("  The Lean proof uses Nat.exists_dvd_of_not_prime2 to find a divisor k")
    print("  with 1 < k < n, then sets a = k and b = n/k.")
    print("  This is exactly the minFac decomposition shown above.")
    print()
    print("  Lean proof (2 lines):")
    print("    obtain ⟨k, hk⟩ := Nat.exists_dvd_of_not_prime2 hn hcomp")
    print("    exact ⟨k, n/k, Nat.mul_div_cancel' hk.1, hk.2.1, ...⟩")
    print()

    # --- Statistics ---
    N = 10000
    composites_count = sum(1 for n in range(2, N) if not is_prime(n))
    all_factored = all(
        min_factor(n) < n
        for n in range(4, N) if not is_prime(n)
    )
    print(f"  Verified factoring oracle for all {composites_count} composites in [2, {N}): {all_factored}")
    print()
    print("=" * 70)


if __name__ == "__main__":
    main()
