from __future__ import annotations
from typing import List

Mat = List[List[int]]

def gf2_rank(matrix: Mat) -> int:
    """Rank of a 0/1 matrix over GF(2); the number of pivot columns
    produced by Gaussian elimination with XOR row operations."""
    rows: Mat = [row[:] for row in matrix]
    if not rows:
        return 0
    n_cols: int = len(rows[0])
    rank: int = 0
    pivot: int = 0
    for col in range(n_cols):
        sel: int = next((r for r in range(pivot, len(rows)) if rows[r][col] == 1), -1)
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
