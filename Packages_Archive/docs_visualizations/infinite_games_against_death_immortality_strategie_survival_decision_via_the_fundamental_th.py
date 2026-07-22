from __future__ import annotations
from typing import Callable
# Assumes the Ordinal class of the ordinal-arithmetic algorithm is in scope.


def mortal_forces(value: "Ordinal", beta: "Ordinal") -> bool:
    """Fundamental Theorem: Mortal forces round beta iff beta <= value.

    Deciding survival for a whole game therefore reduces to a single ordinal
    comparison, computable in O(#terms) on Cantor Normal Forms."""
    return beta <= value


def round_of_death(value: "Ordinal") -> "Ordinal":
    """The least round Mortal cannot force is exactly the survival value."""
    return value


def survives_all_below(value: "Ordinal", betas: "list[Ordinal]") -> bool:
    """Downward closure check: if the largest forced round is <= value, then
    every earlier round is forced too."""
    return all(mortal_forces(value, b) for b in betas)
