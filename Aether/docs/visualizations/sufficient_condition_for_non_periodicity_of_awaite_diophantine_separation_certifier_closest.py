from __future__ import annotations
import math
from typing import Tuple

def sqrt_separation_constant(d: int) -> float:
    """The explicit constant c = 1/(2*sqrt(d)+1) from sqrt_Diophantine."""
    return 1.0 / (2.0 * math.sqrt(d) + 1.0)

def certify_diophantine(d: int, B: int, c: float) -> Tuple[bool, float]:
    """Verify |sqrt(d) - a/b| >= c/b^2 for all 1<=b<=B. The only candidate
    violator for each b is a = round(b*sqrt(d)) (the closest integer)."""
    root = math.sqrt(d)
    ok = True
    worst = math.inf
    for b in range(1, B + 1):
        a = round(root * b)
        err = abs(root - a / b)
        worst = min(worst, b * b * err)
        if err < c / (b * b) - 1e-12:
            ok = False
    return ok, worst
