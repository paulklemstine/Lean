from __future__ import annotations
from typing import List, Sequence

def direct_sum(C1: Sequence[Sequence[float]],
               C2: Sequence[Sequence[float]],
               eps: float = 0.0) -> List[List[float]]:
    """Block-diagonal direct sum on n1 + n2 nodes. Cross-blocks carry weight eps
    (eps = 0 gives the strict direct sum, which is disconnected => Phi = 0).
    Complexity: O((n1+n2)^2)."""
    n1, n2 = len(C1), len(C2)
    n = n1 + n2
    M = [[0.0] * n for _ in range(n)]
    for i in range(n1):
        for j in range(n1):
            M[i][j] = C1[i][j]
    for i in range(n2):
        for j in range(n2):
            M[n1 + i][n1 + j] = C2[i][j]
    if eps != 0.0:
        for i in range(n1):
            for j in range(n2):
                M[i][n1 + j] = eps
                M[n1 + j][i] = eps
    return M
