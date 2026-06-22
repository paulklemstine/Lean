from itertools import combinations
from typing import Dict, List, Tuple

Edge = Tuple[int, int]


def odd_vertices(ends: List[Edge], n_vertices: int) -> List[int]:
    deg = {v: 0 for v in range(n_vertices)}
    for (u, w) in ends:
        deg[u] += 1
        deg[w] += 1
    return [v for v in range(n_vertices) if deg[v] % 2 == 1]


def min_pairing_cost(verts: List[int],
                     dist: Dict[Tuple[int, int], float]) -> float:
    """Exact minimum-weight perfect matching (small |verts|)."""
    if not verts:
        return 0.0
    first, rest = verts[0], verts[1:]
    best = float('inf')
    for i, partner in enumerate(rest):
        remaining = rest[:i] + rest[i + 1:]
        cost = dist[(first, partner)] + min_pairing_cost(remaining, dist)
        best = min(best, cost)
    return best
