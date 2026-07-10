"""
Morphogenesis as Algebraic Geometry: numerical demonstrations.

This self-contained script illustrates the main results relating Turing
patterns to conic sections:

  1. The Chebyshev correspondence: cos(n*theta) is a polynomial of exactly
     degree n in X = cos(theta), so the number of spatial modes equals the
     algebraic degree of the pattern.
  2. Spots are bounded (definite quadratic level sets lie inside a disc).
  3. Labyrinths are unbounded (indefinite quadratic level sets escape every disc).
  4. Stripes are periodic and unbounded (single-mode level sets).
  5. The morphological dichotomy: a spot (circle) level set and a labyrinth
     (hyperbola) level set are never the same set of points.

No third-party dependencies are required.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# 1. Chebyshev correspondence: mode count = algebraic degree
# ---------------------------------------------------------------------------

def chebyshev_T(n: int) -> List[float]:
    """Return the coefficients of the n-th Chebyshev polynomial T_n of the
    first kind, as a list [c_0, c_1, ..., c_n] with T_n(X) = sum c_k X^k.

    T_n satisfies T_n(cos theta) = cos(n theta) and has degree exactly n
    with leading coefficient 2^(n-1) for n >= 1.
    """
    if n == 0:
        return [1.0]
    if n == 1:
        return [0.0, 1.0]
    prev2: List[float] = [1.0]            # T_0
    prev1: List[float] = [0.0, 1.0]       # T_1
    for _ in range(2, n + 1):
        # T_k = 2 X T_{k-1} - T_{k-2}
        shifted = [0.0] + [2.0 * c for c in prev1]      # 2 X T_{k-1}
        cur = list(shifted)
        for i, c in enumerate(prev2):
            cur[i] -= c
        prev2, prev1 = prev1, cur
    return prev1


def poly_eval(coeffs: List[float], x: float) -> float:
    """Evaluate a polynomial given by ascending-order coefficients at x."""
    acc = 0.0
    for c in reversed(coeffs):
        acc = acc * x + c
    return acc


def poly_degree(coeffs: List[float], tol: float = 1e-9) -> int:
    """Return the true degree, ignoring negligible high-order coefficients."""
    deg = 0
    for i, c in enumerate(coeffs):
        if abs(c) > tol:
            deg = i
    return deg


def verify_chebyshev(n: int, samples: int = 200) -> Tuple[int, float]:
    """Check that T_n has degree n and reproduces cos(n theta).

    Returns (degree, max_error).
    """
    coeffs = chebyshev_T(n)
    deg = poly_degree(coeffs)
    max_err = 0.0
    for k in range(samples):
        theta = math.pi * k / (samples - 1)
        lhs = poly_eval(coeffs, math.cos(theta))
        rhs = math.cos(n * theta)
        max_err = max(max_err, abs(lhs - rhs))
    return deg, max_err


# ---------------------------------------------------------------------------
# 2. Spots are bounded (definite quadratic)
# ---------------------------------------------------------------------------

def spot_radius_bound(a: float, b: float, c: float) -> float:
    """For the ellipse a x^2 + b y^2 = c with a,b > 0, return the theoretical
    bound R = c/a + c/b on x^2 + y^2 (Theorem: spots are bounded)."""
    assert a > 0 and b > 0
    return c / a + c / b


def sample_ellipse(a: float, b: float, c: float, samples: int = 361
                   ) -> List[Tuple[float, float]]:
    """Sample points on a x^2 + b y^2 = c using the parametrization
    x = sqrt(c/a) cos t, y = sqrt(c/b) sin t."""
    pts: List[Tuple[float, float]] = []
    rx, ry = math.sqrt(c / a), math.sqrt(c / b)
    for k in range(samples):
        t = 2.0 * math.pi * k / (samples - 1)
        pts.append((rx * math.cos(t), ry * math.sin(t)))
    return pts


# ---------------------------------------------------------------------------
# 3. Labyrinths are unbounded (indefinite quadratic)
# ---------------------------------------------------------------------------

def hyperbola_far_point(c: float, R: float) -> Tuple[float, float]:
    """Construct an explicit point on x^2 - y^2 = c (c > 0) whose squared norm
    exceeds R. This witnesses Theorem: labyrinths are unbounded."""
    assert c > 0
    t = math.sqrt(abs(R) + 1.0)          # t^2 = |R| + 1 > R
    x = math.sqrt(t * t + c)
    y = t
    return x, y


# ---------------------------------------------------------------------------
# 4. Stripes: periodic and unbounded (single mode)
# ---------------------------------------------------------------------------

def stripe_periodic_check(c: float, x: float, k: int) -> float:
    """Return |cos(x + 2 pi k) - c| given cos(x) = c; should be ~0."""
    return abs(math.cos(x + k * 2.0 * math.pi) - c)


def stripe_far_point(R: float) -> Tuple[float, float]:
    """Point on {cos x = 1} with squared norm > R (transverse direction)."""
    return 0.0, math.sqrt(abs(R) + 1.0)


# ---------------------------------------------------------------------------
# 5. Morphological dichotomy: circle != hyperbola
# ---------------------------------------------------------------------------

def dichotomy_witness(rho: float, c: float) -> Tuple[float, float, float, float]:
    """Return a hyperbola point that cannot lie on the circle x^2+y^2=rho^2,
    demonstrating that the two level sets differ. Returns
    (x, y, x^2 - y^2, x^2 + y^2)."""
    x, y = hyperbola_far_point(c, rho * rho)
    return x, y, x * x - y * y, x * x + y * y


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 68)
    print("Morphogenesis as Algebraic Geometry -- numerical demonstrations")
    print("=" * 68)

    print("\n[1] Chebyshev correspondence: mode count = algebraic degree")
    print(f"    {'n':>3} | {'degree of T_n':>13} | {'max |T_n(cos t) - cos(n t)|':>28}")
    for n in range(0, 7):
        deg, err = verify_chebyshev(n)
        print(f"    {n:>3} | {deg:>13} | {err:>28.2e}")
    print("    => degree equals mode number exactly (leading coeff 2^(n-1)).")

    print("\n[2] Spots are bounded (ellipse a x^2 + b y^2 = c, a,b>0)")
    a, b, c = 2.0, 5.0, 3.0
    R = spot_radius_bound(a, b, c)
    pts = sample_ellipse(a, b, c)
    worst = max(x * x + y * y for x, y in pts)
    print(f"    a={a}, b={b}, c={c}: theoretical bound R = c/a + c/b = {R:.4f}")
    print(f"    max sampled x^2 + y^2 on the curve         = {worst:.4f}  (<= R)")

    print("\n[3] Labyrinths are unbounded (hyperbola x^2 - y^2 = c, c>0)")
    c = 1.5
    for Rtarget in (10.0, 1_000.0, 1_000_000.0):
        x, y = hyperbola_far_point(c, Rtarget)
        print(f"    target R={Rtarget:>12.0f}: point ({x:.3f},{y:.3f}), "
              f"x^2-y^2={x*x-y*y:.4f}, x^2+y^2={x*x+y*y:.1f} > R")

    print("\n[4] Stripes: periodic and unbounded (single mode cos x = c)")
    c = 0.3
    x0 = math.acos(c)
    errs = [stripe_periodic_check(c, x0, k) for k in (-3, -1, 1, 5, 42)]
    print(f"    cos x = {c}: max periodicity error over k in [-3,42] = {max(errs):.2e}")
    xf, yf = stripe_far_point(1_000.0)
    print(f"    transverse point on cos x = 1: ({xf},{yf:.3f}), "
          f"x^2+y^2={xf*xf+yf*yf:.1f}")

    print("\n[5] Morphological dichotomy: circle != hyperbola")
    rho, c = 4.0, 1.5
    x, y, hyp, nrm = dichotomy_witness(rho, c)
    print(f"    circle radius rho={rho} (so points have x^2+y^2 = {rho*rho})")
    print(f"    hyperbola witness ({x:.3f},{y:.3f}): x^2-y^2={hyp:.4f} (=c), "
          f"x^2+y^2={nrm:.1f}")
    print(f"    {nrm:.1f} > {rho*rho:.1f}: this hyperbola point is NOT on the circle.")
    print("    => spot and labyrinth level sets are genuinely different varieties.")

    print("\nDone.")


if __name__ == "__main__":
    main()
