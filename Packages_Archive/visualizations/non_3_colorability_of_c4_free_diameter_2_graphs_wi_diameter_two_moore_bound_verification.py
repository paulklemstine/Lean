from math import isqrt
from typing import Dict, Set, List, Tuple

Graph = Dict[int, Set[int]]


def max_degree(g: Graph) -> int:
    """Return the maximum degree Delta of the graph."""
    return max((len(g[v]) for v in g), default=0)


def has_diameter_2(g: Graph) -> bool:
    """Return True iff every pair of distinct vertices is adjacent or shares
    a common neighbour (diameter at most two)."""
    verts: List[int] = list(g)
    for i in range(len(verts)):
        for j in range(i + 1, len(verts)):
            a, b = verts[i], verts[j]
            if b in g[a]:
                continue
            if not (g[a] & g[b]):
                return False
    return True


def moore_bound_check(g: Graph) -> Tuple[bool, int, int]:
    """Verify the diameter-two Moore bound |V| <= Delta^2 + 1.

    Returns (holds, |V|, Delta^2 + 1). If has_diameter_2(g) is True, the
    Moore bound is guaranteed to hold by the theorem.
    """
    assert has_diameter_2(g), "Moore bound assumes diameter <= 2"
    n = len(g)
    d = max_degree(g)
    return n <= d * d + 1, n, d * d + 1
