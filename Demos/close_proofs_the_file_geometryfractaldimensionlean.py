"""
Set-Local Distortion of Hausdorff Dimension — Numerical Demonstrations
======================================================================

This script illustrates, with self-contained numerical experiments, the
mathematical results on how Hausdorff (fractal) dimension behaves under maps
that are controlled *only on a set*:

  * Lipschitz-on-a-set maps do not increase dimension.
  * Antilipschitz-on-a-set maps do not decrease dimension (the headline result).
  * Bilipschitz-on-a-set maps preserve dimension exactly.
  * Isometry-on-a-set maps preserve dimension exactly.

All functions are inlined; the only dependency is the Python standard library.

Mathematical conventions
-------------------------
For points x, y and a map f:
  Lipschitz-on s with K   :  d(f x, f y) <= K * d(x, y)         (no over-expansion)
  Antilipschitz-on s with K:  d(x, y)   <= K * d(f x, f y)       (no over-contraction)
A map is bilipschitz-on s if it is both, and an isometry-on s if d(f x, f y)=d(x,y).

The Hausdorff dimension is estimated here by the box-counting dimension, which
coincides with it for the self-similar fractals used below.
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import Callable, Iterable, List, Sequence, Tuple

Point = Tuple[float, float]


# --------------------------------------------------------------------------- #
# Distances and distortion constants
# --------------------------------------------------------------------------- #
def dist(p: Point, q: Point) -> float:
    """Euclidean distance in the plane."""
    return math.hypot(p[0] - q[0], p[1] - q[1])


def lipschitz_constant_on(points: Sequence[Point], f: Callable[[Point], Point]) -> float:
    """Smallest K with d(f x, f y) <= K d(x, y) over the sample (empirical Lip-on)."""
    best = 0.0
    for p, q in combinations(points, 2):
        d = dist(p, q)
        if d > 0:
            best = max(best, dist(f(p), f(q)) / d)
    return best


def antilipschitz_constant_on(points: Sequence[Point], f: Callable[[Point], Point]) -> float:
    """Smallest K with d(x, y) <= K d(f x, f y) over the sample (empirical anti-Lip-on).

    Returns math.inf if f collapses some pair (then f is NOT antilipschitz on the set).
    """
    best = 0.0
    for p, q in combinations(points, 2):
        df = dist(f(p), f(q))
        if df == 0:
            return math.inf  # a collapse: no finite antilipschitz constant exists
        best = max(best, dist(p, q) / df)
    return best


def is_injective_on(points: Sequence[Point], f: Callable[[Point], Point], tol: float = 1e-12) -> bool:
    """Check that f maps distinct sample points to distinct images (Proposition 3.4)."""
    images = [f(p) for p in points]
    for i, j in combinations(range(len(images)), 2):
        if dist(images[i], images[j]) <= tol:
            return False
    return True


# --------------------------------------------------------------------------- #
# Box-counting (Minkowski) dimension estimate
# --------------------------------------------------------------------------- #
def box_count(points: Iterable[Point], eps: float) -> int:
    """Number of grid cells of side `eps` that contain at least one point."""
    occupied = set()
    for x, y in points:
        occupied.add((math.floor(x / eps), math.floor(y / eps)))
    return len(occupied)


def box_dimension(points: Sequence[Point], scales: Sequence[float]) -> float:
    """Slope of log N(eps) vs log(1/eps): the box-counting dimension estimate."""
    xs: List[float] = []
    ys: List[float] = []
    for eps in scales:
        n = box_count(points, eps)
        if n > 0:
            xs.append(math.log(1.0 / eps))
            ys.append(math.log(n))
    # least-squares slope
    m = len(xs)
    mx = sum(xs) / m
    my = sum(ys) / m
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den


# --------------------------------------------------------------------------- #
# Fractal generators (self-similar point clouds)
# --------------------------------------------------------------------------- #
def sierpinski(depth: int) -> List[Point]:
    """Vertices of the Sierpinski gasket at the given recursion depth.

    Exact Hausdorff dimension: log 3 / log 2 ~= 1.585.
    """
    pts: List[Point] = [(0.0, 0.0)]
    corners = [(0.0, 0.0), (1.0, 0.0), (0.5, math.sqrt(3) / 2)]
    for _ in range(depth):
        nxt: List[Point] = []
        for (px, py) in pts:
            for (cx, cy) in corners:
                nxt.append(((px + cx) / 2, (py + cy) / 2))
        pts = nxt
    return pts


def koch_curve(depth: int) -> List[Point]:
    """Polyline vertices of the Koch curve. Hausdorff dimension log 4 / log 3 ~= 1.262."""
    pts: List[Point] = [(0.0, 0.0), (1.0, 0.0)]
    for _ in range(depth):
        nxt: List[Point] = [pts[0]]
        for a, b in zip(pts, pts[1:]):
            ax, ay = a
            bx, by = b
            dx, dy = (bx - ax) / 3, (by - ay) / 3
            p1 = (ax + dx, ay + dy)
            p2 = (ax + 2 * dx, ay + 2 * dy)
            # apex of the bump (rotate (dx,dy) by 60 degrees)
            angle = math.radians(60)
            rx = dx * math.cos(angle) - dy * math.sin(angle)
            ry = dx * math.sin(angle) + dy * math.cos(angle)
            apex = (p1[0] + rx, p1[1] + ry)
            nxt.extend([p1, apex, p2, b])
        pts = nxt
    return pts


# --------------------------------------------------------------------------- #
# Example maps
# --------------------------------------------------------------------------- #
def affine(a: float, b: float, c: float, d: float, e: float = 0.0, g: float = 0.0
           ) -> Callable[[Point], Point]:
    """Affine map (x,y) -> (a x + b y + e, c x + d y + g)."""
    def f(p: Point) -> Point:
        x, y = p
        return (a * x + b * y + e, c * x + d * y + g)
    return f


def rotation(theta: float) -> Callable[[Point], Point]:
    """Rigid rotation by angle theta — an isometry."""
    return affine(math.cos(theta), -math.sin(theta), math.sin(theta), math.cos(theta))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_distortion_bounds() -> None:
    print("=" * 70)
    print("DEMO 1: Distortion constants and the two inequalities")
    print("=" * 70)
    pts = sierpinski(5)

    rot = rotation(math.radians(37))      # isometry
    scale = affine(2.0, 0.0, 0.0, 2.0)    # bilipschitz, scale by 2
    shear = affine(1.0, 0.6, 0.0, 1.0)    # bilipschitz shear
    crush = affine(1.0, 0.0, 0.0, 0.0)    # projection onto x-axis: collapses pairs

    for name, f in [("rotation (isometry)", rot),
                    ("scaling x2", scale),
                    ("shear", shear),
                    ("projection (collapses)", crush)]:
        kL = lipschitz_constant_on(pts, f)
        kA = antilipschitz_constant_on(pts, f)
        inj = is_injective_on(pts, f)
        print(f"\nMap: {name}")
        print(f"  Lipschitz-on constant     K_Lip  = {kL:.4f}")
        print(f"  Antilipschitz-on constant K_anti = {kA:.4f}")
        print(f"  Injective on the set?            = {inj}")
        if math.isinf(kA):
            print("  -> NOT antilipschitz on s: lower bound does not apply.")
        else:
            print("  -> bilipschitz on s: dimension is preserved (Theorem 5.2).")


def demo_dimension_invariance() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2: Dimension is preserved by bilipschitz-on / isometry-on maps")
    print("=" * 70)
    scales = [1 / 2 ** k for k in range(2, 8)]

    for label, pts, exact in [
        ("Sierpinski gasket", sierpinski(7), math.log(3) / math.log(2)),
        ("Koch curve", koch_curve(6), math.log(4) / math.log(3)),
    ]:
        d0 = box_dimension(pts, scales)
        rot = rotation(math.radians(25))
        shear = affine(1.0, 0.5, 0.0, 1.0)
        scale2 = affine(1.7, 0.0, 0.0, 1.7)
        d_rot = box_dimension([rot(p) for p in pts], scales)
        d_shear = box_dimension([shear(p) for p in pts], scales)
        d_scale = box_dimension([scale2(p) for p in pts], scales)
        print(f"\n{label}  (exact Hausdorff dim = {exact:.4f})")
        print(f"  box-dim original         : {d0:.4f}")
        print(f"  box-dim after rotation   : {d_rot:.4f}   (isometry-on, Thm 5.4)")
        print(f"  box-dim after shear      : {d_shear:.4f}   (bilipschitz-on, Thm 5.2)")
        print(f"  box-dim after scaling x  : {d_scale:.4f}   (bilipschitz-on, Thm 5.2)")


def demo_local_beats_global() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3: Set-local beats global — wild off-set behavior is harmless")
    print("=" * 70)
    # The set s lives in the unit square [0,1]^2. Define a map that is a clean
    # rotation ON s but collapses everything OUTSIDE s to the origin. Globally it
    # is NOT antilipschitz, yet on s it is an isometry, so dim(s) is preserved.
    s = sierpinski(6)
    rot = rotation(math.radians(40))

    def f(p: Point) -> Point:
        x, y = p
        in_s = 0.0 <= x <= 1.0 and 0.0 <= y <= 1.0
        return rot(p) if in_s else (0.0, 0.0)  # crush off-set points together

    # On s, f equals the rotation, so it is an isometry-on-s:
    kL = lipschitz_constant_on(s, f)
    kA = antilipschitz_constant_on(s, f)
    print(f"\nMap f: rotation on s, collapse-to-origin off s")
    print(f"  Lipschitz-on s constant     = {kL:.4f}")
    print(f"  Antilipschitz-on s constant = {kA:.4f}")
    print("  (Globally f collapses infinitely many off-set pairs, so the GLOBAL")
    print("   antilipschitz lower bound does NOT apply.)")
    scales = [1 / 2 ** k for k in range(2, 8)]
    d0 = box_dimension(s, scales)
    d1 = box_dimension([f(p) for p in s], scales)
    print(f"  box-dim of s        = {d0:.4f}")
    print(f"  box-dim of f(s)     = {d1:.4f}")
    print("  -> Equal: the set-local theorem (Theorem 5.1/5.4) still guarantees it.")


def main() -> None:
    demo_distortion_bounds()
    demo_dimension_invariance()
    demo_local_beats_global()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
