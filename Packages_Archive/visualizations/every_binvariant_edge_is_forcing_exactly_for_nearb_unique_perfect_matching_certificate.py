from __future__ import annotations
from typing import Dict, FrozenSet, Optional, Set, Tuple

Edge = FrozenSet[int]
Graph = Tuple[Set[int], Set[Edge]]
Matching = FrozenSet[Edge]


def unique_matching_certificate(g: Graph) -> Optional[Matching]:
    """Return the unique perfect matching of g if there is exactly one, else None.

    By the completeness principle, if this returns a matching M, then every edge
    of M is a forcing edge of g.
    """
    V, E = g
    found = []

    def bt(rem: Tuple[int, ...], acc: Matching) -> None:
        if len(found) > 1:
            return
        if not rem:
            found.append(acc)
            return
        a, rest = rem[0], rem[1:]
        for b in rest:
            if frozenset((a, b)) in E:
                bt(tuple(x for x in rest if x != b), acc | {frozenset((a, b))})

    bt(tuple(sorted(V)), frozenset())
    return found[0] if len(found) == 1 else None
