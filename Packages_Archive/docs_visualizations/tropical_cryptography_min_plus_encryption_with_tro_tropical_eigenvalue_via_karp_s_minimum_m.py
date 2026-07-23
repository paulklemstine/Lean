from __future__ import annotations
import math
from typing import List

INF = math.inf
Matrix = List[List[float]]

def min_mean_cycle_eigenvalue(A: Matrix) -> float:
    """
    Tropical eigenvalue via Karp's minimum-mean-cycle algorithm:
        lambda(A) = min over cycles C of (sum of weights on C) / (length of C).
    Time O(n * E). Edges with weight +inf are absent.
    """
    n = len(A)
    d = [[INF] * n for _ in range(n + 1)]
    for v in range(n):
        d[0][v] = 0.0
    for k in range(1, n + 1):
        for v in range(n):
            best = INF
            for u in range(n):
                if A[u][v] != INF and d[k - 1][u] != INF:
                    best = min(best, d[k - 1][u] + A[u][v])
            d[k][v] = best
    lam = INF
    for v in range(n):
        if d[n][v] == INF:
            continue
        worst = -INF
        for k in range(n):
            if d[k][v] == INF:
                worst = INF
                break
            worst = max(worst, (d[n][v] - d[k][v]) / (n - k))
        lam = min(lam, worst)
    return lam
