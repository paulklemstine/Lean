from fractions import Fraction
from typing import List

Matrix = List[List[Fraction]]


def column_rank(m: Matrix) -> int:
    """Rank over Q via Gaussian elimination."""
    rows = [row[:] for row in m]
    ncols = len(rows[0]) if rows else 0
    r = 0
    col = 0
    rank = 0
    while r < len(rows) and col < ncols:
        piv = next((i for i in range(r, len(rows)) if rows[i][col] != 0), None)
        if piv is None:
            col += 1
            continue
        rows[r], rows[piv] = rows[piv], rows[r]
        pv = rows[r][col]
        rows[r] = [c / pv for c in rows[r]]
        for i in range(len(rows)):
            if i != r and rows[i][col] != 0:
                f = rows[i][col]
                rows[i] = [a - f * b for a, b in zip(rows[i], rows[r])]
        r += 1
        col += 1
        rank += 1
    return rank


def is_restriction_injective(rho: Matrix) -> bool:
    """rho : N -> N_U is injective iff it has full column rank (trivial kernel)."""
    ncols = len(rho[0]) if rho else 0
    return column_rank(rho) == ncols


def matmul(a: Matrix, b: Matrix) -> Matrix:
    return [[sum((a[i][k] * b[k][j] for k in range(len(b))), Fraction(0))
             for j in range(len(b[0]))] for i in range(len(a))]


def restriction_faithful(rho: Matrix, g1: Matrix, g2: Matrix) -> bool:
    """Realize `restriction_faithful`: given an injective target restriction rho and
    rho.g1 == rho.g2, conclude g1 == g2. Returns whether g1 == g2 is forced."""
    if not is_restriction_injective(rho):
        raise ValueError("restriction map must be injective (depth >= 1)")
    if matmul(rho, g1) != matmul(rho, g2):
        raise ValueError("hypothesis rho.g1 == rho.g2 is not satisfied")
    return g1 == g2
