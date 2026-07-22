from __future__ import annotations
from itertools import product
from typing import List

def pattern_lp_norm(W: List[List[float]], edges: List[tuple], k_vertices: int,
                    p: float) -> float:
    """||W_F||_{L^p} for a pattern F given by its edge list on k_vertices vertices.

    Averages prod_{(u,v) in edges} W[phi[u]][phi[v]]^p over all maps phi and takes
    the (1/p)-th power. Exact but O(N^k) in the number of pattern vertices.
    """
    n = len(W)
    total = 0.0
    for phi in product(range(n), repeat=k_vertices):
        prod = 1.0
        for (u, v) in edges:
            prod *= W[phi[u]][phi[v]] ** p
        total += prod
    return (total / n ** k_vertices) ** (1.0 / p)
