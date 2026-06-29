"""
Hodge-Laplacian Message Passing: Exact Mode Dynamics & Polynomial Filters
=========================================================================

Numerical demonstrations of the main results.

We work with a symmetric positive-semidefinite operator ``L`` (a graph / Hodge
Laplacian) acting on a real inner-product space ``E = R^n``.  The basic
message-passing layer is the gradient step

    mpStep(L, alpha) = I - alpha * L,        x  |->  x - alpha * (L x).

The results demonstrated here:

  * Theorem 3.1  mpStep acts on an eigenvector  L v = nu v  as  (1 - alpha nu) v.
  * Theorem 3.2  depth-k orbit is the closed form  (1 - alpha nu)^k v.
  * Theorem 3.3  the energy <T^k v, T^k v> equals  (1 - alpha nu)^(2k) <v, v>.
  * Theorem 4.1  on the slowest mode  nu = mu, energy = sigma^k <v,v>, sigma=(1-alpha mu)^2.
  * Theorem 4.2  reaching tolerance eps forces  sigma^k < eps / <v, v>.
  * Def 5.1      polynomial filter  mpFilter(L, alphas) = prod_i (I - alpha_i L).
  * Theorem 5.2  harmonics (L h = 0) are fixed by every p(0)=1 filter.
  * Theorem 5.3  the filter acts on a mode as the scalar  p(nu) = prod_i (1 - alpha_i nu).
  * Theorem 5.4  energy scales by  p(nu)^2.
  * Theorem 5.5  heavy-ball filter is the quadratic  I - (a+b) L + ab L^2.

Self-contained: requires only ``numpy``.
"""

from __future__ import annotations

import math
from typing import List, Tuple

import numpy as np


# --------------------------------------------------------------------------- #
# Core operators                                                              #
# --------------------------------------------------------------------------- #
def mp_step(L: np.ndarray, alpha: float) -> np.ndarray:
    """One message-passing layer  I - alpha * L  as a dense matrix."""
    n = L.shape[0]
    return np.eye(n) - alpha * L


def mp_step_power(L: np.ndarray, alpha: float, k: int) -> np.ndarray:
    """Depth-k message passing  (I - alpha L)^k."""
    return np.linalg.matrix_power(mp_step(L, alpha), k)


def mp_filter(L: np.ndarray, alphas: List[float]) -> np.ndarray:
    """Polynomial filter  prod_i (I - alpha_i L)  (Definition 5.1)."""
    n = L.shape[0]
    out = np.eye(n)
    for a in alphas:
        out = mp_step(L, a) @ out
    return out


def energy(v: np.ndarray) -> float:
    """Inner-product energy  <v, v>  on R^n."""
    return float(np.dot(v, v))


def filter_scalar(alphas: List[float], nu: float) -> float:
    """p(nu) = prod_i (1 - alpha_i nu)  (Theorem 5.3)."""
    p = 1.0
    for a in alphas:
        p *= (1.0 - a * nu)
    return p


# --------------------------------------------------------------------------- #
# Example operator: a path-graph Laplacian (small spectral gap)              #
# --------------------------------------------------------------------------- #
def path_laplacian(n: int) -> np.ndarray:
    """Combinatorial Laplacian of the path graph on n nodes (symmetric PSD)."""
    L = np.zeros((n, n))
    for i in range(n - 1):
        L[i, i] += 1.0
        L[i + 1, i + 1] += 1.0
        L[i, i + 1] -= 1.0
        L[i + 1, i] -= 1.0
    return L


