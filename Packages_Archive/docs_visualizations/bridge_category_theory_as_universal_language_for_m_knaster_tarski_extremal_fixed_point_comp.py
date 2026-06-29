from __future__ import annotations
from typing import Callable, FrozenSet, List

Elt = FrozenSet[int]

def knaster_tarski_lfp(elements: List[Elt], top: Elt,
                       f: Callable[[Elt], Elt]) -> Elt:
    """Least fixed point = sInf {x | f x ≤ x} (meet of pre-fixed points)."""
    acc = top
    for x in elements:
        if f(x) <= x:          # x is pre-fixed
            acc = acc & x
    return acc

def knaster_tarski_gfp(elements: List[Elt], bot: Elt,
                       f: Callable[[Elt], Elt]) -> Elt:
    """Greatest fixed point = sSup {x | x ≤ f x} (join of post-fixed points)."""
    acc = bot
    for x in elements:
        if x <= f(x):          # x is post-fixed
            acc = acc | x
    return acc
