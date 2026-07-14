"""
Numerical demonstrations of the Cone Colorful Caratheodory Theorem.

This standalone script illustrates, with concrete numerical examples:

  1. The homogeneity bridge: for the origin, a nontrivial conical combination
     can be rescaled to a convex combination, and vice versa.
  2. Testing whether the origin lies in the convex hull of a finite point set
     (equivalently, whether the set convexly captures the origin).
  3. The nearest-transversal descent algorithm that constructs a colorful
     transversal whose convex hull contains the origin, given color classes each
     of which captures the origin, with at least d+1 colors.
  4. The sharpness of the d+1 threshold: with only d colors the conclusion can
     fail (the {+1, -1} example in dimension one).

Dependencies: numpy, scipy.
"""

from __future__ import annotations

import itertools
from typing import Iterable, Sequence

import numpy as np
from scipy.optimize import linprog, minimize


# --------------------------------------------------------------------------- #
# 1. The homogeneity bridge
# --------------------------------------------------------------------------- #
def conic_to_convex(weights: np.ndarray) -> np.ndarray:
    """Rescale nonnegative conical weights (not all zero) to convex weights.

    Given w_i >= 0 with some w_j > 0, return w_i / sum(w) which are >= 0 and
    sum to 1, witnessing the convex combination of the same vanishing sum.
    """
    total = float(np.sum(weights))
    if total <= 0.0:
        raise ValueError("weights must be nonnegative and not all zero")
    return weights / total


def convex_to_conic(weights: np.ndarray) -> np.ndarray:
    """A convex combination is already a conical one (identity map here)."""
    return np.array(weights, dtype=float)


# --------------------------------------------------------------------------- #
# 2. Origin-in-convex-hull test
# --------------------------------------------------------------------------- #
def origin_in_convex_hull(points: Sequence[np.ndarray], tol: float = 1e-9) -> bool:
    """Return True iff 0 is a convex combination of `points`.

    Solves the feasibility LP:  find w >= 0, sum(w) = 1, sum_i w_i p_i = 0.
    """
    pts = np.asarray(points, dtype=float)
    n, d = pts.shape
    # Equality constraints: P^T w = 0  (d rows) and 1^T w = 1 (1 row).
    a_eq = np.vstack([pts.T, np.ones((1, n))])
    b_eq = np.concatenate([np.zeros(d), np.ones(1)])
    res = linprog(
        c=np.zeros(n),
        A_eq=a_eq,
        b_eq=b_eq,
        bounds=[(0.0, None)] * n,
        method="highs",
    )
    return bool(res.success) and float(np.linalg.norm(a_eq @ res.x - b_eq)) < tol


def nearest_point_in_hull(points: Sequence[np.ndarray]) -> tuple[np.ndarray, np.ndarray]:
    """Return (p, w): the point p of conv(points) nearest the origin, and the
    convex weights w achieving it (w >= 0, sum w = 1, p = sum_i w_i p_i)."""
    pts = np.asarray(points, dtype=float)
    n = pts.shape[0]

    def objective(w: np.ndarray) -> float:
        return float(np.dot(pts.T @ w, pts.T @ w))

    cons = ({"type": "eq", "fun": lambda w: float(np.sum(w) - 1.0)},)
    bounds = [(0.0, None)] * n
    w0 = np.full(n, 1.0 / n)
    res = minimize(objective, w0, method="SLSQP", bounds=bounds, constraints=cons)
    w = np.clip(res.x, 0.0, None)
    w = w / np.sum(w)
    return pts.T @ w, w


# --------------------------------------------------------------------------- #
# 3. Nearest-transversal descent for colorful Caratheodory (origin)
# --------------------------------------------------------------------------- #
def colorful_transversal_bruteforce(
    colors: Sequence[Sequence[np.ndarray]], tol: float = 1e-7
) -> list[np.ndarray] | None:
    """Find a colorful transversal (one point per color) whose convex hull
    contains the origin, by scanning all transversals.

    Guaranteed to succeed when each color captures the origin and #colors >= d+1.
    """
    for choice in itertools.product(*colors):
        p, _ = nearest_point_in_hull(list(choice))
        if float(np.linalg.norm(p)) < tol:
            return [np.asarray(c, dtype=float) for c in choice]
    return None


