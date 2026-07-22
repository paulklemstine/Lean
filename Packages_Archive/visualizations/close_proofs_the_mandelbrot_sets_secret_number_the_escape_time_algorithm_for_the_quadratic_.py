from __future__ import annotations
from typing import Optional


def escape_time(c: complex, max_iter: int = 1000, radius: float = 2.0) -> Optional[int]:
    """
    Escape-time algorithm for f_c(z) = z^2 + c.

    Returns the smallest n such that |z_n| > radius (orbit guaranteed to
    diverge, by the geometric escape estimate), or None if the orbit stays
    within the disk of radius `radius` for `max_iter` steps.
    Complexity: O(max_iter) complex mult-adds per parameter c.
    """
    z: complex = 0.0 + 0.0j
    for n in range(1, max_iter + 1):
        z = z * z + c
        if abs(z) > radius:
            return n
    return None
