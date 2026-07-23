from __future__ import annotations
from typing import Iterator, Tuple

def rank_of_apparition(m: int) -> int:
    a, b, k = 0, 1, 0
    while True:
        k += 1
        a, b = b % m, (a + b) % m
        if a == 0:
            return k

def two_adic_split(x: int) -> Tuple[int, int]:
    v = 0
    while x % 2 == 0:
        x //= 2
        v += 1
    return v, x

def apparition_indices(p: int, limit: int) -> Iterator[int]:
    """Yield all n <= limit with p | L(n), for an odd prime p."""
    a, s = two_adic_split(rank_of_apparition(p))
    if a == 0:
        return
    base = 2 ** (a - 1)
    t = 1
    while base * t <= limit:
        if t % s == 0:
            yield base * t
        t += 2
