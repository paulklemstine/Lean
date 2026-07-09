from itertools import combinations
from typing import FrozenSet, Iterable, Set

Point = int
OpenSet = FrozenSet[Point]
Topology = FrozenSet[OpenSet]


def generate_topology(ground: FrozenSet[Point], subbasis: Iterable[OpenSet]) -> Topology:
    """Smallest topology on `ground` containing `subbasis`.

    Step 1: seed with the empty set, the whole space, and each subbasis element.
    Step 2: close under pairwise (hence finite) intersections to obtain a basis.
    Step 3: close under arbitrary unions of basis elements.
    """
    basis: Set[OpenSet] = {frozenset(), ground}
    for s in subbasis:
        basis.add(frozenset(s) & ground)
    changed = True
    while changed:
        changed = False
        for u in list(basis):
            for v in list(basis):
                w = u & v
                if w not in basis:
                    basis.add(w)
                    changed = True
    opens: Set[OpenSet] = {frozenset(), ground}
    for r in range(1, len(basis) + 1):
        for combo in combinations(basis, r):
            opens.add(frozenset().union(*combo))
    return frozenset(opens)
