"""Numerical demonstrations for the Split Geometry.

The split geometry is the plane R^2 with the anisotropic warped metric

    ds^2 = dx^2 / cosh^2(y) + cosh^2(x) dy^2,     i.e.  E = sech^2(y), G = cosh^2(x).

This self-contained script (standard library only) demonstrates the paper's
results:

  1. The closed-form Gaussian curvature
         K(x, y) = -cosh^2(y) + (2 - cosh^2(y)) / (cosh^2(x) cosh^2(y))
     agrees with a finite-difference evaluation of the Brioschi formula.
  2. Along the x-axis, K(x, 0) = -tanh^2(x) <= 0 (hyperbolic).
  3. Along the y-axis, K(0, y) = -cosh^2(y) + 2 sech^2(y) - 1 <= 0, so the
     conjectured elliptic (K > 0) behavior does NOT occur.
  4. The Jacobi equation J'' + K J = 0 gives divergence (sinh) for K < 0 and
     bounded refocusing (sin) for K > 0.
  5. The coordinate-axis lines are geodesics; the proposed exponential curve is
     not.

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
# Metric coefficients and curvature
# --------------------------------------------------------------------------- #

def sech(t: float) -> float:
    """Hyperbolic secant, sech(t) = 1 / cosh(t)."""
    return 1.0 / math.cosh(t)


def E(x: float, y: float) -> float:
    """First metric coefficient E = sech^2(y)."""
    return sech(y) ** 2


def G(x: float, y: float) -> float:
    """Second metric coefficient G = cosh^2(x)."""
    return math.cosh(x) ** 2


def K_closed(x: float, y: float) -> float:
    """Closed-form Gaussian curvature of the split metric."""
    cy2 = math.cosh(y) ** 2
    cx2 = math.cosh(x) ** 2
    return -cy2 + (2.0 - cy2) / (cx2 * cy2)


def K_brioschi(x: float, y: float, h: float = 1e-4) -> float:
    """Gaussian curvature via a finite-difference Brioschi formula.

    For an orthogonal metric g = E dx^2 + G dy^2,

        K = -1 / (2 sqrt(EG)) [ d/dx (G_x / sqrt(EG)) + d/dy (E_y / sqrt(EG)) ].
    """
    def root(a: float, b: float) -> float:
        return math.sqrt(E(a, b) * G(a, b))

    def dG_dx(a: float, b: float) -> float:
        return (G(a + h, b) - G(a - h, b)) / (2 * h)

    def dE_dy(a: float, b: float) -> float:
        return (E(a, b + h) - E(a, b - h)) / (2 * h)

    def term_x(a: float, b: float) -> float:
        return dG_dx(a, b) / root(a, b)

    def term_y(a: float, b: float) -> float:
        return dE_dy(a, b) / root(a, b)

    d_term_x = (term_x(x + h, y) - term_x(x - h, y)) / (2 * h)
    d_term_y = (term_y(x, y + h) - term_y(x, y - h)) / (2 * h)
    return -(d_term_x + d_term_y) / (2 * root(x, y))


def K_xaxis(x: float) -> float:
    """K(x, 0) = -tanh^2(x)."""
    return -math.tanh(x) ** 2


def K_yaxis(y: float) -> float:
    """K(0, y) = -cosh^2(y) + 2 sech^2(y) - 1."""
    return -math.cosh(y) ** 2 + 2.0 * sech(y) ** 2 - 1.0


# --------------------------------------------------------------------------- #
# Jacobi equation (geodesic deviation)
# --------------------------------------------------------------------------- #

def integrate_jacobi(
    curvature: float, j0: float, jp0: float, t_max: float, n: int
) -> List[Tuple[float, float]]:
    """Integrate J'' + K J = 0 with constant K via classical RK4.

    Returns a list of (t, J(t)) samples.
    """
    dt = t_max / n

    def deriv(state: Tuple[float, float]) -> Tuple[float, float]:
        j, jp = state
        return (jp, -curvature * j)

    def add(s: Tuple[float, float], d: Tuple[float, float], f: float) -> Tuple[float, float]:
        return (s[0] + f * d[0], s[1] + f * d[1])

    state = (j0, jp0)
    out: List[Tuple[float, float]] = [(0.0, j0)]
    t = 0.0
    for _ in range(n):
        k1 = deriv(state)
        k2 = deriv(add(state, k1, dt / 2))
        k3 = deriv(add(state, k2, dt / 2))
        k4 = deriv(add(state, k3, dt))
        state = (
            state[0] + dt / 6 * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0]),
            state[1] + dt / 6 * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1]),
        )
        t += dt
        out.append((t, state[0]))
    return out


# --------------------------------------------------------------------------- #
# Geodesic equation residuals
# --------------------------------------------------------------------------- #

def geodesic_residual(
    x: Callable[[float], float],
    y: Callable[[float], float],
    t: float,
    h: float = 1e-4,
) -> Tuple[float, float]:
    """Residuals of the two geodesic equations at parameter t.

    A curve is a geodesic iff both residuals vanish for all t. Uses centered
    finite differences for derivatives and the split-metric Christoffel symbols.
    """
    def d1(f: Callable[[float], float], s: float) -> float:
        return (f(s + h) - f(s - h)) / (2 * h)

    def d2(f: Callable[[float], float], s: float) -> float:
        return (f(s + h) - 2 * f(s) + f(s - h)) / (h * h)

    xt, yt = x(t), y(t)
    xd, yd = d1(x, t), d1(y, t)
    xdd, ydd = d2(x, t), d2(y, t)

    chr1_12 = -math.tanh(yt)
    chr1_22 = -math.cosh(xt) * math.sinh(xt) * math.cosh(yt) ** 2
    chr2_11 = sech(yt) ** 2 * math.tanh(yt) / math.cosh(xt) ** 2
    chr2_12 = math.tanh(xt)

    res1 = xdd + 2 * chr1_12 * xd * yd + chr1_22 * yd ** 2
    res2 = ydd + chr2_11 * xd ** 2 + 2 * chr2_12 * xd * yd
    return res1, res2


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_curvature_agreement() -> None:
    print("=" * 68)
    print("1. Closed-form curvature vs. finite-difference Brioschi formula")
    print("=" * 68)
    pts = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (0.7, -0.4), (-1.2, 0.9)]
    print(f"{'(x, y)':>14} | {'K_closed':>14} | {'K_brioschi':>14} | {'|diff|':>10}")
    for (x, y) in pts:
        a, b = K_closed(x, y), K_brioschi(x, y)
        print(f"{f'({x:+.2f},{y:+.2f})':>14} | {a:>14.8f} | {b:>14.8f} | {abs(a-b):>10.2e}")
    print()


def demo_axes() -> None:
    print("=" * 68)
    print("2 & 3. Curvature along the axes (both nonpositive => no split)")
    print("=" * 68)
    print("x-axis: K(x,0) = -tanh^2(x)      |  y-axis: K(0,y) = -cosh^2+2sech^2-1")
    print(f"{'t':>7} | {'K(t,0)':>16} | {'K(0,t)':>16}")
    for t in [-2.0, -1.0, 0.0, 1.0, 2.0]:
        kx, ky = K_xaxis(t), K_yaxis(t)
        # cross-check against the general closed form on the axes
        assert abs(kx - K_closed(t, 0.0)) < 1e-9
        assert abs(ky - K_closed(0.0, t)) < 1e-9
        print(f"{t:>7.2f} | {kx:>16.8f} | {ky:>16.8f}")
    print("Both columns <= 0; strictly < 0 off the origin. Elliptic K>0 never occurs.")
    print()


def demo_jacobi() -> None:
    print("=" * 68)
    print("4. Geodesic deviation via the Jacobi equation J'' + K J = 0")
    print("=" * 68)
    k = 1.0
    # Hyperbolic: K = -k, exact solution sinh(sqrt(k) t) -> diverges.
    hyp = integrate_jacobi(-k, j0=0.0, jp0=1.0, t_max=3.0, n=3000)
    t_end, j_end = hyp[-1]
    exact_hyp = math.sinh(math.sqrt(k) * t_end)
    print(f"Hyperbolic (K=-1): J({t_end:.1f}) = {j_end:.6f}  vs  sinh = {exact_hyp:.6f}"
          f"   (diverges)")
    # Elliptic: K = +k, exact solution sin(sqrt(k) t), refocuses at pi/sqrt(k).
    ell = integrate_jacobi(k, j0=0.0, jp0=1.0, t_max=math.pi, n=3000)
    t_ref, j_ref = ell[-1]
    print(f"Elliptic  (K=+1): J(pi) = {j_ref:.6f}  vs  sin(pi) = {math.sin(math.pi):.6f}"
          f"   (refocuses to 0)")
    max_ell = max(abs(j) for _, j in ell)
    print(f"Elliptic amplitude bound: max|J| = {max_ell:.6f} (<= 1, bounded)")
    print()


def demo_geodesics() -> None:
    print("=" * 68)
    print("5. Geodesic check: axis lines vs. the proposed exponential curve")
    print("=" * 68)
    # x-axis line
    r1 = geodesic_residual(lambda t: 1.0 + 2.0 * t, lambda t: 0.0, t=0.3)
    print(f"x-axis line (x=1+2t, y=0):   residuals = ({r1[0]:.2e}, {r1[1]:.2e})  -> geodesic")
    # y-axis line
    r2 = geodesic_residual(lambda t: 0.0, lambda t: -1.0 + 0.5 * t, t=0.3)
    print(f"y-axis line (x=0, y=-1+t/2): residuals = ({r2[0]:.2e}, {r2[1]:.2e})  -> geodesic")
    # proposed exponential curve x=t, y=exp(t)
    r3 = geodesic_residual(lambda t: t, lambda t: math.exp(t), t=0.0)
    print(f"exp curve (x=t, y=e^t) at 0: residuals = ({r3[0]:.2e}, {r3[1]:.2e})  -> NOT geodesic")
    predicted = 1.0 + sech(1.0) ** 2 * math.tanh(1.0)
    print(f"   predicted 2nd residual at t=0: 1 + sech^2(1)tanh(1) = {predicted:.6f}")
    print()


def main() -> None:
    demo_curvature_agreement()
    demo_axes()
    demo_jacobi()
    demo_geodesics()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
