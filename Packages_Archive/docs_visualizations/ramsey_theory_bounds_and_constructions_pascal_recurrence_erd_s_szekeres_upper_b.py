from math import comb
from typing import List

def erdos_szekeres_bound(s: int, t: int) -> int:
    """Certified upper bound R(s+1, t+1) <= C(s+t, s)."""
    return comb(s + t, s)

def bound_table(max_k: int = 5) -> List[List[int]]:
    return [[erdos_szekeres_bound(s, t) for t in range(max_k)]
            for s in range(max_k)]
