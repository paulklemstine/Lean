"""
demo.py — Convexity & Bicombing of Interleaving Geodesics (Boltzmann Bridge XI)
================================================================================

Self-contained numerical demonstration of the main results:

  * Filtrations as weight functions  w : Finset(alpha) -> R  with
        w(empty) <= 0   and   sigma subseteq tau  =>  w(sigma) <= w(tau).
  * Interleaving distance via the ISOMETRY FORMULA
        d(F, G) = sup_sigma | w_F(sigma) - w_G(sigma) |.
  * Geodesic interpolation  lerp(F, G, t)  with weight
        (1 - t) * w_F(sigma) + t * w_G(sigma).
  * lerp_reverse :  lerp(F, G, t) == lerp(G, F, 1 - t).
  * lerp_self    :  lerp(F, F, t) == F.
  * Busemann convexity (the convex geodesic bicombing inequality):
        d(lerp(F,G,t), lerp(F',G',t)) <= (1-t) d(F,F') + t d(G,G').
  * Convexity of distance to a fixed filtration along a geodesic:
        d(lerp(F,G,t), H) <= (1-t) d(F,H) + t d(G,H).

Everything is inlined; no third-party dependencies. Run with:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Hashable, Iterable, List, Sequence, Tuple

# A simplex is a frozenset of vertices; a filtration is a weight dictionary.
Simplex = FrozenSet[Hashable]
Filtration = Dict[Simplex, float]


# ---------------------------------------------------------------------------
# Construction: Vietoris-Rips filtration of a finite point cloud
# ---------------------------------------------------------------------------
def euclidean(p: Sequence[float], q: Sequence[float]) -> float:
    """Euclidean distance between two points of equal dimension."""
    return sum((a - b) ** 2 for a, b in zip(p, q)) ** 0.5


def all_simplices(n: int, max_dim: int) -> List[Simplex]:
    """All nonempty subsets of {0,...,n-1} of size <= max_dim + 1, plus empty."""
    out: List[Simplex] = [frozenset()]
    for k in range(1, max_dim + 2):
        for combo in combinations(range(n), k):
            out.append(frozenset(combo))
    return out


def vr_filtration(points: Sequence[Sequence[float]], max_dim: int = 2) -> Filtration:
    """Vietoris-Rips filtration: weight(sigma) = diameter(sigma).

    Singletons and the empty simplex have weight 0. The result satisfies the
    filtration axioms: w(empty) = 0 <= 0, and a superset's diameter dominates a
    subset's (monotonicity).
    """
    n = len(points)
    w: Filtration = {}
    for sigma in all_simplices(n, max_dim):
        verts = sorted(sigma)
        if len(verts) <= 1:
            w[sigma] = 0.0
        else:
            w[sigma] = max(
                euclidean(points[i], points[j])
                for i, j in combinations(verts, 2)
            )
    return w


def is_filtration(w: Filtration) -> bool:
    """Check the two filtration axioms on the (finite) support of w."""
    if w.get(frozenset(), 0.0) > 1e-12:
        return False
    keys = list(w.keys())
    for s in keys:
        for t in keys:
            if s <= t and w[s] > w[t] + 1e-12:  # s subseteq t but heavier
                return False
    return True


# ---------------------------------------------------------------------------
# Metric: interleaving distance via the isometry formula
# ---------------------------------------------------------------------------
def common_support(F: Filtration, G: Filtration) -> List[Simplex]:
    """Union of the simplex sets of two filtrations (missing weights = 0)."""
    return sorted(set(F) | set(G), key=lambda s: (len(s), sorted(s)))


def interleaving_distance(F: Filtration, G: Filtration) -> float:
    """d(F, G) = max_sigma | w_F(sigma) - w_G(sigma) |  (the isometry formula)."""
    return max(
        abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in common_support(F, G)
    )


def argmax_simplex(F: Filtration, G: Filtration) -> Tuple[Simplex, float]:
    """The supremising simplex for d(F, G) and the attained gap."""
    best_s, best_v = frozenset(), -1.0
    for s in common_support(F, G):
        v = abs(F.get(s, 0.0) - G.get(s, 0.0))
        if v > best_v:
            best_s, best_v = s, v
    return best_s, best_v


# ---------------------------------------------------------------------------
# Geodesics: lerp and its algebraic identities
# ---------------------------------------------------------------------------
def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    """Geodesic interpolation: weight (1 - t) w_F + t w_G. Requires 0 <= t <= 1."""
    assert -1e-12 <= t <= 1 + 1e-12, "parameter t must lie in [0, 1]"
    return {
        s: (1.0 - t) * F.get(s, 0.0) + t * G.get(s, 0.0)
        for s in common_support(F, G)
    }


def filtrations_equal(F: Filtration, G: Filtration, tol: float = 1e-9) -> bool:
    """Equality of weight functions on the common support."""
    return all(
        abs(F.get(s, 0.0) - G.get(s, 0.0)) <= tol for s in common_support(F, G)
    )


# ---------------------------------------------------------------------------
# Certifier for the Busemann bicombing inequality (Theorem 3.5 / C4)
# ---------------------------------------------------------------------------
def bicombing_slack(
    F: Filtration, G: Filtration, Fp: Filtration, Gp: Filtration, t: float
) -> Tuple[float, float, float]:
    """Return (lhs, rhs, slack) for the convex geodesic bicombing inequality.

        lhs  = d(lerp(F,G,t), lerp(Fp,Gp,t))
        rhs  = (1 - t) d(F, Fp) + t d(G, Gp)
        slack = rhs - lhs   (>= 0 certifies Busemann convexity)
    """
    lhs = interleaving_distance(lerp(F, G, t), lerp(Fp, Gp, t))
    rhs = (1.0 - t) * interleaving_distance(F, Fp) + t * interleaving_distance(G, Gp)
    return lhs, rhs, rhs - lhs


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def banner(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def demo_filtrations() -> Tuple[Filtration, Filtration, Filtration, Filtration]:
    """Build four VR filtrations from four 3-point clouds and validate axioms."""
    banner("1. Vietoris-Rips filtrations of four 3-point clouds")
    cloud_F = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0)]
    cloud_G = [(0.0, 0.0), (2.0, 0.0), (0.0, 2.0)]
    cloud_Fp = [(0.0, 0.0), (1.0, 0.0), (0.5, 1.0)]
    cloud_Gp = [(0.0, 0.0), (3.0, 0.0), (0.0, 1.0)]
    F, G = vr_filtration(cloud_F), vr_filtration(cloud_G)
    Fp, Gp = vr_filtration(cloud_Fp), vr_filtration(cloud_Gp)
    for name, w in [("F", F), ("G", G), ("F'", Fp), ("G'", Gp)]:
        print(f"  filtration {name:2s}: valid axioms = {is_filtration(w)}")
        for s in sorted(w, key=lambda x: (len(x), sorted(x))):
            if s:
                print(f"      w({set(s)!s:>12}) = {w[s]:.4f}")
    return F, G, Fp, Gp


def demo_isometry_and_geodesic(F: Filtration, G: Filtration) -> None:
    banner("2. Isometry formula and constant-speed geodesic")
    d = interleaving_distance(F, G)
    s, v = argmax_simplex(F, G)
    print(f"  d(F, G) = {d:.4f}   attained at simplex {set(s)} (gap {v:.4f})")
    print("  constant-speed check  d(lerp(F,G,s), lerp(F,G,t)) = |s-t| d(F,G):")
    for s_, t_ in [(0.0, 1.0), (0.0, 0.5), (0.25, 0.75)]:
        got = interleaving_distance(lerp(F, G, s_), lerp(F, G, t_))
        exp = abs(s_ - t_) * d
        print(f"    s={s_:.2f} t={t_:.2f}: got {got:.4f}, expected {exp:.4f}"
              f"  ({'OK' if abs(got - exp) < 1e-9 else 'FAIL'})")


def demo_symmetries(F: Filtration, G: Filtration) -> None:
    banner("3. Affine symmetries: lerp_reverse and lerp_self")
    for t in [0.0, 0.3, 0.5, 1.0]:
        rev = filtrations_equal(lerp(F, G, t), lerp(G, F, 1.0 - t))
        print(f"  lerp(F,G,{t:.2f}) == lerp(G,F,{1 - t:.2f}) : {rev}")
    for t in [0.0, 0.5, 1.0]:
        stay = filtrations_equal(lerp(F, F, t), F)
        print(f"  lerp(F,F,{t:.2f}) == F : {stay}")


def demo_bicombing(
    F: Filtration, G: Filtration, Fp: Filtration, Gp: Filtration
) -> None:
    banner("4. Busemann convexity: the convex geodesic bicombing inequality")
    print("  t      lhs=d(.,.)   rhs=(1-t)d+td   slack(>=0)   verdict")
    grid = [i / 10 for i in range(11)]
    ok = True
    for t in grid:
        lhs, rhs, slack = bicombing_slack(F, G, Fp, Gp, t)
        ok = ok and slack >= -1e-9
        verdict = "OK" if slack >= -1e-9 else "VIOLATION"
        print(f"  {t:.2f}   {lhs:9.4f}    {rhs:9.4f}      {slack:9.4f}   {verdict}")
    print(f"\n  Busemann convexity certified across the grid: {ok}")


def demo_convex_to_fixed(F: Filtration, G: Filtration, H: Filtration) -> None:
    banner("5. Convexity of distance to a fixed filtration H along the geodesic")
    print("  t      d(lerp(F,G,t),H)   (1-t)d(F,H)+t d(G,H)   slack(>=0)")
    dFH, dGH = interleaving_distance(F, H), interleaving_distance(G, H)
    for t in [i / 10 for i in range(11)]:
        lhs = interleaving_distance(lerp(F, G, t), H)
        rhs = (1.0 - t) * dFH + t * dGH
        print(f"  {t:.2f}      {lhs:9.4f}            {rhs:9.4f}        {rhs - lhs:9.4f}")


def demo_defect(F: Filtration, G: Filtration, Fp: Filtration, Gp: Filtration) -> None:
    banner("6. Convexity defect = mismatch of supremising simplices (Section 4.1)")
    s_FFp, _ = argmax_simplex(F, Fp)
    s_GGp, _ = argmax_simplex(G, Gp)
    _, _, slack_mid = bicombing_slack(F, G, Fp, Gp, 0.5)
    print(f"  argmax for d(F,F')  : {set(s_FFp)}")
    print(f"  argmax for d(G,G')  : {set(s_GGp)}")
    print(f"  argmaxes coincide   : {s_FFp == s_GGp}")
    print(f"  slack at t=0.5      : {slack_mid:.4f}")
    print("  (mismatch of argmaxes corresponds to strictly positive slack: an")
    print("   l-infinity geometry is flat-convex, never strictly convex.)")


def main() -> None:
    F, G, Fp, Gp = demo_filtrations()
    demo_isometry_and_geodesic(F, G)
    demo_symmetries(F, G)
    demo_bicombing(F, G, Fp, Gp)
    demo_convex_to_fixed(F, G, Fp)  # use F' as the fixed landmark H
    demo_defect(F, G, Fp, Gp)
    banner("All demonstrations complete.")


if __name__ == "__main__":
    main()
