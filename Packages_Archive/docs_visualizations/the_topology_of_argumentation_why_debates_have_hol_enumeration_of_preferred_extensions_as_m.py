from __future__ import annotations
from itertools import combinations, chain
from typing import FrozenSet, List, Set, Tuple

Ext = FrozenSet[int]
Rel = Set[Tuple[int, int]]


def powerset(xs: List[int]) -> List[Ext]:
    return [frozenset(c) for c in chain.from_iterable(
        combinations(xs, k) for k in range(len(xs) + 1))]


def is_admissible(s: Ext, r: Rel) -> bool:
    conflict_free = not any((a, b) in r for a in s for b in s)
    if not conflict_free:
        return False
    for a in s:
        attackers = [b for (b, t) in r if t == a]
        if not all(any((c, b) in r for c in s) for b in attackers):
            return False
    return True


def preferred_extensions(args: List[int], r: Rel) -> List[Ext]:
    """
    Enumerate all maximal admissible sets. We first collect every admissible
    subset, then keep those that are not strictly contained in another admissible
    subset. Correctness rests on Dung's Fundamental Lemma, which guarantees that
    maximal admissible sets exist and are exactly the preferred extensions.
    """
    admissible = [s for s in powerset(args) if is_admissible(s, r)]
    return [s for s in admissible if not any(s < t for t in admissible)]
