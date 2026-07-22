from typing import List
Matrix = List[List[int]]

def rank_f2(mat: Matrix) -> int:
    """Rank of a binary matrix by Gaussian elimination over F2."""
    if not mat or not mat[0]:
        return 0
    rows = [r[:] for r in mat]
    nr, nc = len(rows), len(rows[0])
    piv, rank = 0, 0
    for c in range(nc):
        sel = next((r for r in range(piv, nr) if rows[r][c]), None)
        if sel is None:
            continue
        rows[piv], rows[sel] = rows[sel], rows[piv]
        for r in range(nr):
            if r != piv and rows[r][c]:
                rows[r] = [a ^ b for a, b in zip(rows[r], rows[piv])]
        piv += 1; rank += 1
    return rank

def code_parameters(d1: Matrix, d2: Matrix, n: int) -> tuple[int, int]:
    """Return (n, k) with k = n - rank(d1) - rank(d2)."""
    return n, n - rank_f2(d1) - rank_f2(d2)
