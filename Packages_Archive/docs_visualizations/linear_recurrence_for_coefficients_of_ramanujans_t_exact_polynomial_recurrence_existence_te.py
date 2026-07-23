from fractions import Fraction
from typing import List

def rank_exact(rows: List[List[Fraction]]) -> int:
    """Rank of a rational matrix via fraction-free Gaussian elimination."""
    mat = [row[:] for row in rows]
    if not mat:
        return 0
    ncols = len(mat[0])
    rank = 0
    pivot_row = 0
    for col in range(ncols):
        piv = next((r for r in range(pivot_row, len(mat)) if mat[r][col] != 0), None)
        if piv is None:
            continue
        mat[pivot_row], mat[piv] = mat[piv], mat[pivot_row]
        pv = mat[pivot_row][col]
        for r in range(len(mat)):
            if r != pivot_row and mat[r][col] != 0:
                f = mat[r][col] / pv
                mat[r] = [mat[r][c] - f * mat[pivot_row][c] for c in range(ncols)]
        rank += 1
        pivot_row += 1
        if pivot_row == len(mat):
            break
    return rank

def recurrence_exists(a: List[int], order: int, degree: int) -> bool:
    """True iff a nonzero recurrence sum_i p_i(n) a_{n+i}=0, deg p_i<=degree, exists."""
    nunknown = (order + 1) * (degree + 1)
    max_n = len(a) - order
    if max_n <= nunknown:
        raise ValueError("supply more coefficients to certify")
    rows: List[List[Fraction]] = []
    for n in range(max_n):
        row: List[Fraction] = []
        for i in range(order + 1):
            for j in range(degree + 1):
                row.append(Fraction(a[n + i]) * Fraction(n) ** j)
        rows.append(row)
    return rank_exact(rows) < nunknown
