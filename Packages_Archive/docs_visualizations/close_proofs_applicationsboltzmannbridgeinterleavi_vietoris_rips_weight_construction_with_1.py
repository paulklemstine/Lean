from itertools import combinations
from typing import Callable, Dict, FrozenSet

Simplex = FrozenSet[int]


def diam_weight(d: Callable[[int, int], float], sigma: Simplex) -> float:
    """Vietoris-Rips diameter weight: max(0, max pairwise distance) (Algorithm C)."""
    best = 0.0
    for x in sigma:
        for y in sigma:
            best = max(best, d(x, y))
    return best


def vr_filtration(
    d: Callable[[int, int], float], n: int, max_dim: int
) -> Dict[Simplex, float]:
    """Build the VR weight table on n points up to simplices of `max_dim` vertices.

    Combined with `interleaving_distance`, this yields the 1-Lipschitz stability
    bound:  eInterleavingDist <= max_{i,j} |d1(i,j) - d2(i,j)|.
    """
    weight: Dict[Simplex, float] = {frozenset(): 0.0}
    for k in range(1, max_dim + 1):
        for combo in combinations(range(n), k):
            weight[frozenset(combo)] = diam_weight(d, combo if False else frozenset(combo))
    return weight
