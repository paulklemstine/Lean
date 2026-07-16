#!/usr/bin/env python3
"""Exact demonstrations of Möbius translation on the Poincaré diameter."""

from __future__ import annotations

from fractions import Fraction
from math import log, tanh
from typing import Iterator

Pair = tuple[int, int]
Matrix = tuple[tuple[int, int], tuple[int, int]]


def mobius_add(x: Fraction, y: Fraction) -> Fraction:
    """Return (x+y)/(1+xy) exactly."""
    denominator = 1 + x * y
    if denominator == 0:
        raise ZeroDivisionError("Möbius sum is undefined when 1 + xy = 0")
    return (x + y) / denominator


def coordinates_iterative(n: int) -> Pair:
    """Compute (a_n,b_n) by n integral recurrence steps."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    a, b = 0, 1
    for _ in range(n):
        a, b = 2 * a + b, a + 2 * b
    return a, b


def coordinates_closed(n: int) -> Pair:
    """Compute (a_n,b_n)=((3^n-1)/2,(3^n+1)/2)."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    power = pow(3, n)
    return (power - 1) // 2, (power + 1) // 2


def matmul(left: Matrix, right: Matrix) -> Matrix:
    """Multiply two 2-by-2 integer matrices."""
    return (
        (
            left[0][0] * right[0][0] + left[0][1] * right[1][0],
            left[0][0] * right[0][1] + left[0][1] * right[1][1],
        ),
        (
            left[1][0] * right[0][0] + left[1][1] * right[1][0],
            left[1][0] * right[0][1] + left[1][1] * right[1][1],
        ),
    )


def matrix_power(matrix: Matrix, exponent: int) -> Matrix:
    """Raise a 2-by-2 integer matrix to a nonnegative power."""
    if exponent < 0:
        raise ValueError("exponent must be nonnegative")
    result: Matrix = ((1, 0), (0, 1))
    base = matrix
    k = exponent
    while k:
        if k & 1:
            result = matmul(result, base)
        base = matmul(base, base)
        k >>= 1
    return result


def coordinates_matrix(n: int) -> Pair:
    """Compute coordinates by binary powering of [[2,1],[1,2]]."""
    power = matrix_power(((2, 1), (1, 2)), n)
    return power[0][1], power[1][1]


def orbit(rows: int) -> Iterator[tuple[int, int, int, Fraction, int, float]]:
    """Yield index, coordinates, ratio, norm, and rapidity."""
    if rows < 0:
        raise ValueError("rows must be nonnegative")
    for n in range(rows):
        a, b = coordinates_iterative(n)
        yield n, a, b, Fraction(a, b), b * b - a * a, n * log(3) / 2


def verify_through(limit: int) -> None:
    """Check all exact identities for 0 <= n <= limit."""
    if limit < 0:
        raise ValueError("limit must be nonnegative")
    previous = Fraction(0, 1)
    for n in range(limit + 1):
        iterative = coordinates_iterative(n)
        assert iterative == coordinates_closed(n) == coordinates_matrix(n)
        a, b = iterative
        assert 2 * a == pow(3, n) - 1
        assert 2 * b == pow(3, n) + 1
        assert b * b - a * a == pow(3, n)
        x = Fraction(a, b)
        assert abs(x) < 1
        assert b - a == 1
        if n > 0:
            assert x == mobius_add(previous, Fraction(1, 2))
        previous = x


def main() -> None:
    """Print a table and run independent exact checks."""
    verify_through(100)
    print("Möbius translation by 1/2: exact orbit")
    print(" n |       a |       b |          a/b |   b^2-a^2 | rapidity")
    print("---+---------+---------+--------------+-----------+----------")
    for n, a, b, x, norm, rapidity in orbit(10):
        print(
            f"{n:2d} | {a:7d} | {b:7d} | {str(x):>12} | "
            f"{norm:9d} | {rapidity:8.5f}"
        )
    n = 20
    a, b = coordinates_closed(n)
    x_float = a / b
    expected = tanh(n * log(3) / 2)
    print(f"\nAt n={n}, x_n={x_float:.16f}")
    print(f"Rapidity formula gives {expected:.16f}")
    print("All exact identities verified for 0 <= n <= 100.")


if __name__ == "__main__":
    main()
