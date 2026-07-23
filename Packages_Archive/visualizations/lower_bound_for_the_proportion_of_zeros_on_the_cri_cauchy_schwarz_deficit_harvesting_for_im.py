from __future__ import annotations
from typing import Sequence


def improved_constant(nonzero_weights: Sequence[float], degree: int = 3) -> float:
    """Return the improved proportion constant (1/d^2)(1 + c).

    c = variance/mean^2 of the on-line weights. Runs in O(k) time,
    k = number of on-line zeros.
    """
    k = len(nonzero_weights)
    base = 1.0 / (degree * degree)
    if k == 0:
        return base
    mu = sum(nonzero_weights) / k
    if mu == 0.0:
        return base
    var = sum((w - mu) ** 2 for w in nonzero_weights) / k
    return base * (1.0 + var / (mu * mu))
