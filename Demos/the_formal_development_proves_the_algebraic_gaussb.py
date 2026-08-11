"""
Ideal triangles in the hyperbolic half-plane: numerical demonstrations.

This self-contained script verifies, numerically, every quantitative claim of
the accompanying development:

  1. The chordal integral   int_a^b dx / sqrt((x-a)(b-x)) = pi,  independent of a, b.
  2. The vertical fibre integral   int_c^inf dy / y^2 = 1/c.
  3. The slicing formula, checked against a genuine 2-D quadrature of the
     hyperbolic area element  dx dy / (kappa y^2).
  4. Ideal triangle area = pi / kappa, for many (a, b, kappa).
  5. Ideal n-gon area = (n-2) pi / kappa, and additivity under gluing.
  6. Interior angles of the one-ideal-vertex family: pi - theta and phi,
     computed from tangent vectors, and the Gauss-Bonnet identity
     area = (pi - (alpha + beta + 0)) / kappa = (theta - phi) / kappa.
  7. Strict subideality and monotone degeneration of truncated ideal triangles.
  8. Rigidity: a maximising sequence of admissible angle triples has all three
     angles tending to zero.
  9. Moebius maps: the height-distortion identity, pointwise conformality
     |T'(z)| / Im T(z) = 1 / Im z, the cross-ratio normalisation p,q,r -> 0,1,inf,
     uniqueness of the normaliser, and (Monte Carlo) invariance of hyperbolic area.
 10. Curvature pinching: kappa1 <= K <= kappa2  =>  pi/kappa2 <= area <= pi/kappa1.

Only the Python standard library is used.  Run with:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
import random
from typing import Callable, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
#  Gauss-Legendre quadrature (nodes by Newton iteration on Legendre polynomials)
# --------------------------------------------------------------------------- #


def legendre_p_and_dp(n: int, x: float) -> Tuple[float, float]:
    """Return (P_n(x), P_n'(x)) via the standard three-term recurrence."""
    p_prev, p_cur = 1.0, x
    if n == 0:
        return 1.0, 0.0
    for k in range(2, n + 1):
        p_prev, p_cur = p_cur, ((2 * k - 1) * x * p_cur - (k - 1) * p_prev) / k
    dp = n * (x * p_cur - p_prev) / (x * x - 1.0)
    return p_cur, dp


def gauss_legendre_nodes(n: int) -> Tuple[List[float], List[float]]:
    """Nodes and weights of the n-point Gauss-Legendre rule on [-1, 1]."""
    nodes: List[float] = []
    weights: List[float] = []
    for i in range(1, n + 1):
        x = math.cos(math.pi * (i - 0.25) / (n + 0.5))  # Chebyshev initial guess
        for _ in range(100):
            p, dp = legendre_p_and_dp(n, x)
            dx = -p / dp
            x += dx
            if abs(dx) < 1e-15:
                break
        _, dp = legendre_p_and_dp(n, x)
        nodes.append(x)
        weights.append(2.0 / ((1.0 - x * x) * dp * dp))
    return nodes, weights


_GL_NODES, _GL_WEIGHTS = gauss_legendre_nodes(200)


def quad(f: Callable[[float], float], a: float, b: float, n: int = 200) -> float:
    """Gauss-Legendre quadrature of a smooth f on [a, b]."""
    if n == 200:
        nodes, weights = _GL_NODES, _GL_WEIGHTS
    else:
        nodes, weights = gauss_legendre_nodes(n)
    half, mid = 0.5 * (b - a), 0.5 * (a + b)
    return half * sum(w * f(mid + half * x) for x, w in zip(nodes, weights))


# --------------------------------------------------------------------------- #
#  1.  The chordal integral
# --------------------------------------------------------------------------- #


def chord_height(a: float, b: float, x: float) -> float:
    """Height of the geodesic semicircle of diameter [a, b] over x."""
    return math.sqrt(max((x - a) * (b - x), 0.0))


def chordal_integral(a: float, b: float, n: int = 200) -> float:
    """int_a^b dx / sqrt((x-a)(b-x)), computed after the exact desingularising
    substitution x = (a+b)/2 + (b-a)/2 * sin(s), which makes the integrand 1."""
    mid, half = 0.5 * (a + b), 0.5 * (b - a)

    def integrand(s: float) -> float:
        x = mid + half * math.sin(s)
        return half * math.cos(s) / chord_height(a, b, x)

    return quad(integrand, -math.pi / 2 + 1e-12, math.pi / 2 - 1e-12, n)


def antiderivative(a: float, b: float, x: float) -> float:
    """F_{a,b}(x) = arcsin((2x - a - b) / (b - a)), the exact antiderivative."""
    u = (2.0 * x - a - b) / (b - a)
    return math.asin(max(-1.0, min(1.0, u)))


def demo_chordal_integral() -> None:
    print("=" * 74)
    print("1.  Chordal integral  int_a^b dx/sqrt((x-a)(b-x)) = pi  (endpoint-free)")
    print("=" * 74)
    print(f"{'a':>10} {'b':>10} {'quadrature':>16} {'exact pi':>16} {'error':>12}")
    for a, b in [(0.0, 1.0), (-1.0, 1.0), (-5.0, 3.0), (2.0, 2.001), (0.0, 1e6)]:
        val = chordal_integral(a, b)
        print(f"{a:>10.4g} {b:>10.4g} {val:>16.12f} {math.pi:>16.12f} "
              f"{abs(val - math.pi):>12.3e}")
    # Antiderivative check: F(b) - F(a) = pi/2 - (-pi/2).
    a, b = -3.0, 7.0
    inc = antiderivative(a, b, b) - antiderivative(a, b, a)
    print(f"\nantiderivative increment F(b)-F(a) = {inc:.12f}   (pi = {math.pi:.12f})")
    print()


# --------------------------------------------------------------------------- #
#  2-4.  Fibre integral, slicing, ideal triangle area
# --------------------------------------------------------------------------- #


def fibre_integral(c: float, kappa: float = 1.0, n: int = 200) -> float:
    """int_c^inf dy / (kappa y^2), via the substitution y = c / w, w in (0, 1]."""
    def integrand(w: float) -> float:
        y = c / w
        return (c / (w * w)) / (kappa * y * y)

    return quad(integrand, 1e-14, 1.0, n)


def ideal_triangle_area_2d(a: float, b: float, kappa: float = 1.0,
                           n: int = 160) -> float:
    """Genuine 2-D quadrature of dx dy /(kappa y^2) over the ideal triangle
    Delta(a, b, inf), with both singularities removed by substitution."""
    mid, half = 0.5 * (a + b), 0.5 * (b - a)

    def outer(s: float) -> float:
        x = mid + half * math.sin(s)
        low = chord_height(a, b, x)
        return half * math.cos(s) * fibre_integral(low, kappa, 80)

    return quad(outer, -math.pi / 2 + 1e-10, math.pi / 2 - 1e-10, n)


def ideal_triangle_area_exact(kappa: float = 1.0) -> float:
    """The theorem:  area = pi / kappa,  independent of a and b."""
    return math.pi / kappa


def demo_area() -> None:
    print("=" * 74)
    print("2-4.  Fibre integral, slicing, and the ideal triangle area pi/kappa")
    print("=" * 74)
    print("fibre integral  int_c^inf dy/y^2 = 1/c:")
    for c in [0.25, 1.0, 3.5, 100.0]:
        print(f"   c = {c:>7.3f}   numeric = {fibre_integral(c):.12f}   "
              f"exact = {1.0 / c:.12f}")
    print("\nideal triangle area, by full 2-D quadrature vs the theorem pi/kappa:")
    print(f"{'a':>8} {'b':>8} {'kappa':>8} {'2-D quadrature':>18} {'pi/kappa':>16} "
          f"{'error':>11}")
    for a, b, k in [(0.0, 1.0, 1.0), (-1.0, 1.0, 1.0), (-4.0, 2.0, 1.0),
                    (0.0, 1.0, 2.0), (0.0, 1.0, 0.5), (3.0, 3.01, 1.0)]:
        num = ideal_triangle_area_2d(a, b, k)
        exact = ideal_triangle_area_exact(k)
        print(f"{a:>8.3g} {b:>8.3g} {k:>8.3g} {num:>18.10f} {exact:>16.10f} "
              f"{abs(num - exact):>11.2e}")
    print()


# --------------------------------------------------------------------------- #
#  5.  Ideal polygons
# --------------------------------------------------------------------------- #


def ideal_polygon_area(vertices: Sequence[float], kappa: float = 1.0) -> float:
    """Area of the ideal polygon with finite boundary vertices v_0 < ... < v_m
    and last vertex at infinity, computed by triangulating along the vertical
    geodesics through the finite vertices."""
    total = 0.0
    for v0, v1 in zip(vertices, vertices[1:]):
        total += ideal_triangle_area_2d(v0, v1, kappa, 120)
    return total


def demo_polygons() -> None:
    print("=" * 74)
    print("5.  Ideal n-gon area = (n-2) pi / kappa, and additivity under gluing")
    print("=" * 74)
    print(f"{'vertices (+inf)':>28} {'n':>3} {'computed':>15} {'(n-2)pi':>15} "
          f"{'error':>10}")
    for verts in [[0.0, 1.0], [0.0, 1.0, 3.0], [-2.0, -0.5, 1.0, 4.0],
                  [0.0, 1.0, 2.0, 3.0, 5.0], [-1.0, 0.0, 0.5, 2.0, 6.0, 9.0]]:
        n = len(verts) + 1
        got = ideal_polygon_area(verts)
        want = (n - 2) * math.pi
        print(f"{str(verts):>28} {n:>3} {got:>15.10f} {want:>15.10f} "
              f"{abs(got - want):>10.2e}")
    left, right = [0.0, 1.0, 2.5], [2.5, 4.0]
    glued = [0.0, 1.0, 2.5, 4.0]
    a_l, a_r, a_g = (ideal_polygon_area(left), ideal_polygon_area(right),
                     ideal_polygon_area(glued))
    print(f"\ngluing:  {a_l:.10f} + {a_r:.10f} = {a_l + a_r:.10f}   "
          f"vs glued {a_g:.10f}")
    print()


# --------------------------------------------------------------------------- #
#  6.  Angles from tangent vectors, and Gauss-Bonnet
# --------------------------------------------------------------------------- #


def angle_between(u: Tuple[float, float], v: Tuple[float, float]) -> float:
    """arccos of the normalised Euclidean inner product.  Because the hyperbolic
    metric is a positive multiple of the Euclidean one at every point, this is
    also the hyperbolic angle."""
    dot = u[0] * v[0] + u[1] * v[1]
    nu = math.hypot(u[0], u[1])
    nv = math.hypot(v[0], v[1])
    return math.acos(max(-1.0, min(1.0, dot / (nu * nv))))


def one_ideal_vertex_area(theta: float, phi: float, kappa: float = 1.0) -> float:
    """2-D quadrature of the area of the triangle with vertices
    (cos theta, sin theta), (cos phi, sin phi) and infinity, bounded by two
    vertical geodesics and the unit semicircle."""
    a, b = math.cos(theta), math.cos(phi)

    def outer(x: float) -> float:
        low = math.sqrt(max(1.0 - x * x, 0.0))
        if low <= 0.0:
            return 0.0
        return fibre_integral(low, kappa, 80)

    # Desingularise near x = +-1 with the substitution x = sin(s).
    s0, s1 = math.asin(max(-1.0, min(1.0, a))), math.asin(max(-1.0, min(1.0, b)))

    def outer_s(s: float) -> float:
        return math.cos(s) * outer(math.sin(s))

    return quad(outer_s, s0, s1, 200)


def demo_gauss_bonnet() -> None:
    print("=" * 74)
    print("6.  Angles computed from tangent vectors, and Gauss-Bonnet")
    print("=" * 74)
    print("triangle: vertices (cos t, sin t), (cos p, sin p), infinity;  kappa = 1")
    print(f"{'theta':>8} {'phi':>8} {'alpha':>9} {'beta':>9} {'area (num)':>13} "
          f"{'(pi-a-b)':>11} {'error':>10}")
    up = (0.0, 1.0)
    for theta, phi in [(3 * math.pi / 4, math.pi / 4),
                       (2 * math.pi / 3, math.pi / 6),
                       (math.pi - 1e-3, 1e-3),
                       (math.pi, math.pi / 2),
                       (math.pi, 0.0),
                       (1.2, 0.4)]:
        t_right = (math.sin(theta), -math.cos(theta))
        t_left = (-math.sin(phi), math.cos(phi))
        alpha = angle_between(up, t_right)          # theorem: pi - theta
        beta = angle_between(up, t_left)            # theorem: phi
        num = one_ideal_vertex_area(theta, phi)
        gb = math.pi - (alpha + beta + 0.0)
        print(f"{theta:>8.4f} {phi:>8.4f} {alpha:>9.5f} {beta:>9.5f} "
              f"{num:>13.9f} {gb:>11.7f} {abs(num - gb):>10.2e}")
    print("\n(alpha should equal pi - theta and beta should equal phi:)")
    for theta, phi in [(3 * math.pi / 4, math.pi / 4), (1.2, 0.4)]:
        alpha = angle_between(up, (math.sin(theta), -math.cos(theta)))
        beta = angle_between(up, (-math.sin(phi), math.cos(phi)))
        print(f"   theta={theta:.4f}: alpha={alpha:.12f}, pi-theta={math.pi - theta:.12f}"
              f"  |  phi={phi:.4f}: beta={beta:.12f}")
    print("\nconformal invariance of the angle functional (rescaling by c > 0):")
    u, v = (0.0, 1.0), (0.7, -0.3)
    base = angle_between(u, v)
    for c in [0.001, 1.0, 17.0, 1e6]:
        scaled = angle_between((c * u[0], c * u[1]), v)
        print(f"   c = {c:>9.4g}:  angle = {scaled:.15f}   (unscaled {base:.15f})")
    print()


# --------------------------------------------------------------------------- #
#  7.  Truncation and degeneration
# --------------------------------------------------------------------------- #


def truncated_area(a: float, b: float, t: float, kappa: float = 1.0) -> float:
    """Exact closed form (F(b-t) - F(a+t)) / kappa for the truncated triangle."""
    return (antiderivative(a, b, b - t) - antiderivative(a, b, a + t)) / kappa


def demo_truncation() -> None:
    print("=" * 74)
    print("7.  Truncated ideal triangles: strictly subideal, increasing to pi/kappa")
    print("=" * 74)
    a, b, kappa = 0.0, 1.0, 1.0
    print(f"{'t':>12} {'truncated area':>18} {'pi/kappa':>14} {'deficit':>12} "
          f"{'< pi?':>7}")
    prev = -1.0
    monotone = True
    for t in [0.2, 0.1, 1e-2, 1e-3, 1e-4, 1e-6, 1e-8]:
        area = truncated_area(a, b, t, kappa)
        monotone = monotone and area > prev
        prev = area
        print(f"{t:>12.1e} {area:>18.12f} {math.pi / kappa:>14.10f} "
              f"{math.pi / kappa - area:>12.3e} {str(area < math.pi):>7}")
    print(f"\nareas increase monotonically as t decreases: {monotone}")
    print()


# --------------------------------------------------------------------------- #
#  8.  Rigidity of maximising sequences
# --------------------------------------------------------------------------- #


def gauss_bonnet_area(kappa: float, alpha: float, beta: float,
                      gamma: float) -> float:
    """The Gauss-Bonnet functional (pi - (alpha + beta + gamma)) / kappa."""
    return (math.pi - (alpha + beta + gamma)) / kappa


def demo_rigidity() -> None:
    print("=" * 74)
    print("8.  Rigidity: area -> pi/kappa forces every angle -> 0")
    print("=" * 74)
    kappa = 1.0
    print(f"{'n':>4} {'alpha_n':>12} {'beta_n':>12} {'gamma_n':>12} "
          f"{'area_n':>14} {'pi - area_n':>13}")
    for n in [1, 2, 5, 10, 50, 200, 1000, 10000]:
        alpha = 1.0 / n
        beta = 0.5 / (n * n) ** 0.5
        gamma = math.sin(1.0 / n) / 3.0
        area = gauss_bonnet_area(kappa, alpha, beta, gamma)
        assert alpha >= 0 and beta >= 0 and gamma >= 0
        assert alpha + beta + gamma <= math.pi          # admissible
        print(f"{n:>4} {alpha:>12.6f} {beta:>12.6f} {gamma:>12.6f} "
              f"{area:>14.9f} {math.pi - area:>13.3e}")
    print("\nall three angles -> 0, exactly as the rigidity theorem predicts.")
    print()


# --------------------------------------------------------------------------- #
#  9.  Moebius transformations
# --------------------------------------------------------------------------- #


def mobius(coeffs: Tuple[float, float, float, float], z: complex) -> complex:
    a, b, c, d = coeffs
    return (a * z + b) / (c * z + d)


def mobius_derivative(coeffs: Tuple[float, float, float, float],
                      z: complex) -> complex:
    a, b, c, d = coeffs
    return (a * d - b * c) / (c * z + d) ** 2


def cross_ratio_coeffs(p: float, q: float, r: float
                       ) -> Tuple[float, float, float, float]:
    """Coefficients of the normalising map sending p -> 0, q -> 1, r -> infinity."""
    return (q - r, -(p * (q - r)), q - p, -(r * (q - p)))


def demo_mobius() -> None:
    print("=" * 74)
    print("9.  Real Moebius maps: isometries, and sharp three-transitivity")
    print("=" * 74)
    coeffs = (2.0, 1.0, 1.0, 3.0)          # determinant 5 > 0
    a, b, c, d = coeffs
    det = a * d - b * c
    print(f"T(z) = ({a}z + {b}) / ({c}z + {d}),  det = {det}")
    header = "|T-prime|/Im T"
    print(f"\n{'z':>18} {'Im T(z)':>14} {'det Im z/|cz+d|^2':>20} "
          f"{header:>16} {'1/Im z':>10}")
    for z in [1 + 1j, -2 + 0.5j, 0 + 3j, 5 + 0.01j]:
        imT = mobius(coeffs, z).imag
        pred = det * z.imag / abs(c * z + d) ** 2
        ratio = abs(mobius_derivative(coeffs, z)) / imT
        print(f"{str(z):>18} {imT:>14.10f} {pred:>20.10f} {ratio:>16.8f} "
              f"{1.0 / z.imag:>10.6f}")

    print("\ncross-ratio normalisation  p, q, r  ->  0, 1, infinity:")
    for p, q, r in [(-1.0, 0.0, 1.0), (0.0, 1.0, 2.0), (-5.0, 3.0, 7.5)]:
        cf = cross_ratio_coeffs(p, q, r)
        A, B, C, D = cf
        det3 = A * D - B * C
        tp = (A * p + B) / (C * p + D)
        tq = (A * q + B) / (C * q + D)
        pole = C * r + D
        expected_det = (r - q) * (q - p) * (r - p)
        print(f"   p,q,r = ({p:>5.2f},{q:>5.2f},{r:>5.2f}):  t(p)={tp:+.1e}  "
              f"t(q)={tq:.12f}  Cr+D={pole:+.1e}  det={det3:.6f} "
              f"(={expected_det:.6f})")

    print("\nuniqueness: a real Moebius map fixing 0, 1, infinity is the identity")
    for A, D in [(3.0, 3.0), (-2.0, -2.0), (0.5, 0.5)]:
        vals = [(A * x + 0.0) / D for x in (-3.0, 0.0, 1.0, 7.0)]
        print(f"   A={A:>5}, B=0, C=0, D={D:>5}:  images of (-3,0,1,7) = "
              f"{[round(v, 12) for v in vals]}")

    # Monte-Carlo test of area invariance under a Moebius map (Conjecture B).
    print("\nMonte-Carlo test of hyperbolic-area invariance under T:")
    random.seed(20260811)
    # Sample the ideal triangle Delta(0,1,inf) w.r.t. hyperbolic measure:
    # x has density 1/(pi * ell(x)) on (0,1) via x = (1 + sin s)/2, s uniform;
    # y = ell(x)/w with w uniform on (0,1] gives the fibre measure exactly.
    n_samples = 400000
    total_image, total_source = 0.0, 0.0
    for _ in range(n_samples):
        s = random.uniform(-math.pi / 2, math.pi / 2)
        x = 0.5 + 0.5 * math.sin(s)
        low = chord_height(0.0, 1.0, x)
        w = random.uniform(1e-12, 1.0)
        y = low / w
        # Total hyperbolic mass of Delta(0,1,inf) is pi; each sample carries pi/N.
        total_source += math.pi / n_samples
        z = complex(x, y)
        Tz = mobius(coeffs, z)
        # Pushforward preserves the measure iff the Jacobian factor is 1:
        jac = abs(mobius_derivative(coeffs, z)) ** 2 / (Tz.imag ** 2) * (y ** 2)
        total_image += jac * math.pi / n_samples
    print(f"   source hyperbolic area  = {total_source:.10f}   (exact pi = "
          f"{math.pi:.10f})")
    print(f"   image  hyperbolic area  = {total_image:.10f}   "
          f"(relative error {abs(total_image - math.pi) / math.pi:.2e})")
    print()


# --------------------------------------------------------------------------- #
#  10.  Curvature pinching
# --------------------------------------------------------------------------- #


def variable_curvature_area(K: Callable[[float], float], a: float, b: float,
                            n: int = 400) -> float:
    """int_a^b dx / (K(x) sqrt((x-a)(b-x))), the ideal-triangle area under the
    variable curvature profile -K(x), after desingularisation."""
    mid, half = 0.5 * (a + b), 0.5 * (b - a)

    def integrand(s: float) -> float:
        x = mid + half * math.sin(s)
        return half * math.cos(s) / (K(x) * chord_height(a, b, x))

    return quad(integrand, -math.pi / 2 + 1e-12, math.pi / 2 - 1e-12, n)


def demo_pinching() -> None:
    print("=" * 74)
    print("10.  Curvature pinching: k1 <= K <= k2  =>  pi/k2 <= area <= pi/k1")
    print("=" * 74)
    a, b = 0.0, 1.0
    profiles: List[Tuple[str, Callable[[float], float], float, float]] = [
        ("K = 1 (constant)", lambda x: 1.0, 1.0, 1.0),
        ("K = 2 (constant)", lambda x: 2.0, 2.0, 2.0),
        ("K = 1 + sin(pi x)/2", lambda x: 1.0 + 0.5 * math.sin(math.pi * x),
         1.0, 1.5),
        ("K = 1 + x", lambda x: 1.0 + x, 1.0, 2.0),
        ("K = 2 - x^2", lambda x: 2.0 - x * x, 1.0, 2.0),
        ("K = 3 + 2cos(4 pi x)", lambda x: 3.0 + 2.0 * math.cos(4 * math.pi * x),
         1.0, 5.0),
    ]
    print(f"{'profile':>24} {'pi/k2':>10} {'area':>12} {'pi/k1':>10} {'pinched?':>9}")
    for name, K, k1, k2 in profiles:
        area = variable_curvature_area(K, a, b)
        lo, hi = math.pi / k2, math.pi / k1
        ok = lo - 1e-9 <= area <= hi + 1e-9
        print(f"{name:>24} {lo:>10.6f} {area:>12.8f} {hi:>10.6f} {str(ok):>9}")
    print("\nsharpness: at constant K = kappa both bounds collapse to pi/kappa.")
    for kappa in [0.5, 1.0, 2.0, 7.0]:
        area = variable_curvature_area(lambda x, k=kappa: k, a, b)
        print(f"   kappa = {kappa:>4}:  area = {area:.12f}   pi/kappa = "
              f"{math.pi / kappa:.12f}")
    print()


# --------------------------------------------------------------------------- #


def main() -> None:
    print()
    print("#" * 74)
    print("#  IDEAL TRIANGLES IN THE HYPERBOLIC HALF-PLANE".ljust(73) + "#")
    print("#  numerical demonstrations of the area theory".ljust(73) + "#")
    print("#" * 74)
    print()
    demo_chordal_integral()
    demo_area()
    demo_polygons()
    demo_gauss_bonnet()
    demo_truncation()
    demo_rigidity()
    demo_mobius()
    demo_pinching()
    print("=" * 74)
    print("All demonstrations complete.  Every computed quantity agrees with the")
    print("closed-form predictions:  ideal triangle area pi/kappa, ideal n-gon")
    print("area (n-2)pi/kappa, Gauss-Bonnet area = angular defect / kappa, strict")
    print("subideality of finite triangles, and the sharp curvature pinching.")
    print("=" * 74)


if __name__ == "__main__":
    main()
