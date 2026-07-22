from __future__ import annotations
from random import Random
from typing import Sequence

def sample_invariant(n: int, classes: Sequence[Sequence[int]], seed: int=0) -> tuple[int,...]:
    rng=Random(seed); pattern=[0]*n
    for orbit in classes:
        bit=rng.randrange(2)
        for cell in orbit: pattern[cell]=bit
    return tuple(pattern)

def compress_invariant(pattern: Sequence[int], classes: Sequence[Sequence[int]]) -> tuple[int,...]:
    labels=[]
    for orbit in classes:
        values={pattern[i] for i in orbit}
        if len(values) != 1: raise ValueError("pattern is not invariant")
        labels.append(values.pop())
    return tuple(labels)
