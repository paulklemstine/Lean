from __future__ import annotations
import cmath, math
from typing import Iterator, Tuple

ZETA: complex = cmath.exp(2j * math.pi / 5)

def compositions(n: int, parts: int) -> Iterator[Tuple[int, ...]]:
    if parts == 1:
        yield (n,); return
    for first in range(n + 1):
        for rest in compositions(n - first, parts - 1):
            yield (first,) + rest

def sigma5(n: int) -> float:
    best = math.inf
    for c in compositions(n, 5):
        best = min(best, abs(sum(a * ZETA ** r for r, a in enumerate(c))))
    return best
