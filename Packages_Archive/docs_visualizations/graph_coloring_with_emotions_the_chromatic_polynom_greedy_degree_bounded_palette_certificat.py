from __future__ import annotations
from typing import Dict, List, Set

Graph = Dict[int, Set[int]]


def greedy_emotion_upper_bound(g: Graph, order: List[int] | None = None) -> int:
    """
    Greedy coloring gives emoChrom(G) <= max(used_colors, 3) <= max(deg_max + 1, 3).
    Processes vertices in the given order, assigning each the smallest emotion not
    used by an already-colored friend.
    """
    verts = order if order is not None else sorted(g)
    color: Dict[int, int] = {}
    for v in verts:
        used = {color[u] for u in g[v] if u in color}
        c = 0
        while c in used:
            c += 1
        color[v] = c
    used_colors = max(color.values()) + 1 if color else 0
    return max(used_colors, 3)
