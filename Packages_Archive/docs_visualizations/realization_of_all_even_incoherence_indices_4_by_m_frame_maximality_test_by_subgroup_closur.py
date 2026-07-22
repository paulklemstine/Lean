from __future__ import annotations
from typing import FrozenSet, Set

Frame = FrozenSet[int]

def is_maximal(n: int, frame: Frame) -> bool:
    """True iff the atoms of `frame` generate the whole group Z/nZ.

    Closes the reachable set under addition of atoms starting from 0; the frame
    is maximal exactly when every residue is reached. Complexity O(n * |frame|).
    """
    reachable: Set[int] = {0}
    atoms = [a % n for a in frame]
    changed = True
    while changed:
        changed = False
        for r in list(reachable):
            for a in atoms:
                t = (r + a) % n
                if t not in reachable:
                    reachable.add(t)
                    changed = True
    return len(reachable) == n
