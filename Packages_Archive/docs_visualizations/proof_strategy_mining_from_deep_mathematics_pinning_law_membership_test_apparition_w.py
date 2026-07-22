from math import gcd
from typing import Callable, Optional

def divides_term(u: Callable[[int], int], p: int, m: int,
                 rank: Optional[int] = None) -> bool:
    """Decide  p | u_m  using the pinning law instead of computing u_m.

    For a strong divisibility sequence, p | u_m  <=>  rank(p) | m. We compute the
    rank once (least k with p | u_k) and thereafter answer membership queries by a
    single divisibility test, never forming the (possibly huge) term u_m.
    """
    if rank is None:
        rank = None
        for k in range(1, 2001):
            if u(k) % p == 0:
                rank = k
                break
        if rank is None:
            return False  # p never appears
    return m % rank == 0
