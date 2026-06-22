from itertools import combinations
from typing import List, Sequence, Tuple, FrozenSet
import math

Point = Tuple[float, ...]

def dist(x: Point, y: Point) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))

def is_vr_simplex(points: Sequence[Point], sigma: FrozenSet[int], r: float) -> bool:
    idx = list(sigma)
    return all(dist(points[i], points[j]) <= r for i in idx for j in idx)

def vr_complex(points: Sequence[Point], r: float, max_dim: int) -> List[FrozenSet[int]]:
    """Vietoris-Rips complex at scale r up to dimension max_dim.
    Monotone (VRSimplex_mono) and downward-closed (VRSimplex_of_subset)."""
    n = len(points)
    simplices: List[FrozenSet[int]] = [frozenset()]
    for k in range(1, max_dim + 2):
        for combo in combinations(range(n), k):
            sigma = frozenset(combo)
            if is_vr_simplex(points, sigma, r):
                simplices.append(sigma)
    return simplices
