from __future__ import annotations
import math
from fractions import Fraction
from typing import List, Optional
INF = math.inf
Matrix = List[List[float]]

def min_cycle_mean(a: Matrix) -> Optional[Fraction]:
    """
    Karp's minimum cycle mean = tropical eigenvalue lambda(A).
    d[t][v] = min weight of a length-t walk from source 0 to v; then
    lambda = min_v max_{0<=t<n} (d[n][v]-d[t][v])/(n-t). Runs in O(n^3).
    """
    n = len(a)
    if n == 0:
        return None
    d: List[List[Optional[Fraction]]] = [[None] * n for _ in range(n + 1)]
    d[0][0] = Fraction(0)
    for t in range(1, n + 1):
        for v in range(n):
            best: Optional[Fraction] = None
            for u in range(n):
                if d[t - 1][u] is not None and not math.isinf(a[u][v]):
                    cand = d[t - 1][u] + Fraction(int(a[u][v]))
                    if best is None or cand < best:
                        best = cand
            d[t][v] = best
    lam: Optional[Fraction] = None
    for v in range(n):
        if d[n][v] is None:
            continue
        worst: Optional[Fraction] = None
        for t in range(n):
            if d[t][v] is not None:
                val = Fraction(d[n][v] - d[t][v], n - t)
                if worst is None or val > worst:
                    worst = val
        if worst is not None and (lam is None or worst < lam):
            lam = worst
    return lam
