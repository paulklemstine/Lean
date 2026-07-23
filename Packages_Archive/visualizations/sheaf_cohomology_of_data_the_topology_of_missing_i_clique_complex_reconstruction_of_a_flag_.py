from itertools import combinations
from typing import Iterable

def clique_faces(vertices: Iterable[str], edges: Iterable[tuple[str, str]]) -> list[tuple[str, ...]]:
    vs = sorted(set(vertices)); es = {frozenset(e) for e in edges}
    return [s for k in range(1, len(vs)+1) for s in combinations(vs, k)
            if all(frozenset(p) in es for p in combinations(s, 2))]
