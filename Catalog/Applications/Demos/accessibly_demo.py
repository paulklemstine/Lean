#!/usr/bin/env python3
"""
demo.py — Non-Archimedean Factoring Oracle: Numerical Illustration

This script demonstrates the corrected factoring oracle theorem:
    Every n > 1 is either prime or admits a non-trivial factorization a * b = n
    with a > 1 and b > 1.

The formal Lean proof uses Nat.exists_dvd_of_not_prime2 to extract the smallest
non-trivial divisor (minFac). We replicate this logic computationally.

Usage: python3 demo.py
"""

import math
from typing import Tuple, Optional


def min_factor(n: int) -> int:
    """
    Find the smallest factor of n greater than 1.
    This mirrors Lean's Nat.minFac — trial division from 2 upward.
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
    return n  # n is prime


def factoring_oracle(n: int) -> Tuple[str, Optional[Tuple[int, int]]]:
    """
    The corrected factoring oracle:
    Given n > 1, returns either ("prime", None) or ("composite", (a, b))
    where a * b = n and a > 1, b > 1.

    This corresponds to the Lean theorem:
        Nat.Prime n ∨ ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1

    The proof strategy:
    1. Compute d = minFac(n), the smallest divisor > 1.
    2. If d == n, then n is prime (left disjunct).
    3. Otherwise, (d, n/d) is a non-trivial factorization (right disjunct).
    """
    assert n > 1, "Oracle requires n > 1"
    d = min_factor(n)
    if d == n:
        return ("prime", None)
    else:
        return ("composite", (d, n // d))


def demonstrate_oracle(numbers: list):
    """Run the oracle on a list of numbers and display results."""
    print("=" * 60)
    print("  Non-Archimedean Factoring Oracle — Demonstration")
    print("=" * 60)
    print()
    print("Theorem: ∀ n > 1, Prime(n) ∨ ∃ a b > 1, a·b = n")
    print()

    primes_found = 0
    composites_found = 0

    for n in numbers:
        result, factors = factoring_oracle(n)
        if result == "prime":
            print(f"  n = {n:>10}  →  PRIME")
            primes_found += 1
        else:
            a, b = factors
            # Verify the three conditions from the theorem:
            assert a * b == n, f"Product check failed: {a} * {b} ≠ {n}"
            assert a > 1, f"Factor bound failed: {a} ≤ 1"
            assert b > 1, f"Factor bound failed: {b} ≤ 1"
            print(f"  n = {n:>10}  →  COMPOSITE: {a} × {b} = {n}")
            composites_found += 1

    print()
    print(f"Summary: {primes_found} primes, {composites_found} composites")
    return primes_found, composites_found


def demonstrate_why_original_is_false():
    """
    Show why the ORIGINAL (uncorrected) theorem is false.
    The original claims: ∀ n > 1, ∃ a b > 1, a·b = n
    But for primes, no such a, b exist.
    """
    print()
    print("=" * 60)
    print("  Why the Original Statement is FALSE")
    print("=" * 60)
    print()
    print("Original claim: ∀ n > 1, ∃ a,b > 1 such that a·b = n")
    print()
    print("Counterexample: n = 2 (prime)")
    print("  Possible factorizations of 2 as a·b with a,b ∈ ℕ:")
    for a in range(1, 3):
        for b in range(1, 3):
            if a * b == 2:
                status = "✓ a·b=2" if (a > 1 and b > 1) else "✗ (need a>1 ∧ b>1)"
                print(f"    a={a}, b={b}: {a}×{b}={a*b}  {status}")
    print()
    print("  No pair (a,b) with both a>1 and b>1 satisfies a·b=2. □")


def padic_valuation(n: int, p: int) -> int:
    """
    Compute the p-adic valuation v_p(n) — the exponent of p in n.
    This connects to the p-adic motivation of the theorem.
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def demonstrate_padic_perspective():
    """
    Show how p-adic valuations relate to factorization.
    The key insight: n is composite iff its p-adic valuation profile
    is non-trivially decomposable.
    """
    print()
    print("=" * 60)
    print("  p-Adic Perspective on Factorization")
    print("=" * 60)
    print()
    print("For composite n = a·b, the p-adic valuation decomposes:")
    print("  v_p(n) = v_p(a) + v_p(b)  for all primes p")
    print()

    examples = [(15, 3, 5), (12, 2, 6), (77, 7, 11), (100, 4, 25)]
    primes = [2, 3, 5, 7, 11]

    for n, a, b in examples:
        print(f"  n = {n} = {a} × {b}")
        for p in primes:
            vn = padic_valuation(n, p)
            va = padic_valuation(a, p)
            vb = padic_valuation(b, p)
            if vn > 0:
                print(f"    v_{p}({n}) = {vn} = v_{p}({a}) + v_{p}({b}) = {va} + {vb}")
        print()


def main():
    """
    Main demonstration of the Non-Archimedean Factoring Oracle.

    KEY INSIGHT: The original theorem pAdic_factoring_oracle is FALSE because
    it claims every n > 1 is composite. The corrected version adds a primality
    disjunct: every n > 1 is either prime or composite. This is a tautology
    in classical logic, but its formal verification in Lean demonstrates the
    interplay between decidability and constructive witness extraction.
    """
    # Test on a range of interesting numbers
    test_numbers = [
        2, 3, 4, 5, 6, 7, 8, 9, 10,       # small numbers
        15, 17, 21, 23, 25,                   # mixed
        97, 100, 101, 128,                    # near powers
        561,                                   # Carmichael number
        1009,                                  # prime
        1024,                                  # power of 2
        10007,                                 # prime
        10403,                                 # = 101 × 103 (semiprime)
        65537,                                 # Fermat prime
    ]

    # Run the factoring oracle
    demonstrate_oracle(test_numbers)

    # Show why the original statement fails
    demonstrate_why_original_is_false()

    # p-adic perspective
    demonstrate_padic_perspective()

    print("=" * 60)
    print("  All assertions passed. The corrected oracle is verified.")
    print("=" * 60)


if __name__ == "__main__":
    main()
