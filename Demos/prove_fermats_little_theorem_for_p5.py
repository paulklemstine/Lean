"""Numerical demonstrations for the divisibility structure of a^5 - a.

This self-contained script demonstrates the main results:

  * 5  | a^5 - a          (divisibility by five)
  * 30 | a^5 - a          (sharpened modulus, and 30 is maximal: D(5) = 30)
  * a^5 = (a-1)a(a+1)(a^2+1)   (structural factorization)
  * a^5 = a  (mod 10)     (last-digit stability, and its iterates)
  * p | a^p - a           (Fermat's Little Theorem, additive form)
  * D(n) = product of primes p with (p-1) | (n-1)   (universal denominator)

Run with:  python demo.py
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import List


def defect(a: int, n: int = 5) -> int:
    """Return a^n - a, the divisibility 'defect'."""
    return a ** n - a


def divides(m: int, x: int) -> bool:
    """Return True iff m divides x."""
    return x % m == 0


def check_five(lo: int = -20, hi: int = 20) -> bool:
    """Verify 5 | a^5 - a for every integer a in [lo, hi]."""
    return all(divides(5, defect(a)) for a in range(lo, hi + 1))


def check_thirty(lo: int = -20, hi: int = 20) -> bool:
    """Verify 30 | a^5 - a for every integer a in [lo, hi]."""
    return all(divides(30, defect(a)) for a in range(lo, hi + 1))


def check_factorization(lo: int = -20, hi: int = 20) -> bool:
    """Verify a^5 - a = (a-1) a (a+1) (a^2 + 1) for a in [lo, hi]."""
    return all(
        defect(a) == (a - 1) * a * (a + 1) * (a * a + 1)
        for a in range(lo, hi + 1)
    )


def check_last_digit(lo: int = -20, hi: int = 20) -> bool:
    """Verify a^5 ends in the same decimal digit as a, i.e. a^5 = a (mod 10)."""
    return all((a ** 5) % 10 == a % 10 for a in range(lo, hi + 1))


def check_iterated_last_digit(iterations: int = 4) -> bool:
    """Verify that iterating x -> x^5 (mod 10) fixes every residue class."""
    for r in range(10):
        x = r
        for _ in range(iterations):
            x = (x ** 5) % 10
        if x != r:
            return False
    return True


def universal_denominator(n: int, prime_bound: int = 200) -> int:
    """Compute D(n) = product of primes p (<= prime_bound) with (p-1) | (n-1).

    D(n) is the largest integer dividing a^n - a for every integer a.
    """
    def is_prime(p: int) -> bool:
        if p < 2:
            return False
        return all(p % d for d in range(2, int(p ** 0.5) + 1))

    primes = [p for p in range(2, prime_bound + 1) if is_prime(p)]
    factors = [p for p in primes if (n - 1) % (p - 1) == 0]
    return reduce(lambda x, y: x * y, factors, 1)


def empirical_universal_denominator(n: int, lo: int = 0, hi: int = 50) -> int:
    """Estimate D(n) as gcd of a^n - a over a range (matches the true value)."""
    values = [defect(a, n) for a in range(lo, hi + 1) if defect(a, n) != 0]
    return reduce(gcd, values)


def check_fermat_little(primes: List[int], lo: int = -10, hi: int = 10) -> bool:
    """Verify p | a^p - a for each prime in `primes` over a in [lo, hi]."""
    return all(
        divides(p, a ** p - a)
        for p in primes
        for a in range(lo, hi + 1)
    )


def main() -> None:
    print("=" * 60)
    print("Divisibility structure of a^5 - a")
    print("=" * 60)

    print("\n[1] Table of defects a^5 - a for a = 0..8:")
    row = [defect(a) for a in range(9)]
    print("   ", row)
    print("    all divisible by 30:", all(divides(30, v) for v in row))

    print("\n[2] 5 | a^5 - a   on [-20, 20]:", check_five())
    print("[3] 30 | a^5 - a  on [-20, 20]:", check_thirty())
    print("[4] factorization a^5-a=(a-1)a(a+1)(a^2+1):",
          check_factorization())

    print("\n[5] last-digit stability a^5 = a (mod 10):", check_last_digit())
    print("    iterated fifth power fixes last digit:",
          check_iterated_last_digit())

    print("\n[6] Fermat's Little Theorem p | a^p - a for p in {2,3,5,7,11,13}:")
    print("   ", check_fermat_little([2, 3, 5, 7, 11, 13]))

    print("\n[7] Universal denominators D(n):")
    for n in range(2, 12):
        d_theory = universal_denominator(n)
        d_empirical = empirical_universal_denominator(n)
        agree = "OK" if d_theory == d_empirical else "MISMATCH"
        print(f"    D({n:2d}) = {d_theory:6d}  (empirical {d_empirical:6d})  {agree}")

    print("\n    Notable: D(5) = 30, D(3) = 6, D(7) = 42 (no factor 5).")
    print("=" * 60)


if __name__ == "__main__":
    main()
