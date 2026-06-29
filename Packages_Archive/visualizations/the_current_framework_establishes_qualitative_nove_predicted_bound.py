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


def size(a: Ty) -> int:
    """Total number of constructors: size(o)=1, size(A->B)=1+size(A)+size(B)."""
    if isinstance(a, Base):
        return 1
    return 1 + size(a.left) + size(a.right)


def predicted_bound(a: Ty) -> int:
    """Certified size-exponential ceiling 2^size(A) - 1.

    Theorem 7.1 guarantees state_bound(a) <= predicted_bound(a) for every type.
    Linear time to compute size, then one big-integer exponentiation.
    """
    return 2 ** size(a) - 1
