from math import gcd
from typing import Callable, List, Optional, Tuple

def rank(u: Callable[[int], int], m: int, limit: int = 100_000) -> Optional[int]:
    for k in range(1, limit + 1):
        if m != 0 and u(k) % m == 0:
            return k
    return None

def meet_defects(u: Callable[[int], int], n: int) -> List[Tuple[int, int, int, int]]:
    out: List[Tuple[int, int, int, int]] = []
    for a in range(1, n + 1):
        for b in range(1, n + 1):
            g = rank(u, gcd(a, b))
            ra, rb = rank(u, a), rank(u, b)
            assert g is not None and ra is not None and rb is not None
            gr = gcd(ra, rb)
            assert gr % g == 0  # rank(gcd) | gcd(rank): the true one-sided law
            if g != gr:
                out.append((a, b, g, gr))
    return out