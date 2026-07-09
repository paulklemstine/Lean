from itertools import combinations
from typing import List, Set


def closed_neighborhood(n: int, v: int) -> Set[int]:
    """Closed neighborhood {v-1, v, v+1} of vertex v in P_n, clipped to range."""
    return {u for u in (v - 1, v, v + 1) if 0 <= u < n}


def zero_forcing_closure(n: int, blue: Set[int]) -> Set[int]:
    """Closure of the zero-forcing color-change rule on P_n.

    Repeatedly: any blue vertex with exactly one white neighbor forces that
    neighbor blue, until no further change occurs."""
    blue = set(blue)
    changed = True
    while changed:
        changed = False
        for v in list(blue):
            white = [u for u in closed_neighborhood(n, v) if u != v and u not in blue]
            if len(white) == 1:
                blue.add(white[0])
                changed = True
    return blue


def zero_forcing_number(n: int) -> int:
    """Z(P_n) by exhaustive search; provably equals 1 for all n >= 1."""
    if n == 0:
        return 0
    verts: List[int] = list(range(n))
    for k in range(n + 1):
        for combo in combinations(verts, k):
            if len(zero_forcing_closure(n, set(combo))) == n:
                return k
    return n
