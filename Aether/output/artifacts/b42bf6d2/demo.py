#!/usr/bin/env python3
"""
demo.py — Non-Archimedean Factoring Oracle: Numerical Illustration

This script demonstrates the corrected factoring oracle theorem:
    Every composite number n > 1 admits a nontrivial factorization a * b = n
    with a > 1 and b > 1.

It also illustrates the p-adic valuation perspective on factoring,
showing how the p-adic valuation v_p(n) reveals prime factor structure.

The formal Lean proof uses Nat.exists_dvd_of_not_prime2 to extract a
nontrivial divisor of any composite number, then constructs the
complementary factor via integer division.
"""

import math
from typing import List, Tuple


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


def smallest_nontrivial_factor(n: int) -> int:
    """
    Find the smallest factor k of n with 1 < k < n.
    This mirrors Lean's Nat.minFac, which is the key to the formal proof:
    Nat.exists_dvd_of_not_prime2 guarantees such a k exists for composite n.
    """
    if n <= 1:
        raise ValueError("n must be > 1")
    for k in range(2, int(math.isqrt(n)) + 1):
        if n % k == 0:
            return k
    return n  # n is prime; no nontrivial factor


def factoring_oracle(n: int) -> Tuple[int, int]:
    """
    The factoring oracle: given composite n > 1, return (a, b) with
    a * b = n, a > 1, b > 1.

    This is the computational analogue of pAdic_factoring_oracle_corrected.
    """
    if n <= 1:
        raise ValueError("n must be > 1")
    if is_prime(n):
        raise ValueError(f"{n} is prime — no nontrivial factorization exists")

    k = smallest_nontrivial_factor(n)
    return (k, n // k)


def p_adic_valuation(n: int, p: int) -> int:
    """
    Compute v_p(n), the p-adic valuation of n.
    This is the exponent of p in the prime factorization of n.
    The p-adic perspective motivates the "non-Archimedean" framing:
    in Q_p, the size of n is determined by how divisible it is by p.
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def prime_factorization(n: int) -> List[Tuple[int, int]]:
    """Return the prime factorization of n as a list of (prime, exponent) pairs."""
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            exp = 0
            while n % d == 0:
                exp += 1
                n //= d
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors


def main():
    """
    Main demonstration: illustrate the factoring oracle theorem.

    KEY INSIGHT: The theorem pAdic_factoring_oracle_corrected proves that
    compositeness is a *sufficient* condition for nontrivial factorization.
    The original (false) statement omitted this hypothesis, claiming even
    primes could be split — which formal verification immediately caught.
    """
    print("=" * 70)
    print("  NON-ARCHIMEDEAN FACTORING ORACLE — Numerical Demonstration")
    print("=" * 70)

    # --- Part 1: Demonstrate the corrected theorem ---
    print("\n📐 PART 1: Factoring Oracle for Composite Numbers\n")
    print("Theorem: ∀ n > 1, ¬Prime(n) → ∃ a b > 1, a * b = n\n")

    test_composites = [4, 6, 9, 12, 15, 21, 35, 100, 143, 1001, 2023, 10403]
    for n in test_composites:
        a, b = factoring_oracle(n)
        assert a * b == n and a > 1 and b > 1, "Oracle invariant violated!"
        print(f"  n = {n:>6}  →  {a} × {b} = {n}")

    # --- Part 2: Show primes are the obstruction ---
    print("\n🚫 PART 2: Primes Have No Nontrivial Factorization\n")
    print("These are why the ORIGINAL statement was FALSE:\n")
    test_primes = [2, 3, 5, 7, 11, 13, 97, 101, 1009]
    for p in test_primes:
        assert is_prime(p)
        print(f"  n = {p:>5}  →  PRIME (only 1 × {p}, no a,b > 1)")

    # --- Part 3: p-adic valuation perspective ---
    print("\n🔬 PART 3: p-Adic Valuation Structure\n")
    print("The 'non-Archimedean' perspective: v_p(n) reveals factor structure.\n")

    n = 360  # = 2^3 * 3^2 * 5
    primes_to_check = [2, 3, 5, 7]
    print(f"  n = {n} = {' × '.join(f'{p}^{e}' for p, e in prime_factorization(n))}")
    print()
    for p in primes_to_check:
        v = p_adic_valuation(n, p)
        bar = "█" * v + "░" * (5 - v)
        print(f"  v_{p}({n}) = {v}  [{bar}]")

    # --- Part 4: Factoring as iterated oracle ---
    print("\n🔄 PART 4: Complete Factorization via Iterated Oracle\n")
    print("Repeatedly apply the oracle until all factors are prime:\n")

    n = 2310  # = 2 * 3 * 5 * 7 * 11
    print(f"  Start: n = {n}")
    stack = [n]
    primes_found = []
    step = 0
    while stack:
        current = stack.pop()
        if is_prime(current):
            primes_found.append(current)
            continue
        a, b = factoring_oracle(current)
        step += 1
        print(f"  Step {step}: {current} = {a} × {b}")
        stack.extend([a, b])

    primes_found.sort()
    product = math.prod(primes_found)
    print(f"\n  Result: {n} = {' × '.join(map(str, primes_found))}")
    print(f"  Verification: product = {product} ✓" if product == n else "  ERROR!")

    # --- Summary ---
    print("\n" + "=" * 70)
    print("  KEY INSIGHT")
    print("=" * 70)
    print("""
  The original theorem claimed ALL n > 1 factor nontrivially — FALSE!
  Primes are the precise obstruction. The corrected theorem adds the
  hypothesis ¬Prime(n), and the Lean proof extracts a nontrivial
  divisor via Nat.exists_dvd_of_not_prime2, then constructs the
  complementary factor by division.

  Formal verification caught this specification error immediately:
  no amount of p-adic machinery can factor a prime number.
""")


if __name__ == "__main__":
    main()
