from __future__ import annotations
import math
from typing import Sequence


def kl_ber(p: float, q: float) -> float:
    """KL divergence between Bernoulli(p) and Bernoulli(q), p, q in (0,1)."""
    return p * math.log(p / q) + (1 - p) * math.log((1 - p) / (1 - q))


def bernoulli_gap(p: float, q: float) -> float:
    """g(q) = KL(Ber p || Ber q) - 2(p-q)^2; provably >= 0."""
    return kl_ber(p, q) - 2.0 * (p - q) ** 2


def gap_derivative(p: float, q: float) -> float:
    """Closed-form g'(q) = (q-p)(1-2q)^2 / (q(1-q))."""
    return (q - p) * (1 - 2 * q) ** 2 / (q * (1 - q))


def verify(p: float, grid: Sequence[float], h: float = 1e-6) -> bool:
    for q in grid:
        assert bernoulli_gap(p, q) >= -1e-9
        num = (bernoulli_gap(p, q + h) - bernoulli_gap(p, q - h)) / (2 * h)
        assert abs(gap_derivative(p, q) - num) < 1e-4
    return True
