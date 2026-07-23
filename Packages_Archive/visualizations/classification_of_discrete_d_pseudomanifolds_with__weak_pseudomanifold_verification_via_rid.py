from itertools import combinations
from typing import FrozenSet, Set

Facet = FrozenSet[int]

def is_weak_pseudomanifold(facets: Set[Facet], d: int) -> bool:
    """Return True iff `facets` is pure of dimension d and every ridge
    (d-subset of a facet) is contained in exactly two facets."""
    if any(len(sigma) != d + 1 for sigma in facets):
        return False
    ridges: Set[Facet] = set()
    for sigma in facets:
        for r in combinations(sorted(sigma), d):
            ridges.add(frozenset(r))
    for rho in ridges:
        if sum(1 for sigma in facets if rho <= sigma) != 2:
            return False
    return True
