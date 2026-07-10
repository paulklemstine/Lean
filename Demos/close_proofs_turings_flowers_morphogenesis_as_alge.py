"""
Turing's Flowers: Morphogenesis as Algebraic Geometry
=====================================================

Numerical demonstrations of the Chebyshev correspondence and the boundedness
dichotomy that separates the three linear-onset morphological classes of Turing
patterns (spots, stripes, labyrinths).

Key facts demonstrated:
  1. cos(n theta) = T_n(cos theta), with deg T_n = n exactly (mode = degree).
  2. Two-mode second harmonic is the quadratic 2 X^2 - 1 (a conic).
  3. Three modes reach degree six: cos^2(3 theta) = T_3(cos theta)^2 (sextic).
  4. Spots (definite quadratics) are bounded: x^2 + y^2 <= c/a + c/b.
  5. Labyrinths (hyperbolas) are unbounded.
  6. Stripes are periodic (period 2*pi) and unbounded.

Self-contained: uses only the Python standard library.
"""

from __future__ import annotations

import math
from typing import List, Tuple


# ---------------------------------------------------------------------------
# 1. Chebyshev polynomials of the first kind (mode -> polynomial)
# ---------------------------------------------------------------------------
def chebyshev_T(n: int) -> List[float]:
    """Return coefficients of T_n in ascending powers of X (c[0] + c[1] X + ...).

    Uses the recurrence T_0 = 1, T_1 = X, T_{k+1} = 2 X T_k - T_{k-1}.
    The returned list has length n + 1, so deg T_n = n exactly (leading coeff 2^{n-1}).
    """
    if n == 0:
        return [1.0]
    if n == 1:
        return [0.0, 1.0]
    prev, curr = [1.0], [0.0, 1.0]
    for _ in range(2, n + 1):
        # nxt = 2 X * curr - prev
        shifted = [0.0] + [2.0 * c for c in curr]          # 2 X * curr
        nxt = shifted[:]
        for i, c in enumerate(prev):
            nxt[i] -= c
        prev, curr = curr, nxt
    return curr


def poly_eval(coeffs: List[float], x: float) -> float:
    """Horner evaluation of a polynomial given in ascending-power coefficients."""
    acc = 0.0
    for c in reversed(coeffs):
        acc = acc * x + c
    return acc


def demo_chebyshev_correspondence(max_n: int = 6) -> None:
    """Verify cos(n theta) == T_n(cos theta) and deg T_n == n."""
    print("=" * 68)
    print("DEMO 1: Chebyshev correspondence  cos(n t) = T_n(cos t)")
    print("=" * 68)
    thetas = [0.3, 1.1, 2.7, -0.9, math.pi / 5]
    for n in range(max_n + 1):
        coeffs = chebyshev_T(n)
        degree = len(coeffs) - 1
        max_err = 0.0
        for t in thetas:
            lhs = math.cos(n * t)
            rhs = poly_eval(coeffs, math.cos(t))
            max_err = max(max_err, abs(lhs - rhs))
        print(f"  n={n}: deg T_n = {degree:2d}  (=n? {degree == n})   "
              f"max |cos(nt) - T_n(cos t)| = {max_err:.2e}")
    print()


# ---------------------------------------------------------------------------
# 2 & 3. Two-mode quadratic and three-mode sextic
# ---------------------------------------------------------------------------
def demo_conic_and_sextic() -> None:
    """Show T_2 is a quadratic (conic) and T_3^2 is a sextic reproducing cos^2(3t)."""
    print("=" * 68)
    print("DEMO 2/3: Two-mode quadratic and three-mode sextic")
    print("=" * 68)
    t2 = chebyshev_T(2)
    print(f"  T_2 coefficients (ascending): {t2}   -> 2 X^2 - 1, degree {len(t2)-1}")

    t3 = chebyshev_T(3)
    # square T_3 to get the degree-6 polynomial
    q = [0.0] * (2 * len(t3) - 1)
    for i, a in enumerate(t3):
        for j, b in enumerate(t3):
            q[i + j] += a * b
    print(f"  T_3^2 degree = {len(q) - 1} (sextic, hexagonal regime)")
    max_err = 0.0
    for t in [0.2, 1.3, 2.2, -1.7]:
        lhs = math.cos(3 * t) ** 2
        rhs = poly_eval(q, math.cos(t))
        max_err = max(max_err, abs(lhs - rhs))
    print(f"  max |cos^2(3t) - T_3^2(cos t)| = {max_err:.2e}")
    print()


