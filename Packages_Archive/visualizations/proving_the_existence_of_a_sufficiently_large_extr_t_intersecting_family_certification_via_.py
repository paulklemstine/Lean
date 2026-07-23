from __future__ import annotations
from typing import Sequence, Tuple

Perm = Tuple[int, ...]

def inverse(sigma: Perm) -> Perm:
    inv = [0] * len(sigma)
    for i, s in enumerate(sigma):
        inv[s] = i
    return tuple(inv)

def is_t_intersecting(family: Sequence[Perm], t: int) -> bool:
    """Certify t-intersection via fixed points of pairwise quotients."""
    for sigma in family:
        inv = inverse(sigma)
        for tau in family:
            q = tuple(inv[tau[i]] for i in range(len(tau)))
            fixed = sum(1 for i in range(len(q)) if q[i] == i)
            if fixed < t:
                return False
    return True
