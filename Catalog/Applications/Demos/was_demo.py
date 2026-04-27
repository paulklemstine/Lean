#!/usr/bin/env python3
"""
demo.py — Numerical illustration of the Non-Archimedean Factoring Oracle theorem.

This script demonstrates the corrected theorem:
  Every integer n > 1 is either prime or has a non-trivial factorization a * b = n
  with a > 1 and b > 1.

It also illustrates the p-adic valuation perspective that motivated the original
(incorrect) theorem statement, showing how p-adic valuations detect factors.

Usage: python3 demo.py
"""

import math
from collections import defaultdict


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


def smallest_factor(n: int) -> int:
    """Find the smallest factor > 1 of n (analogous to Nat.minFac in Mathlib)."""
    if n <= 1:
        return n
    if n % 2 == 0:
        return 2
    i = 3
    while i * i <= n:
        if n % i == 0:
            return i
        i += 2
    return n


def p_adic_valuation(n: int, p: int) -> int:
    """
    Compute v_p(n), the p-adic valuation of n.
    This is the exponent of p in the prime factorization of n.
    In the p-adic world, large valuation means "small" — a key insight
    that inverts our usual notion of size.
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def factorize(n: int) -> dict:
    """Return prime factorization as {prime: exponent} dict."""
    factors = defaultdict(int)
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] += 1
            n //= d
        d += 1
    if n > 1:
        factors[n] += 1
    return dict(factors)


def demonstrate_dichotomy(n: int) -> str:
    """
    Demonstrate the corrected theorem for a specific n > 1.
    Returns a string describing the result.

    This corresponds to the Lean theorem:
      pAdic_factoring_oracle_corrected: Nat.Prime n ∨ ∃ a b, a * b = n ∧ a > 1 ∧ b > 1
    """
    assert n > 1, f"Requires n > 1, got {n}"

    if is_prime(n):
        return f"  n = {n}: PRIME (left disjunct — no non-trivial factorization exists)"
    else:
        # This is the composite case: find the non-trivial factorization
        # We use the smallest factor, mirroring Mathlib's Nat.minFac
        a = smallest_factor(n)
        b = n // a
        assert a * b == n and a > 1 and b > 1, "Factorization invariant violated!"
        return f"  n = {n}: COMPOSITE, {n} = {a} × {b} (right disjunct)"


def demonstrate_padic_perspective(n: int, primes: list) -> None:
    """
    Show how p-adic valuations reveal the structure of n.

    The original theorem was motivated by the idea that p-adic analysis
    (Newton polygons, Hensel lifting) could serve as a "factoring oracle."
    While the existence of factorizations is elementary, the p-adic viewpoint
    does provide genuine algorithmic insight for polynomial factoring.
    """
    print(f"\n  p-adic profile of n = {n}:")
    factors = factorize(n)
    print(f"  Prime factorization: {n} = ", end="")
    terms = [f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(factors.items())]
    print(" × ".join(terms))

    for p in primes:
        v = p_adic_valuation(n, p)
        # In Q_p, |n|_p = p^(-v_p(n))
        padic_abs = f"p^(-{v})" if v > 0 else "1"
        bar = "█" * v + "░" * (8 - v) if v <= 8 else "█" * 8 + "+"
        print(f"  v_{p}({n}) = {v}  |{n}|_{p} = {padic_abs}  {bar}")


def main():
    """
    Main demonstration of the Non-Archimedean Factoring Oracle theorem.

    KEY INSIGHT: The original theorem claimed every n > 1 has a non-trivial
    factorization. This is FALSE — primes are the counterexample. The corrected
    theorem states the fundamental dichotomy: every n > 1 is either prime or
    composite (with witness factorization). This was formally verified in Lean 4.
    """
    print("=" * 70)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 70)

    # Part 1: The prime/composite dichotomy
    print("\n─── PART 1: Prime-or-Composite Dichotomy (Corrected Theorem) ───\n")
    print("For each n > 1, we verify: Nat.Prime n ∨ ∃ a b > 1, a * b = n\n")

    test_values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 17, 21, 25, 30, 37, 42, 100]
    for n in test_values:
        print(demonstrate_dichotomy(n))

    # Part 2: Why the original theorem is false
    print("\n─── PART 2: Counterexample to Original Claim ───\n")
    print("The original theorem claimed: ∀ n > 1, ∃ a b > 1, a * b = n")
    print("Counterexample: n = 2 is prime.")
    print("  There are NO a, b > 1 with a * b = 2.")
    print("  Proof: if a ≥ 2 and b ≥ 2, then a * b ≥ 4 > 2. ∎")

    # Part 3: p-adic perspective
    print("\n─── PART 3: p-Adic Valuation Perspective ───\n")
    print("The p-adic valuation v_p(n) counts how many times p divides n.")
    print("In Q_p, 'divisible by p' means 'small' — an inverted perspective.")

    composites = [12, 30, 60, 210, 2310]  # Products of first k primes
    small_primes = [2, 3, 5, 7]
    for n in composites:
        demonstrate_padic_perspective(n, small_primes)

    # Part 4: Statistics
    print("\n─── PART 4: Prime vs Composite Statistics ───\n")
    N = 1000
    primes = sum(1 for n in range(2, N + 1) if is_prime(n))
    composites = N - 1 - primes  # n from 2 to N: total N-1 numbers
    print(f"Among integers from 2 to {N}:")
    print(f"  Primes (left disjunct):    {primes:4d} ({100*primes/(N-1):.1f}%)")
    print(f"  Composites (right disjunct): {composites:4d} ({100*composites/(N-1):.1f}%)")
    print(f"  Prime Number Theorem: π({N}) ≈ {N}/ln({N}) = {N/math.log(N):.1f}")

    print("\n" + "=" * 70)
    print("  KEY INSIGHT: The theorem's truth depends critically on excluding")
    print("  primes. Formal verification in Lean 4 caught this error, which")
    print("  demonstrates the power of machine-checked mathematics.")
    print("=" * 70)


if __name__ == "__main__":
    main()
