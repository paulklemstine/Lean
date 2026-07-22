from __future__ import annotations
from typing import Dict, Set

Graph = Dict[int, Set[int]]


def is_k_colorable(g: Graph, k: int) -> bool:
    verts = sorted(g)
    color: Dict[int, int] = {}

    def bt(i: int) -> bool:
        if i == len(verts):
            return True
        v = verts[i]
        used = {color[u] for u in g[v] if u in color}
        for c in range(k):
            if c not in used:
                color[v] = c
                if bt(i + 1):
                    return True
                del color[v]
        return False

    return bt(0)


def chromatic_number(g: Graph) -> int:
    for k in range(len(g) + 1):
        if is_k_colorable(g, k):
            return k
    return len(g)


def emotional_chromatic_number(g: Graph) -> int:
    """emoChrom(G) = max(chromatic_number(G), 3)."""
    return max(chromatic_number(g), 3)
