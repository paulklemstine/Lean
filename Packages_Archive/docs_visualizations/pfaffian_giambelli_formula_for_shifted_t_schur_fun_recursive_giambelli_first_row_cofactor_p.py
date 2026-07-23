from __future__ import annotations
from typing import List

Matrix = List[List[float]]

def pfaffian_giambelli(a: Matrix) -> float:
    """Pfaffian by first-row cofactor (Giambelli) recursion:
    Pf(A) = sum_{j>=1} (-1)^(j-1) A[0][j] Pf(A with rows/cols 0,j deleted)."""
    n = len(a)
    if n == 0:
        return 1.0
    assert n % 2 == 0, "Pfaffian requires an even dimension"

    def delete(m: Matrix, p: int, q: int) -> Matrix:
        keep = [r for r in range(len(m)) if r != p and r != q]
        return [[m[r][c] for c in keep] for r in keep]

    total = 0.0
    for j in range(1, n):
        sign = -1.0 if (j - 1) % 2 else 1.0
        total += sign * a[0][j] * pfaffian_giambelli(delete(a, 0, j))
    return total
