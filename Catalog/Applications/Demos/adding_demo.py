#!/usr/bin/env python3
"""
demo.py — Numerical illustration of the Non-Archimedean Factoring Oracle theorem.

This script demonstrates:
1. The original conjecture is FALSE: primes cannot be non-trivially factored.
2. The corrected theorem is TRUE: every composite n > 1 has a non-trivial factorization.
3. A simple factoring oracle based on smallest-factor extraction (the constructive
   content of the formal proof using Nat.exists_dvd_of_not_prime2).

Links to the formal proof:
- The counterexample theorem (pAdic_factoring_oracle_counterexample) shows ¬∀ n>1, ...
- The corrected theorem (pAdic_factoring_oracle_corrected) adds ¬Prime(n) as hypothesis.
"""

import math


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


def smallest_nontrivial_factor(n: int) -> int:
    """
    Find the smallest factor k of n with 1 < k < n.
    This mirrors Nat.minFac in Mathlib, which is used in the formal proof
    via Nat.exists_dvd_of_not_prime2.
    """
    if n <= 1:
        raise ValueError("n must be > 1")
    for k in range(2, int(math.isqrt(n)) + 1):
        if n % k == 0:
            return k
    return n  # n is prime


def factoring_oracle(n: int):
    """
    The corrected factoring oracle: given composite n > 1, return (a, b)
    with a > 1, b > 1, a * b = n.

    This is the computational content of pAdic_factoring_oracle_corrected.
    """
    if n <= 1:
        raise ValueError("n must be > 1")
    if is_prime(n):
        raise ValueError(f"n = {n} is prime — no non-trivial factorization exists "
                         "(this is exactly what the counterexample theorem proves)")

    k = smallest_nontrivial_factor(n)
    a, b = k, n // k
    assert a * b == n, "Factorization check failed"
    assert a > 1 and b > 1, "Non-triviality check failed"
    return a, b


def main():
    print("=" * 65)
    print("  Non-Archimedean Factoring Oracle — Numerical Demonstration")
    print("=" * 65)

    # --- Part 1: Demonstrate the counterexample ---
    print("\n[1] COUNTEREXAMPLE: The original theorem is FALSE for primes.")
    print("    For any prime p, there are no a,b > 1 with a*b = p.")
    print()

    primes = [2, 3, 5, 7, 11, 13, 97, 101]
    for p in primes:
        # Check that no a,b > 1 satisfy a*b = p
        found = False
        for a in range(2, p):
            if p % a == 0:
                b = p // a
                if b > 1:
                    found = True
                    break
        status = "FACTORED (unexpected!)" if found else "NO factorization (as expected)"
        print(f"    n = {p:>4d} (prime):  {status}")

    # --- Part 2: Demonstrate the corrected theorem ---
    print("\n[2] CORRECTED THEOREM: Every composite n > 1 has a non-trivial factorization.")
    print()

    composites = [4, 6, 8, 9, 10, 12, 15, 21, 35, 77, 100, 1001, 2023, 9991]
    for n in composites:
        a, b = factoring_oracle(n)
        print(f"    n = {n:>5d}  →  {a} × {b} = {a*b}  ✓")

    # --- Part 3: The key insight ---
    print("\n" + "=" * 65)
    print("  KEY INSIGHT")
    print("=" * 65)
    print("""
    The original "p-adic factoring oracle" theorem claimed that EVERY
    integer n > 1 can be written as a product of two factors each > 1.
    This is false — primes are the obstruction.

    The corrected theorem adds the hypothesis ¬Prime(n), after which
    the result follows constructively: extract the minimal factor k
    of n (with 1 < k < n), and set a = k, b = n/k.

    No p-adic machinery is needed for the corrected statement — the
    proof is purely number-theoretic. The formal Lean 4 proof uses
    Nat.exists_dvd_of_not_prime2 from Mathlib.
    """)


if __name__ == "__main__":
    main()
