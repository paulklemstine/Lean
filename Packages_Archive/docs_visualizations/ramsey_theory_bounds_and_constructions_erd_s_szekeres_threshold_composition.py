from math import comb
from typing import List

def es_threshold(s: int, t: int) -> int:
    """Erdos-Szekeres upper bound for R(s,t): C(s+t-2, s-1)."""
    B: List[List[int]] = [[1] * (t + 1) for _ in range(s + 1)]
    for i in range(2, s + 1):
        for j in range(2, t + 1):
            B[i][j] = B[i - 1][j] + B[i][j - 1]
    assert B[s][t] == comb(s + t - 2, s - 1)
    return B[s][t]