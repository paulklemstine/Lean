from __future__ import annotations
from itertools import combinations
from typing import Callable, FrozenSet, List, Set

Elt = FrozenSet[int]

def enumerate_downsets(points: List[int],
                       leq: Callable[[int, int], bool]) -> List[Elt]:
    """Return all down-closed subsets of a finite poset (the frame elements)."""
    out: List[Elt] = []
    for r in range(len(points) + 1):
        for combo in combinations(points, r):
            s = set(combo)
            if all(p in s for q in s for p in points if leq(p, q)):
                out.append(frozenset(s))
    return out

def heyting_implication(elements: List[Elt], a: Elt, c: Elt) -> Elt:
    """a ⇨ c as the join of all x with a ⊓ x ≤ c (the greatest such x)."""
    acc: Set[int] = set()
    for x in elements:
        if (a & x) <= c:
            acc |= x
    return frozenset(acc)
