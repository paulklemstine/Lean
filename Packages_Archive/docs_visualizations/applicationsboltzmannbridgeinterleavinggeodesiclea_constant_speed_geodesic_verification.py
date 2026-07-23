from typing import Dict, FrozenSet, List, Tuple
Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]

def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    keys = set(F) | set(G)
    return {s: (1.0 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}

def interleaving_distance(F: Filtration, G: Filtration) -> float:
    keys = set(F) | set(G)
    return max((abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys), default=0.0)

def verify_geodesic(
    F: Filtration, G: Filtration, samples: List[Tuple[float, float]],
    tol: float = 1e-12,
) -> bool:
    """Numerically verify the constant-speed geodesic identity

        d(lerp_s, lerp_t) = |s - t| * d(F, G)

    over a list of (s, t) parameter pairs in [0, 1].
    """
    d_FG = interleaving_distance(F, G)
    for s, t in samples:
        lhs = interleaving_distance(lerp(F, G, s), lerp(F, G, t))
        rhs = abs(s - t) * d_FG
        if abs(lhs - rhs) > tol:
            return False
    return True
