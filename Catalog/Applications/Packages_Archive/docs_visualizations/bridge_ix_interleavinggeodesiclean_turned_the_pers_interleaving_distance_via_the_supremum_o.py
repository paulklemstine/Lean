from typing import Dict, FrozenSet

Weight = Dict[FrozenSet[int], float]


def interleaving_distance(F: Weight, G: Weight) -> float:
    """d(F, G) = sup over simplices of |F.weight(s) - G.weight(s)|."""
    keys = set(F) | set(G)
    return max((abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys), default=0.0)
