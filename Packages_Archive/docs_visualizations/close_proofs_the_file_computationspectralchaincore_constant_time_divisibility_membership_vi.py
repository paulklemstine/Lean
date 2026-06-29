from math import gcd
from typing import Callable, Optional

def divides_value(u: Callable[[int], int], p: int, m: int,
                  rank: Optional[int] = None) -> bool:
    """Decide whether p | u(m) WITHOUT computing the (possibly enormous) value u(m).

    Strategy (law of apparition): compute the rank of apparition n of p once, then
    p | u(m) holds iff n | m. After the O(n) up-front scan, each query is O(1)."""
    if rank is None:
        n = 1
        while u(n) % p != 0:
            n += 1
        rank = n
    return m % rank == 0
