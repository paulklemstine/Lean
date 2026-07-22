from __future__ import annotations
from typing import Dict, FrozenSet, List, Set

Edge = FrozenSet[int]
ColoredGraph = Dict[Edge, int]

def cure(g: ColoredGraph) -> List[Edge]:
    by_color: Dict[int, List[Edge]] = {}
    for e, k in g.items():
        by_color.setdefault(k, []).append(e)
    deleted: List[Edge] = []
    for k, edges in by_color.items():
        parent: Dict[int, int] = {}
        def find(x: int) -> int:
            parent.setdefault(x, x)
            while parent[x] != x:
                parent[x] = parent[parent[x]]; x = parent[x]
            return x
        for e in edges:
            u, v = tuple(e); ru, rv = find(u), find(v)
            if ru == rv:
                deleted.append(e)          # remove this chord
            else:
                parent[ru] = rv            # keep, extend spanning forest
    return deleted
