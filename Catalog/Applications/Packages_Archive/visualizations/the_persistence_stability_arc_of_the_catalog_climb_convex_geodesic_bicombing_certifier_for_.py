from itertools import combinations
from typing import Dict, FrozenSet, Hashable, List, Sequence, Tuple

Simplex = FrozenSet[Hashable]
Filtration = Dict[Simplex, float]


def interleaving_distance(F: Filtration, G: Filtration) -> float:
    """d(F, G) = max over simplices of |w_F(sigma) - w_G(sigma)| (isometry formula)."""
    keys = set(F) | set(G)
    return max(abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys)


def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    """Geodesic interpolation of weights; requires 0 <= t <= 1."""
    assert 0.0 <= t <= 1.0
    keys = set(F) | set(G)
    return {s: (1.0 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def bicombing_slack(
    F: Filtration, G: Filtration, Fp: Filtration, Gp: Filtration, t: float
) -> Tuple[float, float, float]:
    """Certify the convex geodesic bicombing inequality at parameter t.

    Returns (lhs, rhs, slack) where
        lhs   = d(lerp(F,G,t), lerp(Fp,Gp,t)),
        rhs   = (1 - t) d(F, Fp) + t d(G, Gp),
        slack = rhs - lhs >= 0  (Busemann non-positive curvature).
    Complexity: O(|support|) per call.
    """
    lhs = interleaving_distance(lerp(F, G, t), lerp(Fp, Gp, t))
    rhs = (1.0 - t) * interleaving_distance(F, Fp) + t * interleaving_distance(G, Gp)
    return lhs, rhs, rhs - lhs
