from itertools import product
from typing import List, Optional
Matrix = List[List[int]]
Vector = List[int]

def mat_vec(mat: Matrix, v: Vector) -> Vector:
    return [sum(row[j] * v[j] for j in range(len(v))) % 2 for row in mat]

def systole_distance(d1: Matrix, d2: Matrix, n: int, n2: int) -> int:
    """Minimum Hamming weight of a Z-cycle that is not a Z-boundary."""
    zero = [0] * (len(d1) if d1 else 0)
    boundaries = {tuple(mat_vec(d2, list(x))) for x in product((0, 1), repeat=n2)} \
        if n2 else {tuple([0] * n)}
    best: Optional[int] = None
    for x in product((0, 1), repeat=n):
        v = list(x)
        if (not d1 or mat_vec(d1, v) == zero) and tuple(v) not in boundaries:
            w = sum(v)
            best = w if best is None else min(best, w)
    return -1 if best is None else best
