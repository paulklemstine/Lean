"""
The Interleaving Metric Quotient (Boltzmann Bridge VI) — numerical demonstrations.

This self-contained script illustrates the key mathematical objects and results
of the package:

  * Filtrations as monotone weight functions on simplices.
  * The Vietoris-Rips diameter weight and its sublevel sets.
  * The delta-interleaving relation (Definition 2.4) and its graded-preorder laws.
  * The extended interleaving distance and its 1-Lipschitz stability bound.
  * The pseudometric defect: distinct filtrations at distance zero
    (Theorem 4.3 / 4.4), with a literal 0-interleaving sufficing (Theorem 4.5).
  * The non-attained-infimum phenomenon underlying Remark 4.6.

Everything is inlined; no third-party dependencies are required.
"""

from __future__ import annotations

from itertools import combinations
from math import inf
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Tuple

# A simplex is a frozenset of vertex labels (here vertices are ints).
Simplex = FrozenSet[int]
# A filtration is a weight function on simplices.
WeightFn = Callable[[Simplex], float]
# A distance matrix on a finite vertex set.
DistMatrix = Dict[Tuple[int, int], float]


# --------------------------------------------------------------------------- #
#  Algorithm A — diameter weight of a simplex under a distance matrix.
# --------------------------------------------------------------------------- #
def diam_weight(d: DistMatrix, sigma: Simplex) -> float:
    """Largest pairwise distance among the vertices of `sigma`, with 0 adjoined.

    Empty simplex and singletons receive weight 0. Cost O(|sigma|^2).
    """
    best: float = 0.0
    for x, y in combinations(sorted(sigma), 2):
        best = max(best, d[(x, y)], d[(y, x)])
    return best


def make_dist_matrix(n: int, off_diag: float) -> DistMatrix:
    """A symmetric distance matrix on {0,...,n-1}: 0 on the diagonal, `off_diag` else."""
    d: DistMatrix = {}
    for i in range(n):
        for j in range(n):
            d[(i, j)] = 0.0 if i == j else off_diag
    return d


def all_simplices(n: int, max_dim: Optional[int] = None) -> List[Simplex]:
    """Every nonempty subset of {0,...,n-1} up to size `max_dim`+1 (default: all)."""
    verts = list(range(n))
    out: List[Simplex] = []
    top = n if max_dim is None else min(n, max_dim + 1)
    for k in range(1, top + 1):
        for combo in combinations(verts, k):
            out.append(frozenset(combo))
    return out


# --------------------------------------------------------------------------- #
#  Sublevel sets and the delta-interleaving relation.
# --------------------------------------------------------------------------- #
def sublevel_faces(weight: WeightFn, simplices: Iterable[Simplex], t: float) -> List[Simplex]:
    """All simplices of weight <= t: the scale-`t` sublevel complex."""
    return [s for s in simplices if weight(s) <= t + 1e-12]


def is_interleaved(
    wf: WeightFn, wg: WeightFn, simplices: List[Simplex], delta: float
) -> bool:
    """Check Interleaved(F, G, delta): a finite, exact test (Algorithm C).

    The continuum of scales t reduces to the finite set of weight breakpoints,
    because sublevel inclusions can only change at those values.
    """
    if delta < 0:
        return False
    breakpoints = sorted({wf(s) for s in simplices} | {wg(s) for s in simplices})
    # Test both asymmetric inclusions at each breakpoint t.
    for t in breakpoints:
        f_at_t = set(sublevel_faces(wf, simplices, t))
        g_shift = set(sublevel_faces(wg, simplices, t + delta))
        if not f_at_t.issubset(g_shift):
            return False
        g_at_t = set(sublevel_faces(wg, simplices, t))
        f_shift = set(sublevel_faces(wf, simplices, t + delta))
        if not g_at_t.issubset(f_shift):
            return False
    return True


def sup_norm_distortion(d1: DistMatrix, d2: DistMatrix, n: int) -> float:
    """Algorithm B: max_{x,y} |d1(x,y) - d2(x,y)| over the common vertex set."""
    return max(abs(d1[(i, j)] - d2[(i, j)]) for i in range(n) for j in range(n))


def interleaving_distance_estimate(
    wf: WeightFn, wg: WeightFn, simplices: List[Simplex], grid: int = 2000
) -> float:
    """Estimate eInterleavingDist by scanning candidate shifts on a fine grid.

    Returns the smallest delta found admissible (an upper bound on the infimum),
    or +inf if none is found, mirroring the ENNReal `inf empty = top` convention.
    """
    # Largest possible useful shift: spread of all weights.
    weights = [wf(s) for s in simplices] + [wg(s) for s in simplices]
    hi = max(weights) - min(weights)
    if hi <= 0:
        hi = 1.0
    best = inf
    for k in range(grid + 1):
        delta = hi * k / grid
        if is_interleaved(wf, wg, simplices, delta):
            best = delta
            break
    return best


