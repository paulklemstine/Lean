from __future__ import annotations
from typing import FrozenSet, List

Set = FrozenSet[int]
Topology = FrozenSet[Set]


def consensus(observers: List[Topology]) -> Topology:
    """Supremum in the lattice of topologies: sets open in every observer.

    Complexity: O(k * m) membership operations, k observers, m = largest
    open-set collection.
    """
    if not observers:
        raise ValueError("need at least one observer")
    result = set(observers[0])
    for t in observers[1:]:
        result &= set(t)
    return frozenset(result)
