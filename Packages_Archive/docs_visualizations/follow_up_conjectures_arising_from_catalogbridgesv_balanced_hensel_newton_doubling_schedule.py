from __future__ import annotations
from typing import List, Tuple

def clog2(m: int) -> int:
    return 0 if m <= 1 else (m - 1).bit_length()

def hensel_schedule(target: int) -> Tuple[int, List[int]]:
    k: int = clog2(target)
    precisions: List[int] = []
    p: int = 1
    for _ in range(k + 1):
        precisions.append(p)
        p *= 2
    return k, precisions
