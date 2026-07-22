from __future__ import annotations
from dataclasses import dataclass
from typing import Union

@dataclass(frozen=True)
class Base: pass

@dataclass(frozen=True)
class Arrow:
    dom: "Ty"
    cod: "Ty"

Ty = Union[Base, Arrow]

def depth(a: Ty) -> int:
    if isinstance(a, Base):
        return 0
    return 1 + max(depth(a.dom), depth(a.cod))

def arrow_width(a: Ty) -> int:
    if isinstance(a, Base):
        return 0
    return 1 + arrow_width(a.dom) + arrow_width(a.cod)

def classify_regime(a: Ty) -> str:
    """Classify the growth regime of a type from depth vs arrow width.

    - width == depth  : chain-like, SINGLE exponential in depth (Theorem 4.3),
                        ceiling 3^(depth+1).
    - width == 2^depth-1 : bushy/maximal, DOUBLE exponential in depth
                        (Theorem 4.6), witness 2^(2^depth).
    - otherwise       : intermediate, bounded by 2^size (Theorem 4.8).
    """
    d, w = depth(a), arrow_width(a)
    if w == d:
        return f"single-exponential-in-depth (chain regime); tsb <= 3^{d + 1}"
    if w == 2 ** d - 1:
        return f"double-exponential-in-depth (bushy regime); tsb+1 >= 2^(2^{d})"
    return "intermediate regime; tsb+1 <= 2^size"
