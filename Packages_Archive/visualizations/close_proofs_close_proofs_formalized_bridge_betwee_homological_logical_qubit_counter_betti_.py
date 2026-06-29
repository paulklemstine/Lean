from __future__ import annotations
from typing import List

Mat = List[List[int]]

def gf2_rank(matrix: Mat) -> int:
    """Rank over GF(2) by Gaussian elimination. O(r*c*min(r,c))."""
    rows: Mat = [row[:] for row in matrix]
    if not rows:
        return 0
    n_cols: int = len(rows[0])
    rank: int = 0
    pivot: int = 0
    for col in range(n_cols):
        sel: int = -1
        for r in range(pivot, len(rows)):
            if rows[r][col] == 1:
                sel = r
                break
        if sel == -1:
            continue
        rows[pivot], rows[sel] = rows[sel], rows[pivot]
        for r in range(len(rows)):
            if r != pivot and rows[r][col] == 1:
                rows[r] = [a ^ b for a, b in zip(rows[r], rows[pivot])]
        rank += 1
        pivot += 1
        if pivot == len(rows):
            break
    return rank

def betti1(d1: Mat, d2: Mat, n: int) -> int:
    """First Betti number = dim ker(d1) - rank(d2) = #logical qubits."""
    dim_cycles: int = n - gf2_rank(d1)   # rank-nullity
    dim_boundaries: int = gf2_rank(d2)
    return dim_cycles - dim_boundaries
