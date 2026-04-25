#!/usr/bin/env python3
"""
demo.py — Illustrating the Non-Archimedean Factoring Oracle Theorem

This script demonstrates the corrected theorem:
    Every composite number n > 1 can be written as n = a * b
    with a > 1 and b > 1.

It also shows WHY the original (uncorrected) statement is false:
    primes cannot be so factored.

The formal Lean proof uses Nat.exists_dvd_of_not_prime2 from Mathlib,
which guarantees a divisor k with 2 ≤ k < n for any composite n ≥ 2.
We then take (a, b) = (k, n/k).
"""

from math import isqrt
from typing import Optional, Tuple, List


def smallest_nontrivial_factor(n: int) -> Optional[int]:
    """
    Find the smallest divisor d of n with 2 ≤ d < n.
    This mirrors Mathlib's Nat.minFac — the minimal factor.
    Returns None if n is prime (no such d exists).
    """
    if n < 2:
        return None
    for d in range(2, isqrt(n) + 1):
        if n % d == 0:
            return d
    return None  # n is prime


def factor_oracle(n: int) -> Optional[Tuple[int, int]]:
    """
    The factoring oracle: given composite n > 1, return (a, b) with
    a * b = n, a > 1, b > 1.

    Corresponds to the Lean theorem:
        theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime]
          (n : ℕ) (hn : n > 1) (hc : ¬ Nat.Prime n) :
          ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
    """
    d = smallest_nontrivial_factor(n)
    if d is None:
        return None  # n is prime — theorem does not apply
    return (d, n // d)


def is_prime(n: int) -> bool:
    """Simple primality test."""
    return n > 1 and smallest_nontrivial_factor(n) is None


def main():
    print("=" * 70)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 70)

    # ------------------------------------------------------------------
    # Part 1: Show the theorem works for composite numbers
    # ------------------------------------------------------------------
    print("\n📐 THEOREM (corrected): Every composite n > 1 has a non-trivial")
    print("   factorization n = a × b with a > 1 and b > 1.\n")

    composites = [n for n in range(4, 101) if not is_prime(n)]
    print(f"Composite numbers in [4, 100]: {len(composites)} total\n")

    print(f"{'n':>5} {'a':>5} {'b':>5}  {'a*b':>5}  {'a>1':>5}  {'b>1':>5}  {'valid':>6}")
    print("-" * 50)
    all_valid = True
    for n in composites:
        result = factor_oracle(n)
        assert result is not None, f"factor_oracle failed for composite {n}"
        a, b = result
        valid = (a * b == n) and (a > 1) and (b > 1)
        all_valid = all_valid and valid
        if n <= 30 or n in [50, 77, 91, 100]:
            print(f"{n:>5} {a:>5} {b:>5}  {a*b:>5}  {str(a>1):>5}  {str(b>1):>5}  {'✓' if valid else '✗':>6}")

    print(f"\n{'...' :>5}")
    print(f"\n✅ All {len(composites)} composite numbers verified: {all_valid}\n")

    # ------------------------------------------------------------------
    # Part 2: Show WHY the original statement is false (primes)
    # ------------------------------------------------------------------
    print("=" * 70)
    print("  WHY THE ORIGINAL THEOREM IS FALSE")
    print("=" * 70)

    primes_under_30 = [n for n in range(2, 31) if is_prime(n)]
    print(f"\nPrimes under 30: {primes_under_30}")
    print("\nFor each prime p, attempting to find a, b > 1 with a * b = p:")
    print(f"{'p':>5}  {'result':>20}")
    print("-" * 30)
    for p in primes_under_30:
        result = factor_oracle(p)
        print(f"{p:>5}  {'IMPOSSIBLE (prime)':>20}")

    print("\n❌ Primes have no non-trivial factorization.")
    print("   This is why ¬Nat.Prime n is a necessary hypothesis.\n")

    # ------------------------------------------------------------------
    # Part 3: Key insight
    # ------------------------------------------------------------------
    print("=" * 70)
    print("  KEY INSIGHT")
    print("=" * 70)
    print("""
The original theorem claimed:
    ∀ n > 1, ∃ a b > 1, a * b = n

This is FALSE — it fails for every prime number.

The corrected theorem adds the hypothesis ¬Nat.Prime n:
    ∀ n > 1, ¬Prime(n) → ∃ a b > 1, a * b = n

This is TRUE and formally verified in Lean 4 using Mathlib's
Nat.exists_dvd_of_not_prime2, which provides a non-trivial divisor
for any composite number. The proof constructs the factorization
explicitly as (k, n/k) where k is the guaranteed divisor.

The formal verification uses only standard axioms:
  - propext (propositional extensionality)
  - Classical.choice (law of excluded middle)
  - Quot.sound (quotient soundness)
""")

    # ------------------------------------------------------------------
    # Part 4: p-adic valuation connection
    # ------------------------------------------------------------------
    print("=" * 70)
    print("  P-ADIC VALUATION PERSPECTIVE")
    print("=" * 70)
    print("\nFor composite n, the p-adic valuation v_p(n) reveals structure:\n")

    def v_p(n: int, p: int) -> int:
        """p-adic valuation of n."""
        if n == 0:
            return float('inf')
        v = 0
        while n % p == 0:
            v += 1
            n //= p
        return v

    test_numbers = [12, 30, 60, 100, 360, 2520]
    small_primes = [2, 3, 5, 7]

    print(f"{'n':>6}", end="")
    for p in small_primes:
        print(f"  v_{p}(n)", end="")
    print(f"  {'factorization':>20}")
    print("-" * 60)

    for n in test_numbers:
        print(f"{n:>6}", end="")
        for p in small_primes:
            print(f"  {v_p(n, p):>5}", end="")
        result = factor_oracle(n)
        a, b = result
        print(f"  {a:>3} × {b:<6}")

    print("\nThe p-adic valuations encode the prime factorization structure.")
    print("A 'factoring oracle' extracts this information to split composites.\n")


if __name__ == "__main__":
    main()
