from __future__ import annotations
from typing import Callable

def cascade_bound(region: set[int], pattern_size: int, target: int,
                  bounds: list[Callable[[set[int]], int]]) -> tuple[int, bool]:
    best = len(region)
    for bound in bounds:
        best = min(best, bound(region))
        if pattern_size + best < target:
            return best, True
    return best, pattern_size + best < target
