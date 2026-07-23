from __future__ import annotations
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


def interleaving_distance(F: Filtration, G: Filtration) -> float:
    """eInterleavingDist via the isometry theorem: the supremum (max) distance of
    the two weight functions over all simplices. O(|simplices|)."""
    keys = set(F) | set(G)
    return max(abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys)


def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    """Constant-speed geodesic point at parameter t in [0,1]:
    weight(sigma) = (1-t) F(sigma) + t G(sigma). O(|simplices|)."""
    assert -1e-12 <= t <= 1 + 1e-12
    keys = set(F) | set(G)
    return {s: (1 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def betweenness_residual(F: Filtration, G: Filtration,
                         s: float, u: float, t: float) -> float:
    """Geodesic-segment law residual d(s,u)+d(u,t)-d(s,t) for s<=u<=t.
    Returns ~0 (machine epsilon) confirming additivity."""
    a = interleaving_distance(lerp(F, G, s), lerp(F, G, u))
    b = interleaving_distance(lerp(F, G, u), lerp(F, G, t))
    c = interleaving_distance(lerp(F, G, s), lerp(F, G, t))
    return a + b - c


def convexity_defect(H: Filtration, F: Filtration, G: Filtration,
                     t: float) -> float:
    """Busemann convexity defect (>= 0):
    (1-t) d(H,F) + t d(H,G) - d(H, lerp(F,G,t))."""
    lhs = interleaving_distance(H, lerp(F, G, t))
    rhs = (1 - t) * interleaving_distance(H, F) + t * interleaving_distance(H, G)
    return rhs - lhs
