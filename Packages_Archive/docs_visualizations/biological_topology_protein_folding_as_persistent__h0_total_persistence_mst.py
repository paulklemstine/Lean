import math
from typing import List, Tuple

Point = Tuple[float, ...]

def distance(p: Point, q: Point) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(p, q)))

def h0_total_persistence_mst(points: List[Point]) -> float:
    """Degree-0 total persistence = minimum-spanning-tree weight (Prim's algorithm).

    Components are all born at scale 0 and merge along MST edges; each MST edge
    weight is the death of one component, so the total persistence is the MST weight.
    """
    n = len(points)
    if n == 0:
        return 0.0
    in_tree = [False] * n
    best = [math.inf] * n
    best[0] = 0.0
    total = 0.0
    for _ in range(n):
        u = min((v for v in range(n) if not in_tree[v]), key=lambda v: best[v])
        in_tree[u] = True
        total += 0.0 if best[u] == math.inf else best[u]
        for v in range(n):
            if not in_tree[v]:
                best[v] = min(best[v], distance(points[u], points[v]))
    return total
