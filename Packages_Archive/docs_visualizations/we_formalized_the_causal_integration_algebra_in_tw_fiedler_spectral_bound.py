from __future__ import annotations
from typing import List, Sequence, Tuple

def symmetrize(weight: Sequence[Sequence[float]]) -> List[List[float]]:
    """Undirected weights: w[i][j] + w[j][i]."""
    n = len(weight)
    return [[weight[i][j] + weight[j][i] for j in range(n)] for i in range(n)]

def laplacian(undirected: Sequence[Sequence[float]]) -> List[List[float]]:
    """Graph Laplacian L = D - W of a symmetric weight matrix."""
    n = len(undirected)
    deg = [sum(undirected[i]) for i in range(n)]
    return [[(deg[i] if i == j else 0.0) - undirected[i][j]
             for j in range(n)] for i in range(n)]

def fiedler_value(weight: Sequence[Sequence[float]],
                  iters: int = 500) -> float:
    """Second-smallest Laplacian eigenvalue (Fiedler value) via deflated
    power iteration on (cI - L). Provides a spectral handle on the min cut
    through Cheeger's inequality. Complexity: O(iters * n^2)."""
    import math
    W = symmetrize(weight)
    L = laplacian(W)
    n = len(L)
    c = max(sum(abs(x) for x in row) for row in L) + 1.0  # shift
    M = [[(c if i == j else 0.0) - L[i][j] for j in range(n)] for i in range(n)]
    ones = [1.0 / math.sqrt(n)] * n  # known eigenvector of L (eigenvalue 0)

    def project_out(v: List[float]) -> List[float]:
        d = sum(v[i] * ones[i] for i in range(n))
        return [v[i] - d * ones[i] for i in range(n)]

    v = project_out([math.sin(i + 1.0) for i in range(n)])
    for _ in range(iters):
        w = [sum(M[i][j] * v[j] for j in range(n)) for i in range(n)]
        w = project_out(w)
        nrm = math.sqrt(sum(x * x for x in w)) or 1.0
        v = [x / nrm for x in w]
    Mv = [sum(M[i][j] * v[j] for j in range(n)) for i in range(n)]
    mu = sum(v[i] * Mv[i] for i in range(n))  # top eigval of M
    return c - mu  # back out lambda_2 of L
