from itertools import product
from typing import Dict, List, Tuple

Index = Tuple[int, int, int]
Table = Dict[Index, int]
CELLS = list(product((0, 1), repeat=3))

def M3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1

def add_scaled_M3(u: Table, t: int) -> Table:
    return {c: u[c] + t * M3(*c) for c in CELLS}

def is_nonneg(u: Table) -> bool:
    return all(v >= 0 for v in u.values())

def connecting_walk(u: Table, v: Table) -> List[Table]:
    t = v[(0, 0, 0)] - u[(0, 0, 0)]
    step = 1 if t > 0 else -1
    walk, cur = [u], u
    for _ in range(abs(t)):
        cur = add_scaled_M3(cur, step)
        assert is_nonneg(cur), 'discrete-convexity guarantee violated'
        walk.append(cur)
    assert cur == v
    return walk
