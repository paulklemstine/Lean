from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List, Optional, Tuple

Topology = FrozenSet[FrozenSet[int]]


def strictly_finer(a: Topology, b: Topology) -> bool:
    return b <= a and a != b


def consensus(a: Topology, b: Topology) -> Topology:
    return frozenset(a & b)


def is_splittable(tau: Topology,
                  all_tops: List[Topology]
                  ) -> Tuple[bool, Optional[Tuple[Topology, Topology]]]:
    """Decide whether tau is the consensus of two strictly finer topologies."""
    finer = [t for t in all_tops if strictly_finer(t, tau)]
    for a, b in combinations(finer, 2):
        if consensus(a, b) == tau:
            return True, (a, b)
    return False, None
