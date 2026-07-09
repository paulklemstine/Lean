from __future__ import annotations
from typing import FrozenSet, List, Set

OpenSet = FrozenSet[int]
Topology = Set[OpenSet]

def consensus(observers: List[Topology]) -> Topology:
    """Consensus topology: sets open in every observer (Agreement Principle)."""
    if not observers:
        raise ValueError("need at least one observer")
    result: Topology = set(observers[0])
    for obs in observers[1:]:
        result &= obs
    return result

def is_genuine(observers: List[Topology]) -> bool:
    """True iff every observer is strictly finer than the consensus."""
    c = consensus(observers)
    return all(c < obs for obs in observers)
