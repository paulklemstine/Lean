"""
Boltzmann Bridge IX — The Interleaving Metric is Geodesic
=========================================================

Numerical demonstrations of the constant-speed geodesic identity for the
interleaving distance on filtrations.

A *filtration* assigns to every simplex (a finite set of vertices) a real
"birth scale", subject to:
    - grounding:    weight(empty) <= 0
    - monotonicity: sigma subset tau  =>  weight(sigma) <= weight(tau)

The interleaving distance between two filtrations equals (Boltzmann Bridge VIII)
the supremum over simplices of the absolute weight gap -- an l-infinity / sup
distance:
    d(F, G) = sup_sigma | F[sigma] - G[sigma] |.

The convex-interpolation path is
    lerp(F, G, t)[sigma] = (1 - t) * F[sigma] + t * G[sigma],   t in [0, 1].

This script demonstrates, on concrete examples:
    1. lerp endpoints recover F and G;
    2. lerp is a valid filtration for every t in [0, 1];
    3. pointwise gaps scale linearly:  |lerp_s - lerp_t| = |s - t| * |F - G|;
    4. the constant-speed geodesic identity:
           d(lerp_s, lerp_t) = |s - t| * d(F, G);
    5. the additive midpoint bisection:
           d(F, m) + d(m, G) = d(F, G),  with each half = d(F, G) / 2;
    6. a Vietoris-Rips experiment comparing combinatorial vs geometric
       interpolation.

Pure standard library; run with `python demo.py`.
"""

from __future__ import annotations

from itertools import combinations
from math import isclose, sqrt
from typing import Dict, FrozenSet, Iterable, List, Sequence, Tuple

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


# --------------------------------------------------------------------------- #
# Core operations                                                             #
# --------------------------------------------------------------------------- #
def is_valid_filtration(F: Filtration) -> bool:
    """Check grounding and monotonicity on the recorded simplices."""
    empty: Simplex = frozenset()
    if empty in F and F[empty] > 1e-12:
        return False
    simplices: List[Simplex] = list(F.keys())
    for sigma in simplices:
        for tau in simplices:
            if sigma < tau and F[sigma] > F[tau] + 1e-12:
                return False
    return True


