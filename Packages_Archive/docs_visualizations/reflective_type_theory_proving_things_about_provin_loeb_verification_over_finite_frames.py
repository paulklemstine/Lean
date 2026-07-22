from __future__ import annotations
from itertools import product
from typing import FrozenSet, List, Set, Tuple

World = int
Relation = Set[Tuple[World, World]]
Prop = FrozenSet[World]


def box(worlds: Set[World], R: Relation, P: Prop) -> Prop:
    return frozenset(w for w in worlds if {v for (a, v) in R if a == w} <= set(P))


def implies(worlds: Set[World], A: Prop, B: Prop) -> Prop:
    return frozenset((worlds - set(A)) | set(B))


def all_props(worlds: Set[World]) -> List[Prop]:
    ws = sorted(worlds)
    return [frozenset(w for w, b in zip(ws, bits) if b)
            for bits in product([False, True], repeat=len(ws))]


def loeb_holds(worlds: Set[World], R: Relation) -> bool:
    """Return True iff box(box P -> P) subset box P for every proposition P."""
    for P in all_props(worlds):
        premise = box(worlds, R, implies(worlds, box(worlds, R, P), P))
        if not (set(premise) <= set(box(worlds, R, P))):
            return False
    return True
