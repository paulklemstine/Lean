from __future__ import annotations
import math
from typing import Callable, List

def jackson_interpolant(f: Callable[[float], float], L: float,
                        alpha: float, epsilon: float
                        ) -> Callable[[float], float]:
    """Width-n piecewise-linear EML interpolant with error <= 2L/n^alpha."""
    n: int = max(1, math.ceil((2.0 * L / epsilon) ** (1.0 / alpha)))
    nodes: List[float] = [f(j / n) for j in range(n + 1)]

    def approx(x: float) -> float:
        k: int = min(n - 1, math.floor(n * x))
        a: float = k / n
        b: float = (k + 1) / n
        slope: float = (nodes[k + 1] - nodes[k]) / (b - a)
        return nodes[k] + slope * (x - a)

    return approx
