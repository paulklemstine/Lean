from typing import Dict, FrozenSet

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


def interleaving_distance(F: Filtration, G: Filtration) -> float:
    """Exact interleaving distance = max_sigma |F(sigma) - G(sigma)|."""
    return max(abs(F[sigma] - G[sigma]) for sigma in F)
