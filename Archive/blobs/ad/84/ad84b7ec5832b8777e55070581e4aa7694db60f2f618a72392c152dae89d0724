"""
Local-to-Global Gluing of Interleaving Geodesics — numerical demonstration.

This self-contained script models the mathematics of Boltzmann Bridge X:

  * A *filtration* is a grounded, monotone weight function on the simplices of a
    finite index set: weight(empty) <= 0 and  sigma subset tau  =>  w(sigma) <= w(tau).

  * The *interleaving distance* between two filtrations equals (by the Bridge VIII
    isometry) the supremum over simplices of the pointwise weight gap:

        d(F, G) = max_sigma | F.weight(sigma) - G.weight(sigma) |.

  * The convex-interpolation geodesic ("lerp") is

        lerp(F, G, t).weight(sigma) = (1 - t) * F.weight(sigma) + t * G.weight(sigma),

    and the distance varies exactly linearly along it (Bridge IX):

        d(lerp(F,G,s), lerp(F,G,t)) = |s - t| * d(F, G).

This script verifies, numerically, the five Bridge X theorems:

  1. lerp_lerp                          — the affine gluing law.
  2. eInterleavingDist_lerp_right       — distance to the far endpoint.
  3. eInterleavingDist_lerp_betweenness — exact additive betweenness (s <= u <= t).
  4. eInterleavingDist_lerp_bisect      — universal additive split at every interior t.
  5. eInterleavingDist_lerp_lerp        — multiplicativity of speed under nesting.
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import Dict, FrozenSet, Iterable, List, Tuple

# A simplex is a frozenset of vertices; a filtration weight is a dict simplex -> float.
Simplex = FrozenSet[int]
Weight = Dict[Simplex, float]

TOL = 1e-9


# --------------------------------------------------------------------------- #
#  Filtration construction and validation                                     #
# --------------------------------------------------------------------------- #
def power_set(vertices: Iterable[int]) -> List[Simplex]:
    """All simplices (subsets) of a finite vertex set, including the empty set."""
    verts = list(vertices)
    return [frozenset(s) for s in chain.from_iterable(
        combinations(verts, k) for k in range(len(verts) + 1))]


def is_valid_filtration(weight: Weight) -> bool:
    """Check grounding (w(empty) <= 0) and monotonicity (sigma subset tau => le)."""
    if weight.get(frozenset(), 0.0) > TOL:
        return False
    simplices = list(weight.keys())
    for sigma in simplices:
        for tau in simplices:
            if sigma <= tau and weight[sigma] > weight[tau] + TOL:
                return False
    return True


def diam_filtration(vertices: List[int],
                    metric: Dict[Tuple[int, int], float]) -> Weight:
    """A Vietoris-Rips diameter filtration: weight(sigma) = max pairwise distance
    among the vertices of sigma (0 for vertices and the empty set)."""
    weight: Weight = {}
    for sigma in power_set(vertices):
        if len(sigma) <= 1:
            weight[sigma] = 0.0 if len(sigma) == 1 else -0.0
        else:
            members = sorted(sigma)
            weight[sigma] = max(
                metric[(a, b)] for i, a in enumerate(members) for b in members[i + 1:])
    weight[frozenset()] = 0.0
    return weight


# --------------------------------------------------------------------------- #
#  The interleaving distance (Bridge VIII isometry) and the geodesic          #
# --------------------------------------------------------------------------- #
def interleaving_distance(F: Weight, G: Weight) -> float:
    """d(F, G) = sup over simplices of |F.weight(sigma) - G.weight(sigma)|."""
    keys = set(F) | set(G)
    return max((abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys), default=0.0)


def lerp(F: Weight, G: Weight, t: float) -> Weight:
    """Convex-interpolation geodesic: (1 - t) * F + t * G, valid for t in [0, 1]."""
    assert -TOL <= t <= 1.0 + TOL, "lerp parameter must lie in [0, 1]"
    keys = set(F) | set(G)
    return {s: (1.0 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def weights_close(F: Weight, G: Weight) -> bool:
    keys = set(F) | set(G)
    return all(abs(F.get(s, 0.0) - G.get(s, 0.0)) <= TOL for s in keys)


# --------------------------------------------------------------------------- #
#  Verification of the five Bridge X theorems                                  #
# --------------------------------------------------------------------------- #
def check_gluing_law(F: Weight, G: Weight, r: float, s: float, t: float) -> bool:
    """Theorem lerp_lerp:  lerp(lerp(s), lerp(t), r) == lerp(F, G, (1-r)*s + r*t)."""
    lhs = lerp(lerp(F, G, s), lerp(F, G, t), r)
    rhs = lerp(F, G, (1.0 - r) * s + r * t)
    return weights_close(lhs, rhs)


def check_far_endpoint(F: Weight, G: Weight, t: float) -> bool:
    """Theorem eInterleavingDist_lerp_right:  d(lerp t, G) = (1 - t) * d(F, G)."""
    return abs(interleaving_distance(lerp(F, G, t), G)
               - (1.0 - t) * interleaving_distance(F, G)) <= TOL


def check_betweenness(F: Weight, G: Weight, s: float, u: float, t: float) -> bool:
    """Theorem eInterleavingDist_lerp_betweenness (s <= u <= t):
    d(s, u) + d(u, t) = d(s, t)."""
    assert s <= u <= t
    Fs, Fu, Ft = lerp(F, G, s), lerp(F, G, u), lerp(F, G, t)
    return abs((interleaving_distance(Fs, Fu) + interleaving_distance(Fu, Ft))
               - interleaving_distance(Fs, Ft)) <= TOL


def check_bisect(F: Weight, G: Weight, t: float) -> bool:
    """Theorem eInterleavingDist_lerp_bisect (all t):
    d(F, lerp t) + d(lerp t, G) = d(F, G)."""
    Ft = lerp(F, G, t)
    return abs((interleaving_distance(F, Ft) + interleaving_distance(Ft, G))
               - interleaving_distance(F, G)) <= TOL


def check_nested_speed(F: Weight, G: Weight,
                       a: float, b: float, s: float, t: float) -> bool:
    """Theorem eInterleavingDist_lerp_lerp:
    d(lerp(lerp s, lerp t, a), lerp(lerp s, lerp t, b))
        = |a - b| * (|s - t| * d(F, G))."""
    Ls, Lt = lerp(F, G, s), lerp(F, G, t)
    lhs = interleaving_distance(lerp(Ls, Lt, a), lerp(Ls, Lt, b))
    rhs = abs(a - b) * (abs(s - t) * interleaving_distance(F, G))
    return abs(lhs - rhs) <= TOL


# --------------------------------------------------------------------------- #
#  Driver                                                                      #
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 72)
    print("Boltzmann Bridge X — Gluing of Interleaving Geodesics (numerical demo)")
    print("=" * 72)

    # Two diameter filtrations of a 4-point cloud under two different metrics.
    verts = [0, 1, 2, 3]
    metric_F = {(0, 1): 1.0, (0, 2): 2.0, (0, 3): 3.0,
                (1, 2): 1.5, (1, 3): 2.5, (2, 3): 1.0}
    metric_G = {(0, 1): 2.0, (0, 2): 1.0, (0, 3): 4.0,
                (1, 2): 3.0, (1, 3): 1.0, (2, 3): 2.0}
    F = diam_filtration(verts, metric_F)
    G = diam_filtration(verts, metric_G)

    print(f"\nF valid filtration : {is_valid_filtration(F)}")
    print(f"G valid filtration : {is_valid_filtration(G)}")
    d_FG = interleaving_distance(F, G)
    print(f"d(F, G)            : {d_FG:.6f}")

    # Show linearity of the geodesic (Bridge IX) for context.
    print("\nGeodesic distances d(F, lerp t)  vs  expected t * d(F,G):")
    for t in (0.0, 0.25, 0.5, 0.75, 1.0):
        got = interleaving_distance(F, lerp(F, G, t))
        print(f"  t = {t:4.2f}:  got {got:.6f}   expected {t * d_FG:.6f}")

    # The five Bridge X theorems on a battery of parameter samples.
    samples = [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0]
    results = {
        "1. gluing law (lerp_lerp)": all(
            check_gluing_law(F, G, r, s, t)
            for r in samples for s in samples for t in samples),
        "2. far endpoint":           all(
            check_far_endpoint(F, G, t) for t in samples),
        "3. betweenness (s<=u<=t)":  all(
            check_betweenness(F, G, s, u, t)
            for s in samples for u in samples for t in samples
            if s <= u <= t),
        "4. universal bisection":    all(
            check_bisect(F, G, t) for t in samples),
        "5. nested speed multiply":  all(
            check_nested_speed(F, G, a, b, s, t)
            for a in samples for b in samples for s in samples for t in samples),
    }

    print("\nVerification of the five Bridge X theorems:")
    for name, ok in results.items():
        print(f"  [{'PASS' if ok else 'FAIL'}] {name}")

    print("\nAll theorems verified:", all(results.values()))


if __name__ == "__main__":
    main()
