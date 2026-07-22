from __future__ import annotations
from typing import FrozenSet, Set


def negations_agree_on_frontier(points: FrozenSet[int],
                                opens: Set[FrozenSet[int]],
                                a_open: FrozenSet[int]) -> bool:
    """Check the open/closed De Morgan duality for one open set A.

    Intuitionistic negation ~A = interior(complement); the excluded-middle gap
    is X \\ (A ∪ ~A). The dream glut of the complementary closed set is
    (X\\A) AND closure(A). Duality asserts these two frontier sets coincide.
    """
    def interior(s: FrozenSet[int]) -> FrozenSet[int]:
        out: Set[int] = set()
        for u in opens:
            if u <= s:
                out |= u
        return frozenset(out)

    def closure(s: FrozenSet[int]) -> FrozenSet[int]:
        res = points
        for u in opens:
            c = points - u
            if s <= c:
                res &= c
        return res

    gap = points - (a_open | interior(points - a_open))
    closed = points - a_open
    glut = closed & closure(points - closed)
    return gap == glut
