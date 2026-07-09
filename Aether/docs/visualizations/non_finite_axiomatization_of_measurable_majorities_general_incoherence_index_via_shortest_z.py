from typing import Iterable, Set


def incoherence_index(atoms: Iterable[int], n: int) -> int:
    """Shortest non-empty zero-sum length over `atoms` in Z/nZ (0 if none)."""
    F: Set[int] = {a % n for a in atoms}
    if not F:
        return 0
    frontier: Set[int] = {0}
    visited: Set[int] = set()
    for level in range(1, n + 1):
        nxt: Set[int] = {(r + a) % n for r in frontier for a in F}
        if 0 in nxt:
            return level
        nxt -= visited
        if not nxt:
            return 0
        visited |= nxt
        frontier = nxt
    return 0
