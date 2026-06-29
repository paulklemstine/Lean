from typing import Dict, FrozenSet
Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]

def interleaving_distance(F: Filtration, G: Filtration) -> float:
    """Interleaving distance via the isometry formula (Boltzmann Bridge VIII):

        d(F, G) = sup_sigma | F[sigma] - G[sigma] |.

    A single O(N) scan over the union of supports replaces the naive
    optimisation over interleaving shifts.
    """
    keys = set(F) | set(G)
    return max((abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys), default=0.0)
