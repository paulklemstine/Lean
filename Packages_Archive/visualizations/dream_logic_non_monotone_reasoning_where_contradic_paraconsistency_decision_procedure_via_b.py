from __future__ import annotations
from typing import FrozenSet, Set


def is_paraconsistent(points: FrozenSet[int],
                      opens: Set[FrozenSet[int]]) -> bool:
    """Decide whether the closed-set logic on a finite space is paraconsistent.

    The logic is paraconsistent iff some closed set has a nonempty boundary,
    i.e. some closed set fails to be open. Otherwise it is explosive (classical).
    Complexity: O(|opens|^2 * |points|).
    """
    closeds = {points - u for u in opens}
    for c in closeds:
        interior: Set[int] = set()
        for u in opens:
            if u <= c:
                interior |= u
        if frozenset(interior) != c:  # boundary nonempty
            return True
    return False
