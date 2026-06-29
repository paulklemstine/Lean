from typing import Dict, FrozenSet
Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]

def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    """Convex-interpolation filtration lerp(F, G, t).

    weight_sigma = (1 - t) * F[sigma] + t * G[sigma], for t in [0, 1].
    The result is again a valid filtration: grounding and monotonicity are
    preserved by non-negatively weighted convex combination.
    """
    assert -1e-12 <= t <= 1 + 1e-12, "t must lie in [0, 1]"
    keys = set(F) | set(G)
    return {s: (1.0 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}
