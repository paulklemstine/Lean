import math
from typing import Tuple

def first_moments(n: int, p: float) -> Tuple[float, float, float]:
    """Exact (E[#edges], E[#triangles], E[#isolated]) for G(n, p)."""
    edges = math.comb(n, 2) * p
    triangles = math.comb(n, 3) * p ** 3
    isolated = n * (1.0 - p) ** (n - 1)
    return edges, triangles, isolated
