from itertools import combinations
from typing import FrozenSet, Set, Tuple

Facet = FrozenSet[int]

def handshake(facets: Set[Facet], d: int) -> Tuple[int, int, bool]:
    """Return ((d+1)*f_d, 2*f_{d-1}, whether they are equal) where f_d is the
    number of facets and f_{d-1} the number of ridges."""
    f_d = len(facets)
    ridges: Set[Facet] = set()
    for sigma in facets:
        for r in combinations(sorted(sigma), d):
            ridges.add(frozenset(r))
    f_dm1 = len(ridges)
    return (d + 1) * f_d, 2 * f_dm1, (d + 1) * f_d == 2 * f_dm1
