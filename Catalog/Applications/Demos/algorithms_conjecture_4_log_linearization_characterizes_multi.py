#!/usr/bin/env python3
"""
algorithms.py — Interaction Detection Algorithms

Implements algorithms for detecting multiplicative separability
of positive bivariate functions, based on the log-linearization theorem.

Three certified detection methods:
  1. Grid-based log interaction defect
  2. Additive decomposition fitting via SVD
  3. Cross-ratio sampling test
"""

import numpy as np
from typing import Callable, Tuple, Optional

BivarFunc = Callable[[np.ndarray, np.ndarray], np.ndarray]


def log_interaction_defect_grid(
    f: BivarFunc,
    x_grid: np.ndarray,
    y_grid: np.ndarray,
) -> Tuple[float, Tuple[int, int, int, int]]:
    """
    Compute the maximum absolute log interaction defect over a grid.

    The log interaction defect at (x1,x2,y1,y2) is:
        |log f(x1,y1) + log f(x2,y2) - log f(x1,y2) - log f(x2,y1)|

    By the Cross-Ratio Theorem, this is 0 for all quadruples iff f is
    multiplicatively separable on the positive quadrant.

    Parameters
    ----------
    f : BivarFunc
        Positive function on the positive quadrant.
    x_grid, y_grid : array-like
        Grid points (must be positive).

    Returns
    -------
    max_defect : float
        Maximum absolute log interaction defect.
    worst_indices : tuple
        (i, j, k, l) indices achieving the maximum.

    Complexity: O(n^2 * m^2) where n = len(x_grid), m = len(y_grid).
    """
    x_grid = np.asarray(x_grid, dtype=float)
    y_grid = np.asarray(y_grid, dtype=float)

    # Evaluate log f on the full grid
    X, Y = np.meshgrid(x_grid, y_grid, indexing='ij')
    log_F = np.log(f(X, Y))  # shape (n, m)

    n, m = log_F.shape
    max_defect = 0.0
    worst = (0, 0, 0, 0)

    for i in range(n):
        for j in range(i + 1, n):
            for k in range(m):
                for l in range(k + 1, m):
                    d = abs(log_F[i, k] + log_F[j, l] - log_F[i, l] - log_F[j, k])
                    if d > max_defect:
                        max_defect = d
                        worst = (i, j, k, l)

    return max_defect, worst


def additive_decomposition_svd(
    f: BivarFunc,
    s_grid: np.ndarray,
    t_grid: np.ndarray,
) -> Tuple[np.ndarray, np.ndarray, float]:
    """
    Fit log f(e^s, e^t) ≈ u(s) + v(t) using SVD of the centered matrix.

    By the Main Theorem, if f is multiplicatively separable, then
    G(s,t) = log f(e^s, e^t) is exactly u(s) + v(t) for some u, v.

    The best rank-1 additive approximation is obtained by:
        u(s) = row_mean(G) - grand_mean(G)/2
        v(t) = col_mean(G) - grand_mean(G)/2

    Parameters
    ----------
    f : BivarFunc
        Positive function on the positive quadrant.
    s_grid, t_grid : array-like
        Grid in log-coordinates.

    Returns
    -------
    u_vals : np.ndarray
        Values of u at s_grid points.
    v_vals : np.ndarray
        Values of v at t_grid points.
    max_residual : float
        Maximum absolute residual |G(s,t) - u(s) - v(t)|.
    """
    s_grid = np.asarray(s_grid, dtype=float)
    t_grid = np.asarray(t_grid, dtype=float)

    S, T = np.meshgrid(s_grid, t_grid, indexing='ij')
    G = np.log(f(np.exp(S), np.exp(T)))

    # Additive decomposition via double centering
    row_means = G.mean(axis=1)
    col_means = G.mean(axis=0)
    grand_mean = G.mean()

    u_vals = row_means - grand_mean / 2
    v_vals = col_means - grand_mean / 2

    # Reconstruct and compute residual
    G_fit = u_vals[:, None] + v_vals[None, :]
    # Adjust constant: the decomposition has a free constant
    # Use the convention that absorbs it optimally
    G_fit_centered = (row_means[:, None] - grand_mean) + (col_means[None, :])
    residual = np.abs(G - G_fit_centered).max()

    return u_vals, v_vals, residual


