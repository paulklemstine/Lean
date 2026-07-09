from itertools import combinations
from typing import Dict, Hashable, Iterable, Optional, Set

Family = Dict[Hashable, "frozenset[int]"]


def common_intersection(family: Family, indices: Iterable[Hashable]) -> "frozenset[int]":
    """Intersection of the members indexed by `indices`."""
    indices = list(indices)
    if not indices:
        return frozenset()
    result = family[indices[0]]
    for i in indices[1:]:
        result = result & family[i]
    return result


def trivial_transversal(family: Family) -> "Set[int]":
    """Pick one point from each member: transversal of size <= |family|."""
    transversal: Set[int] = set()
    for member in family.values():
        if member:
            transversal.add(min(member))
    return transversal


def one_shot_transversal(family: Family, q: int) -> Optional["Set[int]"]:
    """One-shot bound: from the full (|s|, q)-property build a transversal of
    size at most |s| - q + 1. One shared point pierces q members; the rest are
    pierced individually. Returns None if no q-subset shares a point."""
    s = list(family.keys())
    for B in combinations(s, q):
        shared = common_intersection(family, B)
        if shared:
            t0 = min(shared)
            rest = {i: family[i] for i in s if i not in B}
            return {t0} | trivial_transversal(rest)
    return None
