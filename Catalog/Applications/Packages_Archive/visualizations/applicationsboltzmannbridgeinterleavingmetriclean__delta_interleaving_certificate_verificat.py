from __future__ import annotations
import math
from typing import Dict, FrozenSet, Sequence

Simplex = FrozenSet[int]
WeightTable = Dict[Simplex, float]


def is_interleaved(F: WeightTable, G: WeightTable, delta: float,
                   grid: Sequence[float]) -> bool:
    """Verify the delta-interleaving inclusions (Definition 2.4):
    F.sublevel(t) subset G.sublevel(t+delta) and symmetrically, for every t in
    `grid`.  Because the weights are monotone, checking at the birth scales is
    exact.  Complexity: O(|grid| * #simplices)."""
    if delta < 0:
        return False
    simplices = set(F) | set(G)
    for t in grid:
        for sigma in simplices:
            wf = F.get(sigma, math.inf)
            wg = G.get(sigma, math.inf)
            if wf <= t and not (wg <= t + delta):
                return False
            if wg <= t and not (wf <= t + delta):
                return False
    return True
