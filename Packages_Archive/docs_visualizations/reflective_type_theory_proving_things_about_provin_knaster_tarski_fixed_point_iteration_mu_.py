from __future__ import annotations
from typing import Callable, FrozenSet, Set

World = int
Prop = FrozenSet[World]
Operator = Callable[[Prop], Prop]


def lfp(worlds: Set[World], f: Operator) -> Prop:
    """Least fixed point of a monotone operator by Kleene iteration from bottom.
    Terminates in at most |worlds| steps on a finite lattice."""
    cur: Prop = frozenset()
    while True:
        nxt = f(cur)
        if nxt == cur:
            return cur
        cur = nxt


def gfp(worlds: Set[World], f: Operator) -> Prop:
    """Greatest fixed point by Kleene iteration from top."""
    cur: Prop = frozenset(worlds)
    while True:
        nxt = f(cur)
        if nxt == cur:
            return cur
        cur = nxt
