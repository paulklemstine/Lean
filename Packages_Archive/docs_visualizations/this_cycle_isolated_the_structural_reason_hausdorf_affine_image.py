from __future__ import annotations
from typing import Callable, List, Sequence


def affine_image(c: float, a: float,
                 points: Sequence[float]) -> List[float]:
    """Apply the invertible affine map x -> c*x + a to every point.

    Requires c != 0 so that the map is bi-Lipschitz (Lipschitz constant |c|,
    antilipschitz constant 1/|c|).  By the affine-invariance theorem the
    Hausdorff dimension of the image equals that of the input.  If c == 0 the
    map is the constant map a, which is Lipschitz but not antilipschitz and
    collapses dimension to 0 -- hence we forbid it.
    """
    if c == 0.0:
        raise ValueError("c must be nonzero for an invertible (bi-Lipschitz) map")
    return [c * x + a for x in points]
