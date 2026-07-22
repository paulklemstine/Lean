from __future__ import annotations
from typing import FrozenSet, List, Set

Statement = FrozenSet[int]
System = Set[Statement]

def diagonal_missing(listing: List[Statement], n: int) -> Statement:
    built: Set[int] = set()
    for i in range(n):
        e_i = listing[i] if i < len(listing) else frozenset()
        if i not in e_i:
            built.add(i)
    return frozenset(built)

def extend(brain: System, d: Statement) -> System:
    return set(brain) | {d}
