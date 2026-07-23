from itertools import product
from typing import Dict, List, Tuple

Cell = Tuple[int, int, int]
Table = Dict[Cell, int]
CELLS: List[Cell] = list(product((0, 1), repeat=3))


def m3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1


def geodesic_walk(u: Table, v: Table) -> List[Table]:
    """Construct a shortest nonnegative walk u -> v by adding/subtracting M3.

    Length is exactly |v(0,0,0) - u(0,0,0)|; every intermediate table is
    nonnegative (discrete convexity). O(d) where d is the distance.
    """
    t: int = v[(0, 0, 0)] - u[(0, 0, 0)]
    step: int = 1 if t >= 0 else -1
    cur: Table = dict(u)
    path: List[Table] = [dict(cur)]
    for _ in range(abs(t)):
        cur = {c: cur[c] + step * m3(*c) for c in CELLS}
        assert all(x >= 0 for x in cur.values())
        path.append(dict(cur))
    return path
