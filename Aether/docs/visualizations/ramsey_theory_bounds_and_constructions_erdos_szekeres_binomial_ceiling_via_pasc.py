from math import comb
from typing import Dict, Tuple


def erdos_szekeres_ceiling(s: int, t: int) -> int:
    """Return the Erdos-Szekeres upper bound R(s,t) <= C(s+t-2, s-1)."""
    U: Dict[Tuple[int, int], int] = {}
    for a in range(1, s + 1):
        for b in range(1, t + 1):
            U[(a, b)] = 1 if (a == 1 or b == 1) else U[(a - 1, b)] + U[(a, b - 1)]
    assert U[(s, t)] == comb(s + t - 2, s - 1)
    return U[(s, t)]
