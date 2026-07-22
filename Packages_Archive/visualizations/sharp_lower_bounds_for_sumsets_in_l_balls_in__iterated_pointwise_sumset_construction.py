from __future__ import annotations
from itertools import product
from typing import Sequence, Set, Tuple

Point = Tuple[int, ...]

def iterated_sumset(sets: Sequence[Set[Point]]) -> Set[Point]:
    """Compute A_1 + A_2 + ... + A_n by folding pointwise sums.

    Complexity: O(prod_j |A_j|) in the worst case, but each fold is bounded by
    |partial sumset| * |A_j|, and the partial sumset never exceeds |B_d(km)|.
    """
    dim = len(next(iter(sets[0])))
    acc: Set[Point] = {tuple([0] * dim)}
    for A in sets:
        acc = {tuple(a + b for a, b in zip(x, y)) for x in acc for y in A}
    return acc
