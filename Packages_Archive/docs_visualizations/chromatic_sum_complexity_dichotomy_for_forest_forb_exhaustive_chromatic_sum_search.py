from __future__ import annotations
from itertools import product
from typing import List, Optional, Tuple

Edge = Tuple[int, int]


def chromatic_sum_bruteforce(
    num_vertices: int, edges: List[Edge]
) -> Tuple[int, Tuple[int, ...]]:
    """
    Compute Sigma(G) exactly by exhaustive search.

    Colours range over 1..num_vertices (an optimal colouring never needs more,
    by a first-fit argument), giving a search space of num_vertices ** n
    colourings, each checked in O(|E|) time.
    """
    n = num_vertices
    max_color = max(n, 1)
    best_sum: Optional[int] = None
    best: Tuple[int, ...] = tuple()
    for coloring in product(range(1, max_color + 1), repeat=n):
        if all(coloring[u] != coloring[v] for u, v in edges):
            s = sum(coloring)
            if best_sum is None or s < best_sum:
                best_sum, best = s, coloring
    assert best_sum is not None
    return best_sum, best
