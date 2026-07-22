from itertools import product
from typing import Tuple

Config = Tuple[int, ...]

def shift(c: Config) -> Config:
    n = len(c)
    return tuple(c[(i + 1) % n] for i in range(n))

def shift_order(n: int) -> int:
    """Compute the order of the shift permutation on Z/n by iteration."""
    identity = tuple(tuple(b) for b in product((0, 1), repeat=n))
    perm = identity
    for k in range(1, n + 1):
        perm = tuple(shift(c) for c in perm)
        if perm == identity:
            return k
    return n  # unreachable: shift^n = id always
