from __future__ import annotations
from itertools import combinations
from typing import Dict, Set, Tuple

Graph = Tuple[Set[int], Dict[int, Set[int]]]


def num_comp(graph: Graph, delete: Set[int]) -> int:
    verts, adj = graph
    keep = verts - delete
    seen: Set[int] = set(); count = 0
    for s in keep:
        if s in seen:
            continue
        count += 1; stack = [s]; seen.add(s)
        while stack:
            v = stack.pop()
            for w in adj[v]:
                if w in keep and w not in seen:
                    seen.add(w); stack.append(w)
    return count


def is_one_tough(graph: Graph) -> bool:
    """Decide 1-toughness by exhaustive cutset search: connected, and for every
    vertex subset S that scatters G into >= 2 components, numComp(G,S) <= |S|."""
    verts, _ = graph
    if num_comp(graph, set()) != 1:
        return False
    n = len(verts)
    vlist = list(verts)
    for k in range(1, n + 1):
        for s in combinations(vlist, k):
            c = num_comp(graph, set(s))
            if c >= 2 and c > k:
                return False
    return True
