#!/usr/bin/env python3
"""
demo.py — Non-Archimedean Factoring Oracle: Numerical Illustration

This script demonstrates the core theorem:
    Every composite n > 1 can be written as a * b with a > 1 and b > 1.

It also illustrates the p-adic perspective by computing p-adic valuations
and showing how the "factoring oracle" extracts non-trivial factors.

Usage:
    python3 demo.py
"""

import math
from typing import Tuple, Optional


def smallest_nontrivial_factor(n: int) -> Optional[int]:
    """
    Find the smallest divisor d of n with 1 < d < n.
    This mirrors the Lean proof's use of Nat.exists_dvd_of_not_prime2,
    which extracts a witness divisor from the negation of primality.

    Returns None if n is prime (no such d exists).
    """
    if n <= 1:
        return None
    for d in range(2, int(math.isqrt(n)) + 1):
        if n % d == 0:
            return d
    return None  # n is prime


def factoring_oracle(n: int) -> Optional[Tuple[int, int]]:
    """
    The factoring oracle: given composite n > 1, return (a, b) with
    a * b = n, a > 1, b > 1.

    This is the computational analogue of the formal theorem:
        theorem pAdic_factoring_oracle {p : ℕ} [Fact p.Prime] (n : ℕ)
            (hn : n > 1) (hc : ¬ Nat.Prime n) :
            ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
    """
    d = smallest_nontrivial_factor(n)
    if d is None:
        return None  # n is prime — theorem does not apply
    return (d, n // d)


def p_adic_valuation(n: int, p: int) -> int:
    """
    Compute v_p(n), the p-adic valuation of n.
    This is the exponent of p in the prime factorization of n.

    In the p-adic world, numbers with high valuation are "close to zero."
    The Newton polygon of a polynomial over Q_p is built from these valuations.
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def demonstrate_factoring():
    """Demonstrate the factoring oracle on a range of composite numbers."""
    print("=" * 65)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 65)
    print()
    print("Theorem (corrected): For every composite n > 1, there exist")
    print("a, b > 1 such that a * b = n.")
    print()

    # Test on a range of numbers
    print(f"{'n':>8}  {'Status':<12}  {'a':>6}  {'b':>6}  {'a*b':>8}  {'Check':>6}")
    print("-" * 55)

    composites_found = 0
    primes_found = 0

    for n in range(2, 51):
        result = factoring_oracle(n)
        if result is not None:
            a, b = result
            check = "✓" if a * b == n and a > 1 and b > 1 else "✗"
            print(f"{n:>8}  {'composite':<12}  {a:>6}  {b:>6}  {a*b:>8}  {check:>6}")
            composites_found += 1
        else:
            print(f"{n:>8}  {'PRIME':<12}  {'—':>6}  {'—':>6}  {'—':>8}  {'N/A':>6}")
            primes_found += 1

    print(f"\nComposites factored: {composites_found}")
    print(f"Primes (oracle N/A): {primes_found}")


def demonstrate_padic_perspective():
    """Show p-adic valuations and how they reveal factoring structure."""
    print()
    print("=" * 65)
    print("  P-ADIC PERSPECTIVE: Valuations reveal factor structure")
    print("=" * 65)
    print()
    print("For n = 360 = 2³ × 3² × 5, the p-adic valuations are:")
    print()

    n = 360
    for p in [2, 3, 5, 7, 11]:
        v = p_adic_valuation(n, p)
        bar = "█" * v + "░" * (5 - v)
        print(f"  v_{p}({n}) = {v}  {bar}")

    print()
    print("High valuation at p means n is 'close to zero' in Q_p.")
    print("The oracle splits 360 into factors by finding the smallest")
    print("non-trivial divisor:")
    result = factoring_oracle(n)
    if result:
        a, b = result
        print(f"  360 = {a} × {b}")
        print()
        print(f"  Valuations of {a}: ", end="")
        print(", ".join(f"v_{p}={p_adic_valuation(a, p)}" for p in [2, 3, 5]))
        print(f"  Valuations of {b}: ", end="")
        print(", ".join(f"v_{p}={p_adic_valuation(b, p)}" for p in [2, 3, 5]))


def demonstrate_large_example():
    """Show the oracle working on a large semiprime (RSA-style)."""
    print()
    print("=" * 65)
    print("  LARGE SEMIPRIME EXAMPLE (RSA-style)")
    print("=" * 65)
    print()

    # Two moderate primes
    p, q = 104729, 104743
    n = p * q
    print(f"  n = {p} × {q} = {n}")
    result = factoring_oracle(n)
    if result:
        a, b = result
        assert a * b == n and a > 1 and b > 1
        print(f"  Oracle returns: {a} × {b} = {a * b}")
        print(f"  Verification: a > 1 ✓, b > 1 ✓, a*b = n ✓")
    print()
    print("The theorem guarantees this always works for composites,")
    print("but says nothing about the *efficiency* of finding factors.")
    print("That's where p-adic methods (Hensel lifting, Newton polygons)")
    print("become interesting for algorithm design.")


def main():
    """
    Main entry point.

    KEY INSIGHT: The non-archimedean factoring oracle theorem guarantees
    that every composite number admits a non-trivial factorization. The
    original statement (without the composite hypothesis) is FALSE —
    primes are counterexamples. This correction, verified in Lean 4
    using Mathlib's Nat.exists_dvd_of_not_prime2, exemplifies how
    formal verification catches subtle errors in mathematical claims.
    """
    print()
    print("  KEY INSIGHT: Every composite n > 1 factors non-trivially.")
    print("  The original universal claim is FALSE (primes are")
    print("  counterexamples). Machine verification caught this error.")
    print()

    demonstrate_factoring()
    demonstrate_padic_perspective()
    demonstrate_large_example()

    print()
    print("=" * 65)
    print("  All demonstrations complete. See RESEARCH_REPORT.md for")
    print("  the full mathematical treatment and Lean formalization.")
    print("=" * 65)


if __name__ == "__main__":
    main()
