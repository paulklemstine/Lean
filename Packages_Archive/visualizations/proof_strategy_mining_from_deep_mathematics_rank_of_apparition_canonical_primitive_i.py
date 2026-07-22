from math import gcd
from typing import Callable, Optional

def rank_of_apparition(u: Callable[[int], int], p: int, search: int = 2000) -> Optional[int]:
    """Least positive index k with p | u_k (the rank of apparition of p in u).

    Returns None if p does not appear within the search window. For a strong
    divisibility sequence this index is the unique primitive index of p, and the
    full divisibility set of p is exactly its multiples (the pinning law).
    """
    for k in range(1, search + 1):
        if u(k) % p == 0:
            return k
    return None
