from __future__ import annotations
from typing import List

def is_locally_dense(W: List[List[float]], rho: float, tol: float = 1e-12) -> bool:
    """Exact brute-force test of rho-local density of a symmetric kernel."""
    n = len(W)
    for mask in range(1 << n):
        S = [i for i in range(n) if (mask >> i) & 1]
        total = sum(W[i][j] for i in S for j in S)
        if total + tol < rho * len(S) ** 2:
            return False
    return True
