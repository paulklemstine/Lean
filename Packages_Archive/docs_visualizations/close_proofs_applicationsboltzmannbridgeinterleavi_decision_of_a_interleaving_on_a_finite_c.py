from typing import Dict, FrozenSet, List

Simplex = FrozenSet[int]


def is_interleaved(
    f_weight: Dict[Simplex, float],
    g_weight: Dict[Simplex, float],
    delta: float,
) -> bool:
    """Decide whether two finite filtrations are delta-interleaved.

    On a finite common carrier, F and G are delta-interleaved iff delta >= 0 and
    their weights differ by at most delta on every simplex (Algorithm A).
    """
    if delta < 0.0:
        return False
    carrier: List[Simplex] = [s for s in f_weight if s in g_weight]
    if not carrier:
        return False
    return all(abs(f_weight[s] - g_weight[s]) <= delta + 1e-12 for s in carrier)
