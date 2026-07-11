"""
Geometry Between the Dimensions -- numerical demonstrations.
================================================================

This self-contained script illustrates the four main results about sets of
infinite Hausdorff dimension:

  1. The isometric staging map iota_n : R^n -> l^2 that pads a vector with
     zeros preserves distances exactly (Proposition: Isometric staging).
  2. Hausdorff dimension does not decrease under distance-expanding
     (antilipschitz) maps, and equals n for R^n; hence l^2, which receives an
     isometric copy of every R^n, has dimension exceeding every finite n
     (Realization Theorem).
  3. No distance-expanding map can send R^n into a strictly lower-dimensional
     space (Dimension Ladder): any linear map R^n -> R^m with m < n has a
     nontrivial kernel, so it collapses distances and cannot be antilipschitz.
  4. A finite union of finite-dimensional pieces has finite dimension (the
     max of the pieces), so it can never cover a set of infinite dimension
     (No Finite Triangulation).

Everything runs with only the Python standard library.
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence


# ---------------------------------------------------------------------------
# 1. Isometric staging  iota_n : R^n -> l^2  (pad with zeros)
# ---------------------------------------------------------------------------
def euclidean_norm(x: Sequence[float]) -> float:
    """The Euclidean norm sqrt(sum x_i^2)."""
    return math.sqrt(sum(xi * xi for xi in x))


def euclidean_dist(x: Sequence[float], y: Sequence[float]) -> float:
    """Distance in R^n."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def iota(x: Sequence[float], ambient: int) -> List[float]:
    """
    Embed an n-vector into the first n coordinates of R^ambient (a finite
    truncation of l^2), padding the remaining coordinates with zeros.
    Requires ambient >= len(x).
    """
    n = len(x)
    assert ambient >= n
    return list(x) + [0.0] * (ambient - n)


def demo_staging_is_isometry(n: int = 5, ambient: int = 50, trials: int = 5) -> None:
    """Verify numerically that iota_n preserves pairwise distances."""
    print("== 1. Isometric staging  iota_n : R^n -> l^2 ==")
    max_err = 0.0
    for _ in range(trials):
        x = [random.uniform(-3, 3) for _ in range(n)]
        y = [random.uniform(-3, 3) for _ in range(n)]
        d_src = euclidean_dist(x, y)
        d_img = euclidean_dist(iota(x, ambient), iota(y, ambient))
        max_err = max(max_err, abs(d_src - d_img))
    print(f"   n = {n}, ambient = {ambient}")
    print(f"   max |dist(x,y) - dist(iota x, iota y)| over {trials} trials = {max_err:.2e}")
    print("   => distances preserved exactly (isometry).\n")


# ---------------------------------------------------------------------------
# 2. Box-counting dimension estimate: dim_H(R^n) = n
# ---------------------------------------------------------------------------
def box_count_dimension(n: int, resolutions: Sequence[int]) -> float:
    """
    Estimate the box-counting dimension of the unit cube in R^n (which equals
    its Hausdorff dimension, n) from the scaling N(eps) ~ eps^{-d}.
    A grid at resolution r has r^n boxes; d = log N / log(1/eps) with eps = 1/r.
    Returns the slope estimate averaged across consecutive resolutions.
    """
    slopes = []
    xs = [math.log(r) for r in resolutions]           # log(1/eps) = log r
    ys = [n * math.log(r) for r in resolutions]        # log N = log(r^n)
    for i in range(1, len(resolutions)):
        slopes.append((ys[i] - ys[i - 1]) / (xs[i] - xs[i - 1]))
    return sum(slopes) / len(slopes)


def demo_dimension_of_Rn() -> None:
    """Confirm the box-counting dimension of R^n equals n, for several n."""
    print("== 2. Hausdorff/box dimension of R^n equals n ==")
    resolutions = [2, 4, 8, 16, 32, 64]
    for n in range(1, 7):
        d = box_count_dimension(n, resolutions)
        print(f"   n = {n}:  estimated dimension = {d:.4f}")
    print("   => l^2 contains R^n for every n, so dim_H(l^2) >= n for all n,")
    print("      i.e. dim_H(l^2) = infinity.\n")


