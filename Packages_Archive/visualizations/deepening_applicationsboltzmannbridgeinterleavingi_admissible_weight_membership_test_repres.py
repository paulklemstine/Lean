from fractions import Fraction
from typing import Dict, FrozenSet

Simplex = FrozenSet[int]


def is_admissible_weight(w: Dict[Simplex, Fraction]) -> bool:
    """True iff w is grounded and monotone (in the representation cone)."""
    if w[frozenset()] > 0:
        return False
    faces = list(w.keys())
    for sigma in faces:
        for tau in faces:
            if sigma <= tau and not (w[sigma] <= w[tau]):
                return False
    return True
