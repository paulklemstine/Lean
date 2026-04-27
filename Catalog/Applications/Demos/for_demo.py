#!/usr/bin/env python3
"""
demo.py — Illustrating the (corrected) p-Adic Factoring Oracle theorem.

THEOREM (corrected):
  For every composite n > 1, there exist a, b > 1 such that a * b = n.

This script:
  1. Demonstrates the counterexample to the ORIGINAL (false) theorem:
     n = 2 (prime) has no nontrivial factorization.
  2. Verifies the CORRECTED theorem for all composite numbers up to 100.
  3. Visualizes the factorization structure using a factor lattice.
"""

import math


def is_prime(n: int) -> bool:
    """Check if n is prime."""
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


def find_nontrivial_factorization(n: int):
    """
    Find a, b > 1 with a * b = n, or return None if n is prime.

    This mirrors the Lean proof strategy:
    - Find the smallest divisor k > 1 of n (analogous to Nat.minFac).
    - If k < n, return (k, n // k).
    - If k == n, then n is prime and no factorization exists.
    """
    if n <= 1:
        return None
    for k in range(2, int(math.isqrt(n)) + 1):
        if n % k == 0:
            return (k, n // k)
    return None  # n is prime


def demonstrate_counterexample():
    """
    Show that the ORIGINAL theorem is false.

    The original claim: ∀ n > 1, ∃ a b > 1, a * b = n.
    Counterexample: n = 2 is prime; any a, b > 1 gives a*b ≥ 4 > 2.
    """
    print("=" * 60)
    print("PART 1: Counterexample to the Original (False) Theorem")
    print("=" * 60)
    print()
    print("Original claim: For ALL n > 1, ∃ a, b > 1 with a·b = n.")
    print()

    n = 2
    result = find_nontrivial_factorization(n)
    print(f"  Testing n = {n} (prime = {is_prime(n)}):")
    if result is None:
        print(f"  ✗ No nontrivial factorization exists!")
        print(f"    Proof: if a ≥ 2 and b ≥ 2, then a·b ≥ 4 > 2. Contradiction.")
    print()

    # Show a few more prime counterexamples
    primes = [p for p in range(2, 30) if is_prime(p)]
    print(f"  All primes up to 30 are counterexamples: {primes}")
    print()


def verify_corrected_theorem(limit=100):
    """
    Verify the corrected theorem: every COMPOSITE n > 1 has a nontrivial factorization.

    Corrected claim: For all n > 1 with ¬Prime(n), ∃ a, b > 1 with a·b = n.
    """
    print("=" * 60)
    print("PART 2: Verification of the Corrected Theorem (n ≤ 100)")
    print("=" * 60)
    print()
    print("Corrected claim: For all COMPOSITE n > 1, ∃ a, b > 1 with a·b = n.")
    print()

    composites_checked = 0
    all_verified = True

    for n in range(2, limit + 1):
        if is_prime(n):
            continue  # Skip primes — they are excluded by the hypothesis

        result = find_nontrivial_factorization(n)
        if result is None:
            print(f"  ✗ FAILURE at n = {n}: no factorization found!")
            all_verified = False
        else:
            a, b = result
            assert a * b == n, f"Product check failed: {a} * {b} != {n}"
            assert a > 1 and b > 1, f"Triviality check failed: a={a}, b={b}"
            composites_checked += 1

    print(f"  Checked {composites_checked} composite numbers in [2, {limit}].")
    if all_verified:
        print("  ✓ ALL composite numbers verified! The corrected theorem holds.")
    print()


def display_factorization_table():
    """
    Display a table of smallest nontrivial factorizations.
    
    This corresponds to using Nat.minFac in the Lean proof:
    for composite n, minFac(n) gives the smallest prime factor,
    and (minFac(n), n / minFac(n)) is the factorization witness.
    """
    print("=" * 60)
    print("PART 3: Factorization Witnesses (smallest factor method)")
    print("=" * 60)
    print()
    print(f"  {'n':>4} | {'Status':>10} | {'a':>4} × {'b':>4} = {'n':>4}")
    print(f"  {'-'*4}-+-{'-'*10}-+-{'-'*4}---{'-'*4}---{'-'*4}")

    for n in range(2, 31):
        if is_prime(n):
            print(f"  {n:>4} | {'PRIME':>10} |  (no nontrivial factorization)")
        else:
            result = find_nontrivial_factorization(n)
            if result:
                a, b = result
                print(f"  {n:>4} | {'COMPOSITE':>10} | {a:>4} × {b:>4} = {n:>4}")
    print()


def padic_valuation(n: int, p: int) -> int:
    """
    Compute the p-adic valuation v_p(n).

    While the corrected theorem doesn't require p-adic methods,
    p-adic valuations are central to the original motivation.
    v_p(n) = max{k : p^k | n}.
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_insight():
    """
    Show how p-adic valuations relate to factorization.

    Key insight: if n = a * b, then v_p(n) = v_p(a) + v_p(b) for all primes p.
    This is the fundamental property that makes p-adic methods relevant to factoring.
    """
    print("=" * 60)
    print("PART 4: p-Adic Valuations and Factorization")
    print("=" * 60)
    print()
    print("Key property: v_p(a·b) = v_p(a) + v_p(b)")
    print("This additivity is why p-adic methods are relevant to factoring.")
    print()

    examples = [(12, 2), (12, 3), (60, 2), (60, 3), (60, 5), (1001, 7), (1001, 11), (1001, 13)]
    for n, p in examples:
        v = padic_valuation(n, p)
        print(f"  v_{p}({n}) = {v}", end="")
        result = find_nontrivial_factorization(n)
        if result:
            a, b = result
            va, vb = padic_valuation(a, p), padic_valuation(b, p)
            print(f"    (n = {a}×{b}: v_{p}({a}) + v_{p}({b}) = {va} + {vb} = {va+vb})")
        else:
            print()
    print()


def main():
    """
    Main entry point.

    KEY INSIGHT: The original "p-adic factoring oracle" theorem is FALSE because
    prime numbers cannot be nontrivially factored. The corrected version —
    requiring n to be composite — is a fundamental theorem of arithmetic:
    every composite number has a nontrivial divisor.

    In Lean 4, this is proved using Nat.exists_dvd_of_not_prime2, which extracts
    a divisor k with 1 < k < n from the assumption that n > 1 is not prime.
    """
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     NON-ARCHIMEDEAN FACTORING ORACLE — DEMONSTRATION   ║")
    print("╠══════════════════════════════════════════════════════════╣")
    print("║  Original theorem: FALSE (primes are counterexamples)  ║")
    print("║  Corrected theorem: TRUE (for composite numbers)       ║")
    print("║  Both formally verified in Lean 4 / Mathlib            ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demonstrate_counterexample()
    verify_corrected_theorem()
    display_factorization_table()
    padic_insight()

    print("=" * 60)
    print("CONCLUSION")
    print("=" * 60)
    print()
    print("The formal Lean proof demonstrates two facts:")
    print("  1. pAdic_factoring_oracle_false: The original statement is")
    print("     disprovable — n=2 (with p=2) is a counterexample.")
    print("  2. pAdic_factoring_oracle_corrected: Adding ¬Prime(n) as a")
    print("     hypothesis makes the theorem true and provable.")
    print()
    print("This illustrates the power of formal verification: catching")
    print("a false conjecture before it enters the mathematical literature.")
    print()


if __name__ == "__main__":
    main()
