from __future__ import annotations
from collections import defaultdict
from typing import Dict, Sequence


def cancellation_test(energies: Sequence[float], shifts: Sequence[float],
                      tol: float = 1e-12) -> bool:
    """Return True iff L(t) = sum_i d_i exp(-t E_i) == 0 for all real t.

    Groups indices into energy levels and checks each aggregate shift is zero.
    Time O(n) up to level lookup; exact over the rationals.
    """
    levels: Dict[float, float] = defaultdict(float)
    reps: list[float] = []
    for e, d in zip(energies, shifts):
        key = next((r for r in reps if abs(r - e) <= tol), None)
        if key is None:
            reps.append(e)
            key = e
        levels[key] += d
    return all(abs(s) <= tol for s in levels.values())
