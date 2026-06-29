"""
demo.py — Numerical demonstrations of the tropical Vietoris–Rips threshold theory.

This self-contained script illustrates the main results of the package
"A Tropical Threshold for Vietoris–Rips Completeness":

  * tropBirthSum  = tropical (max-plus) sum of edge births = max pairwise distance
  * Threshold Theorem      : 1-skeleton complete at eps  <=>  tropBirthSum <= eps
  * Same-Threshold Theorem : all m-cliques present at eps <=>  tropBirthSum <= eps
  * Saturation Theorem     : cliqueCount(m, eps) = C(n, m) <=> tropBirthSum <= eps
  * Diameter identification : tropBirthSum = metric diameter (>= 2 points)
  * l-infinity product law  : tropBirthSum(A x B) = max(tropBirthSum A, tropBirthSum B)
  * Connectivity contrast   : connectivity threshold = MST bottleneck (<= tropBirthSum)

Everything is inlined; no third-party dependencies. Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import comb, inf, hypot
from typing import Callable, List, Sequence, Tuple

Point = Sequence[float]
Matrix = List[List[float]]


# --------------------------------------------------------------------------- #
# Core constructions
# --------------------------------------------------------------------------- #
def distance_matrix(points: Sequence[Point],
                    metric: Callable[[Point, Point], float]) -> Matrix:
    """Full symmetric matrix of pairwise distances under `metric`."""
    n = len(points)
    return [[metric(points[i], points[j]) for j in range(n)] for i in range(n)]


def euclidean(a: Point, b: Point) -> float:
    """Standard Euclidean (l2) distance."""
    return hypot(*[ai - bi for ai, bi in zip(a, b)])


def trop_birth_sum(dmat: Matrix) -> float:
    """Tropical (max-plus) sum of edge births = max off-diagonal distance.

    Returns -inf (tropical zero) when there are fewer than two points.
    """
    n = len(dmat)
    if n <= 1:
        return -inf
    return max(dmat[i][j] for i in range(n) for j in range(n) if i != j)


def diameter(dmat: Matrix) -> float:
    """Metric diameter: supremum of pairwise distances (off-diagonal)."""
    n = len(dmat)
    if n <= 1:
        return 0.0
    return max(dmat[i][j] for i in range(n) for j in range(i + 1, n))


def is_rips_clique(dmat: Matrix, subset: Tuple[int, ...], eps: float) -> bool:
    """True iff every distinct pair in `subset` is within `eps`."""
    return all(dmat[i][j] <= eps for i, j in combinations(subset, 2))


def clique_count(dmat: Matrix, m: int, eps: float) -> int:
    """Number of m-element Rips cliques at scale eps."""
    n = len(dmat)
    return sum(1 for s in combinations(range(n), m) if is_rips_clique(dmat, s, eps))


def skeleton_complete(dmat: Matrix, eps: float) -> bool:
    """True iff the Rips 1-skeleton is complete at scale eps."""
    n = len(dmat)
    return all(dmat[i][j] <= eps for i in range(n) for j in range(i + 1, n))


# --------------------------------------------------------------------------- #
# Connectivity threshold (single-linkage / MST bottleneck) — for contrast
# --------------------------------------------------------------------------- #
def connectivity_threshold(dmat: Matrix) -> float:
    """Spanning-tree minimax = largest edge of a minimum spanning tree (Prim)."""
    n = len(dmat)
    if n <= 1:
        return 0.0
    in_tree = [False] * n
    in_tree[0] = True
    best = [dmat[0][j] for j in range(n)]
    bottleneck = 0.0
    for _ in range(n - 1):
        u = min((j for j in range(n) if not in_tree[j]), key=lambda j: best[j])
        bottleneck = max(bottleneck, best[u])
        in_tree[u] = True
        for j in range(n):
            if not in_tree[j] and dmat[u][j] < best[j]:
                best[j] = dmat[u][j]
    return bottleneck


# --------------------------------------------------------------------------- #
# Product metrics
# --------------------------------------------------------------------------- #
def product_points(pa: Sequence[Point], pb: Sequence[Point]) -> List[Tuple[float, ...]]:
    """Cartesian product of two point sets, concatenating coordinates."""
    return [tuple(a) + tuple(b) for a in pa for b in pb]


def linf_metric(a: Point, b: Point) -> float:
    """l-infinity (sup) distance."""
    return max(abs(ai - bi) for ai, bi in zip(a, b))


def l1_metric(a: Point, b: Point) -> float:
    """l1 (Manhattan) distance."""
    return sum(abs(ai - bi) for ai, bi in zip(a, b))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_threshold_and_saturation() -> None:
    print("=" * 70)
    print("DEMO 1 — Threshold, same-threshold, and saturation")
    print("=" * 70)
    points = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]  # unit square
    dmat = distance_matrix(points, euclidean)
    n = len(points)
    tbs = trop_birth_sum(dmat)
    print(f"Points: {points}")
    print(f"tropBirthSum = max pairwise dist = {tbs:.6f}  (diagonal sqrt(2))")
    print(f"diameter     = {diameter(dmat):.6f}  -> equals tropBirthSum (Thm 8.2)\n")

    for eps in [0.5, 1.0, 1.41421356, 1.5]:
        complete = skeleton_complete(dmat, eps)
        tbs_ok = tbs <= eps + 1e-12
        print(f"  eps = {eps:<10} 1-skeleton complete? {complete!s:<5} "
              f"tropBirthSum<=eps? {tbs_ok!s:<5} (agree: {complete == tbs_ok})")
        for m in range(2, n + 1):
            cc = clique_count(dmat, m, eps)
            full = comb(n, m)
            sat = (cc == full)
            print(f"      m={m}: cliqueCount={cc}/{full}  saturated? {sat!s:<5} "
                  f"(matches tropBirthSum<=eps: {sat == tbs_ok})")
        print()


def demo_monotonicity() -> None:
    print("=" * 70)
    print("DEMO 2 — Monotonicity of clique counts in eps")
    print("=" * 70)
    points = [(0.0,), (1.0,), (3.0,), (7.0,)]  # {0,1,3,7} on the line
    dmat = distance_matrix(points, euclidean)
    print(f"Points: {[p[0] for p in points]}")
    print(f"tropBirthSum = {trop_birth_sum(dmat):.1f}  "
          f"connectivity threshold = {connectivity_threshold(dmat):.1f}\n")
    prev = -1
    for eps in [0, 1, 2, 3, 4, 6, 7]:
        cc2 = clique_count(dmat, 2, eps)
        print(f"  eps={eps:<3} cliqueCount(m=2)={cc2}  "
              f"monotone-nondecreasing? {cc2 >= prev}")
        prev = cc2
    print()


def demo_diameter_identification() -> None:
    print("=" * 70)
    print("DEMO 3 — tropBirthSum = diameter (isometry invariant)")
    print("=" * 70)
    import random
    random.seed(7)
    for trial in range(3):
        pts = [(random.uniform(-5, 5), random.uniform(-5, 5)) for _ in range(6)]
        d = distance_matrix(pts, euclidean)
        # apply a rigid motion: rotate by theta and translate
        import math
        th, tx, ty = 0.9, 2.0, -1.0
        rot = [(math.cos(th) * x - math.sin(th) * y + tx,
                math.sin(th) * x + math.cos(th) * y + ty) for x, y in pts]
        d2 = distance_matrix(rot, euclidean)
        print(f"  trial {trial}: tropBirthSum={trop_birth_sum(d):.6f} "
              f"diameter={diameter(d):.6f} "
              f"isometry-image tropBirthSum={trop_birth_sum(d2):.6f}")
    print()


def demo_product_laws() -> None:
    print("=" * 70)
    print("DEMO 4 — Product laws (l-infinity equality, l1 upper bound)")
    print("=" * 70)
    pa = [(0.0,), (2.0,), (5.0,)]      # tropBirthSum = 5
    pb = [(0.0,), (1.0,), (4.0,)]      # tropBirthSum = 4
    ta = trop_birth_sum(distance_matrix(pa, euclidean))
    tb = trop_birth_sum(distance_matrix(pb, euclidean))
    prod = product_points(pa, pb)
    tinf = trop_birth_sum(distance_matrix(prod, linf_metric))
    t1 = trop_birth_sum(distance_matrix(prod, l1_metric))
    print(f"  tropBirthSum(A) = {ta:.1f},  tropBirthSum(B) = {tb:.1f}")
    print(f"  l-inf product : tropBirthSum(AxB) = {tinf:.1f}  "
          f"vs max = {max(ta, tb):.1f}  (equal: {abs(tinf - max(ta, tb)) < 1e-9})")
    print(f"  l1    product : tropBirthSum(AxB) = {t1:.1f}  "
          f"<= sum = {ta + tb:.1f}  (holds: {t1 <= ta + tb + 1e-9})")
    print()


def demo_connectivity_contrast() -> None:
    print("=" * 70)
    print("DEMO 5 — Completeness vs connectivity (two tropical reductions)")
    print("=" * 70)
    points = [(0.0,), (1.0,), (3.0,), (7.0,)]
    dmat = distance_matrix(points, euclidean)
    print(f"  Points {[p[0] for p in points]}:")
    print(f"     completeness threshold (max over all edges) = "
          f"{trop_birth_sum(dmat):.1f}")
    print(f"     connectivity threshold (min-tree of max edge) = "
          f"{connectivity_threshold(dmat):.1f}")
    print("  -> completeness = 7 (full diameter), connectivity = 4 (the 3->7 gap,")
    print("     the largest edge forced onto the minimum spanning tree).\n")


if __name__ == "__main__":
    demo_threshold_and_saturation()
    demo_monotonicity()
    demo_diameter_identification()
    demo_product_laws()
    demo_connectivity_contrast()
    print("All demonstrations completed.")
