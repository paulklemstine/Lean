from __future__ import annotations
from typing import FrozenSet, Tuple

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]


def cone(h: Graph) -> Graph:
    """K_1 v H (Definition 5): add an apex vertex (index n) adjacent to all of H."""
    n, edges = h
    apex = n
    return (n + 1, frozenset(set(edges) | {frozenset((apex, v)) for v in range(n)}))


def check_cone_identity(h: Graph) -> bool:
    """Theorem 3:  e(K_1 v H) = |V(H)| + e(H)."""
    n, edges = h
    return len(cone(h)[1]) == n + len(edges)