def spectrum(L: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Eigenvalues (ascending) and orthonormal eigenvectors of symmetric L."""
    w, V = np.linalg.eigh(L)
    return w, V


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_exact_mode_dynamics() -> None:
    print("=" * 70)
    print("Theorems 3.1-3.3 : exact modewise dynamics")
    print("=" * 70)
    n = 8
    L = path_laplacian(n)
    w, V = spectrum(L)
    alpha = 1.0 / w[-1]          # spectral step  alpha = 1 / lambda_max
    # pick a genuine eigenvector (the second smallest -> slowest nonzero mode)
    idx = 1
    nu = w[idx]
    v = V[:, idx]
    print(f"n={n}, alpha={alpha:.6f}, eigenvalue nu={nu:.6f}")

    # Theorem 3.1: one layer scales v by (1 - alpha nu)
    lhs = mp_step(L, alpha) @ v
    rhs = (1.0 - alpha * nu) * v
    print(f"  [3.1] || mpStep v - (1-a nu) v ||      = {np.linalg.norm(lhs - rhs):.3e}")

    # Theorem 3.2 & 3.3: closed-form orbit and exact energy
    print("   k |  measured energy   |  (1-a nu)^(2k)<v,v>  |  abs diff")
    for k in (1, 3, 5, 10, 20):
        xk = mp_step_power(L, alpha, k) @ v
        meas = energy(xk)
        pred = (1.0 - alpha * nu) ** (2 * k) * energy(v)
        print(f"  {k:2d} |  {meas:16.10e} |  {pred:16.10e} |  {abs(meas - pred):.2e}")
    print()


def demo_oversmoothing_depth() -> None:
    print("=" * 70)
    print("Theorems 4.1-4.2 : tight oversmoothing & necessary depth")
    print("=" * 70)
    n = 12
    L = path_laplacian(n)
    w, _ = spectrum(L)
    mu = w[1]                    # spectral gap (smallest nonzero eigenvalue)
    lam = w[-1]
    alpha = 1.0 / lam
    sigma = (1.0 - alpha * mu) ** 2
    print(f"spectral gap mu={mu:.6f}, lambda={lam:.6f}, sigma=(1-a mu)^2={sigma:.6f}")

    vv = 1.0                     # normalized mode energy <v,v> = 1
    for eps in (1e-2, 1e-4, 1e-6):
        # Theorem 4.2 inverted: minimal depth with sigma^k <v,v> < eps
        k_star = math.ceil(math.log(vv / eps) / math.log(1.0 / sigma))
        before = sigma ** (k_star - 1) * vv
        after = sigma ** k_star * vv
        ok = (after < eps <= before)
        print(f"  eps={eps:.0e} -> k* = {k_star:3d}  "
              f"(sigma^(k*-1)={before:.3e} >= eps > sigma^k*={after:.3e})  verified={ok}")
    print("  Depth grows like log(1/eps)/log(1/sigma)  ~  (lambda/mu) log(1/eps).")
    print()


def demo_polynomial_filters() -> None:
    print("=" * 70)
    print("Theorems 5.2-5.5 : polynomial filters")
    print("=" * 70)
    n = 8
    L = path_laplacian(n)
    w, V = spectrum(L)
    alphas = [0.30, 0.55, 0.20]          # a degree-3 filter
    F = mp_filter(L, alphas)

    # Theorem 5.2: harmonic (eigenvalue 0) is fixed exactly
    h = V[:, 0]                          # eigenvector for nu = 0  (constant vector)
    print(f"  [5.2] || mpFilter h - h ||  (h harmonic)  = {np.linalg.norm(F @ h - h):.3e}")

    # Theorem 5.3 & 5.4: filter acts on a mode as the scalar p(nu); energy ~ p(nu)^2
    idx = 3
    nu = w[idx]
    v = V[:, idx]
    p_nu = filter_scalar(alphas, nu)
    print(f"  [5.3] mode nu={nu:.4f}, p(nu)={p_nu:.6f}")
    print(f"        || mpFilter v - p(nu) v ||         = {np.linalg.norm(F @ v - p_nu * v):.3e}")
    meas = energy(F @ v)
    pred = p_nu ** 2 * energy(v)
    print(f"  [5.4] energy meas={meas:.6e}, p(nu)^2<v,v>={pred:.6e}, diff={abs(meas-pred):.2e}")

    # Theorem 5.5: heavy-ball composition is the quadratic  I - (a+b)L + ab L^2
    a, b = 0.4, 0.25
    lhs = mp_step(L, a) @ mp_step(L, b)
    rhs = np.eye(n) - (a + b) * L + (a * b) * (L @ L)
    print(f"  [5.5] || (I-aL)(I-bL) - (I-(a+b)L+ab L^2) || = {np.linalg.norm(lhs - rhs):.3e}")
    print()


def demo_chebyshev_speedup() -> None:
    print("=" * 70)
    print("Section 5.1 : Chebyshev acceleration on the band [mu, lambda]")
    print("=" * 70)
    mu, lam = 0.1, 4.0
    band = np.linspace(mu, lam, 4001)

    def worst_case(p_vals: np.ndarray) -> float:
        return float(np.max(np.abs(p_vals)))

    # Plain repeated optimal step: p(nu) = (1 - nu/lam)^m
    # Chebyshev optimum value  rho_m = r^m / T_m((lam+mu)/(lam-mu)),  r=(1-sqrt(k))/(1+sqrt(k))
    kappa = mu / lam
    r = (1 - math.sqrt(kappa)) / (1 + math.sqrt(kappa))
    print("   m |  plain max|p|   |  Chebyshev rho_m  |  speedup")
    for m in (2, 4, 8, 16):
        plain = worst_case((1 - band / lam) ** m)
        x = (lam + mu) / (lam - mu)
        Tm = math.cosh(m * math.acosh(x))         # Chebyshev T_m for x > 1
        cheb = r ** m / Tm
        print(f"  {m:2d} |  {plain:13.6e} |  {cheb:14.6e} |  {plain / cheb:7.2f}x")
    print("  Per-degree rate improves from (1 - mu/lam) to ~ (1 - 2 sqrt(mu/lam)).")
    print()


def main() -> None:
    demo_exact_mode_dynamics()
    demo_oversmoothing_depth()
    demo_polynomial_filters()
    demo_chebyshev_speedup()


if __name__ == "__main__":
    main()
