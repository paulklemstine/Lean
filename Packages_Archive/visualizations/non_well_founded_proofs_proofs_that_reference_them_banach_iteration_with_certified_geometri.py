from __future__ import annotations
import math
from typing import Tuple

def banach_fix(c: float, b: float, x0: float, eps: float = 1e-12) -> Tuple[float, float, int]:
    """Iterate f(x)=c*x+b to its unique fixed point with certified tolerance."""
    if abs(c) >= 1.0:
        raise ValueError('|c| >= 1: f is not a contraction')
    x_star: float = b / (1.0 - c)
    e0: float = abs(x0 - x_star)
    k: int = 0 if e0 <= eps else math.ceil(math.log(eps / e0) / math.log(abs(c))) if e0 > 0 else 0
    x: float = x0
    for _ in range(max(k, 0)):
        x = c * x + b
    return x, x_star, max(k, 0)
