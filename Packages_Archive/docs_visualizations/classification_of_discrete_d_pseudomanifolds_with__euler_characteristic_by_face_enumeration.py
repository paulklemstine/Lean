from itertools import combinations
from typing import FrozenSet, List, Set

Facet = FrozenSet[int]

def euler_characteristic(facets: Set[Facet]) -> int:
    """chi = sum_i (-1)^i f_i, obtained by enumerating all faces by dimension."""
    if not facets:
        return 0
    top = max(len(s) for s in facets)
    layers: List[Set[Facet]] = [set() for _ in range(top)]
    for sigma in facets:
        for k in range(1, len(sigma) + 1):
            for f in combinations(sorted(sigma), k):
                layers[k - 1].add(frozenset(f))
    return sum((-1) ** i * len(layer) for i, layer in enumerate(layers))
