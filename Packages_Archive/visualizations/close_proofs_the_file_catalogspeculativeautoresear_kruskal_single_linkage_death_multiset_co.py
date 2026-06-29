from typing import Dict, List, Tuple

Edge = Tuple[int, int, int]

def kruskal_deaths(num_vertices: int, edges: List[Edge]) -> List[int]:
    """Return the multiset of death (merge) weights = MST edge weights."""
    label: Dict[int, int] = {v: v for v in range(num_vertices)}

    def rep(x: int) -> int:
        root = x
        while label[root] != root:
            root = label[root]
        while label[x] != root:
            label[x], x = root, label[x]
        return root

    deaths: List[int] = []
    for u, v, w in sorted(edges, key=lambda e: e[2]):
        ru, rv = rep(u), rep(v)
        if ru != rv:
            deaths.append(w)
            label[ru] = rv
    return deaths
