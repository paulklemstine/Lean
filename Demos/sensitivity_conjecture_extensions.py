#!/usr/bin/env python3
"""Numerical demonstrations for scalar-square signings of Boolean cubes.

The script uses only the Python standard library.  It constructs the canonical
signed adjacency matrix exactly, checks A_n^2 = nI, demonstrates the recursive
matrix-free action, and exhibits the unsigned two-cube counterexample.
"""

from __future__ import annotations

from math import sqrt
from typing import List, Sequence, Tuple

Matrix = List[List[int]]
Vector = List[int]


def zeros(rows: int, cols: int) -> Matrix:
    """Return an integer zero matrix."""
    return [[0 for _ in range(cols)] for _ in range(rows)]


def identity(size: int) -> Matrix:
    """Return the integer identity matrix of the requested order."""
    result = zeros(size, size)
    for i in range(size):
        result[i][i] = 1
    return result


def signed_cube_matrix(dimension: int) -> Matrix:
    """Construct A_n recursively as [[A, I], [I, -A]]."""
    if dimension < 0:
        raise ValueError("dimension must be nonnegative")
    matrix: Matrix = [[0]]
    for _ in range(dimension):
        size = len(matrix)
        result = zeros(2 * size, 2 * size)
        for i in range(size):
            for j in range(size):
                result[i][j] = matrix[i][j]
                result[size + i][size + j] = -matrix[i][j]
            result[i][size + i] = 1
            result[size + i][i] = 1
        matrix = result
    return matrix


def unsigned_cube_matrix(dimension: int) -> Matrix:
    """Construct ordinary cube adjacency as [[B, I], [I, B]]."""
    if dimension < 0:
        raise ValueError("dimension must be nonnegative")
    matrix: Matrix = [[0]]
    for _ in range(dimension):
        size = len(matrix)
        result = zeros(2 * size, 2 * size)
        for i in range(size):
            for j in range(size):
                result[i][j] = matrix[i][j]
                result[size + i][size + j] = matrix[i][j]
            result[i][size + i] = 1
            result[size + i][i] = 1
        matrix = result
    return matrix


def matrix_multiply(left: Sequence[Sequence[int]],
                    right: Sequence[Sequence[int]]) -> Matrix:
    """Multiply compatible integer matrices exactly."""
    if not left or not right or len(left[0]) != len(right):
        raise ValueError("incompatible matrix dimensions")
    rows, inner, cols = len(left), len(right), len(right[0])
    product = zeros(rows, cols)
    for i in range(rows):
        for k in range(inner):
            coefficient = left[i][k]
            if coefficient:
                for j in range(cols):
                    product[i][j] += coefficient * right[k][j]
    return product


def matrix_vector(matrix: Sequence[Sequence[int]],
                  vector: Sequence[int]) -> Vector:
    """Apply an integer matrix to an integer vector."""
    if any(len(row) != len(vector) for row in matrix):
        raise ValueError("incompatible matrix and vector")
    return [sum(a * b for a, b in zip(row, vector)) for row in matrix]


def scalar_identity(dimension: int, scalar: int) -> Matrix:
    """Return scalar times an identity matrix."""
    result = identity(dimension)
    return [[scalar * entry for entry in row] for row in result]


def apply_signed_recursive(vector: Sequence[int]) -> Vector:
    """Apply A_n without constructing it; the length must be a power of two."""
    size = len(vector)
    if size == 0 or size & (size - 1):
        raise ValueError("vector length must be a positive power of two")
    if size == 1:
        return [0]
    half = size // 2
    lower, upper = vector[:half], vector[half:]
    applied_lower = apply_signed_recursive(lower)
    applied_upper = apply_signed_recursive(upper)
    return ([applied_lower[i] + upper[i] for i in range(half)] +
            [lower[i] - applied_upper[i] for i in range(half)])


def verify_scalar_square(max_dimension: int = 5) -> List[Tuple[int, bool]]:
    """Check A_n^2 = nI exactly for dimensions zero through a cutoff."""
    checks: List[Tuple[int, bool]] = []
    for dimension in range(max_dimension + 1):
        matrix = signed_cube_matrix(dimension)
        square = matrix_multiply(matrix, matrix)
        checks.append(
            (dimension, square == scalar_identity(1 << dimension, dimension))
        )
    return checks


def unsigned_two_cube_counterexample() -> Tuple[Vector, Vector]:
    """Return B_2^2 1 and 2I 1, which are respectively [4,...] and [2,...]."""
    matrix = unsigned_cube_matrix(2)
    constant = [1, 1, 1, 1]
    actual = matrix_vector(matrix, matrix_vector(matrix, constant))
    claimed = [2 * value for value in constant]
    return actual, claimed


def main() -> None:
    """Print exact small-dimensional demonstrations of all key claims."""
    print("Canonical scalar-square checks")
    for dimension, passed in verify_scalar_square(5):
        magnitude = sqrt(dimension)
        print(
            f"  n={dimension}: A_n^2 = {dimension}I -> {passed}; "
            f"allowed eigenvalue magnitude = {magnitude:.6g}"
        )

    sample = [3, -1, 4, 1, 5, -9, 2, 6]
    once = apply_signed_recursive(sample)
    twice = apply_signed_recursive(once)
    expected = [3 * value for value in sample]
    print("\nMatrix-free n=3 signal check")
    print(f"  v       = {sample}")
    print(f"  A_3 v   = {once}")
    print(f"  A_3^2 v = {twice}")
    print(f"  3v      = {expected}")
    print(f"  equality: {twice == expected}")

    actual, claimed = unsigned_two_cube_counterexample()
    print("\nUnsigned two-cube counterexample on the constant signal")
    print(f"  B_2^2 1 = {actual}")
    print(f"  2I 1    = {claimed}")
    print(f"  scalar-square claim holds: {actual == claimed}")

    unsigned_square = matrix_multiply(
        unsigned_cube_matrix(2), unsigned_cube_matrix(2)
    )
    print("\nB_2^2 (opposite-corner entries are nonzero):")
    for row in unsigned_square:
        print(" ", row)


if __name__ == "__main__":
    main()
