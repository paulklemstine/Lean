from __future__ import annotations
from typing import Dict, List, Set, Tuple

Graph = Tuple[Set[int], Dict[int, Set[int]]]


def num_comp(graph: Graph, delete: Set[int]) -> int:
    """Component count numComp(G, S): number of connected components of the
    subgraph induced on V \\ S. Runs in O(|V| + |E|) time via BFS."""
    verts, adj = graph
    keep: Set[int] = verts - delete
    seen: Set[int] = set()
    count: int = 0
    for start in keep:
        if start in seen:
            continue
        count += 1
        stack: List[int] = [start]
        seen.add(start)
        while stack:
            v = stack.pop()
            for w in adj[v]:
                if w in keep and w not in seen:
                    seen.add(w)
                    stack.append(w)
    return count
