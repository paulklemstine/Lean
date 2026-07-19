#!/usr/bin/env python3
"""Exact numerical demonstrations of cellular homology rank formulas.

The script uses only the Python standard library. Matrices are reduced over the
rational numbers, so all reported ranks and Betti numbers are exact.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from typing import Iterable, Sequence

Number = int | Fraction
Matrix = list[list[Fraction]]


def as_fraction_matrix(rows: Sequence[Sequence[Number]]) -> Matrix:
    """Convert a rectangular numeric matrix to exact rational entries."""
    matrix = [[Fraction(value) for value in row] for row in rows]
    if matrix and any(len(row) != len(matrix[0]) for row in matrix):
        raise ValueError("matrix rows must have equal length")
    return matrix


def matrix_shape(matrix: Matrix, empty_columns: int = 0) -> tuple[int, int]:
    """Return matrix dimensions, allowing a declared width for zero-row matrices."""
    return (len(matrix), len(matrix[0]) if matrix else empty_columns)


def matrix_rank(rows: Sequence[Sequence[Number]]) -> int:
    """Compute exact rank by Gaussian elimination over the rational numbers."""
    matrix = as_fraction_matrix(rows)
    if not matrix:
        return 0
    row_count, column_count = len(matrix), len(matrix[0])
    pivot_row = 0
    for column in range(column_count):
        pivot = next(
            (row for row in range(pivot_row, row_count) if matrix[row][column]),
            None,
        )
        if pivot is None:
            continue
        matrix[pivot_row], matrix[pivot] = matrix[pivot], matrix[pivot_row]
        pivot_value = matrix[pivot_row][column]
        matrix[pivot_row] = [value / pivot_value for value in matrix[pivot_row]]
        for row in range(row_count):
            if row != pivot_row and matrix[row][column]:
                factor = matrix[row][column]
                matrix[row] = [
                    value - factor * pivot_value
                    for value, pivot_value in zip(matrix[row], matrix[pivot_row])
                ]
        pivot_row += 1
        if pivot_row == row_count:
            break
    return pivot_row


def matrix_product(left: Matrix, right: Matrix, right_columns: int = 0) -> Matrix:
    """Multiply exact matrices, including a matrix with zero rows when declared."""
    left_rows, left_columns = matrix_shape(left)
    right_rows, columns = matrix_shape(right, right_columns)
    if left_columns != right_rows:
        raise ValueError(
            f"incompatible matrix dimensions: {left_rows}x{left_columns} and "
            f"{right_rows}x{columns}"
        )
    return [
        [sum((left[i][k] * right[k][j] for k in range(left_columns)), Fraction(0))
         for j in range(columns)]
        for i in range(left_rows)
    ]


def is_zero_matrix(matrix: Matrix) -> bool:
    """Test whether every matrix entry vanishes."""
    return all(value == 0 for row in matrix for value in row)


@dataclass(frozen=True)
class HomologyReport:
    """Dimensions, ranks, Betti numbers, and Euler characteristics."""

    cells: tuple[int, int, int]
    ranks: tuple[int, int]
    betti: tuple[int, int, int]
    euler_from_homology: int
    euler_from_cells: int


def analyze_chain_complex(
    d1_rows: Sequence[Sequence[Number]],
    d2_rows: Sequence[Sequence[Number]],
    *,
    c2_if_empty: int = 0,
) -> HomologyReport:
    """Analyze C2 --d2--> C1 --d1--> C0 using exact rational arithmetic.

    ``d1_rows`` is a c0-by-c1 matrix and ``d2_rows`` is a c1-by-c2 matrix.
    For c1 = 0, use an empty d2 matrix and pass c2_if_empty.
    """
    d1 = as_fraction_matrix(d1_rows)
    d2 = as_fraction_matrix(d2_rows)
    c0, c1 = matrix_shape(d1)
    d2_row_count, c2 = matrix_shape(d2, c2_if_empty)
    if d2_row_count != c1:
        raise ValueError("d2 must have one row for every basis vector of C1")
    if not is_zero_matrix(matrix_product(d1, d2, c2)):
        raise ValueError("the matrices do not form a chain complex: d1*d2 is nonzero")
    r1, r2 = matrix_rank(d1), matrix_rank(d2)
    beta0 = c0 - r1
    beta1 = c1 - r1 - r2
    beta2 = c2 - r2
    euler_h = beta0 - beta1 + beta2
    euler_c = c0 - c1 + c2
    if beta1 < 0 or euler_h != euler_c:
        raise ArithmeticError("internal consistency check failed")
    return HomologyReport(
        cells=(c0, c1, c2),
        ranks=(r1, r2),
        betti=(beta0, beta1, beta2),
        euler_from_homology=euler_h,
        euler_from_cells=euler_c,
    )


def activation_patterns(widths: Sequence[int]) -> Iterable[tuple[int, ...]]:
    """Generate every Boolean activation pattern for the given hidden widths."""
    if any(width < 0 for width in widths):
        raise ValueError("layer widths must be nonnegative")
    return product((0, 1), repeat=sum(widths))


def activation_pattern_count(widths: Sequence[int]) -> int:
    """Return the exact architecture count product_i 2**width_i."""
    if any(width < 0 for width in widths):
        raise ValueError("layer widths must be nonnegative")
    result = 1
    for width in widths:
        result *= 2**width
    return result


def print_report(name: str, report: HomologyReport) -> None:
    """Print a compact mathematical summary."""
    c0, c1, c2 = report.cells
    r1, r2 = report.ranks
    b0, b1, b2 = report.betti
    print(f"\n{name}")
    print("-" * len(name))
    print(f"cell dimensions (c0,c1,c2): {report.cells}")
    print(f"boundary ranks (r1,r2):     {report.ranks}")
    print(f"Betti numbers (b0,b1,b2):   {report.betti}")
    print(f"middle identity: {b1} + {r1} + {r2} = {c1}")
    print(
        f"Euler identity: {b0} - {b1} + {b2} = "
        f"{c0} - {c1} + {c2} = {report.euler_from_cells}"
    )


def main() -> None:
    """Run three canonical complexes and an activation-pattern calculation."""
    # Three oriented edges: v0->v1, v1->v2, v2->v0.
    triangle_boundary_1 = [
        [-1, 0, 1],
        [1, -1, 0],
        [0, 1, -1],
    ]

    circle = analyze_chain_complex(
        triangle_boundary_1,
        [[], [], []],
    )
    print_report("Polygonal circle (triangle boundary)", circle)

    filled_triangle = analyze_chain_complex(
        triangle_boundary_1,
        [[1], [1], [1]],
    )
    print_report("Filled triangle", filled_triangle)

    isolated_points = analyze_chain_complex(
        [[], []],
        [],
    )
    print_report("Two isolated points", isolated_points)

    widths = (2, 3, 1)
    count = activation_pattern_count(widths)
    enumerated = sum(1 for _ in activation_patterns(widths))
    print("\nActivation-pattern count")
    print("------------------------")
    print(f"widths: {widths}")
    print(f"product_i 2^w_i: {count}")
    print(f"enumerated patterns: {enumerated}")
    print(f"conditional Euler ceiling 3P: {3 * count}")
    assert count == enumerated


if __name__ == "__main__":
    main()
