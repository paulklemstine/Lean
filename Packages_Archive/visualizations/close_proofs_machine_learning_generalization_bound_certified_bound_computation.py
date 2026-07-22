from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Tuple

@dataclass(frozen=True)
class Base: pass

@dataclass(frozen=True)
class Arrow:
    dom: "Ty"
    cod: "Ty"

Ty = Union[Base, Arrow]

def size(a: Ty) -> int:
    if isinstance(a, Base):
        return 1
    return 1 + size(a.dom) + size(a.cod)

def type_state_bound(a: Ty) -> int:
    if isinstance(a, Base):
        return 1
    return (type_state_bound(a.dom) + 1) * (type_state_bound(a.cod) + 1)

def certified_bound(a: Ty) -> Tuple[int, int, bool]:
    """Return (typeStateBound, predictedBound = 2^size - 1, certificate_holds).

    The certificate `tsb <= 2^size - 1` is Corollary 4.9; it is guaranteed to be
    True for every input by Theorem 4.8.  Big integers are required because the
    value can be doubly exponential in depth.
    """
    tsb = type_state_bound(a)
    pred = 2 ** size(a) - 1
    return tsb, pred, tsb <= pred
