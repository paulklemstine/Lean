from math import gcd
from typing import Callable, Optional


def lcm(a: int, b: int) -> int:
    return 0 if a == 0 or b == 0 else a // gcd(a, b) * b


def joint_divides_by_criterion(u: Callable[[int], int], p: int, q: int, n: int,
                               search_bound: int = 10000) -> Optional[bool]:
    """Whether p | u(n) AND q | u(n), via the join law lcm(rank p, rank q) | n."""
    rp = rank_of_apparition(u, p, search_bound)
    rq = rank_of_apparition(u, q, search_bound)
    if rp is None or rq is None:
        return None
    return n % lcm(rp, rq) == 0
