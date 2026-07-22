from __future__ import annotations
from typing import List, Tuple


def geometric_lower_bounds(c: complex, z: complex, n_max: int) -> List[Tuple[int, float]]:
    """
    Produce the certified geometric lower bounds  |f_c^n(z)| >= |z|(|z|-1)^n
    for n = 0..n_max, valid whenever |z| > 2 and |c| <= |z|.

    The bound is computed in closed form (no iteration needed), so it is O(n_max)
    and numerically stable relative to iterating the (rapidly overflowing) orbit.
    """
    r = abs(z)
    if not (r > 2.0 and abs(c) <= r):
        raise ValueError("requires |z| > 2 and |c| <= |z|")
    return [(n, r * (r - 1.0) ** n) for n in range(n_max + 1)]
