from __future__ import annotations
from fractions import Fraction
from typing import List


def orbit(alpha: float, n: int) -> List[float]:
    """Phase-gate orbit { k*alpha mod 1 : k = 0..n-1 } on the circle R/Z."""
    return [(k * alpha) % 1.0 for k in range(n)]


def is_dense_estimate(alpha: float, n: int = 5000, bins: int = 50) -> bool:
    """Heuristic density test: every bin of [0,1) is hit by the orbit."""
    hit = [False] * bins
    for p in orbit(alpha, n):
        hit[min(int(p * bins), bins - 1)] = True
    return all(hit)


def rational_order(alpha: Fraction) -> int:
    """Finite order of a rational phase gate p/q (lowest terms) is q."""
    return alpha.denominator
