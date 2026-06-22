from typing import Dict, FrozenSet, List

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    return {s: (1.0 - t) * F[s] + t * G[s] for s in F}


def geodesic_samples(F: Filtration, G: Filtration, n: int) -> List[Filtration]:
    """n+1 equally spaced points on the F--G geodesic (constant speed)."""
    return [lerp(F, G, k / n) for k in range(n + 1)]
