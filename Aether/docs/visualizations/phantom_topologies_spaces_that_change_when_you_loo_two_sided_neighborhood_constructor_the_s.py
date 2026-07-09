from __future__ import annotations
from typing import Tuple


def build_euclidean_ball(a: float, x: float, b: float) -> Tuple[float, float, float]:
    """From one-sided certificates (a, x] and [x, b), build a two-sided ball.

    Returns (epsilon, lo, hi) with lo = x - epsilon, hi = x + epsilon, so that
    (lo, hi) is contained in (a, x] U [x, b) = (a, b).
    """
    assert a < x < b, "require a < x < b"
    epsilon = min(x - a, b - x)
    return epsilon, x - epsilon, x + epsilon
