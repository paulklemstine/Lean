from __future__ import annotations
from typing import Sequence


def cancellation_codimension(energies: Sequence[float],
                             tol: float = 1e-12) -> int:
    """Codimension of the cancellation subspace {d : L == 0} for fixed spectrum.

    Equals the number of DISTINCT energy values (each contributes one
    independent level-sum functional d -> S(v)). Time O(n log n).
    """
    reps: list[float] = []
    for e in sorted(energies):
        if not reps or abs(e - reps[-1]) > tol:
            reps.append(e)
    return len(reps)
