"""Numerical demonstrations for the Christoffel-Darboux Airy kernel results.

This script exercises the four main theorems of the package numerically:

  * airyKernel_symm                -> Demo 1 (symmetry K(x,y) = K(y,x))
  * airyKernel_diagonal_tendsto    -> Demo 2 (removable singularity -> -W, flat)
  * gram_corr_det_nonneg           -> Demo 3 (2x2 Cauchy-Schwarz positivity)
  * gram_corr_posSemidef           -> Demo 4 (n x n Gram positive semidefiniteness)

The Airy functions are produced by integrating Airy's ODE  y'' = x*y  with a
classical fourth-order Runge-Kutta scheme, using the standard initial values
Ai(0), Ai'(0), Bi(0), Bi'(0).  For speed, we integrate ONCE over a fine grid
covering the whole range used below and interpolate.  Only numpy is required.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Tuple

import numpy as np

# Standard initial values of the Airy functions at 0.
AI0: float = 0.3550280538878172
AIP0: float = -0.2588194037928068
BI0: float = 0.6149266274460007
BIP0: float = 0.4482883573538264
PI: float = math.pi


def _integrate_table(
    y0: float, yp0: float, x_lo: float, x_hi: float, h: float
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Integrate y'' = x*y outward from 0 to x_lo and to x_hi by RK4.

    Returns (xs, ys, yps): sorted grids of x, y(x), y'(x).
    """
    def rhs(t: float, u: float, v: float) -> Tuple[float, float]:
        return v, t * u

    def march(x_end: float, step: float) -> List[Tuple[float, float, float]]:
        n = max(1, int(abs(x_end) / abs(step)))
        s = x_end / n
        t, u, v = 0.0, y0, yp0
        out: List[Tuple[float, float, float]] = [(t, u, v)]
        for _ in range(n):
            k1u, k1v = rhs(t, u, v)
            k2u, k2v = rhs(t + s / 2, u + s / 2 * k1u, v + s / 2 * k1v)
            k3u, k3v = rhs(t + s / 2, u + s / 2 * k2u, v + s / 2 * k2v)
            k4u, k4v = rhs(t + s, u + s * k3u, v + s * k3v)
            u += s / 6 * (k1u + 2 * k2u + 2 * k3u + k4u)
            v += s / 6 * (k1v + 2 * k2v + 2 * k3v + k4v)
            t += s
            out.append((t, u, v))
        return out

    left = march(x_lo, -h)
    right = march(x_hi, h)
    data = sorted(set(left) | set(right))
    xs = np.array([d[0] for d in data])
    ys = np.array([d[1] for d in data])
    yps = np.array([d[2] for d in data])
    return xs, ys, yps


# Precompute tables once over the full range used by all demos.
_X_LO, _X_HI, _H = -3.0, 13.0, 1.0e-3
_AI_X, _AI_Y, _AI_YP = _integrate_table(AI0, AIP0, _X_LO, _X_HI, _H)
_BI_X, _BI_Y, _BI_YP = _integrate_table(BI0, BIP0, _X_LO, _X_HI, _H)


def Ai(x: float) -> float:
    """Airy function Ai(x) (interpolated from the precomputed table)."""
    return float(np.interp(x, _AI_X, _AI_Y))


def Aip(x: float) -> float:
    """Derivative Ai'(x)."""
    return float(np.interp(x, _AI_X, _AI_YP))


def Bi(x: float) -> float:
    """Airy function Bi(x)."""
    return float(np.interp(x, _BI_X, _BI_Y))


def Bip(x: float) -> float:
    """Derivative Bi'(x)."""
    return float(np.interp(x, _BI_X, _BI_YP))


def airy_kernel(
    f: Callable[[float], float],
    g: Callable[[float], float],
    x: float,
    y: float,
) -> float:
    """Christoffel-Darboux kernel  K(x,y) = (f(x)g(y) - g(x)f(y)) / (x - y)."""
    return (f(x) * g(y) - g(x) * f(y)) / (x - y)


def wronskian(
    f: Callable[[float], float],
    fp: Callable[[float], float],
    g: Callable[[float], float],
    gp: Callable[[float], float],
    x: float,
) -> float:
    """Wronskian  W(x) = f(x) g'(x) - g(x) f'(x)."""
    return f(x) * gp(x) - g(x) * fp(x)


