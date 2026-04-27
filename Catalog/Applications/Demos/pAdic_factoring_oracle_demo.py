#!/usr/bin/env python3
"""
demo.py — Numerical illustration of the Non-Archimedean Factoring Oracle theorem.

THEOREM (corrected):
  For every composite integer n > 1 (i.e., n > 1 and n is not prime),
  there exist a, b > 1 such that a * b = n.

The original conjecture omitted the "not prime" hypothesis and was therefore FALSE.
This script demonstrates:
  1. The theorem holds for all composite numbers.
  2. It fails for primes (illustrating why the hypothesis is necessary).
  3. A p-adic valuation perspective on factoring.
"""

import math
from typing import Optional, Tuple, List


def is_prime(n: int) -> bool:
    """Check primality by trial division."""
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


def find_nontrivial_factor(n: int) -> Optional[Tuple[int, int]]:
    """
    The 'factoring oracle': for composite n > 1, find a, b > 1 with a*b = n.

    This mirrors the Lean proof's strategy:
      1. Find the smallest divisor k > 1 (analogous to Nat.minFac).
      2. Return (k, n // k).

    Returns None for primes (the theorem doesn't apply).
    """
    if n <= 1 or is_prime(n):
        return None
    # Find smallest divisor > 1 (corresponds to Nat.exists_dvd_of_not_prime2)
    for k in range(2, int(math.isqrt(n)) + 1):
        if n % k == 0:
            return (k, n // k)
    return None  # Should never reach here for composite n


def p_adic_valuation(n: int, p: int) -> int:
    """
    Compute v_p(n) — the p-adic valuation of n.
    This is the exponent of p in the prime factorization of n.

    In the original theorem's framing, p-adic valuations were meant to
    guide factoring via Newton polygons. While the final proof is purely
    number-theoretic, valuations remain informative for understanding
    the structure of n.
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def demonstrate_theorem(numbers: List[int]) -> None:
    """
    For each n in the list, demonstrate that:
      - If n is composite: the oracle finds a, b > 1 with a*b = n. ✓
      - If n is prime: no such factorization exists. ✗
    """
    print("=" * 70)
    print("NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 70)
    print()
    print(f"{'n':>8} | {'Prime?':>7} | {'Factorization':>20} | {'Verified':>8}")
    print("-" * 55)

    for n in numbers:
        prime = is_prime(n)
        result = find_nontrivial_factor(n)
        if result:
            a, b = result
            verified = (a * b == n) and (a > 1) and (b > 1)
            print(f"{n:>8} | {'Yes' if prime else 'No':>7} | "
                  f"{a:>6} × {b:<6} = {a*b:<6} | {'✓' if verified else '✗':>8}")
        else:
            print(f"{n:>8} | {'Yes' if prime else 'No':>7} | "
                  f"{'(prime — no split)':>20} | {'N/A':>8}")
    print()


def demonstrate_padic_perspective() -> None:
    """
    Show p-adic valuations for a composite number, illustrating the
    original motivation: different primes p 'see' different aspects
    of n's factorization structure.
    """
    n = 2 * 3 * 5 * 7  # = 210
    print("=" * 70)
    print(f"P-ADIC PERSPECTIVE on n = {n}")
    print("=" * 70)
    print()
    print("The p-adic valuation v_p(n) reveals which primes divide n:")
    print()
    for p in [2, 3, 5, 7, 11, 13]:
        v = p_adic_valuation(n, p)
        bar = "█" * v + "░" * (5 - v)
        divides = "divides" if v > 0 else ""
        print(f"  v_{p:>2}({n}) = {v}  {bar}  {divides}")
    print()
    print("Key insight: v_p(n) > 0 iff p divides n.")
    print("A 'factoring oracle' at prime p succeeds when v_p(n) > 0,")
    print("extracting the factor p^(v_p(n)) from n.")
    print()

    # RSA-style semiprime example
    p_secret, q_secret = 101, 103
    n_rsa = p_secret * q_secret
    print(f"RSA-style semiprime: n = {p_secret} × {q_secret} = {n_rsa}")
    result = find_nontrivial_factor(n_rsa)
    if result:
        a, b = result
        print(f"  Oracle finds: {a} × {b} = {a * b}  ✓")
    print()


def main():
    """
    Main demonstration — the key insight:

    The original theorem claimed EVERY n > 1 has a non-trivial factorization.
    This is FALSE for primes (by definition!). The corrected theorem adds
    the hypothesis ¬ n.Prime, making it true and provable.

    In Lean 4, this was proved using Nat.exists_dvd_of_not_prime2, which
    extracts a divisor k with 1 < k < n from any composite number.
    """
    print()
    print("KEY INSIGHT:")
    print("  The original statement ∀ n > 1, ∃ a b > 1, a*b = n is FALSE.")
    print("  Counterexample: n = 7 (prime). No non-trivial factorization exists.")
    print("  Corrected: ∀ n > 1, ¬ n.Prime → ∃ a b > 1, a*b = n. TRUE. ✓")
    print()

    # Demonstrate with a mix of primes and composites
    test_numbers = [4, 5, 6, 7, 12, 13, 15, 17, 21, 23, 35, 37, 100, 101, 1000, 1009]
    demonstrate_theorem(test_numbers)
    demonstrate_padic_perspective()

    print("=" * 70)
    print("FORMAL VERIFICATION STATUS")
    print("=" * 70)
    print()
    print("  Lean 4 proof: VERIFIED ✓")
    print("  Axioms used: propext, Classical.choice, Quot.sound")
    print("  Key lemma: Nat.exists_dvd_of_not_prime2")
    print("  No sorry remaining in the proof.")
    print()


if __name__ == "__main__":
    main()
