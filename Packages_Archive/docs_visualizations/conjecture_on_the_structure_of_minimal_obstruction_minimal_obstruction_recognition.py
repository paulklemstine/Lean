from __future__ import annotations
from typing import Dict, FrozenSet, List, Set

Edge = FrozenSet[int]
ColoredGraph = Dict[Edge, int]

def _has_cycle(edges) -> bool:
    parent: Dict[int, int] = {}
    def find(x: int) -> int:
        parent.setdefault(x, x)
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for e in edges:
        u, v = tuple(e); ru, rv = find(u), find(v)
        if ru == rv: return True
        parent[ru] = rv
    return False

def has_mono_cycle(g: ColoredGraph) -> bool:
    cls: Dict[int, Set[Edge]] = {}
    for e, k in g.items():
        cls.setdefault(k, set()).add(e)
    return any(_has_cycle(c) for c in cls.values())

def is_minimal_obstruction(g: ColoredGraph) -> bool:
    if not has_mono_cycle(g):
        return False
    for e in g:
        if has_mono_cycle({f: k for f, k in g.items() if f != e}):
            return False
    return True
