from itertools import product
from typing import Dict, Tuple

Index = Tuple[int, int, int]
Table = Dict[Index, int]

def margins(u: Table) -> Tuple[dict, dict, dict]:
    m12 = {(i, j): u[(i, j, 0)] + u[(i, j, 1)] for i in (0, 1) for j in (0, 1)}
    m13 = {(i, k): u[(i, 0, k)] + u[(i, 1, k)] for i in (0, 1) for k in (0, 1)}
    m23 = {(j, k): u[(0, j, k)] + u[(1, j, k)] for j in (0, 1) for k in (0, 1)}
    return m12, m13, m23

def same_margins(u: Table, v: Table) -> bool:
    return margins(u) == margins(v)
