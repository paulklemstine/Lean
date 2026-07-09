from itertools import combinations
from typing import Dict, FrozenSet, Iterable, Set, Tuple

Graph = Tuple[Tuple[int, ...], Dict[int, FrozenSet[int]]]


def common_neighborhood(g: Graph, s: Iterable[int]) -> FrozenSet[int]:
    verts, adj = g
    result: Set[int] = set(verts)
    for u in s:
        result &= set(adj[u])
    return frozenset(result)


def count_kab_copies_anchored(g: Graph, a: int, b: int) -> int:
    """Count labelled copies (A,B) of K_{a,b} using the anchored fiber idea of
    the proof: choose A (size a) with cross-adjacency, then B inside the common
    neighborhood N(A). Mirrors the structure of `fiber_bound`."""
    verts, _ = g
    total = 0
    for A in combinations(verts, a):
        cand = sorted(common_neighborhood(g, A) - set(A))
        # every b-subset of N(A) gives a valid B; this counts the fiber.
        for _B in combinations(cand, b):
            total += 1
    return total
