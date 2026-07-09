from __future__ import annotations
from typing import Dict, List, Tuple

TransMono = Dict[int, float]
Key = Tuple[Tuple[int, float], ...]
TSeries = Dict[Key, float]

def exp_shift(series: TSeries) -> TSeries:
    """
    Apply the exp-substitution x |-> e^x to a whole transseries by raising every
    tower height by one in every transmonomial, leaving coefficients fixed.
    Realizes expShift_term/expShift_var/expShift_C; injective (expShift_injective).
    """
    out: TSeries = {}
    for k, coeff in series.items():
        shifted: Key = tuple(sorted((h + 1, a) for h, a in k))
        out[shifted] = out.get(shifted, 0.0) + coeff
    return {k: c for k, c in out.items() if c != 0.0}
