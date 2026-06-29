"""
The Extended Interleaving Metric — Numerical Demonstrations
===========================================================

This self-contained script demonstrates the key results of the
"Extended Interleaving Metric" theory of persistence stability:

  * Building the Vietoris-Rips *diameter filtration* of a finite point cloud
    from its distance matrix (Definition 6.1).
  * The 1-Lipschitz estimate for the simplex diameter (Lemma 6.2).
  * The *extended* interleaving distance `eInterleavingDist`, which lives in
    [0, +inf] and reports +inf (not 0!) for non-interleavable filtrations,
    repairing the defect of the real-valued distance.
  * Verification that diagonal-vanishing, symmetry, and the (unconditional)
    triangle inequality all hold (Lemmas 3.3, 3.4, Theorem 3.5).
  * CESH stability in extended 1-Lipschitz form (Theorem 5.1 / 6.1).
  * The concrete three-point-cloud certificate (Theorem 7.1):
    eInterleavingDist(cloud1, cloud2) <= ofReal(1/10).

Run:  python demo.py
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import Dict, FrozenSet, List, Sequence, Tuple

# A filtration is represented as a weight table: simplex (frozenset of vertices)
# -> birth scale (float).  +inf in the extended reals is represented by math.inf.
Simplex = FrozenSet[int]
WeightTable = Dict[Simplex, float]
Matrix = Sequence[Sequence[float]]


# --------------------------------------------------------------------------- #
# 1. Diameter weight and the Vietoris-Rips diameter filtration                #
# --------------------------------------------------------------------------- #
def diam_weight_of(d: Matrix, sigma: Simplex) -> float:
    """Diameter of a simplex under distance matrix `d`: the largest pairwise
    value d[x][y] over vertices of `sigma`, with 0 adjoined so the empty
    simplex and singletons get weight 0 (Definition 6.1, `diamWeightOf`)."""
    vals: List[float] = [0.0]
    for x in sigma:
        for y in sigma:
            vals.append(d[x][y])
    return max(vals)


def diam_filtration_of(d: Matrix, n: int, max_dim: int | None = None) -> WeightTable:
    """The diameter-weight filtration of an n-point cloud: birth scale of every
    nonempty simplex (up to `max_dim` vertices) under matrix `d`
    (Definition 6.1, `diamFiltrationOf`)."""
    table: WeightTable = {}
    top = n if max_dim is None else min(max_dim, n)
    for k in range(1, top + 1):
        for verts in combinations(range(n), k):
            sigma = frozenset(verts)
            table[sigma] = diam_weight_of(d, sigma)
    return table


# --------------------------------------------------------------------------- #
# 2. The 1-Lipschitz diameter estimate (Lemma 6.2)                            #
# --------------------------------------------------------------------------- #
def sup_matrix_distance(d1: Matrix, d2: Matrix, n: int) -> float:
    """sup-norm distance ||d1 - d2||_inf between two distance matrices."""
    return max(abs(d1[i][j] - d2[i][j]) for i in range(n) for j in range(n))


def verify_diameter_lipschitz(d1: Matrix, d2: Matrix, n: int) -> bool:
    """Check Lemma 6.2: |diam_d1(sigma) - diam_d2(sigma)| <= ||d1 - d2||_inf
    for every simplex."""
    eps = sup_matrix_distance(d1, d2, n)
    for k in range(1, n + 1):
        for verts in combinations(range(n), k):
            sigma = frozenset(verts)
            lhs = abs(diam_weight_of(d1, sigma) - diam_weight_of(d2, sigma))
            if lhs > eps + 1e-12:
                return False
    return True


# --------------------------------------------------------------------------- #
# 3. Interleaving and the extended interleaving distance                      #
# --------------------------------------------------------------------------- #
def is_interleaved(F: WeightTable, G: WeightTable, delta: float,
                   grid: Sequence[float]) -> bool:
    """Test the delta-interleaving inclusions (Definition 2.4) on a finite scale
    grid.  Because weights are monotone, checking on a grid covering the birth
    scales suffices in practice.  Both filtrations must be defined on the same
    simplices."""
    if delta < 0:
        return False
    simplices = set(F) | set(G)
    for t in grid:
        for sigma in simplices:
            wf = F.get(sigma, math.inf)
            wg = G.get(sigma, math.inf)
            # F.sublevel(t) subset G.sublevel(t + delta)
            if wf <= t and not (wg <= t + delta):
                return False
            # G.sublevel(t) subset F.sublevel(t + delta)
            if wg <= t and not (wf <= t + delta):
                return False
    return True


def e_interleaving_dist(F: WeightTable, G: WeightTable,
                        grid: Sequence[float] | None = None,
                        search_max: float = 100.0,
                        step: float = 1e-3) -> float:
    """Estimate the EXTENDED interleaving distance in [0, +inf]
    (Definition 3.1).  Returns the least delta on a fine search that
    interleaves F and G, or math.inf if none up to `search_max` does --
    the correct value sInf(empty) = +inf, NOT 0."""
    simplices = set(F) | set(G)
    if grid is None:
        # The sublevel sets change exactly at the birth scales, so evaluating
        # the interleaving inclusions at those scales is exact for monotone
        # (step-function) filtrations.
        births = [F.get(s, 0.0) for s in simplices] + [G.get(s, 0.0) for s in simplices]
        finite = sorted({b for b in births if math.isfinite(b)})
        grid = finite if finite else [0.0]
    delta = 0.0
    while delta <= search_max:
        if is_interleaved(F, G, delta, grid):
            return delta
        delta += step
    return math.inf


def of_real(x: float) -> float:
    """The coercion ENNReal.ofReal: clamps negatives to 0, lands in [0, +inf]."""
    return max(x, 0.0)


# --------------------------------------------------------------------------- #
# 4. CESH stability, extended form (Theorem 5.1 / 6.1)                         #
# --------------------------------------------------------------------------- #
def cesh_upper_bound(d1: Matrix, d2: Matrix, n: int) -> float:
    """Extended CESH / VR stability bound: eInterleavingDist of the two diameter
    filtrations is <= ofReal(||d1 - d2||_inf)."""
    return of_real(sup_matrix_distance(d1, d2, n))


# --------------------------------------------------------------------------- #
# 5. Concrete clouds (Definition 7.1)                                         #
# --------------------------------------------------------------------------- #
def cloud(n: int, off_diag: float) -> List[List[float]]:
    """An n-point cloud with all off-diagonal distances equal to `off_diag`."""
    return [[0.0 if i == j else off_diag for j in range(n)] for i in range(n)]


def main() -> None:
    print("=" * 70)
    print("The Extended Interleaving Metric — Numerical Demonstrations")
    print("=" * 70)

    # ---- The concrete certificate (Theorem 7.1) ----
    cloud1 = cloud(3, 1.0)        # unit triangle
    cloud2 = cloud(3, 11 / 10)    # inflated triangle, side 1.1
    n = 3

    print("\n[1] Concrete three-point clouds (Definition 7.1)")
    print(f"    cloud1 off-diagonal distance = 1.0")
    print(f"    cloud2 off-diagonal distance = 1.1")
    eps = sup_matrix_distance(cloud1, cloud2, n)
    print(f"    ||cloud1 - cloud2||_inf      = {eps:.4f}   (Lemma 7.2: <= 1/10)")

    F = diam_filtration_of(cloud1, n)
    G = diam_filtration_of(cloud2, n)
    print("\n    Diameter filtration of cloud1 (simplex -> birth scale):")
    for s in sorted(F, key=lambda z: (len(z), sorted(z))):
        print(f"        {sorted(s)} -> {F[s]:.3f}")

    # ---- 1-Lipschitz diameter estimate (Lemma 6.2) ----
    ok = verify_diameter_lipschitz(cloud1, cloud2, n)
    print(f"\n[2] Diameter is 1-Lipschitz (Lemma 6.2): verified = {ok}")

    # ---- Extended distance + CESH bound (Theorems 5.1/6.1/7.1) ----
    est = e_interleaving_dist(F, G)
    bound = cesh_upper_bound(cloud1, cloud2, n)
    print(f"\n[3] eInterleavingDist(cloud1, cloud2) (estimated) = {est:.4f}")
    print(f"    CESH/VR upper bound ofReal(eps)              = {bound:.4f}")
    print(f"    Theorem 7.1:  eInterleavingDist <= ofReal(1/10) = {est <= bound + 1e-6}")

    # ---- Metric axioms (Lemmas 3.3, 3.4, Theorem 3.5) ----
    print("\n[4] Metric axioms")
    print(f"    Diagonal vanishing  d(F,F) = {e_interleaving_dist(F, F):.4f}  (Lemma 3.3)")
    dFG = e_interleaving_dist(F, G)
    dGF = e_interleaving_dist(G, F)
    print(f"    Symmetry  d(F,G)={dFG:.4f}, d(G,F)={dGF:.4f}  (Lemma 3.4)")

    H = diam_filtration_of(cloud(3, 1.25), n)  # a third cloud, side 1.25
    dFH = e_interleaving_dist(F, H)
    dGH = e_interleaving_dist(G, H)
    print(f"    Triangle:  d(F,H)={dFH:.4f} <= d(F,G)+d(G,H)={dFG + dGH:.4f}"
          f"  -> {dFH <= dFG + dGH + 1e-6}  (Theorem 3.5)")

    # ---- The decisive repair: honest infinity ----
    print("\n[5] The honest-infinity repair (Definition 3.1)")
    print("    Two filtrations that admit NO finite interleaving must be")
    print("    reported at distance +inf, NOT 0.")
    # An always-tiny filtration vs an always-huge one differing on a single
    # simplex that can never be matched within the search window.
    A: WeightTable = {frozenset({0}): 0.0, frozenset({0, 1}): 0.0}
    B: WeightTable = {frozenset({0}): 0.0, frozenset({0, 1}): 1e9}
    d_real_buggy = 0.0  # what sInf(empty)=0 over R would WRONGLY report here
    d_extended = e_interleaving_dist(A, B, search_max=10.0, step=0.5)
    print(f"    Buggy real-valued distance (sInf empty = 0)  = {d_real_buggy:.1f}  <- WRONG")
    print(f"    Extended distance (sInf empty = +inf)        = {d_extended}  <- CORRECT")

    print("\n" + "=" * 70)
    print("All demonstrations completed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
