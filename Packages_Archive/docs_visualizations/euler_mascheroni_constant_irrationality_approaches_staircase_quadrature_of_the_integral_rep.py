from __future__ import annotations
import math

def staircase_partial(N: int) -> float:
    """Exact value of int_1^N (1/floor(x) - 1/x) dx, computed term by
    term as sum_{k=1}^{N-1} g(k) with g(k) = 1/k - ln(1 + 1/k).
    Converges to the Euler-Mascheroni constant as N -> infinity."""
    total: float = 0.0
    for k in range(1, N):
        total += 1.0 / k - math.log(1.0 + 1.0 / k)
    return total
