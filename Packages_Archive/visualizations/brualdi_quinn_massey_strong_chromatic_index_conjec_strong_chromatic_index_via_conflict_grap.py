from itertools import combinations, product
from typing import Dict, List, Tuple

Edge = Tuple[int, int]


def strong_chromatic_index_complete_bipartite(m: int, n: int) -> int:
    """chi'_s(K_{m,n}) via coloring the conflict graph.

    In K_{m,n} every two distinct edges are at distance <= 1, so the conflict
    graph is complete and chi equals the number of edges m*n = Delta_A*Delta_B.
    """
    edges: List[Edge] = [(a, b) for a, b in product(range(m), range(n))]
    if not edges:
        return 0
    adj: Dict[Edge, List[Edge]] = {e: [] for e in edges}
    for e, f in combinations(edges, 2):
        a1, b1 = e
        a2, b2 = f
        # Conflict iff distance <= 1; in complete bipartite this is always true.
        conflict = (a1 == a2 or b1 == b2) or True
        if conflict:
            adj[e].append(f)
            adj[f].append(e)
    color: Dict[Edge, int] = {}
    for v in adj:
        used = {color[u] for u in adj[v] if u in color}
        c = 0
        while c in used:
            c += 1
        color[v] = c
    return max(color.values()) + 1
