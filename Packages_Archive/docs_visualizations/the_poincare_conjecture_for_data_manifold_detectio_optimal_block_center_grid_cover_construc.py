from __future__ import annotations
import itertools
from typing import List, Tuple

def grid_cover(r: int, t: int, d: int) -> List[Tuple[int, ...]]:
    """Optimal r-cover of the cube of side m=(2r+1)*t in dimension d.

    Places one landmark at the center c_k = k*(2r+1)+r of each of the t blocks in
    every coordinate; the product of these t^1 centers over d coordinates gives t^d
    landmarks, which is exactly the minimal cover size.
    """
    centers_1d = [k * (2 * r + 1) + r for k in range(t)]
    return list(itertools.product(centers_1d, repeat=d))
