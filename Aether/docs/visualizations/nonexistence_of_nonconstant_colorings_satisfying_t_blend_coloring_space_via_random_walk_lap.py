from __future__ import annotations
from typing import List

def blend_coloring_dimension(W: List[List[float]], tol: float = 1e-9) -> int:
    """Return dim ker(I - W), the dimension of the blend-coloring space.

    Under strong connectivity + row-stochasticity this equals 1 (only constants).
    """
    n = len(W)
    L = [[(1.0 if i == j else 0.0) - float(W[i][j]) for j in range(n)]
         for i in range(n)]
    rank, r, col = 0, 0, 0
    while r < n and col < n:
        pivot = max(range(r, n), key=lambda k: abs(L[k][col]))
        if abs(L[pivot][col]) <= tol:
            col += 1
            continue
        L[r], L[pivot] = L[pivot], L[r]
        pv = L[r][col]
        L[r] = [x / pv for x in L[r]]
        for k in range(n):
            if k != r and abs(L[k][col]) > tol:
                f = L[k][col]
                L[k] = [a - f * b for a, b in zip(L[k], L[r])]
        r += 1
        rank += 1
        col += 1
    return n - rank
