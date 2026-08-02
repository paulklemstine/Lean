#!/usr/bin/env python3
"""Exact numerical demonstrations for Euler bricks and the cuboid quadric.

Only Python's standard library is used. Integer and rational calculations are
exact; no floating-point tolerance is used to decide square identities.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import isqrt
from typing import Iterator


@dataclass(frozen=True)
class BrickReport:
    """Exact diagonal data for one rectangular box."""

    edges: tuple[int, int, int]
    face_diagonals: tuple[int | None, int | None, int | None]
    space_diagonal: int | None
    squared_space_diagonal: int

    @property
    def is_euler_brick(self) -> bool:
        return all(value is not None for value in self.face_diagonals)

    @property
    def is_perfect_cuboid(self) -> bool:
        return self.is_euler_brick and self.space_diagonal is not None


def exact_square_root(n: int) -> int | None:
    """Return the nonnegative square root of n, or None if n is not a square."""
    if n < 0:
        return None
    root = isqrt(n)
    return root if root * root == n else None


def analyze_brick(x: int, y: int, z: int) -> BrickReport:
    """Compute all face and space diagonals with exact integer square tests."""
    if min(x, y, z) < 0:
        raise ValueError("edge lengths must be nonnegative")
    face_squares = (x * x + y * y, x * x + z * z, y * y + z * z)
    space_square = x * x + y * y + z * z
    return BrickReport(
        edges=(x, y, z),
        face_diagonals=tuple(exact_square_root(n) for n in face_squares),
        space_diagonal=exact_square_root(space_square),
        squared_space_diagonal=space_square,
    )


def diagonal_cone_residual(a: int, b: int, c: int, d: int) -> int:
    """Return a²+b²+c²-2d²; valid perfect-cuboid data give zero."""
    return a * a + b * b + c * c - 2 * d * d


def quadric_point(p: Fraction, q: Fraction) -> tuple[Fraction, Fraction, Fraction]:
    """Parametrize w²=u²+v²-1 using rational slopes p and q."""
    denominator = 1 + p * p - q * q
    if denominator == 0:
        raise ValueError("tangent parameter: 1 + p² - q² must be nonzero")
    u = (p * p - q * q - 1) / denominator
    v = (-2 * p) / denominator
    w = (-2 * q) / denominator
    return u, v, w


def inverse_parameters(
    u: Fraction, v: Fraction, w: Fraction
) -> tuple[Fraction, Fraction]:
    """Recover p and q from a quadric point away from the base point u=1."""
    if u == 1:
        raise ValueError("the base-point chart excludes u = 1")
    return v / (u - 1), w / (u - 1)


def is_rational_square(value: Fraction) -> bool:
    """Decide exactly whether a rational number is a rational square."""
    return (
        value >= 0
        and exact_square_root(value.numerator) is not None
        and exact_square_root(value.denominator) is not None
    )


def cuboid_square_filters(
    u: Fraction, v: Fraction
) -> tuple[Fraction, Fraction, Fraction, tuple[bool, bool, bool]]:
    """Evaluate the three residual square conditions for edge reconstruction."""
    values = (u * u - 1, v * v - 1, u * u + v * v - 2)
    return values[0], values[1], values[2], tuple(
        is_rational_square(value) for value in values
    )


def bounded_euler_bricks(bound: int) -> Iterator[BrickReport]:
    """Yield ordered positive Euler bricks x≤y≤z≤bound by exact enumeration.

    The straightforward algorithm examines O(bound³) triples and uses O(1)
    additional memory apart from yielded reports.
    """
    for x in range(1, bound + 1):
        for y in range(x, bound + 1):
            if exact_square_root(x * x + y * y) is None:
                continue
            for z in range(y, bound + 1):
                report = analyze_brick(x, y, z)
                if report.is_euler_brick:
                    yield report


def main() -> None:
    print("1. The classical Euler-brick near-miss")
    report = analyze_brick(44, 117, 240)
    print(f"   edges: {report.edges}")
    print(f"   face diagonals: {report.face_diagonals}")
    print(f"   squared space diagonal: {report.squared_space_diagonal}")
    lower = isqrt(report.squared_space_diagonal)
    print(
        f"   consecutive-square trap: {lower}²={lower**2} < "
        f"{report.squared_space_diagonal} < {(lower + 1)}²={(lower + 1)**2}"
    )
    print(f"   perfect cuboid? {report.is_perfect_cuboid}\n")

    print("2. Scaling the Euler brick by k=3")
    scaled = analyze_brick(3 * 44, 3 * 117, 3 * 240)
    print(f"   edges: {scaled.edges}")
    print(f"   face diagonals: {scaled.face_diagonals}\n")

    print("3. A rational point on the normalized quadric")
    p, q = Fraction(1), Fraction(1, 2)
    u, v, w = quadric_point(p, q)
    residual = w * w - u * u - v * v + 1
    print(f"   p={p}, q={q} -> (u,v,w)=({u},{v},{w})")
    print(f"   exact residual w²-u²-v²+1 = {residual}")
    recovered = inverse_parameters(u, v, w)
    print(f"   recovered slopes: p={recovered[0]}, q={recovered[1]}")
    r1, r2, r3, flags = cuboid_square_filters(u, v)
    print(f"   square filters: {r1}, {r2}, {r3}")
    print(f"   are rational squares? {flags}\n")

    print("4. First ordered Euler bricks with edges at most 250")
    for found in bounded_euler_bricks(250):
        print(
            f"   {found.edges}, faces={found.face_diagonals}, "
            f"space²={found.squared_space_diagonal}, "
            f"perfect={found.is_perfect_cuboid}"
        )


if __name__ == "__main__":
    main()
