from itertools import combinations
from typing import Dict, FrozenSet, List

Facet = FrozenSet[int]
Member = FrozenSet[int]
Family = List[Member]


def check_missing_trace_size(family: Family, d: int, s: int) -> bool:
    """True iff every member has exactly s private facets."""
    deg: Dict[Facet, int] = {}
    for a in family:
        for combo in combinations(sorted(a), d):
            f = frozenset(combo)
            deg[f] = deg.get(f, 0) + 1
    for a in family:
        count = sum(1 for c in combinations(sorted(a), d)
                    if deg[frozenset(c)] == 1)
        if count != s:
            return False
    return True
