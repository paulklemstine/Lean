from __future__ import annotations
from typing import FrozenSet, List, Set, Tuple

Member = FrozenSet[int]

def greedy_maximal_packing(family: List[Member]) -> Tuple[List[Member], Set[int]]:
    """Return a maximal pairwise-disjoint subfamily P and its union X."""
    packing: List[Member] = []
    union: Set[int] = set()
    for member in family:
        if not (member & union):
            packing.append(member)
            union |= member
    return packing, union

def cover_bound(packing: List[Member], s: int, c: int) -> int:
    """The guaranteed size bound c*(s-1) when no s-packing exists."""
    assert len(packing) <= s - 1
    return c * (s - 1)
