from math import gcd
from typing import Callable, List, Tuple

def lcm(x: int, y: int) -> int:
    return 0 if x == 0 or y == 0 else x // gcd(x, y) * y

def joint_apparition(u: Callable[[int], int],
                     data: List[Tuple[int, int]], big_n: int) -> Tuple[int, int]:
    """Given primitive data [(p_i, rank_i), ...], return (period, count) where
    `period` = lcm of all ranks and `count` = number of indices e in 1..big_n with
    every p_i | u(e). By the finite join law the joint divisibility set is exactly
    the multiples of the lcm of the ranks, so count = floor(big_n / period)."""
    period = 1
    for _, r in data:
        period = lcm(period, r)
    count = big_n // period if period else 0
    return period, count
