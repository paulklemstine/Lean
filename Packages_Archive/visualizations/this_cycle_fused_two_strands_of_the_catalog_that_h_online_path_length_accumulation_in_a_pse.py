from __future__ import annotations
from typing import Callable, Sequence, TypeVar

P = TypeVar('P')

def path_length(f: Sequence[P], n: int, dist: Callable[[P, P], float]) -> float:
    total: float = 0.0
    for i in range(n):
        total += dist(f[i], f[i + 1])
    return total

def path_length_extend(prev_total: float, f: Sequence[P], n: int,
                       dist: Callable[[P, P], float]) -> float:
    return prev_total + dist(f[n], f[n + 1])