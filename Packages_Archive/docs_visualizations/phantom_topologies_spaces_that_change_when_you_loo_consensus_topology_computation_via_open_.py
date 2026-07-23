from __future__ import annotations
from typing import FrozenSet, Iterable, List

Topology = FrozenSet[FrozenSet[int]]


def consensus(observers: Iterable[Topology]) -> Topology:
    """Consensus topology: the sets open in every observer (lattice supremum)."""
    obs: List[Topology] = list(observers)
    if not obs:
        raise ValueError("need at least one observer")
    result = obs[0]
    for t in obs[1:]:
        result = result & t
    return frozenset(result)
