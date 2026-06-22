from __future__ import annotations
from itertools import combinations, chain
from typing import Dict, FrozenSet, Iterable, List, Sequence

Simplex = FrozenSet[int]
Weight = Dict[Simplex, float]

def all_simplices(vertices: Sequence[int]) -> List[Simplex]:
    """All 2^|V| subsets of the vertex set, as simplices."""
    verts = list(vertices)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(verts, r) for r in range(len(verts) + 1))]

def interleaving_distance(w_f: Weight, w_g: Weight) -> float:
    """Exact interleaving distance = sup over simplices of |w_F - w_G| (Thm 3.5)."""
    keys: Iterable[Simplex] = set(w_f) | set(w_g)
    return max((abs(w_f.get(k, 0.0) - w_g.get(k, 0.0)) for k in keys), default=0.0)
