from fractions import Fraction
from typing import List

Matrix = List[List[Fraction]]


def exact_rank(a: Matrix) -> int:
    """Exact rank of a rational matrix via Gaussian elimination (no rounding)."""
    mat = [row[:] for row in a]
    rows = len(mat)
    cols = len(mat[0]) if rows else 0
    r = 0
    for c in range(cols):
        pivot = next((i for i in range(r, rows) if mat[i][c] != 0), None)
        if pivot is None:
            continue
        mat[r], mat[pivot] = mat[pivot], mat[r]
        for i in range(rows):
            if i != r and mat[i][c] != 0:
                factor = mat[i][c] / mat[r][c]
                mat[i] = [mat[i][j] - factor * mat[r][j] for j in range(cols)]
        r += 1
        if r == rows:
            break
    return r
