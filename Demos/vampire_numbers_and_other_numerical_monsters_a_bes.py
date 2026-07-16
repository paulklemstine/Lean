#!/usr/bin/env python3
"""Numerical demonstrations for decimal digit-permutation factorizations."""

from __future__ import annotations

from collections import Counter
from math import isqrt
from typing import Iterable, Iterator, Sequence

UNRESTRICTED_RESIDUE_PAIRS: frozenset[tuple[int, int]] = frozenset(
    {(0, 0), (2, 2), (3, 6), (5, 8), (6, 3), (8, 5)}
)
PRIME_RESIDUE_PAIRS: frozenset[tuple[int, int]] = frozenset(
    {(2, 2), (5, 8), (8, 5)}
)


def digit_signature(n: int) -> tuple[int, ...]:
    """Return the ten-entry decimal digit-frequency vector of n."""
    if n < 0:
        raise ValueError("digit_signature expects a nonnegative integer")
    counts = Counter(str(n))
    return tuple(counts.get(str(digit), 0) for digit in range(10))


def combined_signature(x: int, y: int) -> tuple[int, ...]:
    """Return the coordinatewise sum of the fang digit signatures."""
    return tuple(a + b for a, b in zip(digit_signature(x), digit_signature(y)))


def is_digit_permutation_factorization(x: int, y: int) -> bool:
    """Test whether the digits of x and y together equal those of x*y."""
    if x <= 0 or y <= 0:
        return False
    return combined_signature(x, y) == digit_signature(x * y)


def is_classical_vampire_factorization(x: int, y: int) -> bool:
    """Test equal fang lengths, exact digit preservation, and the zero rule."""
    if len(str(x)) != len(str(y)) or (x % 10 == 0 and y % 10 == 0):
        return False
    product = x * y
    if len(str(product)) != 2 * len(str(x)):
        return False
    return is_digit_permutation_factorization(x, y)


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test for demonstration sizes."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    divisor = 3
    while divisor <= isqrt(n):
        if n % divisor == 0:
            return False
        divisor += 2
    return True


def residue_curve_points(modulus: int = 9) -> list[tuple[int, int]]:
    """Enumerate points satisfying (x-1)(y-1)=1 modulo the modulus."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    return [
        (x, y)
        for x in range(modulus)
        for y in range(modulus)
        if ((x - 1) * (y - 1) - 1) % modulus == 0
    ]


def sieve_primes(limit: int) -> list[int]:
    """Return all primes at most limit using the sieve of Eratosthenes."""
    if limit < 2:
        return []
    flags = bytearray(b"\x01") * (limit + 1)
    flags[0:2] = b"\x00\x00"
    for p in range(2, isqrt(limit) + 1):
        if flags[p]:
            start = p * p
            flags[start : limit + 1 : p] = b"\x00" * (((limit - start) // p) + 1)
    return [n for n, flag in enumerate(flags) if flag]


def find_classical_vampire_witnesses(max_product: int) -> list[tuple[int, int, int]]:
    """Enumerate unordered classical vampire witnesses up to max_product."""
    if max_product < 0:
        raise ValueError("max_product must be nonnegative")
    found: list[tuple[int, int, int]] = []
    max_fang = isqrt(max_product)
    for x in range(1, max_fang + 1):
        digits = len(str(x))
        upper = min(10**digits - 1, max_product // x)
        for y in range(x, upper + 1):
            if (x % 9, y % 9) not in UNRESTRICTED_RESIDUE_PAIRS:
                continue
            if is_classical_vampire_factorization(x, y):
                found.append((x * y, x, y))
    return found


def find_prime_fang_witnesses(fang_digits: int) -> list[tuple[int, int, int]]:
    """Search all prime pairs of a fixed decimal length using residue buckets."""
    if fang_digits < 1:
        raise ValueError("fang_digits must be positive")
    lower = 1 if fang_digits == 1 else 10 ** (fang_digits - 1)
    upper = 10**fang_digits - 1
    primes = [p for p in sieve_primes(upper) if p >= lower]
    found: list[tuple[int, int, int]] = []
    for i, x in enumerate(primes):
        for y in primes[i:]:
            if (x % 9, y % 9) not in PRIME_RESIDUE_PAIRS:
                continue
            if is_digit_permutation_factorization(x, y):
                found.append((x * y, x, y))
    return found


def format_pairs(pairs: Iterable[tuple[int, int]]) -> str:
    """Format residue pairs compactly."""
    return ", ".join(f"({x},{y})" for x, y in pairs)


def main() -> None:
    """Run three reproducible demonstrations of the main results."""
    print("DECIMAL VAMPIRE RESIDUE CURVE")
    points = residue_curve_points(9)
    print("All points modulo 9:", format_pairs(points))
    assert frozenset(points) == UNRESTRICTED_RESIDUE_PAIRS

    prime_points = [pair for pair in points if pair in PRIME_RESIDUE_PAIRS]
    print("Prime-compatible points:", format_pairs(prime_points))
    print("Their product residues:", [x * y % 9 for x, y in prime_points])
    assert all(x * y % 9 == 4 for x, y in prime_points)

    print("\nCLASSICAL EXAMPLE")
    x, y = 21, 60
    print(f"{x * y} = {x} × {y}")
    print("Digit-frequency equality:", combined_signature(x, y), "=", digit_signature(x * y))
    print("Fang residues modulo 9:", (x % 9, y % 9))
    assert is_classical_vampire_factorization(x, y)

    print("\nCLASSICAL SEARCH THROUGH 10,000")
    witnesses = find_classical_vampire_witnesses(10_000)
    for product, left, right in witnesses:
        print(f"{product} = {left} × {right}; residues {(left % 9, right % 9)}")
    assert (1260, 21, 60) in witnesses

    print("\nTWO-DIGIT PRIME-FANG SEARCH")
    prime_witnesses = find_prime_fang_witnesses(2)
    print("Witnesses:", prime_witnesses if prime_witnesses else "none found")
    print("A finite empty search is not an infinitude result; the residue law is only necessary.")


if __name__ == "__main__":
    main()
