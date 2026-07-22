from __future__ import annotations
from itertools import combinations

def transport_embedding_to_complements(
    mapping: list[int],
    small_n: int,
    small_edges: set[frozenset[int]],
    big_n: int,
    big_edges: set[frozenset[int]],
) -> list[int]:
    """Given an induced embedding `mapping` of a small graph into a big graph,
    return the SAME map, now certified as an induced embedding of the
    complements (Theorem 3.1: the complement functor). Raises if the input
    is not a valid induced embedding."""
    for u, v in combinations(range(small_n), 2):
        in_small = frozenset((u, v)) in small_edges
        in_big = frozenset((mapping[u], mapping[v])) in big_edges
        if in_small != in_big:
            raise ValueError("input is not an induced embedding")
    # No recomputation needed: the identical vertex map works for complements.
    return mapping
