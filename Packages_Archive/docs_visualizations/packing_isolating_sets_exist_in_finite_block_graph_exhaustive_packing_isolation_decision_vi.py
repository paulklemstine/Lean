from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

Graph = Dict[int, Set[int]]


def closed_neighborhood(g: Graph, v: int) -> Set[int]:
    return {v} | set(g[v])


def neighborhood_of_set(g: Graph, s: Set[int]) -> Set[int]:
    out: Set[int] = set()
    for v in s:
        out |= closed_neighborhood(g, v)
    return out


def edges(g: Graph) -> List[Tuple[int, int]]:
    return [(u, w) for u in g for w in g[u] if u < w]


def is_two_packing(g: Graph, s: Set[int]) -> bool:
    for u, v in combinations(sorted(s), 2):
        if closed_neighborhood(g, u) & closed_neighborhood(g, v):
            return False
    return True


def is_isolating(g: Graph, s: Set[int]) -> bool:
    cover = neighborhood_of_set(g, s)
    return all((u in cover) or (w in cover) for u, w in edges(g))


def find_packing_isolating(g: Graph) -> FrozenSet[int] | None:
    """Exhaustive certificate: return a packing-isolating set, or None if none exists."""
    verts = list(g)
    for r in range(len(verts) + 1):
        for combo in combinations(verts, r):
            s = set(combo)
            if is_two_packing(g, s) and is_isolating(g, s):
                return frozenset(s)
    return None
