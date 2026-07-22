from __future__ import annotations
from itertools import product
from typing import List, Tuple

Matrix = Tuple[Tuple[int, ...], ...]

def enumerate_gl_f2(n: int) -> List[Matrix]:
    """Enumerate GL(n,2): all invertible n x n matrices over F_2.

    Uses F_2 Gaussian elimination (rank test) on each of the 2^(n^2) candidate
    matrices. Feasible for n <= 3 (|GL(3,2)| = 168). |GL(n,2)| grows as
    prod_{k=0}^{n-1} (2^n - 2^k).
    """
    def full_rank(mat: Matrix) -> bool:
        rows = [sum((mat[i][j] & 1) << j for j in range(n)) for i in range(n)]
        rank = 0
        for col in range(n):
            pivot = next((r for r in range(rank, n) if (rows[r] >> col) & 1), None)
            if pivot is None:
                continue
            rows[rank], rows[pivot] = rows[pivot], rows[rank]
            for r in range(n):
                if r != rank and (rows[r] >> col) & 1:
                    rows[r] ^= rows[rank]
            rank += 1
        return rank == n

    result: List[Matrix] = []
    for flat in product((0, 1), repeat=n * n):
        mat = tuple(tuple(flat[i * n + j] for j in range(n)) for i in range(n))
        if full_rank(mat):
            result.append(mat)
    return result
