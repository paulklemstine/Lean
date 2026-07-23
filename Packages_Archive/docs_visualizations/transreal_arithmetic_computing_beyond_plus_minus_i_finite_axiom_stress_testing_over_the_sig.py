from __future__ import annotations
from itertools import product
from typing import Callable, List
from demo import TReal


def representative_set() -> List[TReal]:
    return [TReal.phi(), TReal.pinf(), TReal.ninf(),
            TReal.real(-2.0), TReal.real(0.0), TReal.real(3.0)]


def stress_test(identity: Callable[..., bool], arity: int) -> bool:
    """True iff `identity` holds over every assignment from the
    representative set (6**arity evaluations)."""
    S = representative_set()
    return all(identity(*a) for a in product(S, repeat=arity))
