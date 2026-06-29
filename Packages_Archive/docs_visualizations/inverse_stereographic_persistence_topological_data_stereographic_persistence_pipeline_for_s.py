from __future__ import annotations
import math
from typing import List, Tuple

Vec = List[float]
SpherePoint = Tuple[List[float], float]

def forward_stereo(p: SpherePoint) -> Vec:
    """Forward stereographic projection S^n minus north pole -> R^n."""
    u, h = p
    return [ui / (1.0 - h) for ui in u]

def conformal_weight(x: Vec) -> float:
    return math.sqrt(1.0 + sum(xi * xi for xi in x))

def weighted_dist(x: Vec, y: Vec, wx: float, wy: float) -> float:
    d = math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))
    return 2.0 * d / (wx * wy)

def weighted_distance_matrix(cloud: List[SpherePoint]) -> List[List[float]]:
    flat = [forward_stereo(p) for p in cloud]
    w = [conformal_weight(x) for x in flat]
    n = len(flat)
    return [[weighted_dist(flat[i], flat[j], w[i], w[j]) for j in range(n)]
            for i in range(n)]

def h0_barcode(matrix: List[List[float]]) -> List[float]:
    """0-dim persistence = sorted MST edge weights (Prim)."""
    n = len(matrix)
    if n == 0:
        return []
    in_tree = [False] * n
    best = [math.inf] * n
    best[0] = 0.0
    deaths: List[float] = []
    for _ in range(n):
        u = min((i for i in range(n) if not in_tree[i]), key=lambda i: best[i])
        in_tree[u] = True
        if best[u] > 0.0:
            deaths.append(best[u])
        for v in range(n):
            if not in_tree[v] and matrix[u][v] < best[v]:
                best[v] = matrix[u][v]
    return sorted(deaths)

def spherical_persistence_via_stereo(cloud: List[SpherePoint]) -> List[float]:
    return h0_barcode(weighted_distance_matrix(cloud))
