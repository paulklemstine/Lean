from __future__ import annotations
from itertools import combinations, chain
from typing import FrozenSet, List, Set, Tuple

Ext = FrozenSet[int]
Rel = Set[Tuple[int, int]]


def powerset(xs: List[int]) -> List[Ext]:
    return [frozenset(c) for c in chain.from_iterable(
        combinations(xs, k) for k in range(len(xs) + 1))]


def euler_characteristic(args: List[int], r: Rel) -> int:
    """
    Unreduced Euler characteristic of the conflict-free complex K(AF):
        chi = sum over nonempty conflict-free faces s of (-1)^(|s|-1).
    A subset s is a face iff it is conflict-free (no internal attack); by downward
    closure these faces form a genuine simplicial complex, so chi is a bona fide
    topological invariant equal to  #vertices - #edges + #triangles - ...
    """
    total = 0
    for s in powerset(args):
        if len(s) == 0:
            continue
        if not any((a, b) in r for a in s for b in s):  # conflict-free
            total += (-1) ** (len(s) - 1)
    return total
