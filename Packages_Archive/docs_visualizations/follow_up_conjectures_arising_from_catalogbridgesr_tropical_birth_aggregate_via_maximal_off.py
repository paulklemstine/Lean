from math import inf
from typing import List

Matrix = List[List[float]]

def trop_birth_sum(dmat: Matrix) -> float:
    """Tropical (max-plus) sum of edge births = max off-diagonal distance.
    Returns -inf (tropical zero) for fewer than two points."""
    n: int = len(dmat)
    if n <= 1:
        return -inf
    return max(dmat[i][j] for i in range(n) for j in range(i + 1, n))
