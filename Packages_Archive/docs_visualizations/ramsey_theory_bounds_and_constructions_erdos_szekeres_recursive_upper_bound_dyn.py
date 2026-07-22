from math import comb
from typing import Dict, Tuple


def erdos_szekeres_table(max_s: int, max_t: int) -> Dict[Tuple[int, int], int]:
    """
    Compute Erdos-Szekeres upper bounds for two-colour Ramsey numbers by
    dynamic programming on the recursion R(s,t) <= R(s-1,t) + R(s,t-1),
    with base cases R(1,t) = R(s,1) = 1.

    Returns a dict mapping (s, t) -> upper bound, for 1 <= s <= max_s,
    1 <= t <= max_t. Runs in O(max_s * max_t) time and space.
    """
    R: Dict[Tuple[int, int], int] = {}
    for s in range(1, max_s + 1):
        for t in range(1, max_t + 1):
            if s == 1 or t == 1:
                R[(s, t)] = 1
            else:
                R[(s, t)] = R[(s - 1, t)] + R[(s, t - 1)]
    return R


def binomial_bound(s: int, t: int) -> int:
    """Closed-form Erdos-Szekeres bound R(s,t) <= C(s+t-2, s-1)."""
    return comb(s + t - 2, s - 1)
