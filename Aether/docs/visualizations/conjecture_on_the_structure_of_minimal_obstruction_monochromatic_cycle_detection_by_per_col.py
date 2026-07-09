from __future__ import annotations
from typing import Dict, FrozenSet, Iterable, Tuple

Edge = FrozenSet[int]

def has_mono_cycle(colored_edges: Iterable[Tuple[Edge, int]]) -> bool:
    parent: Dict[Tuple[int, int], Tuple[int, int]] = {}
    rank: Dict[Tuple[int, int], int] = {}

    def find(node: Tuple[int, int]) -> Tuple[int, int]:
        parent.setdefault(node, node); rank.setdefault(node, 0)
        while parent[node] != node:
            parent[node] = parent[parent[node]]
            node = parent[node]
        return node

    def union(a: Tuple[int, int], b: Tuple[int, int]) -> bool:
        ra, rb = find(a), find(b)
        if ra == rb:
            return False
        if rank[ra] < rank[rb]:
            ra, rb = rb, ra
        parent[rb] = ra
        if rank[ra] == rank[rb]:
            rank[ra] += 1
        return True

    for e, k in colored_edges:
        u, v = tuple(e)
        if not union((k, u), (k, v)):   # keyed by (color, vertex)
            return True
    return False
