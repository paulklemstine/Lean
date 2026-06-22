from math import sqrt
from typing import Sequence, Tuple

Point = Tuple[float, ...]


def dist(x: Point, y: Point) -> float:
    return sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def directed_hausdorff(A: Sequence[Point], B: Sequence[Point]) -> float:
    """sup_{a in A} inf_{b in B} dist(a, b)."""
    return max(min(dist(a, b) for b in B) for a in A)


def hausdorff_dist(A: Sequence[Point], B: Sequence[Point]) -> float:
    """Symmetric Hausdorff distance between nonempty finite sets."""
    return max(directed_hausdorff(A, B), directed_hausdorff(B, A))


def is_novel_set(eps: float, family: Sequence[Sequence[Point]],
                 A: Sequence[Point]) -> bool:
    """Set A is eps-novel against a family in the Hausdorff metric."""
    return all(eps <= hausdorff_dist(A, B) for B in family)
