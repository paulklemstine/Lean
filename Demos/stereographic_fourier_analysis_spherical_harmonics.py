"""
Stereographic Fourier Analysis --- Numerical demonstrations.

This self-contained script demonstrates the central results of the accompanying
paper:

  1. The chordal metric identity for inverse stereographic projection:
         || Phi(x) - Phi(y) ||^2 = 4 ||x - y||^2 / ((1+||x||^2)(1+||y||^2)).
  2. The conformal factor recovered in the coincidence limit:
         ds^2_sphere = 4 / (1 + ||x||^2)^2 * ds^2_flat.
  3. The Liouville equation Delta u + e^{2u} = 0 (constant curvature +1),
     with u = log(2 / (1 + r^2)), verified by finite differences.
  4. A discrete stereographic Fourier transform of a function on S^2.

Only the standard library and NumPy are required.
"""

from __future__ import annotations

import math
from typing import Sequence

import numpy as np


# --------------------------------------------------------------------------- #
# 1. Inverse stereographic projection and the chordal metric identity          #
# --------------------------------------------------------------------------- #

def inverse_stereographic(x: np.ndarray) -> np.ndarray:
    """Lift a point x in R^n onto the unit sphere in R^{n+1}.

    Returns the point ( 2x / (1+|x|^2), (|x|^2 - 1) / (1+|x|^2) ).
    """
    a = float(np.dot(x, x))
    horizontal = (2.0 / (1.0 + a)) * x
    vertical = (a - 1.0) / (1.0 + a)
    return np.concatenate([horizontal, [vertical]])


def chordal_distance_sq(x: np.ndarray, y: np.ndarray) -> float:
    """Squared Euclidean distance between the lifts of x and y (chordal)."""
    px, py = inverse_stereographic(x), inverse_stereographic(y)
    return float(np.dot(px - py, px - py))


def chordal_identity_rhs(x: np.ndarray, y: np.ndarray) -> float:
    """Right-hand side of the chordal metric identity."""
    a = float(np.dot(x, x))
    b = float(np.dot(y, y))
    d = float(np.dot(x - y, x - y))
    return 4.0 * d / ((1.0 + a) * (1.0 + b))


def demo_chordal_identity(dim: int = 3, trials: int = 100_000) -> float:
    """Verify the chordal metric identity on random pairs; return max error."""
    rng = np.random.default_rng(0)
    max_err = 0.0
    for _ in range(trials):
        x = rng.normal(size=dim) * rng.uniform(0.1, 5.0)
        y = rng.normal(size=dim) * rng.uniform(0.1, 5.0)
        lhs = chordal_distance_sq(x, y)
        rhs = chordal_identity_rhs(x, y)
        max_err = max(max_err, abs(lhs - rhs))
    return max_err


# --------------------------------------------------------------------------- #
# 2. Conformal factor from the coincidence limit                               #
# --------------------------------------------------------------------------- #

def conformal_factor(x: np.ndarray) -> float:
    """The conformal factor Omega(x)^2 = 4 / (1 + |x|^2)^2."""
    a = float(np.dot(x, x))
    return 4.0 / (1.0 + a) ** 2


def demo_conformal_factor(dim: int = 3, h: float = 1e-6) -> float:
    """Recover the conformal factor from the chordal identity as y -> x.

    For y = x + h*e, chordal_dist^2 / |x-y|^2 -> 4 / (1+|x|^2)^2.
    Returns the maximum relative discrepancy over several base points.
    """
    rng = np.random.default_rng(1)
    max_rel = 0.0
    for _ in range(1000):
        x = rng.normal(size=dim) * rng.uniform(0.1, 4.0)
        e = rng.normal(size=dim)
        e /= np.linalg.norm(e)
        y = x + h * e
        ratio = chordal_distance_sq(x, y) / float(np.dot(x - y, x - y))
        expected = conformal_factor(x)
        max_rel = max(max_rel, abs(ratio - expected) / expected)
    return max_rel


# --------------------------------------------------------------------------- #
# 3. The Liouville equation Delta u + e^{2u} = 0                                #
# --------------------------------------------------------------------------- #

def liouville_u(x: float, y: float) -> float:
    """u(x,y) = log( 2 / (1 + x^2 + y^2) ); conformal factor = e^{2u}."""
    return math.log(2.0 / (1.0 + x * x + y * y))


