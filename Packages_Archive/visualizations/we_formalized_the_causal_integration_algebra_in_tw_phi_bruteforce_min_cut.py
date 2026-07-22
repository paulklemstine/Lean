from __future__ import annotations
from itertools import product
from typing import Iterable, Sequence, Tuple

def cross_info(weight: Sequence[Sequence[float]], S: frozenset[int]) -> float:
    """Total weight of edges directed from S into its complement."""
    n = len(weight)
    comp = [j for j in range(n) if j not in S]
    return sum(weight[i][j] for i in S for j in comp)

def nontrivial_bipartitions(n: int) -> Iterable[frozenset[int]]:
    """All nonempty proper subsets of {0, ..., n-1}."""
    for bits in product([0, 1], repeat=n):
        subset = frozenset(i for i, b in enumerate(bits) if b)
        if 0 < len(subset) < n:
            yield subset

def phi_bruteforce(weight: Sequence[Sequence[float]]) -> Tuple[float, frozenset[int]]:
    """Exact Phi (minimum directed cut) by enumerating all nontrivial bipartitions.
    Complexity: O(2^n * n^2). Certified reference implementation."""
    n = len(weight)
    assert n >= 2
    best_S = min(nontrivial_bipartitions(n), key=lambda S: cross_info(weight, S))
    return cross_info(weight, best_S), best_S
