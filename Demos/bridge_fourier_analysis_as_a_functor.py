#!/usr/bin/env python3
"""Exact numerical demonstrations for finite Fourier duality.

The script uses only Python's standard library and exact Fraction arithmetic.
It checks two-point Fourier inversion, exhibits the failure of unrestricted
commutation with linear maps, verifies transpose reversal, and displays the
support counterexample to deriving uncertainty from contravariance alone.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Sequence, TypeAlias

Scalar: TypeAlias = Fraction
Vector: TypeAlias = list[Scalar]
Matrix: TypeAlias = list[list[Scalar]]


def matrix_multiply(left: Matrix, right: Matrix) -> Matrix:
    """Return left times right, raising ValueError for incompatible shapes."""
    if not left or not right or not right[0]:
        raise ValueError("matrices must be nonempty")
    inner = len(left[0])
    if any(len(row) != inner for row in left):
        raise ValueError("left matrix is ragged")
    columns = len(right[0])
    if any(len(row) != columns for row in right):
        raise ValueError("right matrix is ragged")
    if inner != len(right):
        raise ValueError("incompatible matrix dimensions")
    return [
        [sum((left[i][k] * right[k][j] for k in range(inner)), Fraction(0))
         for j in range(columns)]
        for i in range(len(left))
    ]


def transpose(matrix: Matrix) -> Matrix:
    """Return the matrix transpose."""
    if not matrix or not matrix[0]:
        raise ValueError("matrix must be nonempty")
    width = len(matrix[0])
    if any(len(row) != width for row in matrix):
        raise ValueError("matrix is ragged")
    return [[matrix[i][j] for i in range(len(matrix))] for j in range(width)]


def apply_matrix(matrix: Matrix, vector: Sequence[Scalar]) -> Vector:
    """Apply a matrix to a column vector."""
    if not matrix or any(len(row) != len(vector) for row in matrix):
        raise ValueError("incompatible matrix and vector dimensions")
    return [sum((entry * value for entry, value in zip(row, vector)), Fraction(0))
            for row in matrix]


def support_size(vector: Sequence[Scalar]) -> int:
    """Count nonzero coordinates exactly."""
    return sum(value != 0 for value in vector)


def two_point_fourier(vector: Sequence[Scalar]) -> Vector:
    """Compute (x0 + x1, x0 - x1)."""
    if len(vector) != 2:
        raise ValueError("the two-point transform requires two coordinates")
    return [vector[0] + vector[1], vector[0] - vector[1]]


def two_point_inverse(vector: Sequence[Scalar]) -> Vector:
    """Reconstruct ((y0 + y1)/2, (y0 - y1)/2)."""
    if len(vector) != 2:
        raise ValueError("the two-point inverse requires two coordinates")
    return [(vector[0] + vector[1]) / 2, (vector[0] - vector[1]) / 2]


def format_matrix(matrix: Matrix) -> str:
    """Format an exact matrix for terminal output."""
    return "[\n" + "\n".join(f"  {[str(x) for x in row]}" for row in matrix) + "\n]"


def main() -> None:
    """Run all demonstrations and assert every claimed equality."""
    one, zero, half = Fraction(1), Fraction(0), Fraction(1, 2)
    fourier: Matrix = [[one, one], [one, -one]]
    inverse: Matrix = [[half, half], [half, -half]]
    identity: Matrix = [[one, zero], [zero, one]]
    projection: Matrix = [[one, zero], [zero, zero]]

    left_inverse = matrix_multiply(fourier, inverse)
    right_inverse = matrix_multiply(inverse, fourier)
    assert left_inverse == identity == right_inverse

    sample = [Fraction(7, 3), Fraction(-2, 5)]
    spectrum = two_point_fourier(sample)
    reconstruction = two_point_inverse(spectrum)
    assert reconstruction == sample

    projection_then_fourier = matrix_multiply(projection, fourier)
    fourier_then_projection = matrix_multiply(fourier, projection)
    assert projection_then_fourier != fourier_then_projection

    a: Matrix = [[Fraction(1), Fraction(2)], [Fraction(3), Fraction(4)]]
    b: Matrix = [[Fraction(0), Fraction(5)], [Fraction(6), Fraction(7)]]
    assert transpose(matrix_multiply(b, a)) == matrix_multiply(transpose(a), transpose(b))
    assert transpose(transpose(a)) == a

    delta = [one, zero]
    unchanged_delta = apply_matrix(identity, delta)
    support_product = support_size(delta) * support_size(unchanged_delta)
    assert support_product == 1 and support_product < 2

    print("Two-point Fourier matrix F:")
    print(format_matrix(fourier))
    print("Inverse (1/2)F:")
    print(format_matrix(inverse))
    print("F(1/2 F) = (1/2 F)F = I:")
    print(format_matrix(identity))
    print(f"Sample {sample} -> spectrum {spectrum} -> reconstruction {reconstruction}")
    print("\nProjection P does not commute with F:")
    print("PF =", format_matrix(projection_then_fourier))
    print("FP =", format_matrix(fourier_then_projection))
    print("\nTranspose reverses composition and double transpose returns the matrix.")
    print(f"Identity-transform support product for delta = {support_product} < 2.")


if __name__ == "__main__":
    main()
