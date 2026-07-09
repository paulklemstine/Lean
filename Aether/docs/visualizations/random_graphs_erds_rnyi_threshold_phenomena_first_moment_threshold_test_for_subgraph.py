import math
from typing import Tuple

def first_moment_triangle_bound(n: int, p: float,
                                small: float = 1e-2) -> Tuple[float, bool]:
    """Upper bound on P(>=1 triangle) and an a.a.s.-triangle-free flag."""
    mean = math.comb(n, 3) * p ** 3
    bound = min(mean, 1.0)
    triangle_free_aas = (n * p) < small
    return bound, triangle_free_aas
