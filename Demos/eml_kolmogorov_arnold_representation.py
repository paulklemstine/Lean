"""Numerical demonstrations of separable rank and the EML outer count in
Kolmogorov-Arnold sum-of-products superpositions.

This script is fully self-contained (standard library only) and reproduces the
key results of the accompanying paper:

  * the product x*y has separable rank 1 (and equals exp(log x + log y) > 0);
  * the sum x+y has separable rank exactly 2 (a 2x2 sample has determinant -1);
  * the power-sum p_N(x,y) = sum_{k<N} x^k y^k has separable rank exactly N,
    certified by a Vandermonde sample V V^T with det = (det V)^2 != 0.

The lower-bound engine is `separable_rank_lower_bound`: by the sampling theorem,
the matrix rank of any evaluation grid never exceeds the true separable rank, so
an invertible m x m sample certifies separable rank >= m.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable, List, Sequence

Target = Callable[[float, float], float]


# --------------------------------------------------------------------------- #
# Exact rational linear algebra (so determinants are exact, no float error).
# --------------------------------------------------------------------------- #
def matrix_det(matrix: List[List[Fraction]]) -> Fraction:
    """Exact determinant via fraction-free Gaussian elimination."""
    n = len(matrix)
    a = [row[:] for row in matrix]
    det = Fraction(1)
    for col in range(n):
        pivot = next((r for r in range(col, n) if a[r][col] != 0), None)
        if pivot is None:
            return Fraction(0)
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            det = -det
        det *= a[col][col]
        inv = a[col][col]
        for r in range(col + 1, n):
            factor = a[r][col] / inv
            for c in range(col, n):
                a[r][c] -= factor * a[col][c]
    return det


def matrix_rank(matrix: List[List[Fraction]]) -> int:
    """Exact rank via row reduction over the rationals."""
    a = [row[:] for row in matrix]
    rows = len(a)
    cols = len(a[0]) if rows else 0
    rank = 0
    pivot_col = 0
    for r in range(rows):
        if pivot_col >= cols:
            break
        # find a pivot in column pivot_col at or below row r
        piv = None
        c = pivot_col
        while c < cols and piv is None:
            piv = next((rr for rr in range(r, rows) if a[rr][c] != 0), None)
            if piv is None:
                c += 1
        if piv is None:
            break
        a[r], a[piv] = a[piv], a[r]
        inv = a[r][c]
        a[r] = [v / inv for v in a[r]]
        for rr in range(rows):
            if rr != r and a[rr][c] != 0:
                f = a[rr][c]
                a[rr] = [x - f * y for x, y in zip(a[rr], a[r])]
        rank += 1
        pivot_col = c + 1
    return rank


# --------------------------------------------------------------------------- #
# Sampling / lower-bound engine (Theorem 3.2 and Corollary 3.3).
# --------------------------------------------------------------------------- #
def evaluation_matrix(
    f: Callable[[Fraction, Fraction], Fraction],
    xs: Sequence[Fraction],
    ys: Sequence[Fraction],
) -> List[List[Fraction]]:
    """The sampling matrix M[i][j] = f(xs[i], ys[j])."""
    return [[f(x, y) for y in ys] for x in xs]


def separable_rank_lower_bound(
    f: Callable[[Fraction, Fraction], Fraction],
    xs: Sequence[Fraction],
    ys: Sequence[Fraction],
) -> int | None:
    """Return m if the m x m sample is invertible (certifies rank >= m), else None."""
    m = len(xs)
    assert len(ys) == m, "need a square sample"
    M = evaluation_matrix(f, xs, ys)
    return m if matrix_det(M) != 0 else None


# --------------------------------------------------------------------------- #
# Targets.
# --------------------------------------------------------------------------- #
def product_target(x: Fraction, y: Fraction) -> Fraction:
    return x * y


def sum_target(x: Fraction, y: Fraction) -> Fraction:
    return x + y


def power_sum(n: int) -> Callable[[Fraction, Fraction], Fraction]:
    def p(x: Fraction, y: Fraction) -> Fraction:
        return sum((x ** k) * (y ** k) for k in range(n))
    return p


def vandermonde(points: Sequence[Fraction]) -> List[List[Fraction]]:
    """V[i][k] = points[i] ** k."""
    n = len(points)
    return [[t ** k for k in range(n)] for t in points]


def vandermonde_det_product(points: Sequence[Fraction]) -> Fraction:
    """det V = product over i<j of (t_j - t_i)."""
    prod = Fraction(1)
    n = len(points)
    for j in range(n):
        for i in range(j):
            prod *= points[j] - points[i]
    return prod


# --------------------------------------------------------------------------- #
# Demonstrations.
# --------------------------------------------------------------------------- #
def demo_product_rank_one() -> None:
    print("=" * 70)
    print("PRODUCT  x*y  : separable rank 1  (mul_sepRankLE_one)")
    print("=" * 70)
    # rank-one decomposition a_0 = b_0 = id : every sample has rank <= 1.
    for xs, ys in [([Fraction(1), Fraction(2)], [Fraction(3), Fraction(5)])]:
        M = evaluation_matrix(product_target, xs, ys)
        print(f"  sample at xs={[str(x) for x in xs]}, ys={[str(y) for y in ys]}")
        print(f"  matrix = {[[str(v) for v in row] for row in M]}")
        print(f"  matrix rank = {matrix_rank(M)}  (<= 1 always)")
    # EML form on the positive quadrant: x*y = exp(log x + log y).
    x, y = 3.0, 5.0
    eml = math.exp(math.log(x) + math.log(y))
    print(f"  EML check: exp(log {x} + log {y}) = {eml:.6f}  vs  x*y = {x * y:.6f}")
    print()


def demo_sum_rank_two() -> None:
    print("=" * 70)
    print("SUM  x+y  : separable rank exactly 2  (add_sepRankLE_two,")
    print("            add_not_sepRankLE_one)")
    print("=" * 70)
    xs = [Fraction(0), Fraction(1)]
    ys = [Fraction(0), Fraction(1)]
    M = evaluation_matrix(sum_target, xs, ys)
    det = matrix_det(M)
    print(f"  2x2 sample at {{0,1}} = {[[str(v) for v in row] for row in M]}")
    print(f"  determinant = {det}  (!= 0  =>  rank >= 2)")
    cert = separable_rank_lower_bound(sum_target, xs, ys)
    print(f"  lower-bound certificate: separable rank >= {cert}")
    print("  upper bound: x+y = x*1 + 1*y  =>  separable rank <= 2")
    print("  => separable rank = 2")
    print()


def demo_power_sum_unbounded(max_n: int = 6) -> None:
    print("=" * 70)
    print("POWER-SUM  p_N = sum_{k<N} x^k y^k : separable rank exactly N")
    print("            (powerSum_sepRankLE, powerSum_rank_ge)")
    print("=" * 70)
    for n in range(1, max_n + 1):
        points = [Fraction(i) for i in range(n)]
        f = power_sum(n)
        M = evaluation_matrix(f, points, points)  # equals V V^T
        detV = vandermonde_det_product(points)
        detM = matrix_det(M)
        rank = matrix_rank(M)
        cert = separable_rank_lower_bound(f, points, points)
        ok = detM == detV * detV
        print(
            f"  N={n}: det V = {str(detV):>6}, det(V V^T) = {str(detM):>8}, "
            f"(det V)^2 = {str(detV * detV):>8}  [{'OK' if ok else 'FAIL'}]"
        )
        print(f"        sampled rank = {rank}, certified separable rank >= {cert} = N")
    print("  => the EML outer count grows without bound (unbounded separable rank)")
    print()


def main() -> None:
    demo_product_rank_one()
    demo_sum_rank_two()
    demo_power_sum_unbounded()


if __name__ == "__main__":
    main()
