from __future__ import annotations
from itertools import product
from typing import Iterable, List, Sequence, Tuple


def valid_weightings(weight_set: Sequence[int], n: int, m: int) -> Iterable[Tuple[int, ...]]:
    alphabet: List[int] = sorted({0} | {w % m for w in weight_set})
    for a in product(alphabet, repeat=n):
        if any(c % m != 0 for c in a):
            yield a


def union_covers_all(weight_set: Sequence[int], n: int, m: int) -> bool:
    union: set = set()
    for a in valid_weightings(weight_set, n, m):
        for x in product(range(m), repeat=n):
            if sum(ai * xi for ai, xi in zip(a, x)) % m == 0:
                union.add(x)
    return len(union) == m ** n
