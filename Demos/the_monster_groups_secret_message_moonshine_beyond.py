#!/usr/bin/env python3
"""Numerical demonstrations of finite moonshine-product principles.

The examples use exact rational arithmetic and require only Python's standard
library. They demonstrate truncated normalized products, character recovery,
and collisions caused by a noninjective observation map.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Iterable, Sequence

Vector = list[Fraction]
Matrix = list[list[Fraction]]


def truncated_convolution(a: Sequence[Fraction], b: Sequence[Fraction], degree: int) -> Vector:
    """Multiply coefficient lists modulo q**(degree + 1)."""
    out = [Fraction(0) for _ in range(degree + 1)]
    for i, ai in enumerate(a[: degree + 1]):
        for j, bj in enumerate(b[: degree + 1 - i]):
            out[i + j] += ai * bj
    return out


def normalized_product(factors: Iterable[Sequence[int]], degree: int) -> tuple[int, Vector]:
    """Return the q-shift and regular coefficients of a normalized product.

    Every input is the regular factor R_c(q), whose constant coefficient must
    equal one. The represented moonshine-type factor is q**(-1) R_c(q).
    """
    product: Vector = [Fraction(1)] + [Fraction(0)] * degree
    count = 0
    for raw_factor in factors:
        factor = [Fraction(value) for value in raw_factor]
        if not factor or factor[0] != 1:
            raise ValueError("each regular factor must have constant coefficient 1")
        product = truncated_convolution(product, factor, degree)
        count += 1
    return -count, product


def matrix_rank(matrix: Sequence[Sequence[Fraction]]) -> int:
    """Compute exact row rank by rational Gaussian elimination."""
    work = [list(map(Fraction, row)) for row in matrix]
    if not work:
        return 0
    rows, cols = len(work), len(work[0])
    rank = pivot_col = 0
    while rank < rows and pivot_col < cols:
        pivot = next((r for r in range(rank, rows) if work[r][pivot_col] != 0), None)
        if pivot is None:
            pivot_col += 1
            continue
        work[rank], work[pivot] = work[pivot], work[rank]
        scale = work[rank][pivot_col]
        work[rank] = [x / scale for x in work[rank]]
        for r in range(rows):
            if r != rank and work[r][pivot_col] != 0:
                scale = work[r][pivot_col]
                work[r] = [x - scale * y for x, y in zip(work[r], work[rank])]
        rank += 1
        pivot_col += 1
    return rank


def solve_square(matrix: Sequence[Sequence[Fraction]], vector: Sequence[Fraction]) -> Vector:
    """Solve a nonsingular square rational system exactly."""
    n = len(matrix)
    if n == 0 or any(len(row) != n for row in matrix) or len(vector) != n:
        raise ValueError("a square matrix and matching vector are required")
    augmented = [list(map(Fraction, row)) + [Fraction(vector[i])] for i, row in enumerate(matrix)]
    for col in range(n):
        pivot = next((r for r in range(col, n) if augmented[r][col] != 0), None)
        if pivot is None:
            raise ValueError("character matrix is not injective")
        augmented[col], augmented[pivot] = augmented[pivot], augmented[col]
        scale = augmented[col][col]
        augmented[col] = [x / scale for x in augmented[col]]
        for r in range(n):
            if r != col:
                scale = augmented[r][col]
                augmented[r] = [x - scale * y for x, y in zip(augmented[r], augmented[col])]
    return [augmented[i][-1] for i in range(n)]


def matvec(matrix: Sequence[Sequence[Fraction]], vector: Sequence[Fraction]) -> Vector:
    """Multiply a matrix by a vector exactly."""
    return [sum((Fraction(x) * Fraction(y) for x, y in zip(row, vector)), Fraction(0)) for row in matrix]


def format_laurent(shift: int, coefficients: Sequence[Fraction]) -> str:
    """Format a shifted coefficient list as a Laurent polynomial."""
    terms: list[str] = []
    for k, coefficient in enumerate(coefficients):
        if coefficient == 0:
            continue
        exponent = shift + k
        terms.append(f"({coefficient})q^{exponent}")
    return " + ".join(terms) if terms else "0"


def demo_product() -> None:
    """Show that three normalized factors produce a leading q^(-3)."""
    shift, coefficients = normalized_product([[1, 1], [1, 2], [1, -1, 1]], degree=4)
    print("Normalized product demo")
    print(" shift:", shift)
    print(" regular coefficients:", coefficients)
    print(" Laurent expansion:", format_laurent(shift, coefficients))
    assert shift == -3 and coefficients[0] == 1


def demo_reconstruction() -> None:
    """Recover multiplicities from an invertible two-character table."""
    table: Matrix = [[Fraction(1), Fraction(1)], [Fraction(1), Fraction(-1)]]
    multiplicities: Vector = [Fraction(3), Fraction(2)]
    traces = matvec(table, multiplicities)
    recovered = solve_square(table, traces)
    print("\nCharacter reconstruction demo")
    print(" rank:", matrix_rank(table), "traces:", traces, "recovered:", recovered)
    assert recovered == multiplicities


def demo_collision() -> None:
    """Exhibit two multiplicity vectors hidden by a rank-one encoding."""
    partial_table: Matrix = [[Fraction(1), Fraction(1)]]
    first: Vector = [Fraction(3), Fraction(2)]
    second: Vector = [Fraction(4), Fraction(1)]
    first_trace = matvec(partial_table, first)
    second_trace = matvec(partial_table, second)
    print("\nNoninjective collision demo")
    print(" rank:", matrix_rank(partial_table), "images:", first_trace, second_trace)
    assert first != second and first_trace == second_trace


def main() -> None:
    demo_product()
    demo_reconstruction()
    demo_collision()


if __name__ == "__main__":
    main()
