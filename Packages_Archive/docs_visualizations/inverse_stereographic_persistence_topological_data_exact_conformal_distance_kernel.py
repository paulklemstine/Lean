from __future__ import annotations
import math
from typing import List

Vec = List[float]

def conformal_chordal(x: Vec, y: Vec) -> float:
    """Exact chordal sphere distance between inverse-stereographic images,
    computed entirely in R^n via the conformal identity."""
    X = sum(xi * xi for xi in x)
    Y = sum(yi * yi for yi in y)
    e2 = sum((a - b) ** 2 for a, b in zip(x, y))
    return 2.0 * math.sqrt(e2) / math.sqrt((1.0 + X) * (1.0 + Y))
