from itertools import product
from typing import Dict, Tuple

Index = Tuple[int, int, int]
Table = Dict[Index, int]
CELLS = list(product((0, 1), repeat=3))

def M3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1

def lattice_coordinate(u: Table, v: Table) -> int:
    t = v[(0, 0, 0)] - u[(0, 0, 0)]
    assert all(v[c] - u[c] == t * M3(*c) for c in CELLS), \
        'tables are not in the same fiber'
    return t
