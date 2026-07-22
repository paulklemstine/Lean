from __future__ import annotations
from itertools import product
from typing import Iterator, Sequence

def enumerate_invariant(n: int, classes: Sequence[Sequence[int]]) -> Iterator[tuple[int,...]]:
    for labels in product((0,1), repeat=len(classes)):
        pattern=[0]*n
        for orbit,bit in zip(classes,labels):
            for cell in orbit: pattern[cell]=bit
        yield tuple(pattern)
