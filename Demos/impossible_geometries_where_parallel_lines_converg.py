"""
Split Geometry: numerical demonstrations.

Split Geometry is the Riemannian metric on R^2 given by

    ds^2 = dx^2 / cosh^2(y) + cosh^2(x) dy^2,

with coefficient functions E(y) = sech^2(y) (horizontal, expanding) and
G(x) = cosh^2(x) (vertical, contracting). Its sign-indicator curvature is

    K(x, y) = sech^2(x) - sech^2(y).

This script demonstrates, with concrete numbers, the main results:
  1. The metric is positive-definite everywhere (consistency).
  2. sech^2 is strictly decreasing in |t| (the monotonicity engine).
  3. K = 0 exactly on the diagonals y = +/- x (the phase boundary).
  4. K > 0 where |x| < |y| (elliptic), K < 0 where |y| < |x| (hyperbolic).
  5. A straight coordinate line not parallel to a diagonal crosses the
     phase boundary at most twice (roots of a quadratic in the parameter).
  6. The metric area density is cosh(x) / cosh(y); area of a rectangle in
     closed form and of a split triangle by quadrature.

Only the Python standard library is used.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------
# Core functions
# --------------------------------------------------------------------------

def sech2(t: float) -> float:
    """sech^2(t) = 1 / cosh^2(t), always in (0, 1]."""
    return 1.0 / math.cosh(t) ** 2


def metric_coeff_E(y: float) -> float:
    """Horizontal (x-x) coefficient E(y) = sech^2(y)."""
    return sech2(y)


def metric_coeff_G(x: float) -> float:
    """Vertical (y-y) coefficient G(x) = cosh^2(x)."""
    return math.cosh(x) ** 2


def metric_norm_sq(x: float, y: float, u: float, v: float) -> float:
    """Squared length of tangent vector (u, v) at the point (x, y)."""
    return metric_coeff_E(y) * u ** 2 + metric_coeff_G(x) * v ** 2


def K(x: float, y: float) -> float:
    """Sign-indicator curvature K(x, y) = sech^2(x) - sech^2(y)."""
    return sech2(x) - sech2(y)


def area_density(x: float, y: float) -> float:
    """Riemannian area density sqrt(E G) = cosh(x) / cosh(y)."""
    return math.cosh(x) / math.cosh(y)


def gudermannian(y: float) -> float:
    """Gudermannian gd(y) = 2*arctan(e^y) - pi/2, an antiderivative of sech."""
    return 2.0 * math.atan(math.exp(y)) - math.pi / 2.0


# --------------------------------------------------------------------------
# 1. Consistency: positive-definiteness
# --------------------------------------------------------------------------

def demo_positive_definite() -> None:
    print("=" * 68)
    print("1. Consistency: metric is positive-definite (norm^2 > 0)")
    print("=" * 68)
    samples: List[Tuple[float, float, float, float]] = [
        (0.0, 0.0, 1.0, 0.0),
        (2.0, -1.5, 0.0, 1.0),
        (-3.0, 2.0, 1.0, -1.0),
        (5.0, 5.0, 0.3, -0.7),
    ]
    for x, y, u, v in samples:
        val = metric_norm_sq(x, y, u, v)
        flag = "OK" if val > 0 else "FAIL"
        print(f"  (x,y)=({x:+.1f},{y:+.1f}) v=({u:+.1f},{v:+.1f}) "
              f"|v|^2 = {val:.6f}  [{flag}]")
    print()


# --------------------------------------------------------------------------
# 2. Monotonicity of sech^2 in |t|
# --------------------------------------------------------------------------

def demo_monotonicity() -> None:
    print("=" * 68)
    print("2. Monotonicity: sech^2(a) < sech^2(b)  <=>  |b| < |a|")
    print("=" * 68)
    pairs: List[Tuple[float, float]] = [(1.0, 2.0), (-3.0, 0.5), (2.0, -2.0)]
    for a, b in pairs:
        lhs = sech2(a) < sech2(b)
        rhs = abs(b) < abs(a)
        print(f"  a={a:+.1f}, b={b:+.1f}: sech2(a)={sech2(a):.5f}, "
              f"sech2(b)={sech2(b):.5f}  |  "
              f"[sech2(a)<sech2(b)]={lhs}  [|b|<|a|]={rhs}  "
              f"agree={lhs == rhs}")
    print()


# --------------------------------------------------------------------------
# 3 & 4. Phase boundary and sign of K
# --------------------------------------------------------------------------

def classify(x: float, y: float, tol: float = 1e-12) -> str:
    k = K(x, y)
    if abs(k) <= tol:
        return "boundary (flat)"
    return "elliptic (K>0)" if k > 0 else "hyperbolic (K<0)"


def demo_phase_structure() -> None:
    print("=" * 68)
    print("3-4. Phase boundary y = +/- x and the sign of K")
    print("=" * 68)
    points: List[Tuple[float, float]] = [
        (0.0, 2.0),   # |x|<|y| -> elliptic
        (2.0, 0.0),   # |y|<|x| -> hyperbolic
        (3.0, 3.0),   # on diagonal y = x
        (2.0, -2.0),  # on diagonal y = -x
        (1.0, 4.0),   # elliptic
        (4.0, -1.0),  # hyperbolic
    ]
    for x, y in points:
        print(f"  (x,y)=({x:+.1f},{y:+.1f}): K={K(x, y):+.6f}  "
              f"-> {classify(x, y)}")
    print()


# --------------------------------------------------------------------------
# 5. Crossing the phase boundary at most twice
# --------------------------------------------------------------------------

def boundary_crossings(a: float, b: float, x0: float, y0: float
                       ) -> List[float]:
    """Return the parameters t at which the line (x0+ta, y0+tb) satisfies
    x^2 = y^2, i.e. the roots of (a^2-b^2)t^2 + 2(x0 a - y0 b)t + (x0^2-y0^2).
    Returns at most two values when a^2 != b^2."""
    A = a ** 2 - b ** 2
    B = 2.0 * (x0 * a - y0 * b)
    C = x0 ** 2 - y0 ** 2
    if abs(A) < 1e-15:  # line parallel to a diagonal: degenerate
        if abs(B) < 1e-15:
            return []  # no finite crossings (or the whole line)
        return [-C / B]
    disc = B * B - 4.0 * A * C
    if disc < 0:
        return []
    sqrt_d = math.sqrt(disc)
    return sorted({(-B + sqrt_d) / (2 * A), (-B - sqrt_d) / (2 * A)})


def demo_crossings() -> None:
    print("=" * 68)
    print("5. A generic line (a^2 != b^2) crosses the boundary at most twice")
    print("=" * 68)
    lines: List[Tuple[float, float, float, float]] = [
        (1.0, 0.3, -2.0, 0.5),
        (0.5, 2.0, 1.0, -3.0),
        (2.0, 0.0, 0.0, 1.0),
    ]
    for a, b, x0, y0 in lines:
        ts = boundary_crossings(a, b, x0, y0)
        print(f"  line (x0,y0)=({x0:+.1f},{y0:+.1f}) dir=({a:+.1f},{b:+.1f}): "
              f"{len(ts)} crossing(s) at t={[round(t, 4) for t in ts]}")
        for t in ts:
            x, y = x0 + t * a, y0 + t * b
            print(f"      t={t:+.4f} -> (x,y)=({x:+.4f},{y:+.4f}), "
                  f"x^2-y^2={x*x - y*y:+.2e}")
    print()


# --------------------------------------------------------------------------
# 6. Metric area
# --------------------------------------------------------------------------

def rectangle_area_closed_form(x1: float, x2: float,
                               y1: float, y2: float) -> float:
    """Exact metric area of [x1,x2] x [y1,y2] using
    (sinh x2 - sinh x1)(gd y2 - gd y1)."""
    return ((math.sinh(x2) - math.sinh(x1))
            * (gudermannian(y2) - gudermannian(y1)))


def rectangle_area_quadrature(x1: float, x2: float, y1: float, y2: float,
                              n: int = 400) -> float:
    """Midpoint-rule metric area of the rectangle for cross-checking."""
    dx = (x2 - x1) / n
    dy = (y2 - y1) / n
    total = 0.0
    for i in range(n):
        xc = x1 + (i + 0.5) * dx
        for j in range(n):
            yc = y1 + (j + 0.5) * dy
            total += area_density(xc, yc)
    return total * dx * dy


def triangle_area_quadrature(p1: Tuple[float, float],
                             p2: Tuple[float, float],
                             p3: Tuple[float, float],
                             n: int = 400) -> float:
    """Metric area of the triangle p1 p2 p3 by barycentric quadrature."""
    (x1, y1), (x2, y2), (x3, y3) = p1, p2, p3
    # Euclidean triangle area for the Jacobian of the barycentric map.
    euclid = 0.5 * abs((x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1))
    total = 0.0
    count = 0
    for i in range(n):
        for j in range(n - i):
            s = (i + 1.0 / 3.0) / n
            t = (j + 1.0 / 3.0) / n
            u = 1.0 - s - t
            if u < 0:
                continue
            x = s * x1 + t * x2 + u * x3
            y = s * y1 + t * y2 + u * y3
            total += area_density(x, y)
            count += 1
    return total / count * euclid if count else 0.0


def demo_area() -> None:
    print("=" * 68)
    print("6. Metric area: density cosh(x)/cosh(y)")
    print("=" * 68)
    x1, x2, y1, y2 = 0.0, 1.0, 0.0, 1.0
    exact = rectangle_area_closed_form(x1, x2, y1, y2)
    approx = rectangle_area_quadrature(x1, x2, y1, y2, n=300)
    print(f"  Rectangle [0,1]x[0,1]: closed form = {exact:.6f}, "
          f"quadrature = {approx:.6f}")
    # Split triangle: one vertex per phase and one on the boundary.
    p_ell = (0.0, 2.0)   # elliptic (|x|<|y|)
    p_hyp = (2.0, 0.0)   # hyperbolic (|y|<|x|)
    p_bnd = (-1.5, 1.5)  # on the diagonal y = -x
    area_tri = triangle_area_quadrature(p_ell, p_hyp, p_bnd, n=300)
    print(f"  Split triangle {p_ell},{p_hyp},{p_bnd}:")
    print(f"      one vertex elliptic, one hyperbolic, one on the boundary")
    print(f"      metric area = {area_tri:.6f}")
    print()


def main() -> None:
    demo_positive_definite()
    demo_monotonicity()
    demo_phase_structure()
    demo_crossings()
    demo_area()


if __name__ == "__main__":
    main()
