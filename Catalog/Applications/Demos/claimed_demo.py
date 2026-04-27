#!/usr/bin/env python3
"""
Non-Archimedean Factoring Oracle — Demonstration
=================================================

This script illustrates the corrected theorem:

    For every composite n > 1, there exist a, b > 1 such that a * b = n.

We also demonstrate the p-adic valuation perspective, showing how the
p-adic structure of a composite number reveals its factorization.

The formal Lean 4 proof uses Nat.exists_dvd_of_not_prime2 to extract
a proper divisor k with 1 < k < n and k | n, then sets a = k, b = n/k.

Usage:
    python3 demo.py
"""

import math
from typing import List, Tuple, Optional


def is_prime(n: int) -> bool:
    """Check if n is prime (trial division)."""
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


def smallest_nontrivial_divisor(n: int) -> Optional[int]:
    """
    Find the smallest divisor k of n with 1 < k < n.
    This mirrors Nat.exists_dvd_of_not_prime2 in Mathlib:
    if n > 1 and ¬ n.Prime, there exists k | n with 1 < k < n.
    Returns None if n is prime (no such k exists).
    """
    if n <= 1:
        return None
    for k in range(2, int(math.isqrt(n)) + 1):
        if n % k == 0:
            return k
    return None  # n is prime


def factoring_oracle(n: int) -> Optional[Tuple[int, int]]:
    """
    The factoring oracle: given composite n > 1, produce (a, b) with
    a * b = n and a > 1, b > 1.

    This is the computational analogue of pAdic_factoring_oracle in Lean 4.
    """
    k = smallest_nontrivial_divisor(n)
    if k is None:
        return None  # n is prime — theorem doesn't apply
    return (k, n // k)


def p_adic_valuation(n: int, p: int) -> int:
    """
    Compute v_p(n) = the largest power of p dividing n.
    The p-adic valuation is central to the Newton polygon approach.
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def display_p_adic_structure(n: int, p: int):
    """
    Display the p-adic structure of n and its factors.
    In the p-adic world, factorization is revealed through valuations.
    """
    result = factoring_oracle(n)
    if result is None:
        print(f"  n = {n} is prime — no non-trivial factorization exists.")
        print(f"  (This is why the original theorem statement was FALSE!)")
        return

    a, b = result
    v_n = p_adic_valuation(n, p)
    v_a = p_adic_valuation(a, p)
    v_b = p_adic_valuation(b, p)

    print(f"  n = {n} = {a} × {b}")
    print(f"  v_{p}({n}) = {v_n}")
    print(f"  v_{p}({a}) = {v_a},  v_{p}({b}) = {v_b}")
    print(f"  Check: v_{p}(a) + v_{p}(b) = {v_a + v_b} = v_{p}(n) ✓" if v_a + v_b == v_n else "")
    print(f"  Both factors > 1: {a} > 1 ✓, {b} > 1 ✓")


def demonstrate_counterexample():
    """
    Show why the ORIGINAL theorem (without ¬ n.Prime) is false.
    """
    print("=" * 60)
    print("COUNTEREXAMPLE: Why the original statement is false")
    print("=" * 60)
    print()
    print("The original theorem claimed: ∀ n > 1, ∃ a b > 1, a*b = n")
    print("But primes have NO non-trivial factorization:")
    print()
    for p in [2, 3, 5, 7, 11, 13]:
        divisors = [d for d in range(1, p + 1) if p % d == 0]
        print(f"  n = {p} (prime): divisors = {divisors}")
        print(f"    Only factorizations: 1 × {p} and {p} × 1")
        print(f"    No a, b > 1 with a × b = {p} exists!")
    print()


def demonstrate_corrected_theorem():
    """
    Show the corrected theorem in action for composite numbers.
    """
    print("=" * 60)
    print("CORRECTED THEOREM: Every composite n > 1 factors non-trivially")
    print("=" * 60)
    print()
    print("Theorem: ∀ n > 1, ¬ Prime n → ∃ a b > 1, a * b = n")
    print()

    composites = [4, 6, 8, 9, 10, 12, 15, 21, 35, 77, 91, 100, 143, 221, 1001]
    for n in composites:
        result = factoring_oracle(n)
        if result:
            a, b = result
            assert a * b == n and a > 1 and b > 1, "Oracle invariant violated!"
            print(f"  {n:>5} = {a:>3} × {b:<5}  (both > 1 ✓)")

    print()


def demonstrate_p_adic_perspective():
    """
    Show how p-adic valuations illuminate the factorization structure.
    The Newton polygon approach to factoring analyzes how p-adic valuations
    distribute across factors.
    """
    print("=" * 60)
    print("P-ADIC PERSPECTIVE: Valuations reveal factor structure")
    print("=" * 60)
    print()

    test_cases = [
        (12, 2),    # 12 = 2² × 3, interesting 2-adic structure
        (12, 3),    # same number, different prime
        (45, 3),    # 45 = 3² × 5
        (100, 2),   # 100 = 2² × 5²
        (100, 5),   # same number, different prime
        (1001, 7),  # 1001 = 7 × 11 × 13
    ]

    for n, p in test_cases:
        print(f"  p = {p}:")
        display_p_adic_structure(n, p)
        print()


def demonstrate_rsa_relevance():
    """
    Show the theorem's relevance to RSA: every RSA modulus (product of two primes)
    is composite, so the theorem guarantees a factorization exists.
    The challenge is FINDING it efficiently, not proving it EXISTS.
    """
    print("=" * 60)
    print("RSA RELEVANCE: Existence vs. Computation")
    print("=" * 60)
    print()
    print("RSA moduli are products of two large primes: n = p × q")
    print("Our theorem guarantees: since n is composite, factors exist.")
    print("The HARD problem is finding them efficiently!")
    print()

    # Small "RSA-like" examples
    rsa_examples = [
        (11, 13),     # 143
        (13, 17),     # 221
        (101, 103),   # 10403
        (1009, 1013), # 1022117
    ]

    for p, q in rsa_examples:
        n = p * q
        result = factoring_oracle(n)
        a, b = result
        print(f"  n = {p} × {q} = {n}")
        print(f"  Oracle finds: {n} = {a} × {b}  ✓")
        print()


def main():
    """
    Main demonstration of the Non-Archimedean Factoring Oracle theorem.

    KEY INSIGHT: The existence of non-trivial factorizations for composite numbers
    is a fundamental fact that underpins all of factoring theory. While the result
    is elementary, its formalization in Lean 4 required correcting the original
    statement (which falsely claimed ALL n > 1 factor non-trivially — primes don't!).

    The p-adic perspective adds depth: in ℚ_p, Hensel's lemma can lift approximate
    factorizations to exact ones, and Newton polygons reveal the p-adic structure
    of factors. Our formal proof establishes the existence guarantee that any such
    algorithm must satisfy.
    """
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   NON-ARCHIMEDEAN FACTORING ORACLE — DEMONSTRATION     ║")
    print("║                                                        ║")
    print("║   Formally verified in Lean 4 (Mathlib v4.28.0)        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    # 1. Show why original statement was wrong
    demonstrate_counterexample()
    print()

    # 2. Show corrected theorem works
    demonstrate_corrected_theorem()

    # 3. P-adic perspective
    demonstrate_p_adic_perspective()

    # 4. RSA connection
    demonstrate_rsa_relevance()

    # Final summary
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("• Original theorem (∀ n > 1, ∃ a,b > 1, a*b = n): FALSE")
    print("  Counterexample: n = 2 is prime, no non-trivial factorization.")
    print()
    print("• Corrected theorem: ∀ n > 1, ¬Prime n → ∃ a,b > 1, a*b = n: TRUE ✓")
    print("  Proved in Lean 4 using Nat.exists_dvd_of_not_prime2.")
    print()
    print("• The p-adic framing motivates ALGORITHMIC factoring via Hensel lifting")
    print("  and Newton polygons, while our formal proof establishes the existence")
    print("  guarantee: composite numbers always have non-trivial factors.")
    print()


if __name__ == "__main__":
    main()
