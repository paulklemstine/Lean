from __future__ import annotations
from typing import Callable, List, Sequence

def affine_map(a: int, b: int, p: int) -> Callable[[int], int]:
    return lambda x: (a * x + b) % p

def is_bijection_mod_p(a: int, b: int, p: int) -> bool:
    f = affine_map(a, b, p)
    return sorted(f(x) for x in range(p)) == list(range(p))

def pigeonhole_advantage(delta: float, coord_adv: Sequence[float]) -> int:
    """Return i with coord_adv[i] >= delta/n (exists if delta<=sum)."""
    n: int = len(coord_adv)
    thresh: float = delta / n
    for i, c in enumerate(coord_adv):
        if c >= thresh:
            return i
    raise AssertionError('pigeonhole guarantee violated')
