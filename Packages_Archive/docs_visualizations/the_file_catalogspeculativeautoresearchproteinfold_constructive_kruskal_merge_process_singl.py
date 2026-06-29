from typing import Dict, List, Tuple

Edge = Tuple[int, int, int]  # (u, v, w)

def kruskal_deaths(edges: List[Edge]) -> List[int]:
    """Single-linkage / Kruskal merge process.

    Process edges in nondecreasing weight order over a union-find labelling;
    emit a death at an edge's weight exactly when it joins two distinct
    components. Returns the multiset (list) of death times = MST edge weights.
    """
    parent: Dict[int, int] = {}

    def find(x: int) -> int:
        parent.setdefault(x, x)
        root = x
        while parent[root] != root:
            root = parent[root]
        while parent[x] != root:  # path compression
            parent[x], x = root, parent[x]
        return root

    deaths: List[int] = []
    for (u, v, w) in sorted(edges, key=lambda e: e[2]):
        ru, rv = find(u), find(v)
        if ru != rv:
            parent[rv] = ru        # merge components
            deaths.append(w)       # record the death
    return deaths