# ---------------------------------------------------------------------------
# 4. Spots are bounded (definite quadratic form)
# ---------------------------------------------------------------------------
def spot_bound(a: float, b: float, c: float) -> float:
    """Enclosing squared radius c/a + c/b for the spot a x^2 + b y^2 = c."""
    return c / a + c / b


def demo_spot_bounded(a: float = 2.0, b: float = 3.0, c: float = 6.0,
                      samples: int = 2000) -> None:
    """Sample the ellipse a x^2 + b y^2 = c and confirm every point lies in the disc."""
    print("=" * 68)
    print("DEMO 4: Spots are bounded (ellipse a x^2 + b y^2 = c)")
    print("=" * 68)
    R = spot_bound(a, b, c)
    sharp = c / min(a, b)
    max_norm2 = 0.0
    for k in range(samples):
        phi = 2.0 * math.pi * k / samples
        x = math.sqrt(c / a) * math.cos(phi)
        y = math.sqrt(c / b) * math.sin(phi)
        max_norm2 = max(max_norm2, x * x + y * y)
    print(f"  a={a}, b={b}, c={c}")
    print(f"  loose bound c/a + c/b        = {R:.4f}")
    print(f"  sharp bound c/min(a,b)       = {sharp:.4f}")
    print(f"  observed max x^2 + y^2       = {max_norm2:.4f}")
    print(f"  all points inside loose disc : {max_norm2 <= R + 1e-9}")
    print()


# ---------------------------------------------------------------------------
# 5. Labyrinths are unbounded (hyperbola)
# ---------------------------------------------------------------------------
def hyperbola_escape_point(c: float, R: float) -> Tuple[float, float]:
    """Witness point on x^2 - y^2 = c with x^2 + y^2 > R (from the proof)."""
    t = math.sqrt(abs(R) + 1.0)
    x = math.sqrt(t * t + c)
    y = t
    return x, y


def demo_labyrinth_unbounded(c: float = 1.0) -> None:
    """Exhibit points on x^2 - y^2 = c escaping any prescribed radius R."""
    print("=" * 68)
    print("DEMO 5: Labyrinths are unbounded (hyperbola x^2 - y^2 = c)")
    print("=" * 68)
    for R in [10.0, 1e3, 1e6, 1e9]:
        x, y = hyperbola_escape_point(c, R)
        on_curve = abs((x * x - y * y) - c) < 1e-6 * max(1.0, x * x)
        norm2 = x * x + y * y
        print(f"  R={R:>10.0e}: witness norm^2 = {norm2:.3e} > R? {norm2 > R}  "
              f"on curve? {on_curve}")
    print()


# ---------------------------------------------------------------------------
# 6. Stripes are periodic and unbounded
# ---------------------------------------------------------------------------
def demo_stripes(c: float = 1.0) -> None:
    """Show cos x = c is 2*pi-periodic and extends unboundedly in y."""
    print("=" * 68)
    print("DEMO 6: Stripes are periodic (2*pi) and unbounded")
    print("=" * 68)
    x0 = 0.0  # cos 0 = 1 = c
    max_err = max(abs(math.cos(x0 + k * 2.0 * math.pi) - c) for k in range(-5, 6))
    print(f"  periodicity: max |cos(x0 + 2*pi*k) - c| over k=-5..5 = {max_err:.2e}")
    for R in [10.0, 1e4, 1e8]:
        y = math.sqrt(abs(R) + 1.0)
        norm2 = x0 * x0 + y * y
        print(f"  R={R:>8.0e}: stripe point (0, {y:.3e}) has norm^2 {norm2:.3e} > R? "
              f"{norm2 > R}")
    print()


# ---------------------------------------------------------------------------
# 7. Morphological separation: spot != labyrinth, spot != stripe
# ---------------------------------------------------------------------------
def demo_separation(rho: float = 2.0) -> None:
    """A bounded circle can equal neither an unbounded hyperbola nor a stripe."""
    print("=" * 68)
    print("DEMO 7: Morphological separation (spot vs labyrinth vs stripe)")
    print("=" * 68)
    R = rho * rho
    hx, hy = hyperbola_escape_point(1.0, R)
    print(f"  circle x^2+y^2 = {R}; hyperbola witness norm^2 = {hx*hx+hy*hy:.3f} > {R} "
          f"=> circle != hyperbola")
    sy = math.sqrt(abs(R) + 1.0)
    print(f"  stripe witness (0,{sy:.3f}) norm^2 = {sy*sy:.3f} > {R} "
          f"=> circle != stripe")
    print()


def main() -> None:
    demo_chebyshev_correspondence()
    demo_conic_and_sextic()
    demo_spot_bounded()
    demo_labyrinth_unbounded()
    demo_stripes()
    demo_separation()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
