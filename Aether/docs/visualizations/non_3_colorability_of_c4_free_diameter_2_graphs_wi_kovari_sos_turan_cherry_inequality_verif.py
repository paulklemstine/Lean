from math import comb
from typing import Dict, Set, List, Tuple

Graph = Dict[int, Set[int]]


def is_c4_free(g: Graph) -> bool:
    """Return True iff every pair of distinct vertices has at most one common
    neighbour (equivalently, the graph contains no 4-cycle)."""
    verts: List[int] = list(g)
    for i in range(len(verts)):
        for j in range(i + 1, len(verts)):
            if len(g[verts[i]] & g[verts[j]]) >= 2:
                return False
    return True


def cherry_bound_check(g: Graph) -> Tuple[bool, int, int]:
    """Verify the Kovari-Sos-Turan cherry inequality for C4-free graphs:

        sum_v C(deg v, 2) <= C(|V|, 2).

    The left side counts cherries (paths a-v-b); the map cherry -> {a, b} is
    injective when g is C4-free, giving the bound. Returns (holds, lhs, rhs).
    """
    assert is_c4_free(g), "cherry inequality assumes C4-freeness"
    n = len(g)
    lhs = sum(comb(len(g[v]), 2) for v in g)
    rhs = comb(n, 2)
    return lhs <= rhs, lhs, rhs