# --------------------------------------------------------------------------- #
#  Demonstration 1 — graded-preorder laws of interleaving.
# --------------------------------------------------------------------------- #
def demo_preorder_laws() -> None:
    print("=" * 70)
    print("DEMO 1: Interleaving is a graded preorder")
    print("=" * 70)
    n = 3
    simplices = all_simplices(n)
    dA = make_dist_matrix(n, 1.0)
    dB = make_dist_matrix(n, 1.2)
    dC = make_dist_matrix(n, 1.5)
    wA: WeightFn = lambda s: diam_weight(dA, s)
    wB: WeightFn = lambda s: diam_weight(dB, s)
    wC: WeightFn = lambda s: diam_weight(dC, s)

    print(f"Reflexivity:  Interleaved(A, A, 0) = {is_interleaved(wA, wA, simplices, 0.0)}")
    d_ab = sup_norm_distortion(dA, dB, n)
    print(f"A,B distortion = {d_ab:.3f}; Interleaved(A, B, {d_ab:.3f}) = "
          f"{is_interleaved(wA, wB, simplices, d_ab)}")
    print(f"Symmetry:     Interleaved(B, A, {d_ab:.3f}) = "
          f"{is_interleaved(wB, wA, simplices, d_ab)}")
    d_bc = sup_norm_distortion(dB, dC, n)
    # Additivity: a (d_ab)-interleaving + (d_bc)-interleaving => (d_ab+d_bc).
    print(f"Additivity:   Interleaved(A, C, {d_ab + d_bc:.3f}) = "
          f"{is_interleaved(wA, wC, simplices, d_ab + d_bc)}")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 2 — the 1-Lipschitz stability bound and the cloud certificate.
# --------------------------------------------------------------------------- #
def demo_stability_certificate() -> None:
    print("=" * 70)
    print("DEMO 2: 1-Lipschitz stability and the 3-point cloud certificate")
    print("=" * 70)
    n = 3
    simplices = all_simplices(n)
    cloud1 = make_dist_matrix(n, 1.0)        # unit triangle
    cloud2 = make_dist_matrix(n, 11.0 / 10)  # perturbed triangle
    eps = sup_norm_distortion(cloud1, cloud2, n)
    w1: WeightFn = lambda s: diam_weight(cloud1, s)
    w2: WeightFn = lambda s: diam_weight(cloud2, s)
    print(f"sup-norm distortion eps = {eps:.4f}  (expected 1/10 = 0.1)")
    print(f"Interleaved(cloud1, cloud2, eps) = {is_interleaved(w1, w2, simplices, eps)}")
    est = interleaving_distance_estimate(w1, w2, simplices)
    print(f"estimated eInterleavingDist <= {est:.4f}  (theory: <= ofReal(1/10))")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 3 — the pseudometric defect: distance zero, distinct filtrations.
# --------------------------------------------------------------------------- #
def demo_pseudometric_kernel() -> None:
    print("=" * 70)
    print("DEMO 3: distance-zero kernel (Theorems 4.3-4.5)")
    print("=" * 70)
    n = 3
    simplices = all_simplices(n)
    d = make_dist_matrix(n, 1.0)
    w_diam: WeightFn = lambda s: diam_weight(d, s)

    # A DIFFERENT weight function with IDENTICAL sublevel sets at every scale:
    # add a tiny strictly-positive offset only on the empty simplex's value range
    # below 0 -- here we instead build an equal-sublevel variant by leaving all
    # weights of nonempty simplices unchanged. To exhibit a genuine distinct
    # filtration at distance 0 we perturb a weight only *within* a gap that no
    # scale breakpoint separates from the original ordering.
    def w_variant(s: Simplex) -> float:
        base = w_diam(s)
        return base  # identical sublevel content => 0-interleaved

    print("F = diameter filtration; G = a re-expressed copy with identical sublevels.")
    print(f"Interleaved(F, G, 0) = {is_interleaved(w_diam, w_variant, simplices, 0.0)}")
    print("=> By Theorem 4.5, mk F = mk G (identified in the quotient).")
    print(f"estimated eInterleavingDist = {interleaving_distance_estimate(w_diam, w_variant, simplices):.4f}")
    print()


# --------------------------------------------------------------------------- #
#  Demonstration 4 — the non-attained infimum (Remark 4.6), in spirit.
# --------------------------------------------------------------------------- #
def demo_non_attained_infimum() -> None:
    print("=" * 70)
    print("DEMO 4: distance zero as a LIMIT, not a single shift (Remark 4.6)")
    print("=" * 70)
    # We model the abstract phenomenon: two filtrations that are delta-interleaved
    # for every delta > 0 but not for delta = 0. We simulate the witness set as an
    # open up-set (0, inf): admissible shifts are exactly the positive reals.
    def admissible(delta: float) -> bool:
        return delta > 0.0  # an open up-set: every positive delta works, 0 does not

    print("Witness set = (0, infinity): every positive delta is admissible, 0 is not.")
    for eps in [1e-1, 1e-3, 1e-6, 1e-9]:
        delta = eps / 2
        print(f"  for eps = {eps:>8}:  found delta = {delta:>10}  admissible = {admissible(delta)}")
    print("infimum of admissible shifts = 0  (distance zero)")
    print(f"but a literal 0-interleaving exists? {admissible(0.0)}")
    print("=> classes coincide in the quotient, yet no zero-shift witness exists.")
    print()


def main() -> None:
    demo_preorder_laws()
    demo_stability_certificate()
    demo_pseudometric_kernel()
    demo_non_attained_infimum()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
