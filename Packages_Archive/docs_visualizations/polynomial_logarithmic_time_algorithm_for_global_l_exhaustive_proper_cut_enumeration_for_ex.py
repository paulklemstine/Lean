from __future__ import annotations
from itertools import combinations
from typing import Hashable, Iterable, List, Set, Tuple

Vertex = Hashable
Label = Hashable
Edge = Tuple[Vertex, Vertex, Label]


def cut_value(edges: Iterable[Edge], A: Set[Vertex]) -> int:
    """Number of distinct labels on edges crossing the cut (A, complement)."""
    return len({lab for (u, v, lab) in edges if (u in A) != (v in A)})


def glmc_brute_force(
    edges: Iterable[Edge], vertices: Iterable[Vertex]
) -> Tuple[int, Set[Vertex] | None]:
    """Exact Global Label Min-Cut via exhaustive enumeration of proper cuts.

    Returns (optimum, witnessing proper cut). Time O(2^n * |E|).
    Correct by the attainment + lower-bound theorems: the returned value is the
    genuine minimum number of distinct labels crossing any nontrivial bipartition.
    """
    edges = list(edges)
    V = list(vertices)
    best_val: int | None = None
    best_cut: Set[Vertex] | None = None
    for r in range(1, len(V)):                 # 1 <= |A| <= |V|-1  (proper cuts)
        for combo in combinations(V, r):
            A = set(combo)
            val = cut_value(edges, A)
            if best_val is None or val < best_val:
                best_val, best_cut = val, A
                if val == 0:                   # sound early exit: 0 is optimal
                    return 0, A
    return (0 if best_val is None else best_val), best_cut
