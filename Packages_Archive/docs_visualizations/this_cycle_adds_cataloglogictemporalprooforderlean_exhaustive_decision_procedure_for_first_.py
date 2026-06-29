from __future__ import annotations
from itertools import product
from typing import Callable, List, Tuple

Pair = Tuple[bool, bool]
FOUR: List[Pair] = [(False, False), (False, True), (True, False), (True, True)]

def designated(a: Pair) -> bool:
    return a[0]

def fde_entails(
    premises: Callable[[Tuple[Pair, ...]], Pair],
    conclusion: Callable[[Tuple[Pair, ...]], Pair],
    arity: int,
) -> bool:
    """
    Decide FDE entailment: `premises |= conclusion` holds iff, for every
    assignment of FOUR-values to the `arity` propositional variables, whenever
    the premise formula is designated the conclusion formula is designated too.
    Exhaustive over 4**arity assignments; each check is O(1).
    """
    for assignment in product(FOUR, repeat=arity):
        if designated(premises(assignment)) and not designated(conclusion(assignment)):
            return False
    return True
