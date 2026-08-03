#!/usr/bin/env python3
"""Numerical demonstrations for the recursively signed Boolean hypercube."""

from __future__ import annotations

import math
from typing import Iterable, List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]


def matvec(matrix: Sequence[Sequence[float]], vector: Sequence[float]) -> Vector:
    """Multiply a dense matrix by a vector."""
    if any(len(row) != len(vector) for row in matrix):
        raise ValueError("matrix and vector dimensions do not agree")
    return [sum(a * x for a, x in zip(row, vector)) for row in matrix]


def matmul(left: Sequence[Sequence[float]], right: Sequence[Sequence[float]]) -> Matrix:
    """Multiply two dense matrices."""
    if not left or not right or len(left[0]) != len(right):
        raise ValueError("matrix dimensions do not agree")
    columns = list(zip(*right))
    return [[sum(a * b for a, b in zip(row, col)) for col in columns] for row in left]


def identity(size: int) -> Matrix:
    """Return the size-by-size identity matrix."""
    return [[1.0 if i == j else 0.0 for j in range(size)] for i in range(size)]


def canonical_signed_cube_matrix(n: int) -> Matrix:
    """Construct A_n recursively as [[A, I], [I, -A]]."""
    if n < 0:
        raise ValueError("dimension must be nonnegative")
    matrix: Matrix = [[0.0]]
    for _ in range(n):
        size = len(matrix)
        result = [[0.0 for _ in range(2 * size)] for _ in range(2 * size)]
        for i in range(size):
            for j in range(size):
                result[i][j] = matrix[i][j]
                result[size + i][size + j] = -matrix[i][j]
            result[i][size + i] = 1.0
            result[size + i][i] = 1.0
        matrix = result
    return matrix


def apply_signed_cube_recursive(n: int, vector: Sequence[float]) -> Vector:
    """Apply A_n by recursion without constructing a dense matrix."""
    if n < 0 or len(vector) != 1 << n:
        raise ValueError("vector length must equal 2**n")
    if n == 0:
        return [0.0]
    half = len(vector) // 2
    left = list(vector[:half])
    right = list(vector[half:])
    a_left = apply_signed_cube_recursive(n - 1, left)
    a_right = apply_signed_cube_recursive(n - 1, right)
    return ([a_left[i] + right[i] for i in range(half)]
            + [left[i] - a_right[i] for i in range(half)])


def spectral_parts(n: int, vector: Sequence[float]) -> Tuple[Vector, Vector]:
    """Return the +sqrt(n) and -sqrt(n) spectral components."""
    if n <= 0:
        raise ValueError("spectral formulas require positive dimension")
    transformed = apply_signed_cube_recursive(n, vector)
    r = math.sqrt(n)
    positive = [(x + y / r) / 2.0 for x, y in zip(vector, transformed)]
    negative = [(x - y / r) / 2.0 for x, y in zip(vector, transformed)]
    return positive, negative


def l2_norm(vector: Iterable[float]) -> float:
    """Return the Euclidean norm."""
    return math.sqrt(sum(x * x for x in vector))


def subtract(left: Sequence[float], right: Sequence[float]) -> Vector:
    return [x - y for x, y in zip(left, right)]


def add(left: Sequence[float], right: Sequence[float]) -> Vector:
    return [x + y for x, y in zip(left, right)]


def scale(c: float, vector: Sequence[float]) -> Vector:
    return [c * x for x in vector]


def unsigned_square_matrix() -> Matrix:
    """Return the ordinary all-positive adjacency matrix of Q_2."""
    return [
        [0.0, 1.0, 1.0, 0.0],
        [1.0, 0.0, 0.0, 1.0],
        [1.0, 0.0, 0.0, 1.0],
        [0.0, 1.0, 1.0, 0.0],
    ]


def max_abs_matrix_difference(left: Matrix, right: Matrix) -> float:
    return max(abs(x - y) for row_l, row_r in zip(left, right) for x, y in zip(row_l, row_r))


def demonstrate(n: int = 4) -> None:
    """Print residuals for all projection laws and the unsigned counterexample."""
    vector = [float(((7 * i + 3) % 17) - 8) for i in range(1 << n)]
    matrix = canonical_signed_cube_matrix(n)
    square = matmul(matrix, matrix)
    target = [[n * x for x in row] for row in identity(1 << n)]
    positive, negative = spectral_parts(n, vector)
    r = math.sqrt(n)

    reconstruction = l2_norm(subtract(add(positive, negative), vector))
    positive_eigen = l2_norm(subtract(apply_signed_cube_recursive(n, positive), scale(r, positive)))
    negative_eigen = l2_norm(subtract(apply_signed_cube_recursive(n, negative), scale(-r, negative)))
    pp, _ = spectral_parts(n, positive)
    _, nn = spectral_parts(n, negative)
    _, negative_of_positive = spectral_parts(n, positive)
    positive_of_negative, _ = spectral_parts(n, negative)
    pythagoras = abs(l2_norm(vector) ** 2 - l2_norm(positive) ** 2 - l2_norm(negative) ** 2)

    unsigned = unsigned_square_matrix()
    unsigned_square = matmul(unsigned, unsigned)
    two_identity = [[2.0 * x for x in row] for row in identity(4)]

    print(f"dimension n = {n}; vertices = {1 << n}")
    print(f"max |A_n^2 - nI|:               {max_abs_matrix_difference(square, target):.3e}")
    print(f"reconstruction residual:         {reconstruction:.3e}")
    print(f"positive eigenvector residual:    {positive_eigen:.3e}")
    print(f"negative eigenvector residual:    {negative_eigen:.3e}")
    print(f"positive idempotence residual:    {l2_norm(subtract(pp, positive)):.3e}")
    print(f"negative idempotence residual:    {l2_norm(subtract(nn, negative)):.3e}")
    print(f"P_-(P_+ f) residual:              {l2_norm(negative_of_positive):.3e}")
    print(f"P_+(P_- f) residual:              {l2_norm(positive_of_negative):.3e}")
    print(f"orthogonal energy residual:       {pythagoras:.3e}")
    print(f"unsigned Q_2 max |B^2 - 2I|:      {max_abs_matrix_difference(unsigned_square, two_identity):.3e}")
    print("unsigned Q_2 has a nonzero off-diagonal two-step contribution, so B^2 != 2I")


if __name__ == "__main__":
    demonstrate()
