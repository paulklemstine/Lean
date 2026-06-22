from typing import Callable, Dict, Hashable, List, Set

def bottleneck_distance(
    points: List[Hashable],
    dist: Callable[[Hashable, Hashable], float],
    x: Hashable,
    y: Hashable,
) -> float:
    """Bottleneck (min-max path) distance: the smallest eps at which x and y
    become Rips-connected. Computed by Dijkstra relaxation under the (min, max)
    tropical semiring. Over an ultrametric space this equals dist(x, y)."""
    if x == y:
        return 0.0
    best: Dict[Hashable, float] = {p: float("inf") for p in points}
    best[x] = 0.0
    unvisited: Set[Hashable] = set(points)
    while unvisited:
        u = min(unvisited, key=lambda p: best[p])
        unvisited.remove(u)
        if u == y:
            return best[y]
        for v in unvisited:
            cand = max(best[u], dist(u, v))
            if cand < best[v]:
                best[v] = cand
    return best[y]
