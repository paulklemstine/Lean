from __future__ import annotations
from typing import Callable, Optional


def entry_point(u: Callable[[int], int], m: int, limit: int = 5000) -> Optional[int]:
    """Least k > 0 with m | u(k)."""
    if m == 0:
        return None
    for k in range(1, limit + 1):
        if u(k) % m == 0:
            return k
    return None


def divides_term(u: Callable[[int], int], m: int, k: int,
                 cache: dict[int, int] | None = None) -> bool:
    """
    Decide whether m | u(k) WITHOUT forming the (possibly astronomically large)
    term u(k), using the law of apparition (Theorem 5.1):

        m | u(k)  <=>  entry(m) | k.

    entry(m) is computed once (and may be cached across many queries on k).
    """
    if cache is None:
        cache = {}
    if m not in cache:
        e = entry_point(u, m)
        if e is None:
            return False  # m does not appear
        cache[m] = e
    return k % cache[m] == 0
