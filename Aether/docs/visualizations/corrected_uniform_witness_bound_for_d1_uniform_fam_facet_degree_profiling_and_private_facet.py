from itertools import combinations
from typing import Dict, FrozenSet, List, Tuple

Facet = FrozenSet[int]
Member = FrozenSet[int]
Family = List[Member]


def facet_profile(family: Family, d: int
                  ) -> Tuple[Dict[Facet, int], Dict[Member, List[Facet]]]:
    """Return (facet_degrees, private_facets_per_member)."""
    deg: Dict[Facet, int] = {}
    for a in family:
        for combo in combinations(sorted(a), d):
            f = frozenset(combo)
            deg[f] = deg.get(f, 0) + 1
    priv: Dict[Member, List[Facet]] = {}
    for a in family:
        priv[a] = [frozenset(c) for c in combinations(sorted(a), d)
                   if deg[frozenset(c)] == 1]
    return deg, priv
