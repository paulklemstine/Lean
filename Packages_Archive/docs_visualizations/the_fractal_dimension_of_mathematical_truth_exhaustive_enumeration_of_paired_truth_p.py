from __future__ import annotations
from itertools import product
from typing import Iterator

def enumerate_paired_prefixes(n: int) -> Iterator[tuple[int, ...]]:
    if n < 0: raise ValueError("n must be nonnegative")
    for free in product((0, 1), repeat=n):
        yield tuple(v for bit in free for v in (1, bit))
