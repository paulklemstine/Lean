from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List

Open = FrozenSet[int]
Topology = FrozenSet[Open]

def powerset(carrier: FrozenSet[int]) -> List[Open]:
    xs = list(carrier)
    return [frozenset(c) for r in range(len(xs)+1) for c in combinations(xs, r)]

def is_topology(opens: set, carrier: FrozenSet[int]) -> bool:
    if frozenset() not in opens or carrier not in opens:
        return False
    for u in opens:
        for v in opens:
            if (u & v) not in opens or (u | v) not in opens:
                return False
    return True

def all_topologies(carrier: FrozenSet[int]) -> List[Topology]:
    forced = {frozenset(), carrier}
    optional = [u for u in powerset(carrier) if u not in forced]
    out: List[Topology] = []
    for r in range(len(optional)+1):
        for extra in combinations(optional, r):
            cand = set(forced) | set(extra)
            if is_topology(cand, carrier):
                out.append(frozenset(cand))
    return out

def is_join_reducible(tau: Topology, carrier: FrozenSet[int]) -> bool:
    """Decide whether tau = a join b for strictly finer a, b, i.e. whether tau
    admits a genuine (phantom-number-two) representation."""
    finer = [t for t in all_topologies(carrier) if tau < t]
    return any((a & b) == tau for a, b in combinations(finer, 2))
