#!/usr/bin/env python3
"""Exact numerical demonstrations for canonical dyadic surreal arithmetic.

A pair (m, n) denotes the value m / 2**n.  The program uses integers only:
there is no floating-point arithmetic in equality or ring operations.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import gcd
from typing import Iterable


@dataclass(frozen=True, order=False)
class Dyadic:
    """A normalized dyadic rational m / 2**n with n nonnegative."""

    numerator: int
    exponent: int

    def __post_init__(self) -> None:
        if self.exponent < 0:
            raise ValueError("the denominator exponent must be nonnegative")
        m, n = normalize_pair(self.numerator, self.exponent)
        object.__setattr__(self, "numerator", m)
        object.__setattr__(self, "exponent", n)

    def __str__(self) -> str:
        return f"{self.numerator}/2^{self.exponent}"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Dyadic):
            return NotImplemented
        return cross_multiply_equal(
            self.numerator, self.exponent, other.numerator, other.exponent
        )

    def __hash__(self) -> int:
        return hash((self.numerator, self.exponent))

    def __add__(self, other: Dyadic) -> Dyadic:
        scale = max(self.exponent, other.exponent)
        total = (self.numerator << (scale - self.exponent)) + (
            other.numerator << (scale - other.exponent)
        )
        return Dyadic(total, scale)

    def __mul__(self, other: Dyadic) -> Dyadic:
        return Dyadic(
            self.numerator * other.numerator,
            self.exponent + other.exponent,
        )

    def reciprocal_if_dyadic(self) -> Dyadic | None:
        """Return the reciprocal when it remains dyadic, otherwise None."""
        if self.numerator == 0:
            return None
        m, n = normalize_pair(self.numerator, self.exponent)
        if abs(m) != 1:
            return None
        return Dyadic((1 if m > 0 else -1) << n, 0)

    def decimal(self, digits: int = 8) -> str:
        return f"{self.numerator / (1 << self.exponent):.{digits}f}"


def normalize_pair(numerator: int, exponent: int) -> tuple[int, int]:
    """Remove common factors of two and return the unique reduced pair."""
    if exponent < 0:
        raise ValueError("the denominator exponent must be nonnegative")
    if numerator == 0:
        return (0, 0)
    while exponent > 0 and numerator % 2 == 0:
        numerator //= 2
        exponent -= 1
    return (numerator, exponent)


def cross_multiply_equal(m1: int, n1: int, m2: int, n2: int) -> bool:
    """Test m1/2**n1 = m2/2**n2 by the proved integer criterion."""
    if n1 < 0 or n2 < 0:
        raise ValueError("exponents must be nonnegative")
    return (m1 << n2) == (m2 << n1)


def canonical_unit_birthday(exponent: int) -> int:
    """Birthday of the canonical representative of 2**(-exponent)."""
    if exponent < 0:
        raise ValueError("the exponent must be nonnegative")
    return exponent + 1


def inverse_obstruction(odd_integer: int, max_exponent: int) -> list[tuple[int, int]]:
    """Return (n, 2**n mod odd_integer), exposing failed divisibility."""
    if odd_integer <= 1 or odd_integer % 2 == 0:
        raise ValueError("choose an odd integer greater than one")
    return [(n, pow(2, n, odd_integer)) for n in range(max_exponent + 1)]


def binary_grid(level: int) -> Iterable[Dyadic]:
    """Generate the dyadic subdivision of [0, 1] at a selected level."""
    if level < 0:
        raise ValueError("the level must be nonnegative")
    return (Dyadic(k, level) for k in range((1 << level) + 1))


def main() -> None:
    print("CANONICAL UNITS AND BIRTHDAYS")
    for n in range(8):
        unit = Dyadic(1, n)
        print(f"2^-{n:<2} = {unit.decimal(8):>10}; birthday = {canonical_unit_birthday(n)}")

    print("\nCROSS-MULTIPLICATION EQUALITY")
    examples = [(6, 4, 3, 3), (5, 3, 3, 2), (-10, 4, -5, 3)]
    for m1, n1, m2, n2 in examples:
        left = m1 << n2
        right = m2 << n1
        relation = "=" if left == right else "≠"
        print(f"{m1}/2^{n1} and {m2}/2^{n2}: {left} {relation} {right}")

    print("\nEXACT RING ARITHMETIC")
    x, y = Dyadic(3, 3), Dyadic(5, 4)
    print(f"{x} + {y} = {x + y}")
    print(f"{x} × {y} = {x * y}")
    print(f"normalizing 12/2^5 gives {Dyadic(12, 5)}")

    print("\nWHY THREE HAS NO DYADIC INVERSE")
    residues = inverse_obstruction(3, 12)
    print("residues 2^n mod 3:", [residue for _, residue in residues])
    print("No residue is 0, so no equation 3m = 2^n can hold.")
    print("reciprocal of 3 in dyadics:", Dyadic(3, 0).reciprocal_if_dyadic())
    print("reciprocal of 1/8 in dyadics:", Dyadic(1, 3).reciprocal_if_dyadic())

    print("\nLEVEL-3 BINARY GRID")
    print(", ".join(str(value) for value in binary_grid(3)))


if __name__ == "__main__":
    main()
