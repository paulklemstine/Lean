from __future__ import annotations
from typing import Callable, Optional


def rank_of_apparition(
    u: Callable[[int], int], m: int, search_limit: int = 1_000_000
) -> Optional[int]:
    """Least k > 0 with m | u(k); None if none is found within search_limit.

    By the spine theorem, the full appearance set is {k, 2k, 3k, ...}.
    """
    if m == 0:
        return None
    for k in range(1, search_limit + 1):
        if u(k) % m == 0:
            return k
    return None
