from math import inf
from typing import Dict, FrozenSet, List

Simplex = FrozenSet[int]


def interleaving_distance(
    f_weight: Dict[Simplex, float],
    g_weight: Dict[Simplex, float],
) -> float:
    """Exact extended interleaving distance on a finite carrier (Algorithm B).

    The infimum over admissible slacks is *attained* and equals the maximum
    weight-difference -- the finite shadow of the attained-infimum theorem.
    Returns +inf when the carriers do not overlap (no interleaving exists), so
    that distance 0 occurs exactly for identical weight tables (T0 separation).
    """
    carrier: List[Simplex] = [s for s in f_weight if s in g_weight]
    if not carrier:
        return inf
    return max(abs(f_weight[s] - g_weight[s]) for s in carrier)
