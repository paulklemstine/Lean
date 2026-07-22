from __future__ import annotations
import itertools
from typing import Iterable, Sequence, Tuple

Vector = Sequence[float]

def all_sign_vectors(m: int) -> Iterable[Tuple[bool, ...]]:
    return itertools.product([False, True], repeat=m)

def rad_sum(f: Vector, sigma: Sequence[bool]) -> float:
    return sum((1.0 if sigma[i] else -1.0) * f[i] for i in range(len(f)))

def emp_rad(classF: Sequence[Vector]) -> float:
    if not classF:
        raise ValueError('Function class must be nonempty.')
    m = len(classF[0])
    total = 0.0
    for sigma in all_sign_vectors(m):
        total += max(rad_sum(f, sigma) for f in classF)
    return (1.0 / m) * (1.0 / (2.0 ** m)) * total
