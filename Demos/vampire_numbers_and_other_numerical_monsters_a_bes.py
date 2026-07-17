#!/usr/bin/env python3
"""Numerical demonstrations of the modular unit curve for fang pairs."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from math import gcd, isqrt
from typing import Iterable


@dataclass(frozen=True)
class FangCertificate:
    product: int
    x: int
    y: int
    residue_pair: tuple[int, int]
    unit_curve_holds: bool


def digits(n: int, base: int = 10) -> list[int]:
    """Return the standard base-``base`` digits of a nonnegative integer."""
    if base < 2:
        raise ValueError("base must be at least 2")
    if n < 0:
        raise ValueError("n must be nonnegative")
    if n == 0:
        return [0]
    out: list[int] = []
    while n:
        n, digit = divmod(n, base)
        out.append(digit)
    return out


def digit_multiset(n: int, base: int = 10) -> Counter[int]:
    return Counter(digits(n, base))


def is_fang_pair(x: int, y: int, base: int = 10) -> bool:
    """Test exact digit-multiset equality for x*y versus x and y combined."""
    if x <= 0 or y <= 0:
        return False
    return digit_multiset(x * y, base) == digit_multiset(x, base) + digit_multiset(y, base)


def unit_curve_holds(x: int, y: int, base: int = 10) -> bool:
    modulus = base - 1
    return modulus == 1 or ((x - 1) * (y - 1) - 1) % modulus == 0


def unit_curve_points(base: int = 10) -> list[tuple[int, int]]:
    """Enumerate ordered residue pairs on (X-1)(Y-1)=1 mod base-1."""
    if base < 2:
        raise ValueError("base must be at least 2")
    modulus = base - 1
    if modulus == 1:
        return [(0, 0)]
    return [
        (x, y)
        for x in range(modulus)
        for y in range(modulus)
        if ((x - 1) * (y - 1)) % modulus == 1
    ]


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    for d in range(3, isqrt(n) + 1, 2):
        if n % d == 0:
            return False
    return True


def certify_examples(examples: Iterable[tuple[int, int]]) -> list[FangCertificate]:
    certificates: list[FangCertificate] = []
    for x, y in examples:
        if not is_fang_pair(x, y):
            raise ValueError(f"{x}, {y} is not a decimal fang pair")
        certificates.append(
            FangCertificate(
                product=x * y,
                x=x,
                y=y,
                residue_pair=(x % 9, y % 9),
                unit_curve_holds=unit_curve_holds(x, y),
            )
        )
    return certificates


def enumerate_classical_vampires(limit: int) -> dict[int, list[tuple[int, int]]]:
    """Enumerate classical equal-length decimal fang factorizations up to limit."""
    found: dict[int, list[tuple[int, int]]] = {}
    for value in range(10, limit + 1):
        text = str(value)
        if len(text) % 2:
            continue
        half = len(text) // 2
        lower = 10 ** (half - 1)
        upper = 10**half - 1
        pairs: list[tuple[int, int]] = []
        for x in range(lower, min(upper, isqrt(value)) + 1):
            if value % x:
                continue
            y = value // x
            if y > upper or (x % 10 == 0 and y % 10 == 0):
                continue
            # Necessary modular sieve before the digit-multiset test.
            if not unit_curve_holds(x, y, 10):
                continue
            if is_fang_pair(x, y, 10):
                pairs.append((x, y))
        if pairs:
            found[value] = pairs
    return found


def main() -> None:
    examples = [(21, 60), (15, 93), (35, 41), (30, 51), (21, 87), (27, 81), (80, 86)]
    print("Decimal unit-curve points modulo 9:")
    print(unit_curve_points(10))
    print("\nSeven certified fang factorizations:")
    for cert in certify_examples(examples):
        print(
            f"{cert.product} = {cert.x} * {cert.y}; "
            f"residues={cert.residue_pair}; curve={cert.unit_curve_holds}"
        )

    print("\nClassical vampire numbers through 10,000:")
    for value, pairs in enumerate_classical_vampires(10_000).items():
        print(f"{value}: {pairs}")

    prime_points = [
        point for point in unit_curve_points(10)
        if point in {(2, 2), (5, 8), (8, 5)}
    ]
    print("\nPrime-compatible points and product residues:")
    for x_residue, y_residue in prime_points:
        print((x_residue, y_residue), "->", (x_residue * y_residue) % 9)


if __name__ == "__main__":
    main()
