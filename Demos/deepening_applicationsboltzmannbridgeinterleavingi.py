"""
Boltzmann Bridge IX — Representation and Edge-Realization of the Interleaving Isometry
=====================================================================================

Self-contained numerical demonstration of the main results:

  * The weight map identifies filtrations with the cone of GROUNDED, MONOTONE
    weight functions (Representation theorem).

  * For genuine distance matrices, the interleaving distance between two
    Vietoris-Rips filtrations equals the sup over ALL simplices of the weight
    gap, which COLLAPSES onto the sup over EDGES (pairs of points):

        eInterleavingDist(VR(d1), VR(d2)) = max_{x,y} |d1[x,y] - d2[x,y]|.

  * The two concrete 3-point clouds (unit triangle vs 10%-inflated triangle)
    are at interleaving distance EXACTLY 1/10.

The script verifies, on finite examples, that the brute-force supremum over all
2^n simplices equals the cheap O(n^2) edge supremum.

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple

Simplex = FrozenSet[int]
Matrix = Sequence[Sequence[Fraction]]


# ---------------------------------------------------------------------------
# Core constructions (mirroring the Lean definitions)
# ---------------------------------------------------------------------------

def all_simplices(n: int) -> List[Simplex]:
    """All 2^n faces (subsets) of an n-point vertex set, including the empty face."""
    verts = list(range(n))
    faces: List[Simplex] = []
    for k in range(n + 1):
        for combo in combinations(verts, k):
            faces.append(frozenset(combo))
    return faces


def diam_weight(d: Matrix, sigma: Simplex) -> Fraction:
    """Diameter weight: max over the vertex-pairs of sigma, with 0 adjoined.

    Mirrors `diamWeightOf`: the empty face and singletons receive weight 0.
    """
    best = Fraction(0)
    for x in sigma:
        for y in sigma:
            best = max(best, d[x][y])
    return best


def diam_filtration_weight(d: Matrix, n: int) -> Dict[Simplex, Fraction]:
    """The Vietoris-Rips weight function sigma |-> diam(sigma)."""
    return {sigma: diam_weight(d, sigma) for sigma in all_simplices(n)}


def is_dist_matrix(d: Matrix, n: int) -> bool:
    """Check IsDistMatrix: nonnegative, zero diagonal, symmetric."""
    for i in range(n):
        if d[i][i] != 0:
            return False
        for j in range(n):
            if d[i][j] < 0:
                return False
            if d[i][j] != d[j][i]:
                return False
    return True


def is_admissible_weight(w: Dict[Simplex, Fraction], n: int) -> bool:
    """Check that w is grounded (w(empty) <= 0) and monotone under inclusion.

    This is the cone characterized by the representation theorem: w is the weight
    function of a genuine filtration iff it lies in this cone.
    """
    if w[frozenset()] > 0:
        return False
    faces = list(w.keys())
    for sigma in faces:
        for tau in faces:
            if sigma <= tau and not (w[sigma] <= w[tau]):
                return False
    return True


# ---------------------------------------------------------------------------
# Distances
# ---------------------------------------------------------------------------

def weight_sup_dist(wF: Dict[Simplex, Fraction], wG: Dict[Simplex, Fraction]) -> Fraction:
    """Brute-force supremum over ALL simplices of |wF(sigma) - wG(sigma)|.

    By the isometry theorem this equals eInterleavingDist(F, G).
    """
    return max(abs(wF[s] - wG[s]) for s in wF)


def edge_sup_dist(d1: Matrix, d2: Matrix, n: int) -> Fraction:
    """Cheap O(n^2) supremum over ordered pairs of |d1[x,y] - d2[x,y]|."""
    return max(abs(d1[x][y] - d2[x][y]) for x, y in product(range(n), repeat=2))


def vr_interleaving_distance(d1: Matrix, d2: Matrix, n: int) -> Fraction:
    """The exact Vietoris-Rips interleaving distance, by the edge-realization theorem."""
    return edge_sup_dist(d1, d2, n)


# ---------------------------------------------------------------------------
# Example data
# ---------------------------------------------------------------------------

def cloud1(n: int) -> List[List[Fraction]]:
    """Unit-distance clique: 0 on the diagonal, 1 off-diagonal."""
    return [[Fraction(0) if i == j else Fraction(1) for j in range(n)] for i in range(n)]


def cloud2(n: int, scale: Fraction = Fraction(11, 10)) -> List[List[Fraction]]:
    """Inflated clique: 0 on the diagonal, `scale` off-diagonal."""
    return [[Fraction(0) if i == j else scale for j in range(n)] for i in range(n)]


def random_dist_matrix(n: int, seed: int) -> List[List[Fraction]]:
    """A deterministic pseudo-random symmetric, zero-diagonal, nonnegative matrix."""
    state = seed
    def nxt() -> int:
        nonlocal state
        state = (1103515245 * state + 12345) % (1 << 31)
        return state
    d = [[Fraction(0) for _ in range(n)] for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            val = Fraction(nxt() % 1000, 100)  # in [0, 10)
            d[i][j] = val
            d[j][i] = val
    return d


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_representation(n: int = 4, seed: int = 7) -> None:
    print("=" * 72)
    print("DEMO 1 — Representation: a VR weight lies in the admissible cone")
    print("=" * 72)
    d = random_dist_matrix(n, seed)
    print(f"random distance matrix on {n} points: IsDistMatrix = {is_dist_matrix(d, n)}")
    w = diam_filtration_weight(d, n)
    print(f"VR weight grounded & monotone (admissible) = {is_admissible_weight(w, n)}")
    print("  -> the persistence map lands EXACTLY in the cone of admissible weights.")
    print()


def demo_edge_realization(n: int = 6, seed_a: int = 3, seed_b: int = 11) -> None:
    print("=" * 72)
    print("DEMO 2 — Edge-realization: simplex-sup == edge-sup")
    print("=" * 72)
    d1 = random_dist_matrix(n, seed_a)
    d2 = random_dist_matrix(n, seed_b)
    wF = diam_filtration_weight(d1, n)
    wG = diam_filtration_weight(d2, n)
    simplex_sup = weight_sup_dist(wF, wG)       # over 2^n simplices
    edge_sup = edge_sup_dist(d1, d2, n)         # over n^2 pairs
    print(f"n = {n}  ->  #simplices = {2**n},  #pairs = {n*n}")
    print(f"sup over ALL simplices : {simplex_sup}  (= {float(simplex_sup):.4f})")
    print(f"sup over EDGES (pairs) : {edge_sup}  (= {float(edge_sup):.4f})")
    print(f"equal? {simplex_sup == edge_sup}")
    print("  -> the exponential simplex search collapses to the quadratic edge search.")
    print()


def demo_exact_cloud_certificate() -> None:
    print("=" * 72)
    print("DEMO 3 — Exact certificate: two 3-point clouds at distance EXACTLY 1/10")
    print("=" * 72)
    n = 3
    d1 = cloud1(n)
    d2 = cloud2(n)
    dist = vr_interleaving_distance(d1, d2, n)
    print(f"cloud1 = unit triangle (off-diagonal 1)")
    print(f"cloud2 = inflated triangle (off-diagonal 11/10)")
    print(f"interleaving distance = {dist}  (expected 1/10)")
    assert dist == Fraction(1, 10), "certificate failed!"
    # cross-check against the brute-force simplex supremum
    wF = diam_filtration_weight(d1, n)
    wG = diam_filtration_weight(d2, n)
    assert weight_sup_dist(wF, wG) == Fraction(1, 10)
    print("  -> upgraded from the old bound '<= 1/10' to the exact equality '= 1/10'.")
    print()


def demo_stress_test(trials: int = 25, n: int = 5) -> None:
    print("=" * 72)
    print(f"DEMO 4 — Stress test: simplex-sup == edge-sup over {trials} random pairs")
    print("=" * 72)
    failures = 0
    for t in range(trials):
        d1 = random_dist_matrix(n, seed=100 + 2 * t)
        d2 = random_dist_matrix(n, seed=101 + 2 * t)
        wF = diam_filtration_weight(d1, n)
        wG = diam_filtration_weight(d2, n)
        if weight_sup_dist(wF, wG) != edge_sup_dist(d1, d2, n):
            failures += 1
    print(f"agreements: {trials - failures}/{trials}, failures: {failures}")
    assert failures == 0
    print("  -> edge-realization holds on every randomly generated distance matrix.")
    print()


def main() -> None:
    demo_representation()
    demo_edge_realization()
    demo_exact_cloud_certificate()
    demo_stress_test()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
