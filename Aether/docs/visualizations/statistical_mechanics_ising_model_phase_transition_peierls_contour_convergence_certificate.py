from __future__ import annotations
import math


def peierls_weight(beta: float) -> float:
    """The energy-vs-entropy ratio x = 3 e^{-2 beta} controlling contour convergence."""
    return 3.0 * math.exp(-2.0 * beta)


def peierls_bound(beta: float) -> float:
    """Return sum_{L>=4} L x^L with x = 3 e^{-2 beta}; +inf if x >= 1 (divergent).

    Uses the closed form sum_{L>=1} L x^L = x/(1-x)^2 minus the L=1,2,3 terms.
    """
    x = peierls_weight(beta)
    if x >= 1.0:
        return math.inf
    full = x / (1.0 - x) ** 2          # sum_{L>=1} L x^L
    head = 1 * x + 2 * x ** 2 + 3 * x ** 3
    return full - head


def orders_at(beta: float) -> bool:
    """True if the Peierls bound certifies order (bound < 1/2)."""
    return peierls_bound(beta) < 0.5
