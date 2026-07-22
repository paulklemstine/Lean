from __future__ import annotations
from itertools import combinations
from typing import List, Set, FrozenSet, Tuple

def central_graph(vertices: List[int],
                  edges: Set[FrozenSet[int]]
                  ) -> Tuple[List[Tuple[str, object]], Set[FrozenSet]]:
    """Build the central graph C(G): subdivide each edge, join non-adjacent pairs."""
    cverts: List[Tuple[str, object]] = (
        [("o", v) for v in vertices] + [("s", e) for e in edges])
    cedges: Set[FrozenSet] = set()
    for u, w in combinations(vertices, 2):
        if frozenset({u, w}) not in edges:
            cedges.add(frozenset({("o", u), ("o", w)}))
    for e in edges:
        for u in e:
            cedges.add(frozenset({("o", u), ("s", e)}))
    return cverts, cedges
