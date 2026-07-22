from __future__ import annotations
import math
from typing import Dict, FrozenSet, Sequence

Simplex = FrozenSet[int]
WeightTable = Dict[Simplex, float]


def e_interleaving_dist(F: WeightTable, G: WeightTable,
                        search_max: float = 100.0, step: float = 1e-3) -> float:
    """Estimate the EXTENDED interleaving distance in [0, +inf]
    (Definition 3.1).  Scans candidate shifts at the birth scales and returns
    the least delta that interleaves F and G, or math.inf if none up to
    `search_max` does -- the correct value sInf(empty)=+inf (NOT 0), which is the
    repair that restores the triangle inequality.  Complexity:
    O((search_max/step) * #scales * #simplices)."""
    simplices = set(F) | set(G)
    births = [F.get(s, 0.0) for s in simplices] + [G.get(s, 0.0) for s in simplices]
    grid = sorted({b for b in births if math.isfinite(b)}) or [0.0]

    def interleaved(delta: float) -> bool:
        for t in grid:
            for s in simplices:
                wf = F.get(s, math.inf)
                wg = G.get(s, math.inf)
                if wf <= t and not (wg <= t + delta):
                    return False
                if wg <= t and not (wf <= t + delta):
                    return False
        return True

    delta = 0.0
    while delta <= search_max:
        if interleaved(delta):
            return delta
        delta += step
    return math.inf
