from __future__ import annotations
from typing import Callable, FrozenSet, Hashable, List, Sequence

def orbit_partition(group: Sequence[Hashable],
                    points: Sequence[Hashable],
                    act: Callable[[Hashable, Hashable], Hashable]
                    ) -> List[FrozenSet[Hashable]]:
    """Compute the orbit space X / G as a list of disjoint frozensets.

    Each orbit is the full set {g.x : g in group} for a representative x.
    The number of orbits equals the maximal number of points any invariant
    function can separate (Theorem B / quotient dichotomy).
    Complexity: O(|group| * |points|).
    """
    seen: set = set()
    result: List[FrozenSet[Hashable]] = []
    for x in points:
        if x in seen:
            continue
        orb = frozenset(act(g, x) for g in group)
        seen |= orb
        result.append(orb)
    return result
