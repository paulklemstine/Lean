from itertools import combinations
from typing import FrozenSet, List, Sequence, Set

Point = int
OpenSet = FrozenSet[Point]
Topology = FrozenSet[OpenSet]


def is_discrete(ground: FrozenSet[Point], topology: Topology) -> bool:
    """True iff every singleton {p} is open (equivalently topology has 2**|ground| opens)."""
    return all(frozenset({p}) in topology for p in ground)


def possibility_number(ground: FrozenSet[Point],
                       candidate_observers: Sequence[Topology],
                       generate, possibility) -> int:
    """Least number of the given (coarser) observers whose pooled possibility is
    discrete. Searches by increasing subset size; returns -1 if none suffice.
    """
    n = len(candidate_observers)
    for k in range(1, n + 1):
        for combo in combinations(range(n), k):
            pooled = possibility(ground, [candidate_observers[i] for i in combo])
            if is_discrete(ground, pooled):
                return k
    return -1
