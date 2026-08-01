#!/usr/bin/env python3
"""Numerical demonstrations for alternating adjacent-sum transfer matrices.

The script uses only the Python standard library and exact integer arithmetic.
It constructs compatibility matrices, computes open and cyclic counts, checks
the common second-order recurrence, and verifies cyclic rotation invariance.
"""

from __future__ import annotations

from typing import List, Sequence, Tuple

Matrix = List[List[int]]
Vector = Sequence[int]


def identity(size: int) -> Matrix:
    """Return the integer identity matrix of the requested size."""
    return [[int(i == j) for j in range(size)] for i in range(size)]


def matmul(left: Matrix, right: Matrix) -> Matrix:
    """Multiply compatible integer matrices."""
    if not left or not right or len(left[0]) != len(right):
        raise ValueError("incompatible matrix dimensions")
    columns = len(right[0])
    if any(len(row) != columns for row in right):
        raise ValueError("right matrix is ragged")
    return [
        [sum(left[i][k] * right[k][j] for k in range(len(right)))
         for j in range(columns)]
        for i in range(len(left))
    ]


def matrix_power(matrix: Matrix, exponent: int) -> Matrix:
    """Compute a square matrix power by binary exponentiation."""
    if exponent < 0 or not matrix or any(len(row) != len(matrix) for row in matrix):
        raise ValueError("expected a square matrix and a nonnegative exponent")
    result = identity(len(matrix))
    base = [row[:] for row in matrix]
    while exponent:
        if exponent & 1:
            result = matmul(result, base)
        base = matmul(base, base)
        exponent >>= 1
    return result


def adjacency_matrix(d: int, bound: int) -> Matrix:
    """Build A_bound, where entry (i,j) is 1 exactly when i+j <= bound."""
    if d <= 0 or bound < 0:
        raise ValueError("d must be positive and bound nonnegative")
    return [[int(i + j <= bound) for j in range(d)] for i in range(d)]


def period_matrix(d: int, s: int) -> Matrix:
    """Return the strict-then-relaxed period matrix A_s A_(s+1)."""
    return matmul(adjacency_matrix(d, s), adjacency_matrix(d, s + 1))


def trace(matrix: Matrix) -> int:
    """Return the trace of a square integer matrix."""
    if not matrix or any(len(row) != len(matrix) for row in matrix):
        raise ValueError("trace requires a square matrix")
    return sum(matrix[i][i] for i in range(len(matrix)))


def determinant_2x2(matrix: Matrix) -> int:
    """Return the determinant of a 2 by 2 matrix."""
    if len(matrix) != 2 or any(len(row) != 2 for row in matrix):
        raise ValueError("expected a 2 by 2 matrix")
    return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]


def open_count(u: Vector, v: Vector, matrix: Matrix, periods: int) -> int:
    """Compute u^T M^periods v exactly."""
    power = matrix_power(matrix, periods)
    if len(u) != len(power) or len(v) != len(power):
        raise ValueError("boundary vectors have the wrong dimension")
    return sum(u[i] * power[i][j] * v[j]
               for i in range(len(power)) for j in range(len(power)))


def even_cyclic_count(matrix: Matrix, periods: int) -> int:
    """Compute trace(M^periods)."""
    return trace(matrix_power(matrix, periods))


def odd_cyclic_count(matrix: Matrix, extra: Matrix, periods: int) -> int:
    """Compute trace(M^periods A) for one unpaired extra step A."""
    return trace(matmul(matrix_power(matrix, periods), extra))


def recurrence_sequence(x0: int, x1: int, t: int, delta: int,
                        length: int) -> List[int]:
    """Generate x[n+2] = t*x[n+1] - delta*x[n]."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    values = [x0, x1][:length]
    while len(values) < length:
        values.append(t * values[-1] - delta * values[-2])
    return values


def check_recurrence(values: Sequence[int], t: int, delta: int) -> bool:
    """Check the characteristic recurrence for every available index."""
    return all(values[n + 2] == t * values[n + 1] - delta * values[n]
               for n in range(len(values) - 2))


def characteristic_denominator(matrix: Matrix) -> Tuple[int, int, int]:
    """Return coefficients of 1 - trace(M) z + det(M) z^2."""
    return (1, -trace(matrix), determinant_2x2(matrix))


def demonstrate(d: int = 2, s: int = 1, terms: int = 8) -> None:
    """Print and independently check the three principal counting sequences."""
    if d != 2:
        raise ValueError("the shared second-order demonstration requires d=2")
    strict = adjacency_matrix(d, s)
    relaxed = adjacency_matrix(d, s + 1)
    period = matmul(strict, relaxed)
    rotated = matmul(relaxed, strict)
    t, delta = trace(period), determinant_2x2(period)
    u = v = (1, 1)

    open_values = [open_count(u, v, period, n) for n in range(terms)]
    even_values = [even_cyclic_count(period, n) for n in range(terms)]
    odd_values = [odd_cyclic_count(period, strict, n) for n in range(terms)]

    print(f"states d={d}, alternating bounds {s} and {s + 1}")
    print(f"A_{s} = {strict}")
    print(f"A_{s + 1} = {relaxed}")
    print(f"M = A_{s} A_{s + 1} = {period}")
    print(f"trace(M)={t}, det(M)={delta}")
    print(f"characteristic denominator coefficients: {characteristic_denominator(period)}")
    print(f"open counts:       {open_values}")
    print(f"even cyclic:       {even_values}")
    print(f"odd cyclic:        {odd_values}")

    for name, values in (("open", open_values), ("even", even_values),
                         ("odd", odd_values)):
        assert check_recurrence(values, t, delta), f"{name} recurrence failed"
        predicted = recurrence_sequence(values[0], values[1], t, delta, terms)
        assert predicted == values, f"{name} matrix and recurrence counts differ"

    for positive_power in range(1, terms + 1):
        assert trace(matrix_power(period, positive_power)) == trace(
            matrix_power(rotated, positive_power)
        )
    print("All recurrences and cyclic rotation checks passed.")


if __name__ == "__main__":
    demonstrate()
