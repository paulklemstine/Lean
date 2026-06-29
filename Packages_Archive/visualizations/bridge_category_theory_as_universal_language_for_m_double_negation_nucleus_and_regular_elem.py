from __future__ import annotations
from typing import FrozenSet, List, Set

Elt = FrozenSet[int]

def pseudocomplement(elements: List[Elt], a: Elt) -> Elt:
    """aᶜ = a ⇨ ⊥ : the join of all x disjoint from a."""
    acc: Set[int] = set()
    for x in elements:
        if not (a & x):
            acc |= x
    return frozenset(acc)

def double_negation(elements: List[Elt], a: Elt) -> Elt:
    """The nucleus dneg a = aᶜᶜ (regularization / interior-of-closure)."""
    return pseudocomplement(elements, pseudocomplement(elements, a))

def regular_elements(elements: List[Elt]) -> List[Elt]:
    """Fixed points of the nucleus: {a | aᶜᶜ = a}."""
    return [a for a in elements if double_negation(elements, a) == a]
