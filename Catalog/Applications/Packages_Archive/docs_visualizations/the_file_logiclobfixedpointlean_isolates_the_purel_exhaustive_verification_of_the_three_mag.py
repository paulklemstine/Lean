from itertools import combinations
from typing import FrozenSet, List

Prop = FrozenSet[int]


def box(s: Prop, n: int) -> Prop:
    return frozenset(k for k in range(n) if all(m in s for m in range(k)))


def all_props(n: int) -> List[Prop]:
    elts = list(range(n))
    return [frozenset(c) for size in range(n + 1) for c in combinations(elts, size)]


def verify_gl_axioms(n: int) -> bool:
    """Exhaustively verify the three GL axioms over all 2^n subsets of {0,...,n-1}."""
    universe = frozenset(range(n))
    if box(universe, n) != universe:            # box_top
        return False
    for a in all_props(n):
        box_a = box(a, n)
        himp = (universe - box_a) | a
        if not box(himp, n) <= box_a:           # Loeb's axiom
            return False
        if not box_a <= box(box_a, n):          # axiom 4 (derived)
            return False
        for b in all_props(n):
            if box(a & b, n) != box(a, n) & box(b, n):   # axiom K
                return False
    return True
