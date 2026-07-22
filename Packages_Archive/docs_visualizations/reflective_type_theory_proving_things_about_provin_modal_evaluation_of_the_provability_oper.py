from __future__ import annotations
from typing import FrozenSet, Set, Tuple

World = int
Relation = Set[Tuple[World, World]]
Prop = FrozenSet[World]


def successors(R: Relation, w: World) -> Set[World]:
    """All stages reachable from w in one provability step."""
    return {v for (a, v) in R if a == w}


def box(worlds: Set[World], R: Relation, P: Prop) -> Prop:
    """Necessity: w in box P iff every one-step successor of w lies in P."""
    return frozenset(w for w in worlds if successors(R, w) <= set(P))


def dia(worlds: Set[World], R: Relation, P: Prop) -> Prop:
    """Possibility: w in dia P iff some one-step successor of w lies in P."""
    return frozenset(w for w in worlds if successors(R, w) & set(P))


def provable_not_provably_provable(
    worlds: Set[World], R: Relation, P: Prop, w: World
) -> bool:
    """Decide box P and not box box P at world w."""
    bP = box(worlds, R, P)
    bbP = box(worlds, R, bP)
    return (w in bP) and (w not in bbP)
