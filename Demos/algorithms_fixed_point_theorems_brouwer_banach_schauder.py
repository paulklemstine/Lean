#!/usr/bin/env python3
"""
Fixed Point Theory: Algorithm Implementations

Implements the core algorithms from the research paper with
complete docstrings, type hints, and example usage.
"""

import numpy as np
from typing import Callable, Tuple, Optional, List


def banach_iterate(
    f: Callable[[np.ndarray], np.ndarray],
    x0: np.ndarray,
    K: float,
    tol: float = 1e-10,
    max_iter: int = 1000,
) -> Tuple[np.ndarray, List[float], int]:
    """
    Certified Banach contraction iteration with a priori error bound.

    Given a contraction f with constant K < 1, iterates x_{n+1} = f(x_n)
    and returns the approximate fixed point with certified error bounds.

    Args:
        f: Contraction mapping.
        x0: Initial point (numpy array).
        K: Contraction constant (must satisfy 0 ≤ K < 1).
        tol: Desired precision ε.
        max_iter: Maximum iterations.

    Returns:
        (x_star, errors, n_iter): Approximate fixed point, list of
        a priori error bounds K^n * d(x0, f(x0)) / (1-K), and
        number of iterations.

    Raises:
        ValueError: If K ≥ 1 or K < 0.

    Example:
        >>> f = lambda x: np.array([np.cos(x[0])])
        >>> x, errs, n = banach_iterate(f, np.array([0.0]), K=0.85)
        >>> print(f"Fixed point: {x[0]:.10f}, iterations: {n}")
    """
    if not (0 <= K < 1):
        raise ValueError(f"Contraction constant K={K} must satisfy 0 ≤ K < 1")

    x = x0.copy()
    d0 = np.linalg.norm(f(x0) - x0)
    errors = []

    for n in range(max_iter):
        error_bound = K**n / (1 - K) * d0
        errors.append(error_bound)

        if error_bound < tol:
            return x, errors, n

        x = f(x)

    return x, errors, max_iter


def approximate_brouwer_witness(
    f: Callable[[np.ndarray], np.ndarray],
    dim: int,
    grid_size: int = 100,
) -> Tuple[np.ndarray, float]:
    """
    Find an approximate Brouwer fixed point via grid search.

    For a continuous self-map f: [0,1]^d → [0,1]^d, searches a uniform
    grid for the point minimizing ||f(x) - x||.

    Args:
        f: Continuous function mapping [0,1]^d to [0,1]^d.
        dim: Dimension d.
        grid_size: Number of grid points per dimension.

    Returns:
        (x_approx, residual): Best approximate fixed point and its residual.

    Complexity:
        Time: O(grid_size^dim * dim)
        Space: O(grid_size^dim * dim)

    Example:
        >>> f = lambda x: np.clip([0.5 + 0.3*np.sin(x[0]), 0.5 + 0.2*np.cos(x[1])], 0, 1)
        >>> x, r = approximate_brouwer_witness(f, dim=2, grid_size=50)
        >>> print(f"Approx FP: {x}, residual: {r:.2e}")
    """
    # Generate grid points
    axes = [np.linspace(0, 1, grid_size) for _ in range(dim)]
    grids = np.meshgrid(*axes, indexing='ij')
    points = np.stack([g.ravel() for g in grids], axis=-1)

    best_residual = float('inf')
    best_point = points[0]

    for p in points:
        fp = np.asarray(f(p))
        residual = np.linalg.norm(fp - p)
        if residual < best_residual:
            best_residual = residual
            best_point = p.copy()

    return best_point, best_residual


def compactness_upgrade(
    f: Callable[[np.ndarray], np.ndarray],
    approx_fp_sequence: Callable[[float], np.ndarray],
    eps_sequence: Optional[List[float]] = None,
    tol: float = 1e-12,
) -> Tuple[np.ndarray, float]:
    """
    Compactness upgrade: refine approximate fixed points to near-exact.

    Given a function that produces ε-approximate fixed points for
    decreasing ε, extracts a limit that is (numerically) an exact
    fixed point.

    Args:
        f: The map.
        approx_fp_sequence: Function ε → x_ε with ||f(x_ε) - x_ε|| ≤ ε.
        eps_sequence: Decreasing sequence of ε values.
        tol: Convergence tolerance.

    Returns:
        (x_star, final_residual): Near-exact fixed point and its residual.
    """
    if eps_sequence is None:
        eps_sequence = [10**(-k) for k in range(1, 15)]

    x_prev = approx_fp_sequence(eps_sequence[0])

    for eps in eps_sequence[1:]:
        x_curr = approx_fp_sequence(eps)
        residual = np.linalg.norm(f(x_curr) - x_curr)

        if residual < tol:
            return x_curr, residual

        x_prev = x_curr

    final_residual = np.linalg.norm(f(x_prev) - x_prev)
    return x_prev, final_residual


