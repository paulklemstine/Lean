from typing import Dict, List, Tuple

Edge = Tuple[int, int]


def degree_parity_check(ends: List[Edge], n_vertices: int) -> Tuple[int, bool]:
    """Return (#odd-degree vertices, whether <= 2 so a trail may exist)."""
    deg: Dict[int, int] = {v: 0 for v in range(n_vertices)}
    for (u, w) in ends:
        deg[u] += 1
        deg[w] += 1  # a loop (u == w) adds 2 to deg[u]
    odd = sum(1 for v in range(n_vertices) if deg[v] % 2 == 1)
    return odd, odd <= 2
