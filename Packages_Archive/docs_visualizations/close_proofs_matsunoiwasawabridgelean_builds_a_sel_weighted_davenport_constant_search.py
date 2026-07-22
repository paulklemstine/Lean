from __future__ import annotations
from typing import Optional, Sequence


def weighted_davenport(weight_set: Sequence[int], m: int,
                       n_max: int = 12) -> Optional[int]:
    from itertools import product
    def valid(n):
        alphabet = sorted({0} | {w % m for w in weight_set})
        for a in product(alphabet, repeat=n):
            if any(c % m != 0 for c in a):
                yield a
    def cover(n):
        for x in product(range(m), repeat=n):
            if not any(sum(ai * xi for ai, xi in zip(a, x)) % m == 0
                       for a in valid(n)):
                return False
        return True
    for n in range(1, n_max + 1):
        if cover(n):
            return n
    return None
