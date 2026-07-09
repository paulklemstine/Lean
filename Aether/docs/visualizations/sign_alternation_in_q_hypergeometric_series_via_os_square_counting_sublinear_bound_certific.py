import math
from typing import Tuple

def square_count_bound(N: int) -> Tuple[int, float, bool]:
    """Return (#perfect squares < N, sqrt(N)+1, whether the bound holds).
    Certifies the sublinear-counting criterion for density zero of the squares."""
    count = math.isqrt(N - 1) + 1 if N > 0 else 0  # squares 0,1,...,isqrt(N-1)^2
    bound = math.sqrt(N) + 1.0
    return count, bound, count <= bound
