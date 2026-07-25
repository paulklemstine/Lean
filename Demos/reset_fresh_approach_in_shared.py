#!/usr/bin/env python3
"""Numerical demonstrations of Fibonacci gcd transport and synchronization.

The script uses only Python's standard library.  It computes Fibonacci numbers by
fast doubling, verifies finite gcd transport on representative families, finds
primitive prime divisors for modest indices, and demonstrates the exact
apparition and finite-family synchronization laws at q = 13 and q = 17.
"""

from __future__ import annotations

from functools import reduce
from math import gcd, isqrt
from typing import Iterable, Sequence


def fib(n: int) -> int:
    """Return F_n in O(log n) big-integer multiplication steps."""
    if n < 0:
        raise ValueError("Fibonacci indices must be nonnegative")

    def pair(k: int) -> tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = pair(k // 2)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if k % 2 else (c, d)

    return pair(n)[0]


def gcd_all(values: Iterable[int]) -> int:
    """Return the gcd of a finite iterable, using gcd(empty) = 0."""
    return reduce(gcd, values, 0)


def fibonacci_family_gcd(indices: Sequence[int]) -> int:
    """Compute gcd(F_n : n in indices) through the gcd of the indices."""
    if any(n < 0 for n in indices):
        raise ValueError("indices must be nonnegative")
    return fib(gcd_all(indices))


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test for demonstration sizes."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d <= isqrt(n):
        if n % d == 0:
            return False
        d += 2
    return True


def prime_factors(n: int) -> list[int]:
    """Return the distinct prime factors of a positive integer."""
    if n < 1:
        raise ValueError("factorization input must be positive")
    factors: list[int] = []
    d = 2
    while d <= isqrt(n):
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d = 3 if d == 2 else d + 2
    if n > 1:
        factors.append(n)
    return factors


def primitive_prime_divisors(n: int) -> list[int]:
    """Find prime factors of F_n that divide no earlier positive F_k."""
    if n <= 0:
        return []
    result: list[int] = []
    for p in prime_factors(fib(n)):
        if all(fib(k) % p != 0 for k in range(1, n)):
            result.append(p)
    return result


def exact_apparition_check(q: int, p: int, limit: int) -> bool:
    """Check p | F_m iff q | m for 0 <= m <= limit."""
    return all((fib(m) % p == 0) == (m % q == 0) for m in range(limit + 1))


def synchronization_check(q: int, p: int, indices: Sequence[int]) -> bool:
    """Check the synchronization equivalence for one finite family."""
    value_gcd = gcd_all(fib(n) for n in indices)
    index_gcd = gcd_all(indices)
    return (value_gcd % p == 0) == (index_gcd % q == 0)


def print_transport_demo() -> None:
    families: list[list[int]] = [[], [0, 26, 52], [18, 30, 42], [26, 39, 65]]
    print("Finite GCD Transport")
    for indices in families:
        direct = gcd_all(fib(n) for n in indices)
        transported = fibonacci_family_gcd(indices)
        print(
            f"  S={indices}: gcd(indices)={gcd_all(indices)}, "
            f"direct gcd={direct}, F_gcd={transported}, equal={direct == transported}"
        )


def print_apparition_demo() -> None:
    print("\nExact Prime-Index Apparition")
    for q in (13, 17):
        primitive = primitive_prime_divisors(q)
        p = primitive[0]
        multiples = [m for m in range(0, 4 * q + 1) if fib(m) % p == 0]
        print(
            f"  q={q}, primitive p={p}: observed indices={multiples}; "
            f"exact through {4*q}: {exact_apparition_check(q, p, 4*q)}"
        )


def print_synchronization_demo() -> None:
    q, p = 13, 233
    families: list[list[int]] = [[], [26, 39, 65], [26, 39, 66], [0, 26, 52]]
    print("\nFinite-Family Synchronization for q=13 and p=233")
    for indices in families:
        ig = gcd_all(indices)
        vg = gcd_all(fib(n) for n in indices)
        print(
            f"  S={indices}: gcd(S)={ig}, q|gcd(S)={ig % q == 0}, "
            f"p|gcd(F_n)={vg % p == 0}, theorem={synchronization_check(q, p, indices)}"
        )


def main() -> None:
    print_transport_demo()
    print_apparition_demo()
    print_synchronization_demo()


if __name__ == "__main__":
    main()
