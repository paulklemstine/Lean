from __future__ import annotations
from typing import Sequence

def suffix_start(xs: Sequence[object]) -> int:
    if not xs: raise ValueError("empty sequence")
    i = len(xs) - 1
    while i > 0 and xs[i - 1] == xs[-1]: i -= 1
    return i

def synchronized_stage(costs: Sequence[int], ideals: Sequence[frozenset[str]]) -> int:
    if len(costs) != len(ideals) or not costs: raise ValueError("incompatible traces")
    if any(b > a for a, b in zip(costs, costs[1:])): raise ValueError("costs must descend")
    if any(not a <= b for a, b in zip(ideals, ideals[1:])): raise ValueError("ideals must ascend")
    return max(suffix_start(costs), suffix_start(ideals))
