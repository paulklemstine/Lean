from __future__ import annotations
from typing import List, Sequence, Tuple

Vector = Tuple[float, ...]

def moment_matrix(X: Sequence[Vector], n: int) -> List[List[float]]:
    M = [[0.0] * n for _ in range(n)]
    for x in X:
        for i in range(n):
            for j in range(n):
                M[i][j] += x[i] * x[j]
    return M

def degree_two_in_hst(X: Sequence[Vector], n: int, tol: float = 1e-9) -> bool:
    """Decide 2 in Hst(X) by testing isotropy of the moment matrix."""
    M = moment_matrix(X, n)
    target = len(X) / n
    for i in range(n):
        for j in range(n):
            expected = target if i == j else 0.0
            if abs(M[i][j] - expected) > tol:
                return False
    return True