def colorful_transversal_descent(
    colors: Sequence[Sequence[np.ndarray]], tol: float = 1e-7, max_iter: int = 1000
) -> list[np.ndarray] | None:
    """Construct a colorful transversal capturing the origin by descent.

    Mirrors the constructive proof: start from an arbitrary transversal; while
    its nearest point p to the origin is nonzero, extract the supporting
    hyperplane <p, .> = |p|^2, find a color j whose current pick is not needed
    to represent p and which contains a near-side vertex y (<p, y> < |p|^2),
    swap it in, and repeat. Each swap strictly reduces |p|.
    """
    d = int(np.asarray(colors[0][0]).shape[0])
    if len(colors) < d + 1:
        return None
    # Initial transversal: first element of each color.
    trans: list[np.ndarray] = [np.asarray(c[0], dtype=float) for c in colors]

    for _ in range(max_iter):
        p, w = nearest_point_in_hull(trans)
        if float(np.linalg.norm(p)) < tol:
            return trans
        p_sq = float(np.dot(p, p))
        # Colors that materially support p (positive weight): "used" colors.
        used = {i for i, wi in enumerate(w) if wi > 1e-9}
        improved = False
        for j in range(len(colors)):
            if j in used:
                continue
            # Look for a near-side vertex y in color j: <p, y> < |p|^2.
            for y in colors[j]:
                y = np.asarray(y, dtype=float)
                if float(np.dot(p, y)) < p_sq - 1e-12:
                    trans[j] = y
                    improved = True
                    break
            if improved:
                break
        if not improved:
            # Fallback: any color/vertex strictly improving the nearest distance.
            best = float(np.linalg.norm(p))
            arg = None
            for j in range(len(colors)):
                for y in colors[j]:
                    cand = list(trans)
                    cand[j] = np.asarray(y, dtype=float)
                    q, _ = nearest_point_in_hull(cand)
                    if float(np.linalg.norm(q)) < best - 1e-10:
                        best, arg = float(np.linalg.norm(q)), (j, np.asarray(y, float))
            if arg is None:
                return trans
            trans[arg[0]] = arg[1]
    return trans


# --------------------------------------------------------------------------- #
# 4. Demonstrations
# --------------------------------------------------------------------------- #
def demo_homogeneity_bridge() -> None:
    print("=" * 70)
    print("1. Homogeneity bridge")
    print("=" * 70)
    # Vectors summing to zero with nonnegative, non-normalized weights.
    pts = [np.array([1.0, 0.0]), np.array([-2.0, 1.0]), np.array([0.0, -1.0])]
    conic = np.array([2.0, 1.0, 1.0])  # 2*(1,0)+1*(-2,1)+1*(0,-1) = (0,0)
    combo = sum(wi * p for wi, p in zip(conic, pts))
    print(f"conical weights {conic},  weighted sum = {combo}")
    convex = conic_to_convex(conic)
    print(f"rescaled convex weights {np.round(convex, 4)},  sum = {convex.sum():.4f}")
    combo2 = sum(wi * p for wi, p in zip(convex, pts))
    print(f"convex weighted sum = {np.round(combo2, 12)}")
    print()


def demo_hull_test() -> None:
    print("=" * 70)
    print("2. Origin-in-convex-hull test")
    print("=" * 70)
    triangle = [np.array([1.0, 1.0]), np.array([-1.0, 1.0]), np.array([0.0, -1.0])]
    print(f"triangle around origin captures 0? {origin_in_convex_hull(triangle)}")
    off = [np.array([1.0, 1.0]), np.array([2.0, 1.0]), np.array([1.5, 2.0])]
    print(f"triangle avoiding origin captures 0? {origin_in_convex_hull(off)}")
    print()


def demo_colorful() -> None:
    print("=" * 70)
    print("3. Colorful Caratheodory in R^2 (need d+1 = 3 colors)")
    print("=" * 70)
    # Each color is a triangle whose hull contains the origin.
    color0 = [np.array([1.0, 0.0]), np.array([-1.0, 1.0]), np.array([-1.0, -1.0])]
    color1 = [np.array([0.0, 1.0]), np.array([1.0, -1.0]), np.array([-1.0, -1.0])]
    color2 = [np.array([-1.0, 0.0]), np.array([1.0, 1.0]), np.array([1.0, -1.0])]
    colors = [color0, color1, color2]
    for k, c in enumerate(colors):
        print(f"  color {k} captures origin? {origin_in_convex_hull(c)}")
    trans = colorful_transversal_descent(colors)
    assert trans is not None
    print("  descent transversal:", [tuple(np.round(v, 3)) for v in trans])
    print(f"  transversal captures origin? {origin_in_convex_hull(trans)}")
    bf = colorful_transversal_bruteforce(colors)
    print(f"  brute-force also finds one? {bf is not None}")
    print()


def demo_sharpness() -> None:
    print("=" * 70)
    print("4. Sharpness: d colors can fail (d = 1)")
    print("=" * 70)
    color = [np.array([1.0]), np.array([-1.0])]  # single color captures 0
    print(f"  single color {{+1,-1}} captures 0? {origin_in_convex_hull(color)}")
    # With only ONE color (d = 1, need d+1 = 2), every transversal is a single
    # nonzero number -> cannot capture the origin.
    any_ok = any(
        origin_in_convex_hull([np.asarray(t[0], float)])
        for t in itertools.product(color)
    )
    print(f"  any single-color transversal captures 0? {any_ok}  (expected False)")
    # With TWO copies of the color (2 colors, d+1 = 2), a transversal succeeds.
    colors2 = [color, color]
    trans = colorful_transversal_bruteforce(colors2)
    print(f"  with 2 colors, transversal found? {trans is not None}")
    if trans is not None:
        print(f"    transversal = {[float(v[0]) for v in trans]}")
    print()


def main() -> None:
    np.set_printoptions(suppress=True)
    demo_homogeneity_bridge()
    demo_hull_test()
    demo_colorful()
    demo_sharpness()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
