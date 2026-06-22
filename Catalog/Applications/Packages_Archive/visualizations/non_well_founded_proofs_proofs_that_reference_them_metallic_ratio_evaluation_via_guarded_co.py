from __future__ import annotations
import math
from typing import Tuple

def metallic(m: int, depth: int = 40) -> Tuple[float, float, float]:
    """Return (continued-fraction truncation, closed form, quadratic residual)."""
    x: float = float(m)
    for _ in range(depth):
        x = m + 1.0 / x
    phi: float = (m + math.sqrt(m * m + 4)) / 2.0
    residual: float = phi * phi - (m * phi + 1.0)
    return x, phi, residual
