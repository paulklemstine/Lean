"""
demo.py — Numerical demonstrations of the Vietoris–Rips completion threshold.

This standalone script illustrates the main results of the package:

  * Completion Threshold Theorem:
        VR(eps) = full complex  <=>  every pair of points is within eps.
  * Diameter / max-plus form (finite spaces):
        VR(eps) = full complex  <=>  diameter <= eps,
    where the diameter is the MAX-PLUS BIRTH SUM
        tropBirthSum = (+)_{x,y} dist(x,y)   with tropical (+) = max.
  * The diameter is the LEAST completion scale (a sharp threshold).
  * Structural laws of the fold: additivity over unions, monotonicity
    under non-expanding maps, and sharp 1-Lipschitz stability.

Everything is inlined; no third-party dependencies are required.
"""

from __future__ import annotations

from itertools import combinations
from math import sqrt
from typing import Callable, Iterable, List, Sequence, Tuple

Point = Tuple[float, ...]
Metric = Callable[[Point, Point], float]


# ---------------------------------------------------------------------------
# Core metric utilities
# ---------------------------------------------------------------------------
def euclidean(x: Point, y: Point) -> float:
    """Standard Euclidean distance between two equal-length tuples."""
    return sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def trop_birth_sum(points: Sequence[Point], dist: Metric = euclidean) -> float:
    """The max-plus birth sum = diameter = tropical sum of edge births.

    Tropical addition is `max`, so this single O(n^2) fold over all pairs
    returns the exact least completion scale (Diameter Form theorem).
    """
    best = float("-inf")  # tropical additive identity
    for p, q in combinations(points, 2):
        best = max(best, dist(p, q))  # tropical (+) = max
    if best == float("-inf"):  # 0 or 1 point: already complete at any scale
        return float("-inf")
    return best


def is_complete_at(points: Sequence[Point], eps: float, dist: Metric = euclidean) -> bool:
    """Decide VR(eps) = full complex without building a single simplex.

    Equivalent to `trop_birth_sum(points) <= eps` (Completion Threshold Theorem).
    Short-circuits on the first violating pair.
    """
    for p, q in combinations(points, 2):
        if dist(p, q) > eps:
            return False
    return True


def face_birth(face: Sequence[Point], dist: Metric = euclidean) -> float:
    """Birth scale of a single face: the internal max-plus fold of its edges."""
    if len(face) < 2:
        return float("-inf")
    return max(dist(p, q) for p, q in combinations(face, 2))


def num_faces_of_full_complex(n: int) -> int:
    """Number of nonempty faces of the full complex on n vertices: 2^n - 1."""
    return (1 << n) - 1


def num_rips_faces(points: Sequence[Point], eps: float, dist: Metric = euclidean) -> int:
    """Number of nonempty faces of VR(eps); a face is present iff its
    internal pairwise distances are all <= eps (i.e. face_birth <= eps)."""
    n = len(points)
    count = 0
    for k in range(1, n + 1):
        for face in combinations(points, k):
            if face_birth(face, dist) <= eps:
                count += 1
    return count


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_unit_square() -> None:
    print("=" * 70)
    print("DEMO 1 — Unit square in the plane (Euclidean)")
    print("=" * 70)
    square: List[Point] = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]
    D = trop_birth_sum(square)
    print(f"points              : {square}")
    print(f"diameter (tropBirthSum) = {D:.6f}   (expected sqrt(2) = {sqrt(2):.6f})")
    for eps in [0.5, 1.0, 1.41, sqrt(2), 1.5]:
        complete = is_complete_at(square, eps)
        faces = num_rips_faces(square, eps)
        full = num_faces_of_full_complex(len(square))
        print(f"  eps={eps:<7.5f} complete={complete!s:<5} "
              f"faces={faces:>2}/{full}  (theory: complete iff eps >= {D:.5f})")
    print()


def demo_collinear_triple() -> None:
    print("=" * 70)
    print("DEMO 2 — Collinear triple {0, 1, 3} on the line")
    print("=" * 70)
    pts: List[Point] = [(0.0,), (1.0,), (3.0,)]
    D = trop_birth_sum(pts)
    print(f"diameter (tropBirthSum) = {D:.6f}   (expected 3.0, the extreme pair)")
    for eps in [1.0, 2.0, 2.999, 3.0]:
        print(f"  eps={eps:<6.3f} complete={is_complete_at(pts, eps)}")
    print()


def demo_least_threshold() -> None:
    print("=" * 70)
    print("DEMO 3 — The diameter is the LEAST completion scale (sharpness)")
    print("=" * 70)
    pts: List[Point] = [(0.0, 0.0), (2.0, 0.0), (1.0, 1.7)]
    D = trop_birth_sum(pts)
    below = D - 1e-9
    print(f"diameter = {D:.6f}")
    print(f"  at eps = diameter - 1e-9 : complete = {is_complete_at(pts, below)} (must be False)")
    print(f"  at eps = diameter        : complete = {is_complete_at(pts, D)} (must be True)")
    print()


def demo_stability() -> None:
    print("=" * 70)
    print("DEMO 4 — Sharp 1-Lipschitz stability under perturbation")
    print("=" * 70)
    base: List[Point] = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]
    D0 = trop_birth_sum(base)
    delta = 0.05
    # Worst case: push the diametral pair apart by delta along the diagonal.
    perturbed = list(base)
    perturbed[3] = (1.0 + delta / sqrt(2), 1.0 + delta / sqrt(2))
    D1 = trop_birth_sum(perturbed)
    print(f"baseline diameter   = {D0:.6f}")
    print(f"perturbed diameter  = {D1:.6f}")
    print(f"threshold shift     = {abs(D1 - D0):.6f}   (must be <= delta = {delta})")
    print(f"  -> stability bound |dD| <= delta is respected, and ~tight.")
    print()


def demo_union_additivity() -> None:
    print("=" * 70)
    print("DEMO 5 — Additivity of the fold over unions")
    print("=" * 70)
    A: List[Point] = [(0.0, 0.0), (1.0, 0.0)]
    B: List[Point] = [(5.0, 0.0), (5.0, 2.0)]
    DA, DB = trop_birth_sum(A), trop_birth_sum(B)
    cross = max(euclidean(p, q) for p in A for q in B)
    D_union = trop_birth_sum(A + B)
    predicted = max(DA, DB, cross)
    print(f"diam(A)              = {DA:.6f}")
    print(f"diam(B)              = {DB:.6f}")
    print(f"max cross distance   = {cross:.6f}")
    print(f"diam(A ∪ B)          = {D_union:.6f}")
    print(f"max(diam A, diam B, cross) = {predicted:.6f}  -> match: {abs(D_union - predicted) < 1e-12}")
    print()


def demo_monotonicity() -> None:
    print("=" * 70)
    print("DEMO 6 — Monotonicity under a non-expanding map (0.5x scaling)")
    print("=" * 70)
    pts: List[Point] = [(0.0, 0.0), (3.0, 0.0), (0.0, 4.0)]
    shrunk: List[Point] = [(0.5 * x, 0.5 * y) for (x, y) in pts]
    print(f"diameter before scaling = {trop_birth_sum(pts):.6f}")
    print(f"diameter after  0.5x    = {trop_birth_sum(shrunk):.6f}  (must not increase)")
    print()


if __name__ == "__main__":
    demo_unit_square()
    demo_collinear_triple()
    demo_least_threshold()
    demo_stability()
    demo_union_additivity()
    demo_monotonicity()
    print("All demonstrations completed.")
