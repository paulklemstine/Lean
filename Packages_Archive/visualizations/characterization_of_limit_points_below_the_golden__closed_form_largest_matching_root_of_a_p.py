from __future__ import annotations
import math


def largest_matching_root(n: int) -> float:
    """Closed-form largest matching root of the path P_n (n >= 1):
        mu(P_n) = 2 cos(pi / (n + 1)).
    Derived from the fact that the full root set of mu(P_n) is
        { 2 cos(k pi/(n+1)) : k = 1, ..., n },
    the maximum occurring at k = 1. Complexity: O(1).
    """
    if n < 1:
        raise ValueError("n must be >= 1")
    return 2.0 * math.cos(math.pi / (n + 1))


def all_matching_roots(n: int) -> list[float]:
    """All n roots of mu(P_n), largest first. Complexity: O(n)."""
    return [2.0 * math.cos(k * math.pi / (n + 1)) for k in range(1, n + 1)]
