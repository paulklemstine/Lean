from __future__ import annotations
from typing import Sequence, Tuple


def pooled_bound(per_twist: Sequence[Tuple[float, float]], degree: int = 3) -> Tuple[float, bool]:
    """Aggregate per-twist counts (N_b, onLine_b) into a pooled proportion.

    Returns (pooled_proportion, certified) where certified is True iff every
    member satisfies onLine_b >= N_b / d^2. Runs in O(|family|) time.
    """
    base = 1.0 / (degree * degree)
    tot = 0.0
    onl = 0.0
    certified = True
    for n, k in per_twist:
        tot += n
        onl += k
        if k < base * n - 1e-12:
            certified = False
    if tot == 0.0:
        raise ValueError("empty family")
    return onl / tot, certified
