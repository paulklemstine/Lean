from __future__ import annotations
import itertools
from typing import Iterable, Sequence, Tuple

def all_sign_vectors(m: int) -> Iterable[Tuple[bool, ...]]:
    return itertools.product([False, True], repeat=m)

def rad_sum(f: Sequence[float], sigma: Sequence[bool]) -> float:
    return sum((1.0 if s else -1.0) * fi for s, fi in zip(sigma, f))

def emp_rad_symmetric_pair(f: Sequence[float]) -> float:
    m = len(f)
    total = sum(abs(rad_sum(f, s)) for s in all_sign_vectors(m))
    return (1.0 / m) * (1.0 / (2.0 ** m)) * total
