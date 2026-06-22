from __future__ import annotations
from itertools import combinations
from typing import Dict, FrozenSet, List, Sequence

Simplex = FrozenSet[int]
Matrix = Sequence[Sequence[float]]


def diam_weight_of(d: Matrix, sigma: Simplex) -> float:
    """Diameter of a simplex: max pairwise d[x][y] over its vertices, with 0
    adjoined (Definition 6.1, `diamWeightOf`)."""
    vals: List[float] = [0.0]
    for x in sigma:
        for y in sigma:
            vals.append(d[x][y])
    return max(vals)


def diam_filtration_of(d: Matrix, n: int,
                       max_dim: int | None = None) -> Dict[Simplex, float]:
    """Birth-scale table of every nonempty simplex (up to `max_dim` vertices)
    under distance matrix `d` (Definition 6.1, `diamFiltrationOf`).
    Complexity: O(2^n * n^2)."""
    table: Dict[Simplex, float] = {}
    top = n if max_dim is None else min(max_dim, n)
    for k in range(1, top + 1):
        for verts in combinations(range(n), k):
            table[frozenset(verts)] = diam_weight_of(d, frozenset(verts))
    return table
