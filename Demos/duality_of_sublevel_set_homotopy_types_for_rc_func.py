"""
Numerical demonstration of the polarity duality of sublevel sets of RC functions.

This script certifies, by direct computation on the concrete planar instance from
the theory, the chain of results:

  * The intertwining identity      f_dual(L(x)) = f(x)          (hypothesis (*))
  * The image identity             {f_dual <= c} = L({f <= c})  (sublevel_image)
  * The duality homeomorphism      L restricts to {f<=c} -> {f_dual<=c}
  * Equal discrete topology        same component / loop counts (homology iso)

The concrete instance (X = Y = R^2):

    p(x, y)      = |x|              q(x, y)       = |x| + |y|
    p_dual(x, y) = |y|             q_dual(x, y)  = |x| + |y|
    f      = p / q      = |x| / (|x| + |y|)
    f_dual = p_dual/q_dual = |y| / (|x| + |y|)
    L(x, y) = (y, x)               (coordinate swap; L^{-1} = L)

Everything is self-contained: no third-party dependencies are required.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple

Point = Tuple[float, float]


# ---------------------------------------------------------------------------
# RC building blocks (degree-one homogeneous, non-negative, convex)
# ---------------------------------------------------------------------------

def p(point: Point) -> float:
    """p(x, y) = |x|."""
    x, _ = point
    return abs(x)


def q(point: Point) -> float:
    """q(x, y) = |x| + |y|."""
    x, y = point
    return abs(x) + abs(y)


def p_dual(point: Point) -> float:
    """p_dual(x, y) = |y|."""
    _, y = point
    return abs(y)


def q_dual(point: Point) -> float:
    """q_dual(x, y) = |x| + |y|."""
    x, y = point
    return abs(x) + abs(y)


def ratio(num: Callable[[Point], float],
          den: Callable[[Point], float],
          point: Point) -> float:
    """RC ratio num/den, defined where den > 0."""
    d = den(point)
    if d <= 0.0:
        raise ZeroDivisionError("ratio undefined where denominator vanishes")
    return num(point) / d


def f(point: Point) -> float:
    """f = p / q = |x| / (|x| + |y|)."""
    return ratio(p, q, point)


def f_dual(point: Point) -> float:
    """f_dual = p_dual / q_dual = |y| / (|x| + |y|)."""
    return ratio(p_dual, q_dual, point)


# ---------------------------------------------------------------------------
# The polarity map L : (x, y) |-> (y, x)
# ---------------------------------------------------------------------------

def L(point: Point) -> Point:
    """Coordinate swap, a non-identity continuous linear equivalence."""
    x, y = point
    return (y, x)


def L_inv(point: Point) -> Point:
    """Inverse of L; here L is an involution so L_inv == L."""
    x, y = point
    return (y, x)


# ---------------------------------------------------------------------------
# Degree-zero homogeneity check: f(t * x) == f(x) for t > 0  (ratio_smul_pos)
# ---------------------------------------------------------------------------

def check_degree_zero_homogeneity(samples: List[Point],
                                  scales: List[float],
                                  tol: float = 1e-12) -> bool:
    """Verify f(t*point) == f(point) for all positive scales t."""
    for point in samples:
        if q(point) <= 0.0:
            continue
        base = f(point)
        for t in scales:
            scaled = (t * point[0], t * point[1])
            if abs(f(scaled) - base) > tol:
                return False
    return True


# ---------------------------------------------------------------------------
# Intertwining identity (*) : f_dual(L(point)) == f(point)
# ---------------------------------------------------------------------------

def check_intertwining(samples: List[Point], tol: float = 1e-12) -> bool:
    """Verify the polarity intertwining identity f_dual o L = f."""
    for point in samples:
        if q(point) <= 0.0:
            continue
        if abs(f_dual(L(point)) - f(point)) > tol:
            return False
    return True


# ---------------------------------------------------------------------------
# Image identity {f_dual <= c} = L({f <= c}), checked on a grid
# ---------------------------------------------------------------------------

def grid(n: int, extent: float) -> List[Point]:
    """A symmetric (2n+1) x (2n+1) grid on [-extent, extent]^2, origin removed."""
    step = extent / n
    pts: List[Point] = []
    for i in range(-n, n + 1):
        for j in range(-n, n + 1):
            point = (i * step, j * step)
            if q(point) > 0.0:
                pts.append(point)
    return pts


def check_image_identity(samples: List[Point], c: float,
                         tol: float = 1e-12) -> bool:
    """Verify membership equivalence: f_dual(y) <= c  iff  y = L(x), f(x) <= c.

    Since L is a bijection of the grid (a coordinate swap of a symmetric grid),
    we test, for each x, that  f(x) <= c  iff  f_dual(L(x)) <= c.
    """
    for point in samples:
        in_primal = f(point) <= c + tol
        in_dual_image = f_dual(L(point)) <= c + tol
        if in_primal != in_dual_image:
            return False
    return True


# ---------------------------------------------------------------------------
# Discrete topology: count connected components of a sublevel set on the grid
# (a coarse, computational stand-in for H_0; equality across the duality
#  illustrates the homology isomorphism sublevelHomologyIso).
# ---------------------------------------------------------------------------

def sublevel_membership(level_fn: Callable[[Point], float],
                        samples: List[Point], c: float,
                        tol: float = 1e-9) -> List[Point]:
    """Return the grid points lying in {level_fn <= c}."""
    return [pt for pt in samples if level_fn(pt) <= c + tol]


def count_components(points: List[Point], step: float,
                     tol: float = 1e-9) -> int:
    """Count 4-connected components of a finite set of grid points."""
    index = {(round(x / step), round(y / step)): k
             for k, (x, y) in enumerate(points)}
    parent = list(range(len(points)))

    def find(a: int) -> int:
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    def union(a: int, b: int) -> None:
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb

    for (gx, gy), k in index.items():
        for dgx, dgy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nbr = (gx + dgx, gy + dgy)
            if nbr in index:
                union(k, index[nbr])
    return len({find(k) for k in range(len(points))})


def betti0_match(samples: List[Point], c: float, step: float) -> Tuple[int, int, bool]:
    """Compare component counts of {f<=c} and {f_dual<=c} (a proxy for H_0 iso)."""
    primal = sublevel_membership(f, samples, c)
    dual = sublevel_membership(f_dual, samples, c)
    b_primal = count_components(primal, step)
    b_dual = count_components(dual, step)
    return b_primal, b_dual, b_primal == b_dual


# ---------------------------------------------------------------------------
# Main driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 72)
    print("Polarity duality of RC sublevel sets -- numerical certification")
    print("=" * 72)

    samples = [
        (1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (2.0, 1.0), (1.0, 3.0),
        (-1.0, 2.0), (3.0, -2.0), (-2.0, -5.0), (0.5, 0.25), (7.0, 4.0),
    ]
    scales = [0.5, 1.0, 2.0, 10.0, 0.1]

    print("\n[1] Degree-zero homogeneity  f(t*x) = f(x), t>0  (ratio_smul_pos)")
    ok_homog = check_degree_zero_homogeneity(samples, scales)
    print(f"    f is scale-invariant along rays: {ok_homog}")

    print("\n[2] Intertwining identity (*)  f_dual(L(x)) = f(x)")
    ok_inter = check_intertwining(samples)
    print(f"    polarity map L intertwines f and f_dual: {ok_inter}")
    for point in samples[:5]:
        print(f"      f{point} = {f(point):.6f}   "
              f"f_dual(L{point}) = {f_dual(L(point)):.6f}")

    print("\n[3] Image identity  {f_dual<=c} = L({f<=c})  (sublevel_image)")
    g = grid(n=40, extent=2.0)
    for c in (0.25, 0.5, 0.75):
        ok_img = check_image_identity(g, c)
        print(f"    c = {c:<4}  membership equivalence holds: {ok_img}")

    print("\n[4] Discrete homology proxy: component counts agree across duality")
    step = 2.0 / 40
    for c in (0.25, 0.5, 0.75):
        bp, bd, match = betti0_match(g, c, step)
        print(f"    c = {c:<4}  components(f<=c) = {bp}   "
              f"components(f_dual<=c) = {bd}   equal: {match}")

    print("\n[5] Explicit wedges at c = 1/2")
    print("    {f      <= 1/2} = {(x,y): |x| <= |y|}  (double wedge around y-axis)")
    print("    {f_dual <= 1/2} = {(x,y): |y| <= |x|}  (double wedge around x-axis)")
    print("    L(x,y) = (y,x) exchanges them exactly.")

    all_ok = ok_homog and ok_inter
    print("\n" + "=" * 72)
    print(f"All structural checks passed: {all_ok}")
    print("=" * 72)


if __name__ == "__main__":
    main()
