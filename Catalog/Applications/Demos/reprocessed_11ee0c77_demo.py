#!/usr/bin/env python3
"""
Non-Archimedean Factoring Oracle — Numerical Demonstration

This script illustrates the key insight of the formal proof:
  - The original claim (every n > 1 has a non-trivial factorization) is FALSE.
  - The corrected claim (every COMPOSITE n > 1 has one) is TRUE.

We demonstrate this by testing all integers from 2 to 100, showing which ones
are prime (counterexamples to the original claim) and which are composite
(where the oracle succeeds).

We also visualize the minimal-factor decomposition used in the Lean proof.
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


def min_factor(n: int) -> int:
    """
    Find the minimal factor > 1 of n.
    This mirrors Nat.minFac in Mathlib, which is the key ingredient
    in the corrected theorem's proof.
    """
    if n < 2:
        return n
    if n % 2 == 0:
        return 2
    i = 3
    while i * i <= n:
        if n % i == 0:
            return i
        i += 2
    return n


def factoring_oracle(n: int):
    """
    Attempt to produce a non-trivial factorization of n.

    Returns (a, b) with a * b = n and a > 1 and b > 1 if n is composite,
    or None if n is prime (the original theorem is false for primes).

    The proof strategy mirrors the Lean formalization:
      1. Find k = minFactor(n)  [via Nat.exists_dvd_of_not_prime2]
      2. Set a = k, b = n // k
      3. Both a > 1 and b > 1 are guaranteed for composite n
    """
    if n <= 1 or is_prime(n):
        return None  # No non-trivial factorization exists

    k = min_factor(n)
    return (k, n // k)


def main():
    print("=" * 70)
    print("NON-ARCHIMEDEAN FACTORING ORACLE — DEMONSTRATION")
    print("=" * 70)
    print()

    # Key insight: the original theorem is false
    print("KEY INSIGHT: The original theorem claims every n > 1 has a")
    print("non-trivial factorization (a * b = n with a, b > 1).")
    print("This is FALSE — primes are counterexamples.")
    print()

    # Demonstrate the counterexample from the formal disproof
    print("FORMAL DISPROOF (n = 2):")
    print(f"  n = 2, is_prime(2) = {is_prime(2)}")
    print(f"  For any a, b > 1: a >= 2, b >= 2, so a*b >= 4 > 2. Contradiction!")
    print(f"  factoring_oracle(2) = {factoring_oracle(2)}")
    print()

    # Test the corrected theorem on composites
    print("CORRECTED THEOREM: Every composite n > 1 has a non-trivial factorization.")
    print()

    N = 50
    primes = []
    composites = []

    for n in range(2, N + 1):
        result = factoring_oracle(n)
        if result is None:
            primes.append(n)
        else:
            a, b = result
            assert a * b == n, f"Factorization error: {a} * {b} != {n}"
            assert a > 1 and b > 1, f"Trivial factor: {a}, {b}"
            composites.append((n, a, b))

    print(f"Primes (counterexamples to original claim): {primes}")
    print(f"  Count: {len(primes)} primes in [2, {N}]")
    print()

    print("Composite factorizations (corrected theorem holds):")
    print(f"  {'n':>4} = {'a':>4} × {'b':>4}  (via minFactor)")
    print(f"  {'─'*4}   {'─'*4}   {'─'*4}")
    for n, a, b in composites[:20]:
        print(f"  {n:>4} = {a:>4} × {b:>4}")
    if len(composites) > 20:
        print(f"  ... and {len(composites) - 20} more")
    print()

    # Verify exhaustively that the corrected theorem holds
    print(f"VERIFICATION: Tested all n in [2, 10000]")
    all_correct = True
    for n in range(2, 10001):
        if not is_prime(n):
            result = factoring_oracle(n)
            if result is None:
                print(f"  FAILURE at n = {n}")
                all_correct = False
                break
            a, b = result
            if a * b != n or a <= 1 or b <= 1:
                print(f"  INVALID factorization at n = {n}: {a} * {b}")
                all_correct = False
                break
    if all_correct:
        print("  ✓ All composite numbers in range have valid non-trivial factorizations")
    print()

    # Show the connection to p-adic ideas
    print("P-ADIC CONNECTION:")
    print("  The theorem is parameterized by a prime p (unused in the corrected")
    print("  version). In the p-adic approach, one would lift factorizations from")
    print("  Z/pZ to Z_p via Hensel's lemma. The corrected theorem shows that")
    print("  composite numbers always admit such factorizations, but the p-adic")
    print("  structure is not needed for the existence result — only for")
    print("  algorithmic efficiency.")
    print()
    print("=" * 70)
    print("CONCLUSION: Formal verification caught a false theorem statement.")
    print("The corrected version is proven in Lean 4 with Mathlib.")
    print("=" * 70)


if __name__ == "__main__":
    main()
