import math
from typing import List, Tuple, Optional

Point = Tuple[float, ...]

def distance(p: Point, q: Point) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(p, q)))

def mst_weight(points: List[Point]) -> float:
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

def select_native_fold(
    decoys: List[Tuple[str, List[Point]]]
) -> Tuple[Optional[str], float]:
    """Return the (unique) minimizer of the topological energy over an ensemble.

    By the existence/uniqueness theorems, when energies are distinct this is the
    well-defined native fold.
    """
    best_name: Optional[str] = None
    best_e = math.inf
    for name, pts in decoys:
        e = mst_weight(pts)
        if e < best_e:
            best_name, best_e = name, e
    return best_name, best_e
