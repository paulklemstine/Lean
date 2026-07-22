from itertools import product
from typing import Callable, List, Tuple

Kernel = Callable[[int, int], float]

def lp_pattern(W: Kernel, N: int, n_vertices: int,
               edges: List[Tuple[int, int]], p: float) -> float:
    total = 0.0
    for phi in product(range(N), repeat=n_vertices):
        w = 1.0
        for u, v in edges:
            w *= W(phi[u], phi[v]) ** p
        total += w
    return (total / N ** n_vertices) ** (1.0 / p)
