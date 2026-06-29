from typing import Union
from dataclasses import dataclass


@dataclass(frozen=True)
class Base:
    """Base type o."""


@dataclass(frozen=True)
class Arrow:
    left: "Ty"
    right: "Ty"


Ty = Union[Base, Arrow]


def depth(a: Ty) -> int:
    if isinstance(a, Base):
        return 0
    return 1 + max(depth(a.left), depth(a.right))


def arrow_width(a: Ty) -> int:
    if isinstance(a, Base):
        return 0
    return 1 + arrow_width(a.left) + arrow_width(a.right)


def is_chain(a: Ty) -> bool:
    if isinstance(a, Base):
        return True
    return isinstance(a.left, Base) and is_chain(a.right)


def regime_classifier(a: Ty) -> str:
    """Classify a type's growth regime.

    Tame (chain) types satisfy depth == width and grow singly exponentially in
    depth (T <= 3^(depth+1), Theorem 4.2). Any branching type has width > depth;
    depth alone is then insufficient and only the size bound 2^size - 1 applies.
    """
    if is_chain(a):
        return "tame chain: single exponential in depth (T <= 3^(depth+1))"
    if arrow_width(a) > depth(a):
        return "branching: depth insufficient; size bound 2^size - 1 applies"
    return "borderline"
