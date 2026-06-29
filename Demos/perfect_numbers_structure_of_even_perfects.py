"""Numerical demonstrations for the abundancy-index framework for perfect numbers.

This script is fully self-contained (standard library only) and uses exact
rational arithmetic via :class:`fractions.Fraction` so that every abundancy
comparison with 2 is exact, not floating point.

Results demonstrated (mirroring the formally verified theorems):
  * abundancy_eq_two_iff_perfect : n perfect  <=>  A(n) = 2
  * abundancy_mul_coprime        : A(m*n) = A(m)*A(n) for coprime m, n
  * abundancy_prime              : A(p) = (p+1)/p
  * prime_deficient              : A(p) < 2 for primes p
  * primePow_deficient           : A(p^k) < 2 for prime powers
  * perfect_not_isPrimePow       : no perfect number is a prime power
  * perfect_sum_reciprocal_divisors : sum_{d|n} 1/d = 2 for perfect n
  * Euclid-Euler form            : 2^(p-1)(2^p - 1) with 2^p - 1 prime
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, isqrt
from typing import List, Tuple


def divisors(n: int) -> List[int]:
    """Return the sorted list of positive divisors of ``n`` (n > 0)."""
    if n <= 0:
        raise ValueError("divisors requires n > 0")
    small: List[int] = []
    large: List[int] = []
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
    return small + large[::-1]


def sigma(n: int) -> int:
    """Sum of all positive divisors of ``n`` (the function sigma_1)."""
    return sum(divisors(n))


def abundancy(n: int) -> Fraction:
    """The abundancy index A(n) = sigma(n)/n as an exact rational."""
    return Fraction(sigma(n), n)


def classify(n: int) -> str:
    """Classify ``n`` as 'deficient', 'perfect', or 'abundant'."""
    a = abundancy(n)
    if a < 2:
        return "deficient"
    if a == 2:
        return "perfect"
    return "abundant"


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    for d in range(3, isqrt(n) + 1, 2):
        if n % d == 0:
            return False
    return True


def is_prime_power(n: int) -> bool:
    """True iff n = p^k for a prime p and k >= 1."""
    if n < 2:
        return False
    for p in range(2, isqrt(n) + 1):
        if n % p == 0:
            m = n
            while m % p == 0:
                m //= p
            return m == 1
    return True  # n is itself prime


def sum_reciprocal_divisors(n: int) -> Fraction:
    """Compute sum_{d | n} 1/d as an exact rational."""
    return sum((Fraction(1, d) for d in divisors(n)), Fraction(0))


def euclid_euler(p: int) -> Tuple[int, bool]:
    """Return (2^(p-1)*(2^p - 1), is_mersenne_prime) for exponent p."""
    mersenne = (1 << p) - 1
    return (1 << (p - 1)) * mersenne, is_prime(mersenne)


def demo() -> None:
    print("=" * 64)
    print("1. Abundancy classification of small integers")
    print("=" * 64)
    for n in range(1, 31):
        print(f"  n={n:2d}  sigma={sigma(n):3d}  A(n)={str(abundancy(n)):>7}  -> {classify(n)}")

    print()
    print("=" * 64)
    print("2. Perfection  <=>  A(n) = 2   (abundancy_eq_two_iff_perfect)")
    print("=" * 64)
    for n in [6, 28, 496, 8128]:
        print(f"  A({n}) = {abundancy(n)}  -> perfect: {abundancy(n) == 2}")

    print()
    print("=" * 64)
    print("3. Multiplicativity on coprime arguments (abundancy_mul_coprime)")
    print("=" * 64)
    for m, n in [(4, 9), (8, 7), (16, 31), (3, 5)]:
        lhs = abundancy(m * n)
        rhs = abundancy(m) * abundancy(n)
        print(f"  gcd({m},{n})={gcd(m,n)}  A({m*n})={lhs}  A({m})A({n})={rhs}  equal: {lhs == rhs}")

    print()
    print("=" * 64)
    print("4. Primes and prime powers are deficient (prime/primePow_deficient)")
    print("=" * 64)
    for p in [2, 3, 5, 7, 11]:
        print(f"  A({p}) = {abundancy(p)} = (p+1)/p,  < 2: {abundancy(p) < 2}")
    for p, k in [(2, 5), (3, 4), (5, 3), (7, 2)]:
        pk = p ** k
        print(f"  A({p}^{k}) = A({pk}) = {abundancy(pk)},  < 2: {abundancy(pk) < 2}")

    print()
    print("=" * 64)
    print("5. No perfect number is a prime power (perfect_not_isPrimePow)")
    print("=" * 64)
    for n in [6, 28, 496, 8128]:
        print(f"  n={n} perfect; is_prime_power: {is_prime_power(n)} (must be False)")

    print()
    print("=" * 64)
    print("6. Reciprocals of divisors sum to 2 (perfect_sum_reciprocal_divisors)")
    print("=" * 64)
    for n in [6, 28, 496]:
        s = sum_reciprocal_divisors(n)
        print(f"  sum_(d|{n}) 1/d = {s}  -> equals 2: {s == 2}")

    print()
    print("=" * 64)
    print("7. Euclid-Euler generator of even perfect numbers")
    print("=" * 64)
    for p in range(2, 20):
        n, ok = euclid_euler(p)
        if ok:
            # Verify perfection directly only for small n (divisor enumeration is
            # O(sqrt(n))); for larger n the Euclid-Euler construction guarantees it.
            verified = abundancy(n) == 2 if n < 10 ** 7 else "by construction"
            print(f"  p={p:2d}: 2^{p-1}*(2^{p}-1) = {n}  (perfect: {verified})")


if __name__ == "__main__":
    demo()
