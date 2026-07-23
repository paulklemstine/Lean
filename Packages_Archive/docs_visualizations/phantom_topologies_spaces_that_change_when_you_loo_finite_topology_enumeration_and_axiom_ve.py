from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List, Set

OpenSet = FrozenSet[int]
Topology = FrozenSet[OpenSet]


def powerset(xs: FrozenSet[int]) -> List[OpenSet]:
    items = list(xs)
    return [frozenset(c) for r in range(len(items) + 1)
            for c in combinations(items, r)]


def is_topology(opens: Set[OpenSet], universe: FrozenSet[int]) -> bool:
    """Verify the topology axioms on a finite universe."""
    if frozenset() not in opens or universe not in opens:
        return False
    for a in opens:
        for b in opens:
            if (a & b) not in opens or (a | b) not in opens:
                return False
    return True


def all_topologies(universe: FrozenSet[int]) -> List[Topology]:
    """Enumerate every topology on a small finite universe by brute force."""
    middle = [s for s in powerset(universe)
              if s not in (frozenset(), universe)]
    out: List[Topology] = []
    for r in range(len(middle) + 1):
        for chosen in combinations(middle, r):
            opens = set(chosen) | {frozenset(), universe}
            if is_topology(opens, universe):
                out.append(frozenset(opens))
    return out
