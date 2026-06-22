from __future__ import annotations
from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

Vertex = int
Complex = Set[FrozenSet[Vertex]]


def vr_complex(V: FrozenSet[Vertex],
               d: Dict[Tuple[Vertex, Vertex], float],
               eps: float) -> Complex:
    """Vietoris-Rips complex at scale eps."""
    edges = {frozenset((u, v)) for u, v in combinations(sorted(V), 2)
             if d[(u, v)] <= eps and d[(v, u)] <= eps}
    def is_clique(s):
        return all(frozenset((u, v)) in edges for u, v in combinations(s, 2))
    faces: Complex = set()
    vs = sorted(V)
    for r in range(len(vs) + 1):
        for c in combinations(vs, r):
            if is_clique(c):
                faces.add(frozenset(c))
    return faces


def vr_filtration(V: FrozenSet[Vertex],
                  d: Dict[Tuple[Vertex, Vertex], float]
                  ) -> List[Tuple[float, Complex]]:
    """Enumerate the filtration at all critical scales."""
    scales = sorted({d[(u, v)] for u, v in combinations(sorted(V), 2)})
    return [(eps, vr_complex(V, d, eps)) for eps in scales]
