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
    return min(abs(sum(a * ZETA ** r for r, a in enumerate(c)))
               for c in compositions(n, 5))

def certify_monotone(kmax: int = 4, eps: float = 1e-12) -> bool:
    for r in range(5):
        prev = sigma5(r)
        for k in range(1, kmax + 1):
            cur = sigma5(5 * k + r)
            if cur > prev + eps:
                return False
            prev = cur
    return True
