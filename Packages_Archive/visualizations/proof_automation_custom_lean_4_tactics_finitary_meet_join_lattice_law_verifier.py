from functools import reduce
from math import gcd
from typing import Callable, Sequence, Tuple


def lcm(x: int, y: int) -> int:
    """Least common multiple on N; lcm(0, y) = 0 (0 is the divisibility top)."""
    if x == 0 or y == 0:
        return 0
    return x // gcd(x, y) * y


def verify_finitary_laws(
    a: Callable[[int], int], indices: Sequence[int]
) -> Tuple[bool, bool]:
    """Verify the finitary meet law (exact) and join sub-law (divides) for a
    strong divisibility sequence `a` over a finite family of `indices`.

    Returns (meet_ok, join_ok) where
        meet_ok :  gcd_i a(g_i) == a(gcd_i g_i)
        join_ok :  lcm_i a(g_i) divides a(lcm_i g_i)
    """
    g_idx: int = reduce(gcd, indices, 0)        # gcd of empty family = 0
    l_idx: int = reduce(lcm, indices, 1)        # lcm of empty family = 1
    meet_lhs: int = reduce(gcd, (a(g) for g in indices), 0)
    join_lhs: int = reduce(lcm, (a(g) for g in indices), 1)
    meet_ok: bool = meet_lhs == a(g_idx)
    a_l: int = a(l_idx)
    join_ok: bool = join_lhs != 0 and a_l % join_lhs == 0
    return meet_ok, join_ok
