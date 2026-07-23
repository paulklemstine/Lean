from typing import Callable, Dict, Hashable, List, Set, Tuple
from itertools import combinations

def connected_components(
    points: List[Hashable],
    dist: Callable[[Hashable, Hashable], float],
    eps: float,
) -> List[Set[Hashable]]:
    """Connected components (pi_0) of the Rips graph at scale eps via union-find.
    Over an ultrametric space each component is exactly a closed eps-ball, and
    the component count equals the number of distinct closed eps-balls."""
    parent: Dict[Hashable, Hashable] = {p: p for p in points}

    def find(p: Hashable) -> Hashable:
        while parent[p] != p:
            parent[p] = parent[parent[p]]
            p = parent[p]
        return p

    def union(p: Hashable, q: Hashable) -> None:
        parent[find(p)] = find(q)

    for x, y in combinations(points, 2):
        if dist(x, y) <= eps:
            union(x, y)
    groups: Dict[Hashable, Set[Hashable]] = {}
    for p in points:
        groups.setdefault(find(p), set()).add(p)
    return list(groups.values())
