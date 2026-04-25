#!/usr/bin/env python3
"""
demo.py — Non-Archimedean Factoring Oracle: Numerical Illustration
==================================================================

This script illustrates the corrected theorem:

    Every composite integer n > 1 admits a non-trivial factorization
    a * b = n  with  a > 1  and  b > 1.

It also explores the p-adic valuation landscape that motivated the
original (false) conjecture, showing how p-adic valuations decompose
integers but do NOT by themselves guarantee compositeness.

Usage:
    python3 demo.py
"""

import math
from collections import defaultdict


def smallest_factor(n: int) -> int:
    """Return the smallest factor of n greater than 1.
    
    This mirrors Mathlib's Nat.minFac, which is the key function
    used in the formal Lean proof.
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


def nontrivial_factorization(n: int):
    """
    For composite n > 1, return (a, b) with a * b = n, a > 1, b > 1.
    
    This is the computational witness for the formal theorem
    pAdic_factoring_oracle. The proof uses Nat.exists_dvd_of_not_prime2
    to extract the minimal factor k, then sets a = k, b = n / k.
    """
    assert n > 1, f"n must be > 1, got {n}"
    d = smallest_factor(n)
    assert d < n, f"n = {n} is prime — theorem requires composite input"
    return d, n // d


def p_adic_valuation(n: int, p: int) -> int:
    """Compute v_p(n) = the p-adic valuation of n."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def demonstrate_factoring_oracle():
    """
    Demonstrate the factoring oracle on various composite numbers.
    
    The formal theorem states:
      ∀ n > 1, ¬ Prime n → ∃ a b, a * b = n ∧ a > 1 ∧ b > 1
    
    We show this concretely for several composites.
    """
    print("=" * 65)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 65)
    print()
    
    # --- Part 1: Factoring composite numbers ---
    print("PART 1: Non-trivial factorizations of composite numbers")
    print("-" * 55)
    print(f"{'n':>8}  {'a':>6}  {'b':>8}  {'a*b==n':>8}  {'a>1':>5}  {'b>1':>5}")
    print("-" * 55)
    
    composites = [4, 6, 8, 9, 10, 12, 15, 21, 25, 100, 561, 1001, 1729, 10403]
    for n in composites:
        a, b = nontrivial_factorization(n)
        assert a * b == n and a > 1 and b > 1, "Theorem violated!"
        print(f"{n:>8}  {a:>6}  {b:>8}  {str(a*b == n):>8}  {str(a>1):>5}  {str(b>1):>5}")
    
    print()
    print("✓ All composite numbers successfully factored with a > 1, b > 1.")
    print()
    
    # --- Part 2: Why the ORIGINAL theorem is false ---
    print("PART 2: Why the original theorem fails (primes are counterexamples)")
    print("-" * 55)
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    print(f"Primes up to 31: {primes}")
    print("For each prime p, the ONLY factorizations p = a*b have {a,b} = {1,p}.")
    print("So no a > 1, b > 1 with a*b = p exists. The original theorem is FALSE.")
    print()
    
    # --- Part 3: p-adic valuation landscape ---
    print("PART 3: p-adic valuation landscape (motivation for the conjecture)")
    print("-" * 55)
    print()
    print("The p-adic valuation v_p(n) counts how many times prime p divides n.")
    print("A composite n has v_p(n) ≥ 1 for some p < n, giving a non-trivial factor.")
    print("But a prime n only has v_n(n) = 1 — no smaller prime divides it.")
    print()
    
    n_example = 1729  # Ramanujan's number = 7 × 13 × 19
    print(f"Example: n = {n_example} (Hardy–Ramanujan number)")
    small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23]
    for p in small_primes:
        v = p_adic_valuation(n_example, p)
        marker = " ← factor!" if v > 0 else ""
        print(f"  v_{p}({n_example}) = {v}{marker}")
    
    a, b = nontrivial_factorization(n_example)
    print(f"\n  Factorization: {n_example} = {a} × {b}")
    print(f"  Further: {n_example} = 7 × 13 × 19")
    print()
    
    # --- Part 4: Statistics ---
    print("PART 4: Composite vs Prime density up to N")
    print("-" * 55)
    for N in [10, 100, 1000, 10000]:
        primes_count = sum(1 for k in range(2, N + 1) if smallest_factor(k) == k)
        composites_count = N - 1 - primes_count  # numbers from 2..N, minus primes
        pct = 100 * composites_count / (N - 1)
        print(f"  N={N:>5}: {composites_count:>5} composites, "
              f"{primes_count:>4} primes, "
              f"{pct:.1f}% composite")
    
    print()
    print("As N → ∞, the density of composites → 100% (by the prime number theorem),")
    print("so the oracle applies to 'almost all' integers, but NOT all.")


def main():
    """
    Main entry point.
    
    KEY INSIGHT: The original theorem (every n > 1 factors non-trivially) is
    FALSE because primes exist. The corrected theorem adds the hypothesis
    ¬ Prime n, after which the result follows from the existence of the
    minimal factor via Nat.minFac. This is a cautionary tale about the gap
    between suggestive heuristics (p-adic decompositions) and rigorous proof.
    """
    print()
    print("KEY INSIGHT: Every composite n > 1 has a non-trivial factorization,")
    print("but primes do not. The original conjecture omitted the compositeness")
    print("hypothesis — formal verification in Lean caught this error.")
    print()
    demonstrate_factoring_oracle()
    print()
    print("=" * 65)
    print("  Proof formalized and verified in Lean 4 / Mathlib.")
    print("  Axioms used: propext, Classical.choice, Quot.sound")
    print("=" * 65)


if __name__ == "__main__":
    main()
