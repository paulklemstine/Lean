from __future__ import annotations
from itertools import combinations
from typing import Callable, FrozenSet, List, Optional, Tuple


def integrated_information(
    rank: Callable[[FrozenSet[int]], int], n: int
) -> Tuple[int, Optional[FrozenSet[int]]]:
    """Compute Phi = min over nontrivial cuts of (rank(A) - 1) and a realizing cut.

    Returns (Phi, MIP) where MIP is a Minimum Information Partition.
    Complexity O(2^n) over all nonempty proper subsets.
    """
    if n < 2:
        raise ValueError("need n >= 2 for a nontrivial cut")
    best_val: Optional[int] = None
    best_cut: Optional[FrozenSet[int]] = None
    for size in range(1, n):
        for combo in combinations(range(n), size):
            A = frozenset(combo)
            r = rank(A)
            if r < 1:
                raise ValueError("rank(A) must be >= 1 (nonzero pure state)")
            val = r - 1
            if best_val is None or val < best_val:
                best_val, best_cut = val, A
    assert best_val is not None
    return best_val, best_cut
