from __future__ import annotations
from itertools import combinations, chain
from typing import Callable, Dict, FrozenSet, List, Sequence

Simplex = FrozenSet[int]
Weight = Dict[Simplex, float]

def all_simplices(vertices: Sequence[int]) -> List[Simplex]:
    verts = list(vertices)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(verts, r) for r in range(len(verts) + 1))]

def diam_weight(distance: Callable[[int, int], float], sigma: Simplex) -> float:
    """Diameter of sigma: max pairwise distance, 0 adjoined."""
    best = 0.0
    for x, y in combinations(sorted(sigma), 2):
        best = max(best, distance(x, y))
    return best

def vr_filtration(vertices: Sequence[int],
                  distance: Callable[[int, int], float]) -> Weight:
    """The Vietoris-Rips filtration (monotone weight function) of a matrix."""
    return {s: diam_weight(distance, s) for s in all_simplices(vertices)}
