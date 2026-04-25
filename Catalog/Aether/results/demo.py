#!/usr/bin/env python3
"""
demo.py — Non-Archimedean Factoring Oracle: Numerical Illustration

This script demonstrates the corrected theorem:
  Every composite integer n > 1 can be written as a product a * b
  with both a > 1 and b > 1.

It also illustrates why the ORIGINAL (uncorrected) statement is false:
primes cannot be factored non-trivially.

The p-adic context is illustrated by computing p-adic valuations
and showing how the minimal factor serves as a "factoring oracle"
for composite numbers.
"""

import math
from typing import Tuple, Optional


def smallest_nontrivial_factor(n: int) -> Optional[int]:
    """
    Find the smallest divisor d of n with 1 < d < n.
    Returns None if n is prime (no such d exists).
    
    This corresponds to Nat.minFac in Mathlib — the key primitive
    used in the formal Lean proof.
    """
    if n <= 1:
        return None
    for d in range(2, int(math.isqrt(n)) + 1):
        if n % d == 0:
            return d
    return None  # n is prime


def factoring_oracle(n: int) -> Optional[Tuple[int, int]]:
    """
    The 'factoring oracle' from the theorem:
    Given composite n > 1, return (a, b) with a * b = n, a > 1, b > 1.
    
    In the Lean proof, this is constructed via:
      a = k           (smallest nontrivial divisor)
      b = n / k       (complementary factor)
    """
    d = smallest_nontrivial_factor(n)
    if d is None:
        return None  # n is prime — no factorization exists
    return (d, n // d)


def p_adic_valuation(n: int, p: int) -> int:
    """
    Compute v_p(n), the p-adic valuation of n.
    This is the exponent of p in the prime factorization of n.
    
    In the p-adic framework, the Newton polygon of x^2 - n over Q_p
    reveals factorization structure through its slopes, which are
    determined by p-adic valuations.
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


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
    print("=" * 70)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 70)
    
    # ── Part 1: Show the original statement is FALSE ──
    print("\n📌 PART 1: Why the original theorem is FALSE")
    print("-" * 50)
    print("The original claim: ∀ n > 1, ∃ a b > 1, a * b = n")
    print("Counterexamples (primes cannot be factored non-trivially):\n")
    
    primes = [p for p in range(2, 30) if is_prime(p)]
    for p in primes:
        result = factoring_oracle(p)
        print(f"  n = {p:3d}  (prime)   → No factorization exists ✗")
    
    # ── Part 2: The CORRECTED theorem works for all composites ──
    print(f"\n📌 PART 2: The corrected theorem (composite n > 1)")
    print("-" * 50)
    print("Corrected claim: ∀ n > 1, ¬Prime(n) → ∃ a b > 1, a * b = n\n")
    
    composites = [n for n in range(4, 50) if not is_prime(n)]
    for n in composites:
        a, b = factoring_oracle(n)
        assert a * b == n, f"Product check failed for {n}"
        assert a > 1 and b > 1, f"Bound check failed for {n}"
        print(f"  n = {n:3d}  →  {a} × {b} = {n}   (a > 1 ✓, b > 1 ✓)")
    
    # ── Part 3: p-adic valuations reveal structure ──
    print(f"\n📌 PART 3: p-adic valuations and factoring structure")
    print("-" * 50)
    print("For n = 360 = 2³ × 3² × 5, the p-adic valuations are:\n")
    
    n = 360
    for p in [2, 3, 5, 7, 11]:
        v = p_adic_valuation(n, p)
        bar = "█" * v if v > 0 else "·"
        print(f"  v_{p}({n}) = {v}   {bar}")
    
    print(f"\n  Factoring oracle: {factoring_oracle(n)}")
    print(f"  Verification: {factoring_oracle(n)[0]} × {factoring_oracle(n)[1]} = {n} ✓")
    
    # ── Part 4: Key insight ──
    print(f"\n{'=' * 70}")
    print("  KEY INSIGHT")
    print("=" * 70)
    print("""
  The original theorem (every n > 1 factors non-trivially) is FALSE.
  The minimal counterexample is n = 2: a prime number.
  
  The corrected theorem adds the hypothesis ¬Prime(n), making it true
  and provable. In the Lean 4 proof, the key step is:
  
    Nat.exists_dvd_of_not_prime2 : n > 1 → ¬Prime n → ∃ k, k ∣ n ∧ 2 ≤ k < n
  
  This extracts a non-trivial divisor, from which both factors are
  constructed as k and n/k, each provably greater than 1.
  
  While the p-adic framing is aspirational (Newton polygons over Q_p
  CAN guide polynomial factorization algorithms), the core existence
  result is purely number-theoretic.
""")


if __name__ == "__main__":
    main()
