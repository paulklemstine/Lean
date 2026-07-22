from __future__ import annotations
import itertools, math
from typing import Sequence

def cheb_distance(x: Sequence[int], s: Sequence[int]) -> int:
    return max(abs(int(a) - int(b)) for a, b in zip(x, s))

def verify_cover_and_bound(m: int, d: int, r: int,
                           centers: Sequence[Sequence[int]]) -> dict:
    """Verify that `centers` is an r-cover of {0,...,m-1}^d and check the packing bound.

    Returns a dict with the cover status, the cover size, the packing lower bound
    ceil(m^d/(2r+1)^d), and whether the bound is respected.
    """
    pts = itertools.product(range(m), repeat=d)
    is_cover = all(any(cheb_distance(x, s) <= r for s in centers) for x in pts)
    lower = math.ceil(m ** d / (2 * r + 1) ** d)
    size = len(list(centers))
    return {"is_cover": is_cover, "size": size,
            "packing_lower_bound": lower, "bound_respected": size >= lower}
