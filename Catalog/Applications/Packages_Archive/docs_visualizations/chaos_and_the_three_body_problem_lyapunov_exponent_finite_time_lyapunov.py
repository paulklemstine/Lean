from __future__ import annotations
import math
from typing import Callable, List

def finite_time_lyapunov(f: Callable[[float], float],
                         df: Callable[[float], float],
                         x: float, n: int) -> float:
    """Estimate the finite-time Lyapunov exponent log|(f^[n])'(x)| / n by
    accumulating the additive Birkhoff cocycle sum_{i<n} log|f'(f^[i] x)|.

    Working in logarithms (sum) rather than products avoids overflow from the
    c^n growth of the raw stretching factor. Complexity: O(n)."""
    if n < 1:
        raise ValueError("n must be >= 1")
    total: float = 0.0
    y: float = x
    for _ in range(n):
        total += math.log(abs(df(y)))
        y = f(y)
    return total / n
