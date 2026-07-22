from __future__ import annotations
import math
from typing import Callable, Literal

Verdict = Literal["log-linear", "strictly log-convex", "log-concave", "mixed"]

def sign(x: int) -> int:
    return (x > 0) - (x < 0)

def classify_curvature(a: Callable[[int], int], upto: int = 16) -> Verdict:
    """Classify a positive integer sequence by the sign pattern of
    D(n) = a(n)*a(n+2) - a(n+1)^2 for n in [0, upto)."""
    signs = {sign(a(n) * a(n + 2) - a(n + 1) ** 2) for n in range(upto)}
    if signs == {0}:
        return "log-linear"
    if signs <= {1}:
        return "strictly log-convex"
    if signs <= {-1, 0}:
        return "log-concave"
    return "mixed"
