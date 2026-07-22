from itertools import combinations
from typing import Dict, FrozenSet, Iterable, Set, Tuple

Graph = Tuple[Tuple[int, ...], Dict[int, FrozenSet[int]]]


def common_neighborhood(g: Graph, s: Iterable[int]) -> FrozenSet[int]:
    """N(S): vertices adjacent to every vertex of S (intersection of nbhds)."""
    verts, adj = g
    result: Set[int] = set(verts)
    for u in s:
        result &= set(adj[u])
    return frozenset(result)


def is_k3t_free(g: Graph, t: int) -> bool:
    """Certify K_{3,t}-freeness via the triple common-neighborhood cap:
    G is K_{3,t}-free  <=>  every triple S has |N(S)| <= t-1."""
    verts, _ = g
    for triple in combinations(verts, 3):
        if len(common_neighborhood(g, triple)) >= t:
            return False
    return True
