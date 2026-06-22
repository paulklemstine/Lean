from itertools import product
from typing import Dict, List, Tuple

Cell = Tuple[int, int, int]
Table = Dict[Cell, int]
CELLS: List[Cell] = list(product((0, 1), repeat=3))


def M3(i: int, j: int, k: int) -> int:
    """Alternating move: +1 if i+j+k even, -1 if odd."""
    return 1 if (i + j + k) % 2 == 0 else -1


def add_scaled(u: Table, scale: int) -> Table:
    """Return u + scale * M3."""
    return {c: u[c] + scale * M3(*c) for c in CELLS}


def is_nonneg(u: Table) -> bool:
    return all(v >= 0 for v in u.values())


def connecting_walk(u: Table, v: Table) -> List[Table]:
    """
    Explicit non-negative +/- M3 walk from u to v.
    Precondition: u, v >= 0 and same two-way margins.
    Complexity: O(|t|) steps, t = v[(0,0,0)] - u[(0,0,0)].
    """
    t: int = v[(0, 0, 0)] - u[(0, 0, 0)]          # unique multiplier (rank-one kernel)
    step: int = 1 if t >= 0 else -1
    path: List[Table] = [dict(u)]
    w: Table = dict(u)
    for _ in range(abs(t)):
        w = add_scaled(w, step)                     # one unit move toward v
        assert is_nonneg(w)                         # guaranteed by discrete convexity
        path.append(dict(w))
    assert w == v
    return path
