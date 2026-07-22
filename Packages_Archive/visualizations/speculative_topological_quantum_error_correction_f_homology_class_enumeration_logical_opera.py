from itertools import product
from typing import List
Matrix = List[List[int]]
Vector = List[int]

def mat_vec(mat: Matrix, v: Vector) -> Vector:
    return [sum(row[j] * v[j] for j in range(len(v))) % 2 for row in mat]

def homology_representatives(d1: Matrix, d2: Matrix, n: int, n2: int) -> List[Vector]:
    """Enumerate coset representatives of H1 = ker(d1) / im(d2) over F2.

    Returns one nonzero representative per nontrivial homology class (small n).
    """
    zero = [0] * (len(d1) if d1 else 0)
    boundaries = {tuple(mat_vec(d2, list(x))) for x in product((0, 1), repeat=n2)} \
        if n2 else {tuple([0] * n)}
    reps: List[Vector] = []
    seen = set(boundaries)
    for x in product((0, 1), repeat=n):
        v = list(x)
        if (not d1 or mat_vec(d1, v) == zero) and tuple(v) not in seen:
            reps.append(v)
            # mark the whole coset v + boundaries as seen
            for b in list(boundaries):
                seen.add(tuple((a ^ c) for a, c in zip(v, b)))
    return reps