def cross_ratio_test(
    f: BivarFunc,
    x_samples: np.ndarray,
    y_samples: np.ndarray,
    tol: float = 1e-8,
) -> Tuple[bool, float]:
    """
    Test whether f satisfies the cross-ratio identity on sampled points.

    By the Cross-Ratio Theorem, f is multiplicatively separable iff
    f(x1,y1)*f(x2,y2) = f(x1,y2)*f(x2,y1) for all positive x1,x2,y1,y2.

    This test checks the identity on all pairs from the samples and returns
    the maximum relative deviation.

    Parameters
    ----------
    f : BivarFunc
        Positive function.
    x_samples, y_samples : array-like
        Sample points (positive).
    tol : float
        Tolerance for declaring separability.

    Returns
    -------
    is_separable : bool
        Whether max deviation < tol.
    max_deviation : float
        Maximum relative deviation from the cross-ratio identity.
    """
    x = np.asarray(x_samples, dtype=float)
    y = np.asarray(y_samples, dtype=float)

    max_dev = 0.0

    for i in range(len(x)):
        for j in range(i + 1, len(x)):
            for k in range(len(y)):
                for l in range(k + 1, len(y)):
                    lhs = f(x[i], y[k]) * f(x[j], y[l])
                    rhs = f(x[i], y[l]) * f(x[j], y[k])
                    if rhs > 0:
                        dev = abs(lhs / rhs - 1.0)
                        max_dev = max(max_dev, dev)

    return max_dev < tol, max_dev


def extract_factors(
    f: BivarFunc,
    x_grid: np.ndarray,
    y_grid: np.ndarray,
    x0: float = 1.0,
    y0: float = 1.0,
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Extract approximate factors φ(x), ψ(y) from f(x,y) ≈ φ(x)·ψ(y).

    Uses the basepoint factorization from the Cross-Ratio Theorem:
        φ(x) = f(x, y0)
        ψ(y) = f(x0, y) / f(x0, y0)

    Parameters
    ----------
    f : BivarFunc
        Function to factor.
    x_grid, y_grid : array-like
        Points at which to evaluate factors.
    x0, y0 : float
        Basepoint (must be positive).

    Returns
    -------
    phi_vals : np.ndarray
        φ evaluated at x_grid.
    psi_vals : np.ndarray
        ψ evaluated at y_grid.
    """
    x_grid = np.asarray(x_grid, dtype=float)
    y_grid = np.asarray(y_grid, dtype=float)

    f_x0_y0 = f(x0, y0)
    phi_vals = np.array([f(x, y0) for x in x_grid])
    psi_vals = np.array([f(x0, y) / f_x0_y0 for y in y_grid])

    return phi_vals, psi_vals


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 65)
    print("  MULTIPLICATIVE SEPARABILITY DETECTION ALGORITHMS")
    print("=" * 65)
    print()

    # Define test functions
    f_sep = lambda x, y: x**2 * y**3
    f_nonsep = lambda x, y: (x + y)**2

    grid = np.array([0.5, 1.0, 1.5, 2.0, 3.0, 5.0])
    s_grid = np.linspace(-2, 2, 30)
    t_grid = np.linspace(-2, 2, 30)

    # Test 1: Grid defect
    print("1. Log Interaction Defect (grid-based)")
    print("-" * 50)
    for name, f in [("x^2*y^3", f_sep), ("(x+y)^2", f_nonsep)]:
        defect, worst = log_interaction_defect_grid(f, grid, grid)
        print(f"  {name}: max defect = {defect:.2e} at indices {worst}")
    print()

    # Test 2: SVD decomposition
    print("2. Additive Decomposition (SVD-based)")
    print("-" * 50)
    for name, f in [("x^2*y^3", f_sep), ("(x+y)^2", f_nonsep)]:
        u, v, res = additive_decomposition_svd(f, s_grid, t_grid)
        print(f"  {name}: max residual = {res:.2e}")
    print()

    # Test 3: Cross-ratio test
    print("3. Cross-Ratio Identity Test")
    print("-" * 50)
    for name, f in [("x^2*y^3", f_sep), ("(x+y)^2", f_nonsep)]:
        sep, dev = cross_ratio_test(f, grid, grid)
        print(f"  {name}: separable={sep}, max deviation = {dev:.2e}")
    print()

    # Test 4: Factor extraction
    print("4. Factor Extraction (basepoint method)")
    print("-" * 50)
    x_test = np.array([1.0, 2.0, 3.0])
    phi, psi = extract_factors(f_sep, x_test, x_test)
    print(f"  x^2*y^3 at x=1,2,3:")
    print(f"    φ(x) = f(x,1) = {phi}")
    print(f"    ψ(y) = f(1,y)/f(1,1) = {psi}")
    print(f"    Check: φ(2)*ψ(3) = {phi[1]*psi[2]:.4f}, f(2,3) = {f_sep(2,3):.4f}")
    print()

    print("=" * 65)
    print("  ALL TESTS COMPLETE")
    print("=" * 65)
