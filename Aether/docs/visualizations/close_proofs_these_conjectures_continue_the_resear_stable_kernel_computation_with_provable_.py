from __future__ import annotations
from fractions import Fraction
from typing import List

Matrix = List[List[Fraction]]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Exact product of two compatible rational matrices."""
    n, m, p = len(a), len(b), len(b[0])
    out = [[Fraction(0) for _ in range(p)] for _ in range(n)]
    for i in range(n):
        for k in range(m):
            if a[i][k] == 0:
                continue
            for j in range(p):
                out[i][j] += a[i][k] * b[k][j]
    return out


def matrix_rank(a: Matrix) -> int:
    """Exact rank via Gaussian elimination over Q."""
    m = [row[:] for row in a]
    rows = len(m)
    cols = len(m[0]) if rows else 0
    rank, col = 0, 0
    for r in range(rows):
        if col >= cols:
            break
        piv = None
        while col < cols:
            piv = next((i for i in range(r, rows) if m[i][col] != 0), None)
            if piv is not None:
                break
            col += 1
        if col >= cols:
            break
        m[r], m[piv] = m[piv], m[r]
        inv = m[r][col]
        m[r] = [x / inv for x in m[r]]
        for i in range(rows):
            if i != r and m[i][col] != 0:
                f = m[i][col]
                m[i] = [x - f * y for x, y in zip(m[i], m[r])]
        rank += 1
        col += 1
    return rank


def stable_kernel_dimension(a: Matrix) -> int:
    """Compute dim ker(g^infty) for a square rational matrix `a`.

    By the Fitting Kernel Bound, the kernel chain stabilizes by step d = dim V,
    and we may stop as soon as two consecutive kernel dimensions coincide
    (early termination, justified by ker_pow_stable). Returns the stable
    nullity, which equals dim ker(g^d).
    """
    d = len(a)
    n = d  # dimension of the ambient space = number of columns
    power = [row[:] for row in a]            # current g^k, starting k=1
    prev_nullity = n - matrix_rank(power) if d else 0  # nullity of g^1
    # nullity of g^0 = 0; compare consecutive nullities, stop at first plateau
    nullity_prev_prev = 0
    if prev_nullity == nullity_prev_prev:
        return prev_nullity
    for _ in range(2, d + 1):
        power = matmul(power, a)
        nullity = n - matrix_rank(power)
        if nullity == prev_nullity:
            return nullity            # plateau reached: chain is now constant
        prev_nullity = nullity
    return prev_nullity               # guaranteed stable by step d
