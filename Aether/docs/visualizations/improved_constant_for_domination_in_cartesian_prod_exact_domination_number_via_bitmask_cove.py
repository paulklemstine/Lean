from itertools import combinations
from typing import List, Set


def domination_number(n: int, edges: Set[frozenset]) -> int:
    """Exact domination number of a simple graph on vertices 0..n-1.

    Uses closed-neighbourhood bitmasks: a set S dominates iff the bitwise OR of
    the closed neighbourhoods of its members equals the all-ones mask. Subsets
    are enumerated by increasing size, so the first size admitting a full cover
    is gamma(G). Time O(2^n * n) in the worst case.
    """
    if n == 0:
        return 0
    full: int = (1 << n) - 1
    closed: List[int] = []
    for v in range(n):
        mask = 1 << v
        for w in range(n):
            if frozenset((v, w)) in edges:
                mask |= 1 << w
        closed.append(mask)
    for k in range(n + 1):
        for subset in combinations(range(n), k):
            cover = 0
            for v in subset:
                cover |= closed[v]
            if cover == full:
                return k
    return n
