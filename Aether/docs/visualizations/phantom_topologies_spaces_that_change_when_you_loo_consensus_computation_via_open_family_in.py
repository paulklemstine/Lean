from __future__ import annotations
from typing import FrozenSet, List

Open = FrozenSet[int]
Topology = FrozenSet[Open]

def consensus(observers: List[Topology]) -> Topology:
    """Consensus (real) topology: sets open in every observer.

    Runs in O(k * m) set operations where k is the number of observers and m
    the maximum size of an open-set family.
    """
    result: Topology = observers[0]
    for t in observers[1:]:
        result = frozenset(result & t)
    return result
