from typing import Dict, List, Tuple

Edge = Tuple[int, int]
Dissimilarity = Dict[Edge, float]

def interleaving_distance(d: Dissimilarity, d2: Dissimilarity,
                          points: List[int], eps_grid: List[float],
                          scales: List[float]) -> float:
    grid = sorted(eps_grid)
    if not grid or not is_interleaved(d, d2, points, grid[-1], scales):
        return float('inf')
    lo, hi = 0, len(grid) - 1
    while lo < hi:
        mid = (lo + hi) // 2
        if is_interleaved(d, d2, points, grid[mid], scales):
            hi = mid
        else:
            lo = mid + 1
    return grid[lo]
