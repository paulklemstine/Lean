from itertools import combinations
from typing import Dict, FrozenSet, Tuple

Simplex = FrozenSet[int]
DistMatrix = Dict[Tuple[int, int], float]


def diam_weight(d: DistMatrix, sigma: Simplex) -> float:
    """Vietoris-Rips diameter weight: max pairwise distance in `sigma`, 0 adjoined.

    The empty simplex and singletons get weight 0. Cost O(|sigma|^2).
    This is the birth scale of `sigma` in the Vietoris-Rips filtration.
    """
    best: float = 0.0
    for x, y in combinations(sorted(sigma), 2):
        best = max(best, d[(x, y)], d[(y, x)])
    return best
