from math import gcd
from typing import Callable, Optional


def rank_of_apparition(u: Callable[[int], int], p: int,
                       search_bound: int = 10000) -> Optional[int]:
    """Least positive k with p | u(k); None if not found within search_bound."""
    if p == 0:
        return None
    for k in range(1, search_bound + 1):
        if u(k) % p == 0:
            return k
    return None