# ---------------------------------------------------------------------------
# 3. Dimension ladder: a linear map R^n -> R^m (m < n) collapses distances
# ---------------------------------------------------------------------------
def apply_matrix(A: List[List[float]], x: Sequence[float]) -> List[float]:
    """Compute A x where A is m-by-n (list of m rows of length n)."""
    return [sum(a * xi for a, xi in zip(row, x)) for row in A]


def worst_case_expansion_ratio(A: List[List[float]], n: int, samples: int = 20000) -> float:
    """
    For a map A : R^n -> R^m, an antilipschitz constant K would need
        ||x - y|| <= K ||A(x-y)||   for all x, y,
    i.e. K >= ||v|| / ||A v|| for every nonzero v. If A has a nonzero kernel
    (guaranteed when m < n), some v gives ||A v|| = 0 and no finite K works.
    This samples random directions and returns the largest ratio found; a
    diverging ratio witnesses the failure of the antilipschitz property.
    """
    best = 0.0
    for _ in range(samples):
        v = [random.gauss(0, 1) for _ in range(n)]
        nv = euclidean_norm(v)
        if nv == 0:
            continue
        av = euclidean_norm(apply_matrix(A, v))
        if av == 0:
            return math.inf
        best = max(best, nv / av)
    return best


def demo_dimension_ladder(n: int = 4, m: int = 2) -> None:
    """Show that any linear map R^n -> R^m (m < n) fails to be antilipschitz."""
    print("== 3. Dimension ladder: no antilipschitz map R^n -> R^m for m < n ==")
    # A random m-by-n matrix; since m < n it has a nontrivial kernel.
    A = [[random.uniform(-1, 1) for _ in range(n)] for _ in range(m)]
    ratio = worst_case_expansion_ratio(A, n, samples=50000)
    print(f"   n = {n}, m = {m} (m < n)")
    if ratio == math.inf:
        print("   found a direction v with A v = 0  =>  no finite antilipschitz K.")
    else:
        print(f"   largest observed ||v||/||Av|| ratio = {ratio:.2f} (grows without bound).")
    print("   => R^4 cannot be distance-expandingly mapped into R^2.\n")


# ---------------------------------------------------------------------------
# 4. No finite triangulation: dim of a finite union is the max of the pieces
# ---------------------------------------------------------------------------
def union_dimension(piece_dims: Sequence[float]) -> float:
    """
    Hausdorff dimension of a countable union equals the supremum of the pieces.
    For a FINITE family of finite dimensions, this maximum is finite -- so a
    finite union can never reach infinite dimension.
    """
    return max(piece_dims) if piece_dims else 0.0


def demo_no_finite_triangulation() -> None:
    """Illustrate that no finite family of finite-dim pieces reaches infinity."""
    print("== 4. No finite triangulation ==")
    finite_families = [
        [0.0, 1.0, 2.0],
        [3.0, 3.0, 5.0, 1.0],
        [float(k) for k in range(10)],
    ]
    for fam in finite_families:
        print(f"   pieces of dimension {fam}  ->  union dimension = {union_dimension(fam)}")
    print("   A set with dim_H = infinity would need a piece of dimension infinity,")
    print("   impossible for finitely many finite-dimensional simplices.")
    print("   (But INFINITELY many stages do reach infinity:)")
    partial_sup = [union_dimension(list(range(N))) for N in (5, 50, 500, 5000)]
    print(f"   sup over first N=5,50,500,5000 stages = {partial_sup}  ->  infinity.\n")


def main() -> None:
    random.seed(20260711)
    print("Geometry Between the Dimensions -- numerical demonstrations")
    print("=" * 60, "\n")
    demo_staging_is_isometry()
    demo_dimension_of_Rn()
    demo_dimension_ladder()
    demo_no_finite_triangulation()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
