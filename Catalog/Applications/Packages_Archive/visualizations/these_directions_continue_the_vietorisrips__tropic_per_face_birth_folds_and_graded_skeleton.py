from itertools import combinations
from typing import Callable, List, Sequence, Tuple

Point = Tuple[float, ...]
Metric = Callable[[Point, Point], float]


def face_birth(face: Sequence[Point], dist: Metric) -> float:
    """Birth scale of one face: the internal max-plus fold of its edge lengths."""
    if len(face) < 2:
        return float("-inf")
    return max(dist(p, q) for p, q in combinations(face, 2))


def skeleton_completion_scales(points: Sequence[Point], dist: Metric,
                               kmax: int) -> List[float]:
    """For each dimension k in 1..kmax, the scale at which the full k-skeleton
    appears: max over all (k+1)-subsets of their face_birth. Each equals the
    diameter for k >= 1, but the per-dimension folds expose the graded structure.
    """
    out: List[float] = []
    n = len(points)
    for k in range(1, kmax + 1):
        scale = float("-inf")
        for face in combinations(points, k + 1):
            scale = max(scale, face_birth(face, dist))
        out.append(scale)
    return out
