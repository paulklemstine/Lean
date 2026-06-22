from math import gcd
from typing import Callable, Optional

def lcm(x: int, y: int) -> int:
    return 0 if x == 0 or y == 0 else x // gcd(x, y) * y

def rank(u: Callable[[int], int], m: int, limit: int = 100_000) -> Optional[int]:
    for k in range(1, limit + 1):
        if m != 0 and u(k) % m == 0:
            return k
    return None

def rank_lcm(u: Callable[[int], int], a: int, b: int) -> int:
    ra, rb = rank(u, a), rank(u, b)
    assert ra is not None and rb is not None
    return lcm(ra, rb)  # equals rank(u, lcm(a, b))