#!/usr/bin/env python3
"""Numerical demonstrations of planar ternary projective completion.

The script uses T(x, m, b) = x*m + b modulo a prime, constructs all
projective points and lines, audits the two unique-incidence properties, and
computes left nuclei of finite binary operations.  It uses only the Python
standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations, product
from typing import Callable, Iterable, Optional, Sequence


@dataclass(frozen=True, order=True)
class Point:
    """A point tagged as affine, ideal, or vertical-ideal."""

    kind: str
    a: int = 0
    b: int = 0

    def __str__(self) -> str:
        if self.kind == "A":
            return f"({self.a},{self.b})"
        if self.kind == "I":
            return f"I_{self.a}"
        return "I_inf"


@dataclass(frozen=True, order=True)
class Line:
    """A line tagged as ordinary, vertical, or at-infinity."""

    kind: str
    a: int = 0
    b: int = 0

    def __str__(self) -> str:
        if self.kind == "O":
            return f"y={self.a}x+{self.b}"
        if self.kind == "V":
            return f"x={self.a}"
        return "L_inf"


def is_prime(n: int) -> bool:
    """Return whether n is prime by trial division."""
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def ternary_field(x: int, m: int, b: int, q: int) -> int:
    """Evaluate T(x,m,b)=xm+b modulo q."""
    return (x * m + b) % q


def projective_points(q: int) -> list[Point]:
    """Enumerate q^2 affine points, q ideal points, and I_inf."""
    return (
        [Point("A", x, y) for x in range(q) for y in range(q)]
        + [Point("I", m) for m in range(q)]
        + [Point("IV")]
    )


def projective_lines(q: int) -> list[Line]:
    """Enumerate q^2 ordinary lines, q vertical lines, and L_inf."""
    return (
        [Line("O", m, b) for m in range(q) for b in range(q)]
        + [Line("V", a) for a in range(q)]
        + [Line("INF")]
    )


def incident(point: Point, line: Line, q: int) -> bool:
    """Evaluate incidence in the projective completion over Z/qZ."""
    if point.kind == "A" and line.kind == "O":
        return point.b == ternary_field(point.a, line.a, line.b, q)
    if point.kind == "A" and line.kind == "V":
        return point.a == line.a
    if point.kind == "A" and line.kind == "INF":
        return False
    if point.kind == "I" and line.kind == "O":
        return point.a == line.a
    if point.kind == "I" and line.kind == "V":
        return False
    if point.kind == "I" and line.kind == "INF":
        return True
    if point.kind == "IV" and line.kind == "O":
        return False
    if point.kind == "IV" and line.kind in {"V", "INF"}:
        return True
    raise ValueError("unknown point or line tag")


def joining_lines(p: Point, r: Point, lines: Sequence[Line], q: int) -> list[Line]:
    """Return all enumerated lines incident with both points."""
    return [line for line in lines if incident(p, line, q) and incident(r, line, q)]


def intersection_points(
    line: Line, other: Line, points: Sequence[Point], q: int
) -> list[Point]:
    """Return all enumerated points incident with both lines."""
    return [p for p in points if incident(p, line, q) and incident(p, other, q)]


def audit_projective_incidence(q: int) -> tuple[int, int, int, int]:
    """Audit every distinct point pair and line pair for unique incidence.

    Returns (point_count, line_count, bad_point_pairs, bad_line_pairs).
    """
    if not is_prime(q):
        raise ValueError("this field demo requires a prime modulus")
    points = projective_points(q)
    lines = projective_lines(q)
    bad_point_pairs = sum(
        len(joining_lines(p, r, lines, q)) != 1 for p, r in combinations(points, 2)
    )
    bad_line_pairs = sum(
        len(intersection_points(line, other, points, q)) != 1
        for line, other in combinations(lines, 2)
    )
    return len(points), len(lines), bad_point_pairs, bad_line_pairs


def incidence_matrix(q: int) -> list[list[int]]:
    """Build the square 0-1 incidence matrix for the field example."""
    points = projective_points(q)
    lines = projective_lines(q)
    return [[int(incident(p, line, q)) for line in lines] for p in points]


def left_nucleus(
    elements: Sequence[int], mul: Callable[[int, int], int]
) -> tuple[list[int], Optional[tuple[int, int, int]]]:
    """Compute the left nucleus and the first associativity-failure witness."""
    nucleus: list[int] = []
    witness: Optional[tuple[int, int, int]] = None
    for a in elements:
        belongs = True
        for b, c in product(elements, repeat=2):
            if mul(a, mul(b, c)) != mul(mul(a, b), c):
                belongs = False
                if witness is None:
                    witness = (a, b, c)
                break
        if belongs:
            nucleus.append(a)
    return nucleus, witness


def print_matrix(matrix: Iterable[Iterable[int]]) -> None:
    """Print a compact incidence matrix using filled and empty squares."""
    for row in matrix:
        print("".join("■" if value else "·" for value in row))


def main() -> None:
    """Run counting, incidence, intersection, and nucleus demonstrations."""
    print("PROJECTIVE COMPLETION COUNTS AND AUDIT")
    for q in (2, 3, 5, 7):
        p_count, l_count, bad_p, bad_l = audit_projective_incidence(q)
        expected = q * q + q + 1
        print(
            f"q={q}: points={p_count}, lines={l_count}, expected={expected}, "
            f"bad point pairs={bad_p}, bad line pairs={bad_l}"
        )

    q = 3
    points = projective_points(q)
    lines = projective_lines(q)
    p = Point("A", 0, 1)
    r = Point("A", 2, 2)
    join = joining_lines(p, r, lines, q)
    line_1 = Line("O", 2, 1)
    line_2 = Line("O", 1, 2)
    crossing = intersection_points(line_1, line_2, points, q)
    parallel_crossing = intersection_points(Line("O", 2, 1), Line("O", 2, 0), points, q)
    vertical_crossing = intersection_points(Line("V", 0), Line("V", 2), points, q)
    print("\nEXPLICIT GEOMETRY OVER Z/3Z")
    print(f"Joining line of {p} and {r}: {', '.join(map(str, join))}")
    print(f"Intersection of {line_1} and {line_2}: {', '.join(map(str, crossing))}")
    print(f"Intersection of parallel ordinary lines: {', '.join(map(str, parallel_crossing))}")
    print(f"Intersection of vertical lines: {', '.join(map(str, vertical_crossing))}")

    print("\nINCIDENCE MATRIX FOR q=2")
    print_matrix(incidence_matrix(2))

    elements = list(range(3))
    associative_mul = lambda a, b: (a + b) % 3
    nonassociative_mul = lambda a, b: (a - b) % 3
    full_nucleus, no_witness = left_nucleus(elements, associative_mul)
    proper_nucleus, witness = left_nucleus(elements, nonassociative_mul)
    print("\nLEFT-NUCLEUS DIAGNOSTIC ON THREE ELEMENTS")
    print(f"Addition modulo 3: nucleus={full_nucleus}, witness={no_witness}")
    print(f"Subtraction modulo 3: nucleus={proper_nucleus}, witness={witness}")
    if witness is not None:
        a, b, c = witness
        left = nonassociative_mul(a, nonassociative_mul(b, c))
        right = nonassociative_mul(nonassociative_mul(a, b), c)
        print(f"Witness check: {a}*({b}*{c})={left}, ({a}*{b})*{c}={right}")


if __name__ == "__main__":
    main()
