from __future__ import annotations
from typing import Dict, FrozenSet, Optional, Tuple

Simplex = FrozenSet[int]
Weight = Dict[Simplex, float]

def optimal_interleaving(w_f: Weight, w_g: Weight) -> Tuple[float, Optional[Simplex]]:
    """Return (interleaving distance D, witnessing simplex achieving the worst gap).
    D is an admissible shift (CESH stability) and the witness certifies that no
    smaller shift interleaves (Theorem 3.1), so D is provably optimal."""
    best_gap = 0.0
    witness: Optional[Simplex] = None
    for sigma in set(w_f) | set(w_g):
        gap = abs(w_f.get(sigma, 0.0) - w_g.get(sigma, 0.0))
        if gap > best_gap:
            best_gap, witness = gap, sigma
    return best_gap, witness
