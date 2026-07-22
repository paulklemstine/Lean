from __future__ import annotations
from typing import FrozenSet, List, Set, Tuple

Ext = FrozenSet[int]
Rel = Set[Tuple[int, int]]


def defense_operator(s: Ext, args: List[int], r: Rel) -> Ext:
    """F(S): every argument all of whose attackers are counter-attacked by S."""
    def defends(a: int) -> bool:
        attackers = [b for (b, t) in r if t == a]
        return all(any((c, b) in r for c in s) for b in attackers)
    return frozenset(a for a in args if defends(a))


def grounded_extension(args: List[int], r: Rel) -> Ext:
    """
    Least fixed point of the monotone defense operator F, computed by Kleene
    iteration starting from the empty set. Because F is monotone on the finite
    subset lattice, the ascending chain  empty <= F(empty) <= F(F(empty)) <= ...
    stabilizes after at most |A| steps at the least fixed point.
    """
    current: Ext = frozenset()
    while True:
        nxt = defense_operator(current, args, r)
        if nxt == current:
            return current
        current = nxt
