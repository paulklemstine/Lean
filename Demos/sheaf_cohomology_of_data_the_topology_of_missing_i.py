#!/usr/bin/env python3
"""Numerical demonstrations for missing-information cohomology.

The script uses only Python's standard library.  It demonstrates:
1. equal-sized complexes with first-cohomology dimensions n and 0;
2. the nonmonotone proxy n*r^2*log(1/r);
3. convergence of consecutive exponential KL divergences to gamma;
4. least-squares patching for diagonal coboundary maps.
"""

from __future__ import annotations

import math
from typing import Iterable, List, Sequence, Tuple

Matrix = List[List[float]]
Vector = List[float]


def matrix_rank(matrix: Sequence[Sequence[float]], tol: float = 1e-10) -> int:
    """Return numerical row rank by Gaussian elimination with pivoting."""
    if not matrix:
        return 0
    a = [list(map(float, row)) for row in matrix]
    rows, cols = len(a), len(a[0])
    if any(len(row) != cols for row in a):
        raise ValueError("matrix must be rectangular")
    rank = 0
    for col in range(cols):
        pivot = max(range(rank, rows), key=lambda i: abs(a[i][col]), default=rank)
        if rank >= rows or abs(a[pivot][col]) <= tol:
            continue
        a[rank], a[pivot] = a[pivot], a[rank]
        pivot_value = a[rank][col]
        a[rank] = [value / pivot_value for value in a[rank]]
        for row in range(rows):
            if row != rank and abs(a[row][col]) > tol:
                factor = a[row][col]
                a[row] = [x - factor * y for x, y in zip(a[row], a[rank])]
        rank += 1
        if rank == rows:
            break
    return rank


def matmul(a: Sequence[Sequence[float]], b: Sequence[Sequence[float]]) -> Matrix:
    """Multiply rectangular matrices."""
    if not a:
        return []
    if not b:
        return [[] for _ in a]
    if len(a[0]) != len(b):
        raise ValueError("incompatible matrix dimensions")
    return [[sum(x * y for x, y in zip(row, col)) for col in zip(*b)] for row in a]


def h1_dimension(d0: Matrix, d1: Matrix, c1_dimension: int, tol: float = 1e-10) -> int:
    """Compute dim H^1 = dim C^1 - rank(d1) - rank(d0)."""
    if d1 and len(d1[0]) != c1_dimension:
        raise ValueError("d1 must have one column per C1 coordinate")
    if d0 and len(d0) != c1_dimension:
        raise ValueError("d0 must have one row per C1 coordinate")
    product = matmul(d1, d0) if d1 else []
    if any(abs(value) > tol for row in product for value in row):
        raise ValueError("cochain condition d1*d0 = 0 is violated")
    answer = c1_dimension - matrix_rank(d1, tol) - matrix_rank(d0, tol)
    if answer < 0:
        raise ValueError("inconsistent ranks for a cochain complex")
    return answer


def identity(n: int) -> Matrix:
    """Return the n-by-n identity matrix."""
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def zeros(rows: int, cols: int) -> Matrix:
    """Return a zero matrix."""
    return [[0.0 for _ in range(cols)] for _ in range(rows)]


def rate_proxy(n: float, r: float) -> float:
    """Evaluate n*r^2*log(1/r), continuously extended by zero at 0."""
    if n < 0.0 or not 0.0 <= r <= 1.0:
        raise ValueError("require n >= 0 and 0 <= r <= 1")
    if r == 0.0:
        return 0.0
    return n * r * r * math.log(1.0 / r)


def exponential_kl(rate1: float, rate2: float) -> float:
    """KL(Exp(rate1) || Exp(rate2)) for positive rates."""
    if rate1 <= 0.0 or rate2 <= 0.0:
        raise ValueError("rates must be positive")
    return math.log(rate1 / rate2) + rate2 / rate1 - 1.0


def gamma_divergence_partial_sum(terms: int) -> float:
    """Sum KL(Exp(k+1)||Exp(k+2)) for k from 0 through terms-1."""
    if terms < 0:
        raise ValueError("terms must be nonnegative")
    return math.fsum(exponential_kl(k + 1.0, k + 2.0) for k in range(terms))


def diagonal_least_squares(diagonal: Sequence[float], residual: Sequence[float]) -> Tuple[Vector, Vector]:
    """Solve min_x ||diag(diagonal)x-residual|| and return x and remainder."""
    if len(diagonal) != len(residual):
        raise ValueError("vectors must have equal length")
    correction: Vector = []
    remainder: Vector = []
    for coefficient, observed in zip(diagonal, residual):
        if coefficient == 0.0:
            correction.append(0.0)
            remainder.append(float(observed))
        else:
            correction.append(float(observed) / coefficient)
            remainder.append(0.0)
    return correction, remainder


def demo_equal_dimensions(n: int = 6) -> None:
    """Print the obstruction dimensions of the two canonical models."""
    disconnected = h1_dimension(zeros(n, n), zeros(0, n), n)
    patchable = h1_dimension(identity(n), zeros(0, n), n)
    print("Equal cochain dimensions (C0, C1, C2):", (n, n, 0))
    print("  disconnected dim H1:", disconnected)
    print("  patchable    dim H1:", patchable)


def demo_proxy(n: float = 100.0) -> None:
    """Print proxy values showing positivity at one half and zero at one."""
    rates = [0.0, 0.1, 0.25, 0.5, math.exp(-0.5), 0.8, 1.0]
    print("\nMissing-rate proxy P_n(r) for n =", n)
    for rate in rates:
        print(f"  r={rate:0.6f}  P={rate_proxy(n, rate):0.9f}")
    print("  theoretical maximizer exp(-1/2) =", math.exp(-0.5))


def demo_gamma() -> None:
    """Print convergence of accumulated exponential divergences to gamma."""
    gamma_reference = 0.5772156649015329
    print("\nAccumulated consecutive exponential KL divergence")
    for terms in (1, 2, 5, 10, 100, 1000, 10000):
        value = gamma_divergence_partial_sum(terms)
        print(f"  terms={terms:5d}  sum={value:.12f}  error={abs(value-gamma_reference):.3e}")


def demo_patching() -> None:
    """Contrast an uncorrectable zero map with a fully patchable identity map."""
    observed = [2.0, -1.0, 0.5]
    _, disconnected_remainder = diagonal_least_squares([0.0, 0.0, 0.0], observed)
    correction, patchable_remainder = diagonal_least_squares([1.0, 1.0, 1.0], observed)
    print("\nLeast-squares patching of overlap residual", observed)
    print("  zero map remainder:    ", disconnected_remainder)
    print("  identity correction:   ", correction)
    print("  identity remainder:    ", patchable_remainder)


def main() -> None:
    """Run all demonstrations."""
    demo_equal_dimensions()
    demo_proxy()
    demo_gamma()
    demo_patching()


if __name__ == "__main__":
    main()
