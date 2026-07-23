from itertools import product
from typing import Dict, List, Tuple

Cell = Tuple[int, int, int]
Table = Dict[Cell, int]
CELLS: List[Cell] = list(product((0, 1), repeat=3))


def m3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1


def fiber_and_diameter(u: Table) -> Tuple[List[Table], int]:
    """Enumerate the fiber of u and return (members, diameter).

    Admissible multipliers t form the integer interval [lower, upper] where the
    eight nonnegativity half-lines intersect; the fiber is a path graph of
    diameter upper - lower. O(1) to find the interval; O(size) to materialize.
    """
    lower = max(-u[c] for c in CELLS if m3(*c) == 1)
    upper = min(u[c] for c in CELLS if m3(*c) == -1)
    members = [{c: u[c] + t * m3(*c) for c in CELLS} for t in range(lower, upper + 1)]
    return members, upper - lower