def demo_liouville(half_width: float = 2.0, n: int = 401) -> float:
    """Check Delta u + e^{2u} = 0 on an interior grid via finite differences.

    Returns the maximum absolute residual over the interior of the grid.
    """
    xs = np.linspace(-half_width, half_width, n)
    h = xs[1] - xs[0]
    U = np.array([[liouville_u(x, y) for x in xs] for y in xs])
    max_res = 0.0
    for i in range(1, n - 1):
        for j in range(1, n - 1):
            lap = (U[i + 1, j] + U[i - 1, j] + U[i, j + 1] + U[i, j - 1]
                   - 4.0 * U[i, j]) / (h * h)
            residual = lap + math.exp(2.0 * U[i, j])
            max_res = max(max_res, abs(residual))
    return max_res


# --------------------------------------------------------------------------- #
# 4. A discrete stereographic Fourier transform on S^2                         #
# --------------------------------------------------------------------------- #

def stereographic_projection(p: np.ndarray) -> np.ndarray:
    """Map a point p on S^2 (minus north pole) to the plane R^2.

    Inverse of `inverse_stereographic`: phi(u, t) = u / (1 - t).
    """
    u, t = p[:-1], p[-1]
    return u / (1.0 - t)


def stereographic_fourier_transform(
    f_values: Sequence[float],
    sphere_points: np.ndarray,
    weights: Sequence[float],
    k: np.ndarray,
    n: int = 2,
) -> complex:
    """Discrete stereographic Fourier transform evaluated at frequency k.

    F[f](k) = sum_i f(x_i) * (1+|phi(x_i)|^2)^{-n/2}
                        * exp(-2 pi i phi(x_i) . k) * w_i,
    where w_i are quadrature weights for the round surface measure.
    """
    total = 0.0 + 0.0j
    for fi, p, w in zip(f_values, sphere_points, weights):
        t = stereographic_projection(p)
        weight = (1.0 + float(np.dot(t, t))) ** (-n / 2.0)
        total += fi * weight * np.exp(-2j * math.pi * float(np.dot(t, k))) * w
    return total


def demo_stereographic_fourier() -> complex:
    """Transform the degree-one harmonic Y = z (height coordinate) on S^2.

    Samples the sphere on a lat/long grid, applies the transform at a sample
    frequency, and returns the resulting complex amplitude.
    """
    n_theta, n_phi = 60, 120
    thetas = np.linspace(1e-3, math.pi - 1e-3, n_theta)  # avoid the poles
    phis = np.linspace(0.0, 2.0 * math.pi, n_phi, endpoint=False)
    dtheta = thetas[1] - thetas[0]
    dphi = phis[1] - phis[0]

    points, f_values, weights = [], [], []
    for th in thetas:
        for ph in phis:
            x = math.sin(th) * math.cos(ph)
            y = math.sin(th) * math.sin(ph)
            z = math.cos(th)
            points.append(np.array([x, y, z]))
            f_values.append(z)                       # degree-one harmonic Y = z
            weights.append(math.sin(th) * dtheta * dphi)  # surface measure
    sphere_points = np.array(points)

    k = np.array([0.5, 0.0])
    return stereographic_fourier_transform(f_values, sphere_points, weights, k)


# --------------------------------------------------------------------------- #
# Main                                                                          #
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 70)
    print("Stereographic Fourier Analysis --- numerical demonstrations")
    print("=" * 70)

    err = demo_chordal_identity(dim=3, trials=50_000)
    print(f"\n[1] Chordal metric identity (dim=3, 50k random pairs)")
    print(f"    max |LHS - RHS| = {err:.3e}   (should be ~machine epsilon)")

    rel = demo_conformal_factor(dim=3, h=1e-6)
    print(f"\n[2] Conformal factor from coincidence limit")
    print(f"    max relative error = {rel:.3e}   (should be tiny)")

    res = demo_liouville(half_width=2.0, n=201)
    print(f"\n[3] Liouville equation Delta u + e^(2u) = 0")
    print(f"    max finite-difference residual = {res:.3e}   (-> 0 as grid refines)")

    amp = demo_stereographic_fourier()
    print(f"\n[4] Stereographic Fourier transform of Y = z at k = (0.5, 0)")
    print(f"    F[Y](k) = {amp:.6f}")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
