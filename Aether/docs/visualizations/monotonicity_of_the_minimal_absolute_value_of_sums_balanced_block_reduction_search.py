from __future__ import annotations
import cmath, math
from typing import Iterator, Tuple

ZETA: complex = cmath.exp(2j * math.pi / 5)

def reduced_forms(total_max: int, residue: int) -> Iterator[Tuple[int, ...]]:
    for total in range(residue, total_max + 1, 5):
        for a0 in range(total + 1):
            for a1 in range(total - a0 + 1):
                for a2 in range(total - a0 - a1 + 1):
                    for a3 in range(total - a0 - a1 - a2 + 1):
                        a4 = total - a0 - a1 - a2 - a3
                        c = (a0, a1, a2, a3, a4)
                        if min(c) == 0:
                            yield c

def sigma5_reduced(n: int) -> float:
    r = n % 5
    best = math.inf
    for c in reduced_forms(n, r):
        best = min(best, abs(sum(a * ZETA ** k for k, a in enumerate(c))))
    return best
