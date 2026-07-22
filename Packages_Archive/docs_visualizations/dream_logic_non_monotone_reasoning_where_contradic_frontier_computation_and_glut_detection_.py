from __future__ import annotations
from typing import FrozenSet, Set


def frontier(points: FrozenSet[int], opens: Set[FrozenSet[int]],
             a: FrozenSet[int]) -> FrozenSet[int]:
    """Compute the boundary (glut region) of a closed set A on a finite space.

    boundary(A) = A \\ interior(A), where interior(A) is the union of all open
    sets contained in A. By the boundary characterisation theorem this equals
    A AND NOT A in the closed-set (dream) logic.
    """
    interior: Set[int] = set()
    for u in opens:
        if u <= a:
            interior |= u
    return frozenset(a - interior)


def carries_glut(points: FrozenSet[int], opens: Set[FrozenSet[int]],
                 a: FrozenSet[int]) -> bool:
    """A carries a coexisting contradiction iff its frontier is nonempty."""
    return len(frontier(points, opens, a)) > 0
