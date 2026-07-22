from itertools import product
from typing import Dict, List, Optional, Sequence, Set, Tuple

Vertex = Tuple[str, int]

def decide_list_coloring(
    vertices: Sequence[Vertex],
    edges: Sequence[Tuple[Vertex, Vertex]],
    lists: Dict[Vertex, Set[int]],
) -> Optional[Dict[Vertex, int]]:
    """Return a proper list coloring if one exists, else None (backtracking)."""
    adj: Dict[Vertex, List[Vertex]] = {v: [] for v in vertices}
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)
    order = list(vertices)
    color: Dict[Vertex, int] = {}

    def extend(i: int) -> bool:
        if i == len(order):
            return True
        v = order[i]
        for c in sorted(lists[v]):
            if all(color.get(u) != c for u in adj[v]):
                color[v] = c
                if extend(i + 1):
                    return True
                del color[v]
        return False

    return dict(color) if extend(0) else None
