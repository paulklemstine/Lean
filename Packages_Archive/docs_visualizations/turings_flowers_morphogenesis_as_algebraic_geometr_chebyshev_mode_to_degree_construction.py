from __future__ import annotations
from typing import List


def chebyshev_T(n: int) -> List[float]:
    """Coefficients [c_0..c_n] of T_n with T_n(cos t) = cos(n t)."""
    if n == 0:
        return [1.0]
    if n == 1:
        return [0.0, 1.0]
    prev2, prev1 = [1.0], [0.0, 1.0]
    for _ in range(2, n + 1):
        cur = [0.0] + [2.0 * c for c in prev1]
        for i, c in enumerate(prev2):
            cur[i] -= c
        prev2, prev1 = prev1, cur
    return prev1


def degree(coeffs: List[float], tol: float = 1e-9) -> int:
    return max(i for i, c in enumerate(coeffs) if abs(c) > tol)