# --------------------------------------------------------------------------
# Demo 1: symmetry of the Airy kernel  (airyKernel_symm)
# --------------------------------------------------------------------------
def demo_symmetry() -> None:
    print("=" * 70)
    print("DEMO 1  --  Symmetry  K(x,y) = K(y,x)   (airyKernel_symm)")
    print("=" * 70)
    pairs: List[Tuple[float, float]] = [(0.3, 1.1), (-1.0, 0.7), (2.0, -0.5)]
    for x, y in pairs:
        kxy = airy_kernel(Ai, Bi, x, y)
        kyx = airy_kernel(Ai, Bi, y, x)
        print(f"  x={x:+.2f}, y={y:+.2f}:  K(x,y)={kxy:+.6f}  "
              f"K(y,x)={kyx:+.6f}  |diff|={abs(kxy - kyx):.2e}")
    print()


# --------------------------------------------------------------------------
# Demo 2: removable singularity -> constant Wronskian (airyKernel_diagonal_tendsto)
# --------------------------------------------------------------------------
def demo_diagonal() -> None:
    print("=" * 70)
    print("DEMO 2  --  Diagonal limit K(x,x+h) -> -W, flat in x")
    print("           (airyKernel_diagonal_tendsto)")
    print("=" * 70)
    print(f"  Theory: limit = -W(Ai,Bi) = -1/pi = {-1.0 / PI:+.6f} (same at all x)")
    for x in (-1.0, 0.0, 1.0, 2.0):
        w = wronskian(Ai, Aip, Bi, Bip, x)
        approx = airy_kernel(Ai, Bi, x, x + 1.0e-3)
        print(f"  x={x:+.2f}:  -W(x)={-w:+.6f}   K(x,x+1e-3)={approx:+.6f}   "
              f"(W ~ 1/pi = {1.0 / PI:.6f})")
    print()


# --------------------------------------------------------------------------
# Demo 3: 2x2 determinantal positivity  (gram_corr_det_nonneg)
# --------------------------------------------------------------------------
def gram_kernel(phi: Callable[[float], np.ndarray], x: float, y: float) -> float:
    """Discretized Gram kernel  <phi(x), phi(y)>  (an inner product)."""
    return float(np.dot(phi(x), phi(y)))


def airy_wave_map(grid: np.ndarray, dt: float) -> Callable[[float], np.ndarray]:
    """phi(x)(t) = Ai(x+t) sampled on ``grid`` and scaled by sqrt(dt),
    so that <phi(x),phi(y)> approximates the L2 integral of Ai(x+.)Ai(y+.)."""
    def phi(x: float) -> np.ndarray:
        return np.interp(x + grid, _AI_X, _AI_Y) * math.sqrt(dt)
    return phi


def demo_det2() -> None:
    print("=" * 70)
    print("DEMO 3  --  2x2 positivity  K(x,x)K(y,y) - K(x,y)^2 >= 0")
    print("           (gram_corr_det_nonneg ; Cauchy-Schwarz)")
    print("=" * 70)
    dt = 0.02
    grid = np.arange(0.0, 9.0, dt)
    phi = airy_wave_map(grid, dt)
    for x, y in [(0.5, 1.5), (1.0, 1.2), (2.0, 0.3)]:
        kxx = gram_kernel(phi, x, x)
        kyy = gram_kernel(phi, y, y)
        kxy = gram_kernel(phi, x, y)
        det = kxx * kyy - kxy * kxy
        print(f"  x={x:+.2f}, y={y:+.2f}:  det = {det:+.8f}  (>= 0: {det >= -1e-12})")
    print()


# --------------------------------------------------------------------------
# Demo 4: n x n positive semidefiniteness  (gram_corr_posSemidef)
# --------------------------------------------------------------------------
def demo_psd() -> None:
    print("=" * 70)
    print("DEMO 4  --  n x n correlation matrix is PSD  (gram_corr_posSemidef)")
    print("=" * 70)
    dt = 0.02
    grid = np.arange(0.0, 9.0, dt)
    phi = airy_wave_map(grid, dt)
    pts = np.array([-0.5, 0.0, 0.7, 1.3, 2.1])
    n = len(pts)
    M = np.array([[gram_kernel(phi, pts[i], pts[j]) for j in range(n)]
                  for i in range(n)])
    sym_err = float(np.max(np.abs(M - M.T)))
    eigs = np.linalg.eigvalsh(M)
    print(f"  base points: {pts.tolist()}")
    print(f"  symmetry error |M - M^T|_max = {sym_err:.2e}")
    print(f"  eigenvalues: {np.round(eigs, 8).tolist()}")
    print(f"  min eigenvalue = {eigs.min():+.3e}  (PSD: {eigs.min() >= -1e-9})")
    print()


def main() -> None:
    demo_symmetry()
    demo_diagonal()
    demo_det2()
    demo_psd()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
