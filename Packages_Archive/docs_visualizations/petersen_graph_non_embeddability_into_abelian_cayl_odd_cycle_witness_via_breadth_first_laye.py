from collections import deque
from typing import Dict, List, Optional, Tuple

Vertex = object


def odd_cycle_witness(adj: Dict[Vertex, List[Vertex]]) -> Optional[List[Vertex]]:
    """
    Breadth-first 2-coloring. If some edge joins two equally-colored vertices,
    reconstruct and return the odd cycle it closes (a non-bipartiteness
    certificate); otherwise return None (the graph is bipartite).
    """
    color: Dict[Vertex, int] = {}
    parent: Dict[Vertex, Optional[Vertex]] = {}
    for start in adj:
        if start in color:
            continue
        color[start] = 0
        parent[start] = None
        q: deque = deque([start])
        while q:
            u = q.popleft()
            for w in adj[u]:
                if w not in color:
                    color[w] = color[u] ^ 1
                    parent[w] = u
                    q.append(w)
                elif color[w] == color[u]:
                    pu, x = [u], u
                    while parent[x] is not None:
                        x = parent[x]; pu.append(x)
                    pw, y = [w], w
                    while parent[y] is not None:
                        y = parent[y]; pw.append(y)
                    su = set(pu)
                    lca = next(z for z in pw if z in su)
                    return pu[: pu.index(lca) + 1] + list(reversed(pw[: pw.index(lca)]))
    return None
