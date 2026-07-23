from __future__ import annotations
from typing import FrozenSet, List, Tuple

Set = FrozenSet[int]
Topology = FrozenSet[Set]


def consensus(observers: List[Topology]) -> Topology:
    result = set(observers[0])
    for t in observers[1:]:
        result &= set(t)
    return frozenset(result)


def strictly_finer(observer: Topology, real: Topology) -> bool:
    return set(real) < set(observer)


def collapse_to_two(observers: List[Topology], real: Topology) -> Tuple[Topology, Topology]:
    """Reduce a genuine k-observer representation (k >= 2, each observer strictly
    finer than `real`, consensus == real) to a genuine 2-observer pair.

    Complexity: O(k) join computations; terminates in at most k-1 peels.
    """
    assert len(observers) >= 2 and consensus(observers) == real
    assert all(strictly_finer(o, real) for o in observers)
    fam = list(observers)
    while True:
        head, rest = fam[0], fam[1:]
        pooled = consensus(rest)
        if strictly_finer(pooled, real):
            return head, pooled
        assert len(rest) >= 2, "cannot bottom out at one observer"
        fam = rest
