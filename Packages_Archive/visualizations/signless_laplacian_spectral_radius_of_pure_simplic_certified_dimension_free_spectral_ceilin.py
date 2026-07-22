from typing import FrozenSet, Sequence
Facet = FrozenSet[int]

def certified_bound(facets: Sequence[Facet]) -> int:
    """Certified ceiling (facet size) * (max ridge degree); q_{r-1} <= this."""
    if not facets:
        return 0
    facet_size = max(len(f) for f in facets)
    ridges = {r for f in facets for r in f}
    max_degree = max(sum(1 for f in facets if r in f) for r in ridges)
    return facet_size * max_degree
