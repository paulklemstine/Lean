from itertools import combinations
from typing import Dict, FrozenSet, Hashable, List, Sequence

Simplex = FrozenSet[Hashable]
Filtration = Dict[Simplex, float]


def euclidean(p: Sequence[float], q: Sequence[float]) -> float:
    return sum((a - b) ** 2 for a, b in zip(p, q)) ** 0.5


def vr_filtration(points: Sequence[Sequence[float]], max_dim: int = 2) -> Filtration:
    """Vietoris-Rips filtration: weight(sigma) = diameter(sigma).

    Satisfies the filtration axioms w(empty) <= 0 and monotonicity under inclusion.
    Complexity O(n^{max_dim+1}) simplices, each with O(|sigma|^2) diameter cost.
    """
    n = len(points)
    simplices: List[Simplex] = [frozenset()]
    for k in range(1, max_dim + 2):
        simplices += [frozenset(c) for c in combinations(range(n), k)]
    w: Filtration = {}
    for sigma in simplices:
        verts = sorted(sigma)
        w[sigma] = 0.0 if len(verts) <= 1 else max(
            euclidean(points[i], points[j]) for i, j in combinations(verts, 2)
        )
    return w