def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    """Convex-interpolation filtration: (1-t)*F + t*G, simplex by simplex."""
    assert -1e-12 <= t <= 1 + 1e-12, "t must lie in [0, 1]"
    keys = set(F) | set(G)
    return {s: (1.0 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def interleaving_distance(F: Filtration, G: Filtration) -> float:
    """d(F, G) = sup_sigma |F[sigma] - G[sigma]|  (the isometry formula)."""
    keys = set(F) | set(G)
    return max((abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys), default=0.0)


def pointwise_gap(F: Filtration, G: Filtration) -> Dict[Simplex, float]:
    """Per-simplex absolute weight gap |F[sigma] - G[sigma]|."""
    keys = set(F) | set(G)
    return {s: abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys}


# --------------------------------------------------------------------------- #
# Vietoris-Rips construction                                                  #
# --------------------------------------------------------------------------- #
def diam_filtration(
    points: Sequence[Tuple[float, ...]], max_dim: int = 2
) -> Filtration:
    """Vietoris-Rips: weight(sigma) = largest pairwise distance in sigma."""
    n = len(points)

    def dist(i: int, j: int) -> float:
        return sqrt(sum((a - b) ** 2 for a, b in zip(points[i], points[j])))

    F: Filtration = {frozenset(): 0.0}
    for v in range(n):
        F[frozenset({v})] = 0.0
    for k in range(2, max_dim + 2):
        for combo in combinations(range(n), k):
            d = max(dist(i, j) for i, j in combinations(combo, 2))
            F[frozenset(combo)] = d
    return F


def diam_filtration_from_matrix(
    D: Sequence[Sequence[float]], max_dim: int = 2
) -> Filtration:
    """Vietoris-Rips from an explicit (symmetric) distance matrix."""
    n = len(D)
    F: Filtration = {frozenset(): 0.0}
    for v in range(n):
        F[frozenset({v})] = 0.0
    for k in range(2, max_dim + 2):
        for combo in combinations(range(n), k):
            F[frozenset(combo)] = max(D[i][j] for i, j in combinations(combo, 2))
    return F


def interpolate_matrix(
    D1: Sequence[Sequence[float]], D2: Sequence[Sequence[float]], t: float
) -> List[List[float]]:
    """Linear interpolation of two distance matrices: (1-t)*D1 + t*D2."""
    n = len(D1)
    return [[(1 - t) * D1[i][j] + t * D2[i][j] for j in range(n)] for i in range(n)]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def _example_pair() -> Tuple[Filtration, Filtration]:
    """A concrete pair of valid filtrations on vertices {0, 1, 2}."""
    F: Filtration = {
        frozenset(): 0.0,
        frozenset({0}): 0.0,
        frozenset({1}): 0.0,
        frozenset({2}): 0.0,
        frozenset({0, 1}): 1.0,
        frozenset({0, 2}): 2.0,
        frozenset({1, 2}): 3.0,
        frozenset({0, 1, 2}): 4.0,
    }
    G: Filtration = {
        frozenset(): 0.0,
        frozenset({0}): 0.0,
        frozenset({1}): 0.0,
        frozenset({2}): 0.0,
        frozenset({0, 1}): 2.5,
        frozenset({0, 2}): 2.0,
        frozenset({1, 2}): 5.0,
        frozenset({0, 1, 2}): 6.0,
    }
    return F, G


def demo_endpoints() -> None:
    print("=" * 70)
    print("DEMO 1: lerp endpoints recover F and G")
    print("=" * 70)
    F, G = _example_pair()
    L0, L1 = lerp(F, G, 0.0), lerp(F, G, 1.0)
    print("  lerp(F,G,0) == F :", all(isclose(L0[s], F[s]) for s in F))
    print("  lerp(F,G,1) == G :", all(isclose(L1[s], G[s]) for s in G))


def demo_validity() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2: lerp is a valid filtration for every t in [0, 1]")
    print("=" * 70)
    F, G = _example_pair()
    for t in (0.0, 0.25, 0.5, 0.75, 1.0):
        ok = is_valid_filtration(lerp(F, G, t))
        print(f"  t = {t:4.2f}:  valid filtration = {ok}")


def demo_pointwise_linearity() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3: pointwise gaps scale linearly")
    print("        |lerp_s - lerp_t|[sigma] = |s - t| * |F - G|[sigma]")
    print("=" * 70)
    F, G = _example_pair()
    base = pointwise_gap(F, G)
    s, t = 0.2, 0.7
    Ls, Lt = lerp(F, G, s), lerp(F, G, t)
    gap = pointwise_gap(Ls, Lt)
    print(f"  s = {s}, t = {t}, |s - t| = {abs(s - t)}")
    ok = True
    for sigma in sorted(base, key=lambda x: tuple(sorted(x))):
        lhs = gap[sigma]
        rhs = abs(s - t) * base[sigma]
        ok &= isclose(lhs, rhs, abs_tol=1e-12)
        label = "{" + ",".join(map(str, sorted(sigma))) + "}"
        print(f"    sigma = {label:9s}  lhs = {lhs:7.4f}   rhs = {rhs:7.4f}")
    print("  all simplices match:", ok)


def demo_geodesic_identity() -> None:
    print("\n" + "=" * 70)
    print("DEMO 4: constant-speed geodesic identity")
    print("        d(lerp_s, lerp_t) = |s - t| * d(F, G)")
    print("=" * 70)
    F, G = _example_pair()
    d_FG = interleaving_distance(F, G)
    print(f"  d(F, G) = {d_FG}")
    print(f"  {'s':>5} {'t':>5} {'d(lerp_s,lerp_t)':>18} {'|s-t|*d(F,G)':>15} {'match':>7}")
    ok = True
    for s, t in [(0.0, 1.0), (0.1, 0.4), (0.5, 0.9), (0.3, 0.3), (0.0, 0.5)]:
        lhs = interleaving_distance(lerp(F, G, s), lerp(F, G, t))
        rhs = abs(s - t) * d_FG
        match = isclose(lhs, rhs, abs_tol=1e-12)
        ok &= match
        print(f"  {s:5.2f} {t:5.2f} {lhs:18.6f} {rhs:15.6f} {str(match):>7}")
    print("  identity holds for all sampled (s, t):", ok)


def demo_midpoint() -> None:
    print("\n" + "=" * 70)
    print("DEMO 5: additive midpoint bisection")
    print("        d(F, m) + d(m, G) = d(F, G),  each half = d(F, G)/2")
    print("=" * 70)
    F, G = _example_pair()
    m = lerp(F, G, 0.5)
    d_FG = interleaving_distance(F, G)
    d_Fm = interleaving_distance(F, m)
    d_mG = interleaving_distance(m, G)
    print(f"  d(F, G)            = {d_FG}")
    print(f"  d(F, m)            = {d_Fm}")
    print(f"  d(m, G)            = {d_mG}")
    print(f"  d(F, m) + d(m, G)  = {d_Fm + d_mG}")
    print("  bisection additive :", isclose(d_Fm + d_mG, d_FG, abs_tol=1e-12))
    print("  each half = d/2     :", isclose(d_Fm, d_FG / 2) and isclose(d_mG, d_FG / 2))


def demo_vietoris_rips() -> None:
    print("\n" + "=" * 70)
    print("DEMO 6: Vietoris-Rips -- combinatorial vs geometric interpolation")
    print("        compare lerp(VR(D1), VR(D2), t)  vs  VR((1-t)D1 + t D2)")
    print("=" * 70)
    # Two distance matrices on 3 points whose *maximizing* edge differs:
    #   D1: edge (0,1) is the largest;  D2: edge (1,2) is the largest.
    # Then the triangle's diameter is dominated by different edges, so the
    # supremum (= diameter) does not commute with averaging.
    D1 = [
        [0.0, 3.0, 1.0],
        [3.0, 0.0, 1.0],
        [1.0, 1.0, 0.0],
    ]
    D2 = [
        [0.0, 1.0, 1.0],
        [1.0, 0.0, 3.0],
        [1.0, 3.0, 0.0],
    ]
    t = 0.5
    combinatorial = lerp(diam_filtration_from_matrix(D1), diam_filtration_from_matrix(D2), t)
    geometric = diam_filtration_from_matrix(interpolate_matrix(D1, D2, t))
    gaps = pointwise_gap(combinatorial, geometric)
    max_gap = max(gaps.values())
    print(f"  t = {t}")
    print(f"  max simplex-wise discrepancy = {max_gap:.6f}")
    print("  (zero on edges; generally nonzero on higher simplices, since the")
    print("   diameter is a supremum and sup does not commute with averaging)")
    for sigma in sorted(gaps, key=lambda x: (len(x), tuple(sorted(x)))):
        if len(sigma) >= 2:
            label = "{" + ",".join(map(str, sorted(sigma))) + "}"
            print(f"    {label:11s}  combinatorial = {combinatorial[sigma]:7.4f}"
                  f"   geometric = {geometric[sigma]:7.4f}   gap = {gaps[sigma]:7.4f}")


def main() -> None:
    demo_endpoints()
    demo_validity()
    demo_pointwise_linearity()
    demo_geodesic_identity()
    demo_midpoint()
    demo_vietoris_rips()
    print("\n" + "=" * 70)
    print("All demonstrations completed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
