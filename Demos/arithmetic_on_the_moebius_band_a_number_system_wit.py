#!/usr/bin/env python3
"""Exact numerical demonstrations for arithmetic proposed on a Möbius quotient."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import isqrt
from typing import Callable, Iterable


@dataclass(frozen=True)
class Point:
    """A raw point with exact rational coordinates."""

    x: Fraction
    y: Fraction


def point(x: int, y: int) -> Point:
    return Point(Fraction(x), Fraction(y))


def endpoint_equivalent(a: Point, b: Point) -> bool:
    """Decide the elementary endpoint relation (0,y) ~ (1,-y)."""
    return (
        a == b
        or (a.x == 0 and b.x == 1 and a.y == -b.y)
        or (a.x == 1 and b.x == 0 and a.y == -b.y)
    )


def coordinatewise_add(a: Point, b: Point) -> Point:
    return Point(a.x + b.x, a.y + b.y)


def coordinatewise_multiply(a: Point, b: Point) -> Point:
    return Point(a.x * b.x, a.y * b.y)


def descent_witness(operation: Callable[[Point, Point], Point]) -> tuple[Point, Point, bool]:
    """Apply an operation to two choices of the same quotient inputs."""
    left = point(0, 1)
    right = point(1, -1)
    assert endpoint_equivalent(left, right)
    output_left = operation(left, left)
    output_right = operation(right, right)
    return output_left, output_right, endpoint_equivalent(output_left, output_right)


def proposed_coordinate(n: int) -> Fraction:
    if n == 0:
        raise ValueError("the proposed coordinate is undefined for zero")
    return Fraction(1, 2) + Fraction(1, 2 * n)


def represented_value(n: int) -> Fraction:
    """Evaluate |n| * (2*c(n)-1) exactly."""
    c = proposed_coordinate(n)
    return abs(n) * (2 * c - 1)


def signed_prime_factorization(n: int) -> tuple[int, list[int]]:
    """Return a unit sign and prime factors of |n| by trial division."""
    if n == 0:
        raise ValueError("zero has no finite factorization into nonzero primes")
    sign = -1 if n < 0 else 1
    remainder = abs(n)
    factors: list[int] = []
    divisor = 2
    while divisor <= isqrt(remainder):
        while remainder % divisor == 0:
            factors.append(divisor)
            remainder //= divisor
        divisor = 3 if divisor == 2 else divisor + 2
    if remainder > 1:
        factors.append(remainder)
    return sign, factors


def product(values: Iterable[int]) -> int:
    result = 1
    for value in values:
        result *= value
    return result


def main() -> None:
    print("MÖBIUS QUOTIENT REPRESENTATIVE TESTS")
    for name, operation in (
        ("coordinatewise addition", coordinatewise_add),
        ("coordinatewise multiplication", coordinatewise_multiply),
    ):
        first, second, equivalent = descent_witness(operation)
        print(f"{name:30s}: {first} versus {second}; equivalent = {equivalent}")

    print("\nPROPOSED INTEGER EVALUATION")
    print(" n | coordinate c(n) | scale | represented value")
    for n in (-6, -3, -2, -1, 1, 2, 3, 6):
        print(f"{n:2d} | {str(proposed_coordinate(n)):15s} | {abs(n):5d} | {represented_value(n)}")

    print("\nSIGNED FACTORIZATION")
    for n in (6, -6):
        sign, factors = signed_prime_factorization(n)
        reconstruction = sign * product(factors)
        print(f"{n:3d} = unit {sign:+d} × factors {factors}; reconstructed = {reconstruction}")
    print(f"Claim check: (-2)×(-3) = {(-2) * (-3)}, not -6")
    try:
        signed_prime_factorization(0)
    except ValueError as error:
        print(f"0: {error}")


if __name__ == "__main__":
    main()
