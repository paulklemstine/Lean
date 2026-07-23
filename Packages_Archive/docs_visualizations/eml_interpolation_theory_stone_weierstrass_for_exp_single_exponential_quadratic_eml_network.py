from __future__ import annotations
import math
from typing import Callable

def quadratic_network(epsilon: float) -> Callable[[float], float]:
    """Single-exponential EML network with sup error <= epsilon for x^2."""
    h: float = min(1.0, 9.0 * epsilon / 4.0)

    def approx(x: float) -> float:
        return (2.0 / h ** 2) * (math.exp(h * x) - 1.0 - h * x)

    return approx
