from __future__ import annotations
import math
from typing import List, Sequence

Vector = List[float]

def _centroid(p: Sequence[float], V: Sequence[Vector]) -> Vector:
    dim = len(V[0])
    x = [0.0] * dim
    for pi, Vi in zip(p, V):
        for d in range(dim):
            x[d] += pi * Vi[d]
    return x

def greedy_caratheodory(p: Sequence[float], V: Sequence[Vector], k: int
                        ) -> tuple[List[int], Vector, float]:
    """Deterministic greedy arg-min selection of k vertices (with repetition).

    Returns (indices, average, squared_error). By the main theorem the squared
    error is <= tau/k <= R^2/k, where tau = sum_i p_i ||V_i - x||^2.
    """
    x = _centroid(p, V)
    dim = len(V[0])
    s = [0.0] * dim            # running deviation sum s_0 = 0
    idx: List[int] = []
    for _ in range(k):
        best_i, best_val = 0, math.inf
        for i in range(len(V)):
            val = sum((s[d] + (V[i][d] - x[d])) ** 2 for d in range(dim))
            if val < best_val:
                best_i, best_val = i, val
        idx.append(best_i)
        for d in range(dim):
            s[d] += V[best_i][d] - x[d]   # s_{t+1} = s_t + dev(i_t)
    avg = [0.0] * dim
    for i in idx:
        for d in range(dim):
            avg[d] += V[i][d] / k
    err = sum((x[d] - avg[d]) ** 2 for d in range(dim))
    return idx, avg, err
