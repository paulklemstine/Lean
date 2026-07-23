from itertools import product
from typing import Dict, List, Tuple

Cell = Tuple[int, int, int]
Table = Dict[Cell, int]
CELLS: List[Cell] = list(product((0, 1), repeat=3))


def M3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1


def margins(u: Table) -> Tuple[Tuple[int, ...], ...]:
    a = tuple(u[(i, j, 0)] + u[(i, j, 1)] for i, j in product((0, 1), repeat=2))
    b = tuple(u[(i, 0, k)] + u[(i, 1, k)] for i, k in product((0, 1), repeat=2))
    c = tuple(u[(0, j, k)] + u[(1, j, k)] for j, k in product((0, 1), repeat=2))
    return (a, b, c)


def decompose_difference(u: Table, v: Table) -> Tuple[int, bool]:
    """
    Given two equal-margin tables, return (t, ok) where t = v000 - u000 is the
    unique multiplier with v = u + t*M3 (rank-one kernel theorem), and ok
    certifies the reconstruction matches v exactly.
    """
    assert margins(u) == margins(v), "tables must share two-way margins"
    t: int = v[(0, 0, 0)] - u[(0, 0, 0)]
    reconstructed: Table = {c: u[c] + t * M3(*c) for c in CELLS}
    return t, reconstructed == v
