from typing import FrozenSet, Set

Facet = FrozenSet[int]

def suspend(facets: Set[Facet], apex_a: int, apex_b: int) -> Set[Facet]:
    """The suspension Sigma F: cone every facet to two fresh apex vertices."""
    return {s | {apex_a} for s in facets} | {s | {apex_b} for s in facets}

def iterated_suspension(facets: Set[Facet], k: int) -> Set[Facet]:
    """Sigma^k F, allocating fresh apex labels above all existing vertices."""
    current: Set[Facet] = set(facets)
    nxt = max((max(s) for s in facets), default=-1) + 1
    for _ in range(k):
        current = suspend(current, nxt, nxt + 1)
        nxt += 2
    return current
