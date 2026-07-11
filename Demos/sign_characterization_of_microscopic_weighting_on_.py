"""Numerical demonstrations of microscopic weightings on Euclidean subsets.

A *microscopic weighting* of a finite metric space with distance matrix ``D`` is a
vector ``mu`` satisfying

    D @ mu = lam * ones      and      sum(mu) = 1

for a scalar ``lam`` (the *microscopic constant*).  It is the leading-order
(t -> 0) form of the magnitude weighting associated with the similarity matrix
Z_t with entries exp(-t * d(x_i, x_j)).

This script:
  * builds distance matrices for several Euclidean configurations;
  * computes the microscopic weighting via mu = D^{-1} 1 / (1^T D^{-1} 1);
  * verifies the energy identity lam = mu^T D mu;
  * checks the sign characterization: mu(x) > 0 iff x is an extreme point
    (vertex) of the convex hull, and mu(x) <= 0 at non-extreme points.

Only the standard library plus NumPy is required.
"""

from __future__ import annotations

import itertools
from typing import Callable

import numpy as np


# --------------------------------------------------------------------------- #
#  Core computations
# --------------------------------------------------------------------------- #
def distance_matrix(points: np.ndarray) -> np.ndarray:
    """Euclidean pairwise distance matrix of a set of points (rows = points)."""
    diff = points[:, None, :] - points[None, :, :]
    return np.sqrt((diff ** 2).sum(axis=-1))


def microscopic_weighting(D: np.ndarray) -> tuple[np.ndarray, float]:
    """Return (mu, lam) with D @ mu = lam * 1 and sum(mu) = 1.

    Uses the closed form mu = D^{-1} 1 / (1^T D^{-1} 1), valid when D is
    invertible and the row sums of D^{-1} do not cancel.
    """
    n = D.shape[0]
    ones = np.ones(n)
    u = np.linalg.solve(D, ones)          # u = D^{-1} 1
    s = float(u.sum())                    # s = 1^T D^{-1} 1
    if abs(s) < 1e-12:
        raise ValueError("degenerate configuration: 1^T D^{-1} 1 = 0")
    mu = u / s
    lam = 1.0 / s
    return mu, lam


def energy(mu: np.ndarray, D: np.ndarray) -> float:
    """The quadratic energy mu^T D mu, which equals the microscopic constant."""
    return float(mu @ (D @ mu))


def is_extreme_point(points: np.ndarray, i: int, tol: float = 1e-9) -> bool:
    """Decide whether point ``i`` is a vertex of conv(points).

    Point i is *not* extreme iff it lies in the convex hull of the other points,
    i.e. iff there exist convex coefficients c_j >= 0 (j != i), sum c_j = 1, with
    sum_j c_j x_j = x_i.  We test this small feasibility problem by a least-norm
    solve of the affine system followed by a nonnegativity check across the
    supporting simplices (exact for the low-dimensional demos here).
    """
    n = len(points)
    others = [j for j in range(n) if j != i]
    d = points.shape[1]
    target = points[i]
    # Try every affinely-independent subset of size up to d+1 of the others.
    for k in range(1, min(d + 1, len(others)) + 1):
        for combo in itertools.combinations(others, k):
            M = np.array([points[j] for j in combo]).T  # d x k
            # Solve for convex coefficients: M c = target, sum c = 1, c >= 0.
            A = np.vstack([M, np.ones(k)])
            b = np.concatenate([target, [1.0]])
            c, *_ = np.linalg.lstsq(A, b, rcond=None)
            if np.allclose(A @ c, b, atol=tol) and np.all(c >= -tol):
                return False  # x_i is a convex combination of others
    return True


def report(name: str, points: np.ndarray, index_labels: list[str]) -> None:
    """Print the weighting, constant, energy check, and sign audit."""
    D = distance_matrix(points)
    mu, lam = microscopic_weighting(D)
    print(f"\n=== {name} ===")
    print(f"points:\n{points}")
    print(f"microscopic constant lam = {lam:.6f}")
    print(f"energy mu^T D mu          = {energy(mu, D):.6f}  (should match lam)")
    print("per-point audit (weight vs. extreme-point status):")
    all_ok = True
    for i, label in enumerate(index_labels):
        extreme = is_extreme_point(points, i)
        w = mu[i]
        predicted = "positive" if extreme else "<= 0"
        actual = "positive" if w > 1e-9 else "<= 0"
        ok = (predicted == actual)
        all_ok = all_ok and ok
        flag = "OK" if ok else "MISMATCH"
        print(f"  {label:>10s}: mu = {w:+.6f}  extreme={extreme!s:>5}  "
              f"predicted {predicted:>8}, got {actual:>8}  [{flag}]")
    print(f"sign characterization holds for all points: {all_ok}")


# --------------------------------------------------------------------------- #
#  Configurations
# --------------------------------------------------------------------------- #
def demo_two_points() -> None:
    pts = np.array([[0.0], [1.0]])
    report("Two points (both extreme)", pts, ["x0=0", "x1=1"])


def demo_collinear() -> None:
    pts = np.array([[0.0], [1.0], [2.0]])
    report("Three collinear points 0,1,2 (middle non-extreme)", pts,
           ["x0=0", "x1=1", "x2=2"])


def demo_triangle() -> None:
    c = 1.0
    pts = np.array([[0.0, 0.0],
                    [c, 0.0],
                    [c / 2.0, c * np.sqrt(3) / 2.0]])
    report("Equilateral triangle (all extreme)", pts, ["A", "B", "C"])


def demo_square_plus_centre() -> None:
    pts = np.array([[0.0, 0.0],   # centre (interior)
                    [1.0, 1.0],
                    [1.0, -1.0],
                    [-1.0, 1.0],
                    [-1.0, -1.0]])
    report("Square {(+/-1,+/-1)} plus centre (centre interior, negative weight)",
           pts, ["centre", "v1", "v2", "v3", "v4"])


def demo_closed_forms() -> None:
    """Check the exact closed forms stated in the paper."""
    print("\n=== Exact closed-form checks ===")
    # Two points at distance r
    r = 3.7
    D2 = np.array([[0.0, r], [r, 0.0]])
    mu2, lam2 = microscopic_weighting(D2)
    print(f"two points, r={r}: mu={mu2}, lam={lam2:.6f}, expected lam=r/2={r/2}")

    # Square + centre closed form with s = sqrt(2)
    s = np.sqrt(2.0)
    Dsq = np.array([
        [0, s, s, s, s],
        [s, 0, 2, 2 * s, 2],
        [s, 2, 0, 2, 2 * s],
        [s, 2 * s, 2, 0, 2],
        [s, 2, 2 * s, 2, 0],
    ], dtype=float)
    mu_sq, lam_sq = microscopic_weighting(Dsq)
    expected_centre = 2 * (1 - s) / (6 - 2 * s)
    expected_vertex = 1.0 / (6 - 2 * s)
    print(f"square+centre: mu={np.round(mu_sq, 6)}")
    print(f"  centre weight  = {mu_sq[0]:+.6f}  expected {expected_centre:+.6f}")
    print(f"  vertex weight  = {mu_sq[1]:+.6f}  expected {expected_vertex:+.6f}")
    print(f"  lam            = {lam_sq:.6f}  expected {4*s/(6-2*s):.6f}")


def main() -> None:
    demo_two_points()
    demo_collinear()
    demo_triangle()
    demo_square_plus_centre()
    demo_closed_forms()


if __name__ == "__main__":
    main()
