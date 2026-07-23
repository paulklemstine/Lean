from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List, Optional, Tuple

Set = FrozenSet[int]
Topology = FrozenSet[Set]


def powerset(universe: Set) -> List[Set]:
    xs = list(universe)
    return [frozenset(c) for r in range(len(xs) + 1) for c in combinations(xs, r)]


def is_topology(opens, universe: Set) -> bool:
    O = set(opens)
    if frozenset() not in O or universe not in O:
        return False
    return all((a | b) in O and (a & b) in O for a in O for b in O)


def all_topologies(universe: Set) -> List[Topology]:
    P = powerset(universe)
    must = {frozenset(), universe}
    optional = [s for s in P if s not in must]
    out: List[Topology] = []
    for r in range(len(optional) + 1):
        for extra in combinations(optional, r):
            cand = set(must) | set(extra)
            if is_topology(cand, universe):
                out.append(frozenset(cand))
    return out


def consensus(observers: List[Topology]) -> Topology:
    result = set(observers[0])
    for t in observers[1:]:
        result &= set(t)
    return frozenset(result)


def reducibility_witness(real: Topology, universe: Set) -> Optional[Tuple[Topology, Topology]]:
    """Search for a genuine 2-observer factorization of `real`.

    Returns (b, c) with b, c strictly finer than `real` and consensus([b,c]) ==
    real (phantom number 2), or None (join-irreducible: unattainable in finitely
    many observers). Complexity: exponential in |universe| (finite brute force).
    """
    finer = [t for t in all_topologies(universe) if set(real) < set(t)]
    for b, c in combinations(finer, 2):
        if consensus([b, c]) == real:
            return b, c
    return None
