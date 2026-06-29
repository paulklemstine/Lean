"""
Numerical demonstration of the interleaving-distance / bottleneck-stability
theory of sublevel filtrations (Boltzmann Bridge IV).

This script is fully self-contained (standard library only).  It reproduces, on
explicit finite data, every quantitative claim of the accompanying article and
research paper:

  * the sublevel filtration of a monotone simplex weight,
  * the Vietoris-Rips diameter weight built from a distance matrix,
  * the 1-Lipschitz estimate "diameter is 1-Lipschitz in the metric"
    (Theorem 6.3),
  * the interleaving relation and the interleaving distance,
  * the CESH 1-Lipschitz stability bound (Theorem 5.4),
  * the Vietoris-Rips stability bound (Theorem 6.5),
  * the end-to-end three-point-cloud certificate (Section 7).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Tuple

Point = int
Simplex = FrozenSet[Point]
DistMatrix = Dict[Tuple[Point, Point], float]


# --------------------------------------------------------------------------- #
# Simplices and weights
# --------------------------------------------------------------------------- #
def all_nonempty_simplices(vertices: Sequence[Point]) -> List[Simplex]:
    """Every non-empty face of the full simplex on `vertices`."""
    faces: List[Simplex] = []
    for k in range(1, len(vertices) + 1):
        for combo in combinations(vertices, k):
            faces.append(frozenset(combo))
    return faces


def all_simplices(vertices: Sequence[Point]) -> List[Simplex]:
    """Every face, including the empty simplex."""
    return [frozenset()] + all_nonempty_simplices(vertices)


def diam_weight_of(d: DistMatrix, sigma: Simplex) -> float:
    """Diameter weight (Definition 6.1): largest pairwise distance in sigma,
    or 0 when sigma has fewer than two vertices.  The sentinel 0 mirrors the
    Lean `insert 0 ...` construction."""
    pairs = list(combinations(sorted(sigma), 2))
    if not pairs:
        return 0.0
    return max(d[(x, y)] for (x, y) in pairs)


def make_symmetric(entries: Dict[Tuple[Point, Point], float]) -> DistMatrix:
    """Build a full symmetric distance table (with zero diagonal) from the
    upper-triangular entries."""
    d: DistMatrix = {}
    pts = set(chain.from_iterable(entries.keys()))
    for x in pts:
        d[(x, x)] = 0.0
    for (x, y), v in entries.items():
        d[(x, y)] = v
        d[(y, x)] = v
    return d


# --------------------------------------------------------------------------- #
# Sublevel filtrations and interleaving
# --------------------------------------------------------------------------- #
def sublevel_faces(weight: Callable[[Simplex], float],
                   simplices: Iterable[Simplex],
                   t: float) -> FrozenSet[Simplex]:
    """The set of simplices alive at scale t: { sigma : weight sigma <= t }."""
    return frozenset(s for s in simplices if weight(s) <= t + 1e-12)


def is_delta_interleaved(w1: Callable[[Simplex], float],
                         w2: Callable[[Simplex], float],
                         simplices: Sequence[Simplex],
                         delta: float,
                         scales: Sequence[float]) -> bool:
    """Check Interleaved (Definition 3.1) on a finite grid of scales: each
    filtration shifted by delta contains the other.  For monotone weights on a
    finite simplex set, checking the finitely many critical scales is exact."""
    if delta < 0:
        return False
    for t in scales:
        lhs1 = sublevel_faces(w1, simplices, t)
        rhs1 = sublevel_faces(w2, simplices, t + delta)
        lhs2 = sublevel_faces(w2, simplices, t)
        rhs2 = sublevel_faces(w1, simplices, t + delta)
        if not (lhs1 <= rhs1 and lhs2 <= rhs2):
            return False
    return True


def sup_weight_distance(w1: Callable[[Simplex], float],
                        w2: Callable[[Simplex], float],
                        simplices: Iterable[Simplex]) -> float:
    """Sup-norm distance between two weight functions (Definition 5.1)."""
    return max(abs(w1(s) - w2(s)) for s in simplices)


def matrix_distortion(d1: DistMatrix, d2: DistMatrix) -> float:
    """Distortion between two distance matrices (Definition 6.2, identity
    correspondence): the largest entrywise discrepancy."""
    keys = set(d1) | set(d2)
    return max(abs(d1.get(k, 0.0) - d2.get(k, 0.0)) for k in keys)


def interleaving_distance_upper_bound(w1: Callable[[Simplex], float],
                                      w2: Callable[[Simplex], float],
                                      simplices: Sequence[Simplex],
                                      scales: Sequence[float],
                                      grid: Sequence[float]) -> float:
    """Smallest delta on `grid` that yields a delta-interleaving -- an upper
    bound for interleavingDist (Theorem 4.2(2))."""
    for delta in sorted(grid):
        if is_delta_interleaved(w1, w2, simplices, delta, scales):
            return delta
    return float("inf")


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_diameter_lipschitz() -> None:
    """Theorem 6.3: the diameter is 1-Lipschitz in the distance matrix."""
    print("=" * 70)
    print("DEMO 1  --  The diameter is 1-Lipschitz in the metric (Thm 6.3)")
    print("=" * 70)
    verts = [0, 1, 2]
    d1 = make_symmetric({(0, 1): 1.0, (0, 2): 2.0, (1, 2): 1.5})
    eps = 0.3
    # Perturb every entry by at most eps.
    d2 = make_symmetric({(0, 1): 1.0 + 0.3, (0, 2): 2.0 - 0.2, (1, 2): 1.5 + 0.1})
    dist = matrix_distortion(d1, d2)
    print(f"distance-matrix distortion  = {dist:.4f}  (<= eps = {eps})")
    worst = 0.0
    for s in all_nonempty_simplices(verts):
        a, b = diam_weight_of(d1, s), diam_weight_of(d2, s)
        worst = max(worst, abs(a - b))
        print(f"  simplex {set(s)!s:<12} diam1={a:.3f}  diam2={b:.3f}  "
              f"|d|={abs(a-b):.3f}")
    print(f"max diameter discrepancy    = {worst:.4f}")
    assert worst <= dist + 1e-9, "1-Lipschitz bound violated!"
    print(f"VERIFIED: max diam discrepancy {worst:.4f} <= distortion "
          f"{dist:.4f}\n")


def demo_cesh_stability() -> None:
    """Theorem 5.4: interleavingDist <= sup-norm distance of the weights."""
    print("=" * 70)
    print("DEMO 2  --  CESH 1-Lipschitz stability (Thm 5.4)")
    print("=" * 70)
    verts = [0, 1, 2]
    simplices = all_simplices(verts)
    d1 = make_symmetric({(0, 1): 1.0, (0, 2): 2.0, (1, 2): 1.5})
    d2 = make_symmetric({(0, 1): 1.25, (0, 2): 1.8, (1, 2): 1.6})
    w1 = lambda s: diam_weight_of(d1, s)
    w2 = lambda s: diam_weight_of(d2, s)
    D = sup_weight_distance(w1, w2, simplices)
    print(f"sup-norm weight distance D  = {D:.4f}")
    scales = sorted({w1(s) for s in simplices} | {w2(s) for s in simplices})
    grid = [round(0.05 * k, 2) for k in range(0, 41)]
    db = interleaving_distance_upper_bound(w1, w2, simplices, scales, grid)
    print(f"interleaving distance bound = {db:.4f}  (search grid step 0.05)")
    assert db <= D + 0.05 + 1e-9, "Stability bound violated!"
    print(f"VERIFIED: interleavingDist {db:.4f} <= D {D:.4f} "
          f"(up to grid resolution)\n")


def demo_cloud_certificate() -> None:
    """Section 7: end-to-end certificate on two 3-point clouds."""
    print("=" * 70)
    print("DEMO 3  --  End-to-end 3-point-cloud certificate (Section 7)")
    print("=" * 70)
    verts = [0, 1, 2]  # a, b, c
    simplices = all_simplices(verts)
    eps = 0.2
    d1 = make_symmetric({(0, 1): 1.0, (0, 2): 1.7, (1, 2): 1.3})
    d2 = make_symmetric({(0, 1): 1.0 + eps, (0, 2): 1.7 - eps, (1, 2): 1.3 + eps})

    # (1) distortion
    dist = matrix_distortion(d1, d2)
    print(f"(1) cloud distortion        = {dist:.4f}  (<= eps = {eps})")
    assert dist <= eps + 1e-9

    # (2) eps-interleaving
    w1 = lambda s: diam_weight_of(d1, s)
    w2 = lambda s: diam_weight_of(d2, s)
    scales = sorted({w1(s) for s in simplices} | {w2(s) for s in simplices})
    interleaved = is_delta_interleaved(w1, w2, simplices, eps, scales)
    print(f"(2) eps-interleaved         = {interleaved}")
    assert interleaved

    # (3) interleaving distance bound
    grid = [round(0.02 * k, 2) for k in range(0, 51)]
    db = interleaving_distance_upper_bound(w1, w2, simplices, scales, grid)
    print(f"(3) interleavingDist bound  = {db:.4f}  (<= eps = {eps})")
    assert db <= eps + 1e-9
    print("VERIFIED: distortion <= eps  ==>  eps-interleaved  "
          "==>  interleavingDist <= eps\n")


def demo_triangle_inequality() -> None:
    """Theorem 3.2(4): interleavings compose additively (the relational
    triangle inequality), and the fault line at inf of the empty set."""
    print("=" * 70)
    print("DEMO 4  --  Additivity of interleavings (Thm 3.2.4) & the inf-empty "
          "fault line")
    print("=" * 70)
    verts = [0, 1, 2]
    simplices = all_simplices(verts)
    base = {(0, 1): 1.0, (0, 2): 1.7, (1, 2): 1.3}
    d1 = make_symmetric(base)
    d2 = make_symmetric({k: v + 0.15 for k, v in base.items()})
    d3 = make_symmetric({k: v + 0.30 for k, v in base.items()})
    w = lambda d: (lambda s: diam_weight_of(d, s))
    scales = sorted({w(d)(s) for d in (d1, d2, d3) for s in simplices})

    d_fg = matrix_distortion(d1, d2)
    d_gh = matrix_distortion(d2, d3)
    d_fh = matrix_distortion(d1, d3)
    print(f"distortion(F,G) = {d_fg:.3f}, distortion(G,H) = {d_gh:.3f}, "
          f"sum = {d_fg + d_gh:.3f}")
    print(f"distortion(F,H) = {d_fh:.3f}  <=  sum  (triangle inequality)")
    assert d_fh <= d_fg + d_gh + 1e-9
    fg = is_delta_interleaved(w(d1), w(d2), simplices, d_fg, scales)
    gh = is_delta_interleaved(w(d2), w(d3), simplices, d_gh, scales)
    fh = is_delta_interleaved(w(d1), w(d3), simplices, d_fg + d_gh, scales)
    print(f"F~G @ {d_fg:.3f}: {fg}; G~H @ {d_gh:.3f}: {gh}; "
          f"F~H @ {d_fg + d_gh:.3f}: {fh}")
    assert fg and gh and fh
    print("VERIFIED: a delta-interleaving composed with a delta'-interleaving "
          "is a (delta+delta')-interleaving.")
    print("NOTE: with the convention inf(empty set)=0, two never-interleaved "
          "filtrations are reported at distance 0 rather than +infinity --")
    print("      the documented fault line motivating the EReal upgrade "
          "(Future Direction 1).\n")


def main() -> None:
    print("\nINTERLEAVING DISTANCE & BOTTLENECK STABILITY -- NUMERICAL DEMO\n")
    demo_diameter_lipschitz()
    demo_cesh_stability()
    demo_cloud_certificate()
    demo_triangle_inequality()
    print("All demonstrations completed and assertions passed.")


if __name__ == "__main__":
    main()
