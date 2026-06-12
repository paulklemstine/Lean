from typing import Union
from dataclasses import dataclass


@dataclass(frozen=True)
class Base:
    """Base type o."""


@dataclass(frozen=True)
class Arrow:
    """Arrow type left -> right."""
    left: "Ty"
    right: "Ty"


Ty = Union[Base, Arrow]


def state_bound(a: Ty) -> int:
    """Exact semantic state bound T(A).

    T(o) = 1 ;  T(A -> B) = (T(A) + 1) * (T(B) + 1).
    Linear in size(A) ignoring big-integer arithmetic cost; values may be
    double-exponentially large, so arbitrary-precision integers are required.
    """
    if isinstance(a, Base):
        return 1
    return (state_bound(a.left) + 1) * (state_bound(a.right) + 1)
