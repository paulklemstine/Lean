from __future__ import annotations
from typing import FrozenSet, List, Set

Open = FrozenSet[int]
Topology = FrozenSet[Open]

def generate_topology(seed: Set[Open], carrier: FrozenSet[int]) -> Topology:
    """Smallest topology on a finite carrier containing `seed`
    (closure under pairwise intersection and union)."""
    opens: Set[Open] = set(seed) | {frozenset(), carrier}
    changed = True
    while changed:
        changed = False
        for u in list(opens):
            for v in list(opens):
                for w in (u & v, u | v):
                    if w not in opens:
                        opens.add(w); changed = True
    return frozenset(opens)

def collapse_to_two(observers: List[Topology],
                    carrier: FrozenSet[int]) -> List[Topology]:
    """Reduce a genuine k-observer family (k >= 2) to a genuine 2-observer one
    with the same consensus, by merging observers 2..k into a single topology."""
    if len(observers) <= 2:
        return list(observers)
    first = observers[0]
    rest_seed: Set[Open] = set().union(*observers[1:])
    merged = generate_topology(rest_seed, carrier)
    return [first, merged]