def volterra_picard_iteration(
    kernel: Callable[[float, float], float],
    g: Callable[[float], float],
    lam: float,
    N: int = 200,
    max_iter: int = 50,
    tol: float = 1e-10,
) -> Tuple[np.ndarray, np.ndarray, int]:
    """
    Solve the Volterra integral equation by Picard iteration.

    Solves: u(x) = g(x) + λ ∫₀ˣ K(x,t) u(t) dt

    Uses the Banach contraction principle when |λ| · max|K| < 1.

    Args:
        kernel: Kernel function K(x, t).
        g: Forcing function g(x).
        lam: Coupling constant λ.
        N: Number of discretization points.
        max_iter: Maximum Picard iterations.
        tol: Convergence tolerance.

    Returns:
        (xs, u, n_iter): Grid points, solution values, iteration count.

    Example:
        >>> xs, u, n = volterra_picard_iteration(
        ...     kernel=lambda x, t: 1.0,
        ...     g=lambda x: 1.0,
        ...     lam=0.3
        ... )
    """
    xs = np.linspace(0, 1, N)
    h = xs[1] - xs[0]
    u = np.array([g(x) for x in xs])

    for n in range(max_iter):
        u_new = np.array([g(x) for x in xs])
        for i in range(N):
            integral = 0.0
            for j in range(i + 1):
                w_val = h if (0 < j < i) else h / 2
                integral += w_val * kernel(xs[i], xs[j]) * u[j]
            u_new[i] += lam * integral

        if np.max(np.abs(u_new - u)) < tol:
            return xs, u_new, n + 1
        u = u_new

    return xs, u, max_iter


def certified_contraction_data(
    f: Callable,
    domain_sample: np.ndarray,
) -> Tuple[float, bool]:
    """
    Empirically estimate the contraction constant of f.

    Samples pairs of points and computes the supremum of
    ||f(x) - f(y)|| / ||x - y||.

    Args:
        f: The map to test.
        domain_sample: Array of sample points, shape (n, d).

    Returns:
        (K_est, is_contraction): Estimated contraction constant and
        whether K_est < 1.
    """
    n = len(domain_sample)
    K_est = 0.0

    for i in range(n):
        for j in range(i + 1, n):
            x, y = domain_sample[i], domain_sample[j]
            d_xy = np.linalg.norm(x - y)
            if d_xy < 1e-15:
                continue
            d_fxy = np.linalg.norm(f(x) - f(y))
            K_est = max(K_est, d_fxy / d_xy)

    return K_est, K_est < 1.0


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm Examples")
    print("=" * 50)

    # Example 1: Banach iteration
    print("\n1. Banach Iteration for cos(x) = x:")
    f = lambda x: np.array([np.cos(x[0])])
    x_star, errs, n = banach_iterate(f, np.array([0.0]), K=0.85)
    print(f"   Fixed point: {x_star[0]:.12f}")
    print(f"   Iterations: {n}")
    print(f"   Final error bound: {errs[-1]:.2e}")

    # Example 2: Brouwer witness
    print("\n2. Approximate Brouwer Witness (2D):")
    g = lambda x: np.clip([0.5 + 0.3 * np.sin(x[0]), 0.5 + 0.2 * np.cos(x[1])], 0, 1)
    x_approx, residual = approximate_brouwer_witness(g, dim=2, grid_size=100)
    print(f"   Approx FP: ({x_approx[0]:.6f}, {x_approx[1]:.6f})")
    print(f"   Residual: {residual:.2e}")

    # Example 3: Volterra equation
    print("\n3. Volterra Integral Equation:")
    xs, u, n = volterra_picard_iteration(
        kernel=lambda x, t: 1.0,
        g=lambda x: 1.0,
        lam=0.3,
    )
    true_sol = np.exp(0.3 * xs)
    print(f"   Iterations: {n}")
    print(f"   Max error vs exp(0.3x): {np.max(np.abs(u - true_sol)):.2e}")

    # Example 4: Contraction estimation
    print("\n4. Contraction Constant Estimation:")
    h = lambda x: np.array([0.5 * x[0] + 0.3])
    samples = np.linspace(0, 1, 50).reshape(-1, 1)
    K_est, is_contr = certified_contraction_data(h, samples)
    print(f"   Estimated K = {K_est:.6f}")
    print(f"   Is contraction: {is_contr}")
