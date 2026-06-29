from itertools import combinations
from typing import Callable, List, Sequence, Tuple

Point = Tuple[float, ...]


def edge_count_profile_sorted(points: Sequence[Point],
                              max_threshold: int,
                              dist: Callable[[Point, Point], float]) -> List[int]:
    """Compute the full edge-count profile profile(0..max_threshold) in O(n^2 log n)
    by sorting the pairwise distances once and accumulating, instead of one O(n^2)
    sweep per threshold."""
    dists: List[float] = sorted(dist(points[i], points[j])
                                for i, j in combinations(range(len(points)), 2))
    profile: List[int] = []
    idx = 0
    for r in range(max_threshold + 1):
        # advance over all pairwise distances <= r
        while idx < len(dists) and dists[idx] <= r:
            idx += 1
        profile.append(idx)  # idx pairs are within distance r
    return profile
