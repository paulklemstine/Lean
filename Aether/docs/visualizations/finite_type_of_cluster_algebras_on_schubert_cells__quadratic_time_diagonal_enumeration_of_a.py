from itertools import combinations
from typing import FrozenSet, List, Tuple


def next_vertex(i: int, m: int) -> int:
    """Cyclic successor of vertex i in an m-gon."""
    return (i + 1) % m


def is_side(edge: FrozenSet[int], m: int) -> bool:
    """True iff the unordered pair joins two cyclically adjacent vertices."""
    i, j = tuple(edge)
    return next_vertex(i, m) == j or next_vertex(j, m) == i


def enumerate_diagonals(m: int) -> List[FrozenSet[int]]:
    """All diagonals of a convex m-gon: non-degenerate, non-side vertex pairs.
    Returns m(m-3)/2 diagonals; runs in O(m^2)."""
    diagonals: List[FrozenSet[int]] = []
    for i, j in combinations(range(m), 2):
        edge = frozenset({i, j})
        if not is_side(edge, m):
            diagonals.append(edge)
    assert 2 * len(diagonals) == m * (m - 3)
    return diagonals
