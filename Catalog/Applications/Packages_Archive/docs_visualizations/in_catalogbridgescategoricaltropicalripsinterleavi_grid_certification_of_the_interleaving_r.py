from itertools import product
from typing import Callable, Dict, FrozenSet, List, Tuple

Edge = Tuple[int, int]
Dissimilarity = Dict[Edge, float]

def rips_edges(d: Dissimilarity, points: List[int], t: float) -> FrozenSet[Edge]:
    return frozenset((x, y) for x, y in product(points, points)
                     if d.get((x, y), float('inf')) <= t)

def is_interleaved(d: Dissimilarity, d2: Dissimilarity, points: List[int],
                   eps: float, scales: List[float]) -> bool:
    for t in scales:
        M_t  = rips_edges(d,  points, t)
        N_te = rips_edges(d2, points, t + eps)
        N_t  = rips_edges(d2, points, t)
        M_te = rips_edges(d,  points, t + eps)
        if not (M_t <= N_te) or not (N_t <= M_te):
            return False
    return True
