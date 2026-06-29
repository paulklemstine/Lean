"""
Numerical demonstrations for:

    Quasi-Symmetric Gauges, the Bi-Lipschitz Monoid,
    and Hausdorff-Dimension Invariance.

This script is fully self-contained (standard library only). It illustrates,
with concrete numbers, the main results of the accompanying paper:

  * Theorem 3.1  Bi-Lipschitz => quasi-symmetric with linear gauge eta(t) = L^2 t.
  * Theorem 4.1  Gauge enlargement (monotonicity in the gauge).
  * Theorem 4.2  Single-scale eccentricity bound  dist(fx,fa) <= eta(1) dist(fx,fb).
  * Theorem 4.3  Composition law: gauges compose as eta_g . eta_f.
  * Theorem 4.4  Iteration law: the n-fold iterate has gauge eta^[n].
  * Theorem 5.1  Bi-Lipschitz composition multiplies constants  (L, M) -> L*M.
  * Theorem 5.2  Identity is 1-bi-Lipschitz.
  * Theorem 6.1  Bi-Lipschitz maps preserve Hausdorff dimension (box-counting check).

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

Point = Tuple[float, float]
Gauge = Callable[[float], float]


# --------------------------------------------------------------------------- #
# Basic metric helpers                                                        #
# --------------------------------------------------------------------------- #
def dist(p: Point, q: Point) -> float:
    """Euclidean distance in the plane."""
    return math.hypot(p[0] - q[0], p[1] - q[1])


# --------------------------------------------------------------------------- #
# Theorem 3.1 : the linear gauge of a bi-Lipschitz map                        #
# --------------------------------------------------------------------------- #
def linear_gauge(L: float) -> Gauge:
    """Return the certified quasi-symmetric gauge eta(t) = L^2 * t of an
    L-bi-Lipschitz map (Theorem 3.1)."""
    return lambda t: (L ** 2) * t


def check_quasisymmetric_inequality(
    f: Callable[[Point], Point],
    eta: Gauge,
    triples: Sequence[Tuple[Point, Point, Point]],
    tol: float = 1e-9,
) -> bool:
    """Verify the defining QS inequality
        dist(fx,fa) <= eta(dist(x,a)/dist(x,b)) * dist(fx,fb)
    over a list of triples (x, a, b) with x != b."""
    ok = True
    for x, a, b in triples:
        if dist(x, b) == 0.0:
            continue
        lhs = dist(f(x), f(a))
        ratio = dist(x, a) / dist(x, b)
        rhs = eta(ratio) * dist(f(x), f(b))
        if lhs > rhs + tol:
            ok = False
    return ok


# --------------------------------------------------------------------------- #
# Theorem 4.3 / 4.4 : gauge composition and iteration                         #
# --------------------------------------------------------------------------- #
def compose_gauges(eta_g: Gauge, eta_f: Gauge) -> Gauge:
    """Composition law (Theorem 4.3): the gauge of g . f is eta_g . eta_f."""
    return lambda t: eta_g(eta_f(t))


def iterate_gauge(eta: Gauge, n: int) -> Gauge:
    """Iteration law (Theorem 4.4): gauge of f^[n] is eta^[n]."""
    def g(t: float) -> float:
        out = t
        for _ in range(n):
            out = eta(out)
        return out
    return g


# --------------------------------------------------------------------------- #
# Theorem 4.2 : single-scale eccentricity                                     #
# --------------------------------------------------------------------------- #
def eccentricity_bound(eta: Gauge) -> float:
    """The single number eta(1) bounding how much equidistant points spread."""
    return eta(1.0)


# --------------------------------------------------------------------------- #
# Theorem 5.1 / 5.2 : the bi-Lipschitz monoid                                 #
# --------------------------------------------------------------------------- #
def bilipschitz_compose_constant(L: float, M: float) -> float:
    """Composition multiplies constants (Theorem 5.1)."""
    return L * M


def bilipschitz_identity_constant() -> float:
    """Identity is 1-bi-Lipschitz (Theorem 5.2)."""
    return 1.0


def is_bilipschitz(
    f: Callable[[Point], Point],
    L: float,
    points: Sequence[Point],
    tol: float = 1e-9,
) -> bool:
    """Empirically test that f satisfies  L^-1 d <= d(f) <= L d  on all pairs."""
    ok = True
    for i in range(len(points)):
        for j in range(len(points)):
            if i == j:
                continue
            d = dist(points[i], points[j])
            df = dist(f(points[i]), f(points[j]))
            if df > L * d + tol or df < (1.0 / L) * d - tol:
                ok = False
    return ok


# --------------------------------------------------------------------------- #
# Theorem 6.1 : box-counting Hausdorff-dimension invariance                   #
# --------------------------------------------------------------------------- #
def cantor_points(depth: int) -> List[float]:
    """Endpoints of the middle-thirds Cantor set at the given construction depth.
    dimH = log 2 / log 3 ~ 0.6309."""
    intervals: List[Tuple[float, float]] = [(0.0, 1.0)]
    for _ in range(depth):
        nxt: List[Tuple[float, float]] = []
        for a, b in intervals:
            third = (b - a) / 3.0
            nxt.append((a, a + third))
            nxt.append((b - third, b))
        intervals = nxt
    pts: List[float] = []
    for a, b in intervals:
        pts.append(a)
        pts.append(b)
    return pts


def box_count_dimension_1d(points: Sequence[float], scales: Sequence[float]) -> float:
    """Box-counting dimension estimate of a 1-D point set: slope of
    log N(eps) versus log(1/eps) by least squares."""
    xs: List[float] = []
    ys: List[float] = []
    for eps in scales:
        occupied = {math.floor(p / eps) for p in points}
        n = len(occupied)
        if n <= 0:
            continue
        xs.append(math.log(1.0 / eps))
        ys.append(math.log(n))
    # least-squares slope
    m = len(xs)
    sx = sum(xs)
    sy = sum(ys)
    sxx = sum(x * x for x in xs)
    sxy = sum(x * y for x, y in zip(xs, ys))
    denom = m * sxx - sx * sx
    return (m * sxy - sx * sy) / denom if denom != 0 else float("nan")


def affine_1d(scale: float, shift: float) -> Callable[[float], float]:
    """An affine map x -> scale*x + shift. For scale != 0 it is bi-Lipschitz
    with constant L = max(|scale|, 1/|scale|)."""
    return lambda x: scale * x + shift


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_linear_gauge() -> None:
    print("=" * 70)
    print("Theorem 3.1  Bi-Lipschitz => quasi-symmetric with gauge eta(t)=L^2 t")
    print("=" * 70)
    # An L-bi-Lipschitz map of the plane: anisotropic scaling by (2, 1).
    # Distances scale by a factor in [1, 2], so L = 2.
    L = 2.0
    f: Callable[[Point], Point] = lambda p: (2.0 * p[0], 1.0 * p[1])
    eta = linear_gauge(L)
    triples = [
        ((0.0, 0.0), (1.0, 0.0), (0.0, 1.0)),
        ((0.0, 0.0), (0.0, 1.0), (1.0, 0.0)),
        ((1.0, 1.0), (3.0, 0.0), (0.0, 2.0)),
        ((-1.0, 2.0), (2.0, 2.0), (1.0, -1.0)),
    ]
    ok = check_quasisymmetric_inequality(f, eta, triples)
    print(f"  map = (x,y) -> (2x, y),  L = {L},  gauge eta(t) = {L**2} * t")
    print(f"  QS inequality holds on all sampled triples: {ok}")
    print()


def demo_gauge_calculus() -> None:
    print("=" * 70)
    print("Theorems 4.1-4.4  Gauge calculus")
    print("=" * 70)
    eta = linear_gauge(1.5)  # eta(t) = 2.25 t

    # 4.1 enlargement
    eta_bigger: Gauge = lambda t: 3.0 * t
    sample = [0.25, 0.5, 1.0, 2.0, 4.0]
    enlarges = all(eta(t) <= eta_bigger(t) + 1e-12 for t in sample)
    print(f"  4.1 enlargement: eta(t)=2.25t dominated by 3t ?  {enlarges}")

    # 4.2 eccentricity
    print(f"  4.2 eccentricity constant eta(1) = {eccentricity_bound(eta):.4f}")

    # 4.3 composition
    eta_f = linear_gauge(1.5)   # 2.25 t
    eta_g = linear_gauge(2.0)   # 4 t
    comp = compose_gauges(eta_g, eta_f)
    # for linear gauges, composing gives product of slopes: 4 * 2.25 = 9
    print(f"  4.3 composition of gauges at t=1: {comp(1.0):.4f}  (= 4 * 2.25 = 9)")

    # 4.4 iteration of eta(t) = 2.25 t : eta^[n](1) = 2.25^n
    for n in range(0, 5):
        it = iterate_gauge(eta, n)
        print(f"      4.4 eta^[{n}](1) = {it(1.0):.4f}   (= 2.25^{n} = {2.25**n:.4f})")
    print()


def demo_monoid() -> None:
    print("=" * 70)
    print("Theorems 5.1-5.2  The bi-Lipschitz monoid")
    print("=" * 70)
    L, M = 2.0, 3.0
    print(f"  5.1 compose L={L}, M={M}  ->  constant L*M = {bilipschitz_compose_constant(L, M)}")
    print(f"  5.2 identity constant = {bilipschitz_identity_constant()}")
    # empirical check of g . f with f scale (2,1), g scale (3,1), combined L = 6
    f: Callable[[Point], Point] = lambda p: (2.0 * p[0], p[1])
    g: Callable[[Point], Point] = lambda p: (3.0 * p[0], p[1])
    gf: Callable[[Point], Point] = lambda p: g(f(p))
    pts: List[Point] = [(0, 0), (1, 0), (0, 1), (1, 1), (2, 3), (-1, 2)]
    print(f"  composite g.f is 6-bi-Lipschitz on samples: {is_bilipschitz(gf, 6.0, pts)}")
    print()


def demo_dimension_invariance() -> None:
    print("=" * 70)
    print("Theorem 6.1  Bi-Lipschitz maps preserve Hausdorff dimension")
    print("=" * 70)
    depth = 8
    pts = cantor_points(depth)
    scales = [3.0 ** (-k) for k in range(1, depth + 1)]
    true_dim = math.log(2) / math.log(3)

    est_before = box_count_dimension_1d(pts, scales)

    # Apply a bi-Lipschitz affine map x -> 2.7 x - 4.0.
    # |scale| = 2.7 => bi-Lipschitz with L = 2.7; distances scale exactly by 2.7.
    phi = affine_1d(2.7, -4.0)
    pts_img = [phi(x) for x in pts]
    scales_img = [2.7 * s for s in scales]  # match the rescaled geometry
    est_after = box_count_dimension_1d(pts_img, scales_img)

    print(f"  Cantor set (middle-thirds), construction depth {depth}")
    print(f"  true Hausdorff dimension log2/log3      = {true_dim:.4f}")
    print(f"  box-count estimate BEFORE bi-Lip map    = {est_before:.4f}")
    print(f"  box-count estimate AFTER  bi-Lip map    = {est_after:.4f}")
    print(f"  |before - after| = {abs(est_before - est_after):.2e}  (dimension preserved)")
    print()


def main() -> None:
    demo_linear_gauge()
    demo_gauge_calculus()
    demo_monoid()
    demo_dimension_invariance()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
