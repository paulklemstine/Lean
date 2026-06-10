"""
Algorithms for Fredholm Integral Equations
============================================

This module implements numerical methods for solving Fredholm integral equations
of the second kind:

    u(x) - ∫_a^b K(x,t) u(t) dt = f(x)

based on the theoretical guarantee of the Fredholm Alternative: when the
homogeneous equation has only the trivial solution, the inhomogeneous equation
has a unique solution for every right-hand side f.

Algorithms:
    1. Nyström method (quadrature-based discretization)
    2. Degenerate kernel method (finite-rank approximation)
    3. Iterative Neumann series (when ‖K‖ < 1)
    4. Convergence diagnostics
"""

import numpy as np
from scipy import linalg
from typing import Callable, Tuple, Optional


def nystrom_solve(
    kernel: Callable[[float, float], float],
    f: Callable[[float], float],
    n: int,
    a: float = 0.0,
    b: float = 1.0,
    quadrature: str = "trapezoidal"
) -> Tuple[np.ndarray, np.ndarray, dict]:
    """
    Solve the Fredholm integral equation of the second kind using the Nyström method.

        u(x) - ∫_a^b K(x,t) u(t) dt = f(x)

    Parameters
    ----------
    kernel : callable
        K(x, t) -> float
    f : callable
        Right-hand side function f(x) -> float
    n : int
        Number of discretization points
    a, b : float
        Integration interval [a, b]
    quadrature : str
        Quadrature rule: "trapezoidal" or "simpson"

    Returns
    -------
    grid : ndarray of shape (n,)
        Discretization points
    u : ndarray of shape (n,)
        Approximate solution values at grid points
    info : dict
        Diagnostic information including condition number, eigenvalues, etc.

    Raises
    ------
    ValueError
        If the discretized system is singular (Fredholm Alternative: not injective)

    Algorithm
    ---------
    Time complexity: O(n³) for the linear solve
    Space complexity: O(n²) for the kernel matrix

    The method discretizes the integral using a quadrature rule:
        u(x_i) - Σ_j w_j K(x_i, x_j) u(x_j) = f(x_i)

    where x_j are quadrature nodes and w_j are weights.
    """
    h = (b - a) / (n - 1)
    grid = np.linspace(a, b, n)

    # Build kernel matrix with quadrature weights
    K_mat = np.zeros((n, n))
    if quadrature == "trapezoidal":
        weights = np.full(n, h)
        weights[0] = weights[-1] = h / 2
    elif quadrature == "simpson":
        if n % 2 == 0:
            n += 1  # Simpson needs odd number of points
            grid = np.linspace(a, b, n)
            h = (b - a) / (n - 1)
        weights = np.zeros(n)
        weights[0] = weights[-1] = h / 3
        weights[1::2] = 4 * h / 3
        weights[2:-1:2] = 2 * h / 3
    else:
        raise ValueError(f"Unknown quadrature: {quadrature}")

    for i in range(n):
        for j in range(n):
            K_mat[i, j] = weights[j] * kernel(grid[i], grid[j])

    I_minus_K = np.eye(n) - K_mat

    # Compute diagnostics
    eigenvalues = linalg.eigvals(K_mat)
    cond_number = np.linalg.cond(I_minus_K)
    det_val = np.abs(linalg.det(I_minus_K))

    info = {
        "condition_number": cond_number,
        "determinant": det_val,
        "eigenvalues_K": eigenvalues,
        "min_dist_eigenvalue_to_one": np.min(np.abs(eigenvalues - 1.0)),
        "kernel_matrix_norm": np.linalg.norm(K_mat, 2),
        "n_points": n,
    }

    # Check if (I - K) is nearly singular
    if det_val < 1e-12:
        raise ValueError(
            f"System is (nearly) singular: |det(I-K)| = {det_val:.2e}. "
            f"The Fredholm Alternative indicates (I-K) is not injective: "
            f"the homogeneous equation has nontrivial solutions."
        )

    # Solve the linear system
    f_vec = np.array([f(x) for x in grid])
    u = linalg.solve(I_minus_K, f_vec)
    info["residual"] = np.max(np.abs(I_minus_K @ u - f_vec))

    return grid, u, info


def degenerate_kernel_solve(
    phi_funcs: list,
    psi_funcs: list,
    f: Callable[[float], float],
    n: int = 100,
    a: float = 0.0,
    b: float = 1.0,
) -> Tuple[np.ndarray, np.ndarray, dict]:
    """
    Solve Fredholm equation with a degenerate (separable) kernel:

        K(x,t) = Σ_{k=1}^r φ_k(x) ψ_k(t)

    The solution has the form u(x) = f(x) + Σ_{k=1}^r c_k φ_k(x),
    where the coefficients c_k satisfy a finite linear system.

    Parameters
    ----------
    phi_funcs : list of callables
        The functions φ_k(x)
    psi_funcs : list of callables
        The functions ψ_k(t)
    f : callable
        Right-hand side f(x)
    n : int
        Number of points for numerical integration
    a, b : float
        Integration interval

    Returns
    -------
    grid : ndarray
    u : ndarray
    info : dict

    Algorithm
    ---------
    Time complexity: O(r² n + r³) where r = len(phi_funcs)
    Space complexity: O(r² + rn)

    For degenerate kernels, the infinite-dimensional equation reduces to a
    finite r × r linear system. This is the prototype of the Fredholm theory:
    the operator K has finite-dimensional range.
    """
    r = len(phi_funcs)
    assert len(psi_funcs) == r, "Must have equal numbers of φ and ψ functions"

    grid = np.linspace(a, b, n)
    h = (b - a) / (n - 1)

    # Compute the r × r system matrix A where A_{ij} = δ_{ij} - ∫ψ_i(t)φ_j(t)dt
    A = np.eye(r)
    for i in range(r):
        for j in range(r):
            integrand = np.array([psi_funcs[i](t) * phi_funcs[j](t) for t in grid])
            A[i, j] -= np.trapezoid(integrand, grid)

    # Compute right-hand side: b_i = ∫ψ_i(t) f(t) dt
    rhs = np.zeros(r)
    for i in range(r):
        integrand = np.array([psi_funcs[i](t) * f(t) for t in grid])
        rhs[i] = np.trapezoid(integrand, grid)

    # Solve the finite system
    info = {
        "rank": r,
        "system_matrix": A,
        "system_det": np.abs(linalg.det(A)),
        "system_cond": np.linalg.cond(A),
    }

    if np.abs(linalg.det(A)) < 1e-12:
        raise ValueError("Degenerate kernel system is singular")

    coeffs = linalg.solve(A, rhs)
    info["coefficients"] = coeffs

    # Reconstruct solution
    f_vals = np.array([f(x) for x in grid])
    u = f_vals.copy()
    for k in range(r):
        u += coeffs[k] * np.array([phi_funcs[k](x) for x in grid])

    return grid, u, info


def neumann_series_solve(
    kernel: Callable[[float, float], float],
    f: Callable[[float], float],
    n: int = 100,
    max_iter: int = 100,
    tol: float = 1e-10,
    a: float = 0.0,
    b: float = 1.0,
) -> Tuple[np.ndarray, np.ndarray, dict]:
    """
    Solve the Fredholm equation using the Neumann series (successive approximations):

        u = f + Kf + K²f + K³f + ...

    This converges when ‖K‖ < 1, which is a sufficient (but not necessary)
    condition for (I - K) to be invertible.

    Parameters
    ----------
    kernel : callable
    f : callable
    n : int
        Discretization points
    max_iter : int
        Maximum number of iterations
    tol : float
        Convergence tolerance
    a, b : float
        Integration interval

    Returns
    -------
    grid, u, info

    Algorithm
    ---------
    Time complexity: O(iter × n²) where iter is the number of iterations
    Space complexity: O(n²)

    Convergence: geometric rate with ratio ‖K‖ < 1.
    """
    h = (b - a) / (n - 1)
    grid = np.linspace(a, b, n)

    # Build kernel matrix
    K_mat = np.zeros((n, n))
    weights = np.full(n, h)
    weights[0] = weights[-1] = h / 2
    for i in range(n):
        for j in range(n):
            K_mat[i, j] = weights[j] * kernel(grid[i], grid[j])

    K_norm = np.linalg.norm(K_mat, 2)
    f_vec = np.array([f(x) for x in grid])

    info = {
        "operator_norm": K_norm,
        "converges": K_norm < 1,
        "iterations": [],
    }

    if K_norm >= 1:
        info["warning"] = f"‖K‖ = {K_norm:.4f} >= 1, convergence not guaranteed"

    # Neumann series: u = Σ_{k=0}^∞ K^k f
    u = f_vec.copy()
    term = f_vec.copy()

    for k in range(1, max_iter + 1):
        term = K_mat @ term
        u += term
        residual = np.max(np.abs(term))
        info["iterations"].append({"k": k, "residual": residual})
        if residual < tol:
            info["converged"] = True
            info["n_iterations"] = k
            break
    else:
        info["converged"] = False
        info["n_iterations"] = max_iter

    return grid, u, info


def convergence_analysis(
    kernel: Callable[[float, float], float],
    f: Callable[[float], float],
    u_exact: Optional[Callable[[float], float]] = None,
    ns: list = None,
    a: float = 0.0,
    b: float = 1.0,
) -> dict:
    """
    Perform convergence analysis of the Nyström method.

    Parameters
    ----------
    kernel : callable
    f : callable
    u_exact : callable, optional
        Exact solution for error computation
    ns : list of int
        Discretization sizes to test
    a, b : float
        Integration interval

    Returns
    -------
    results : dict with convergence data
    """
    if ns is None:
        ns = [10, 20, 40, 80, 160, 320]

    results = {"ns": ns, "errors": [], "condition_numbers": [], "residuals": []}

    u_ref = None
    for n in ns:
        grid, u, info = nystrom_solve(kernel, f, n, a, b)
        results["condition_numbers"].append(info["condition_number"])
        results["residuals"].append(info["residual"])

        if u_exact is not None:
            exact = np.array([u_exact(x) for x in grid])
            error = np.max(np.abs(u - exact))
            results["errors"].append(error)
        elif u_ref is not None:
            # Compare with previous (coarser) solution via interpolation
            u_interp = np.interp(grid[::2], grid, u) if len(grid) == 2 * len(u_ref) - 1 else None
        u_ref = u.copy()

    return results


# Example usage
if __name__ == "__main__":
    print("Fredholm Integral Equation Solvers")
    print("=" * 50)

    # Example 1: Nyström method
    print("\n--- Nyström Method ---")
    kernel = lambda x, t: x * t
    f = lambda x: 1.0
    grid, u, info = nystrom_solve(kernel, f, 100)
    print(f"Condition number: {info['condition_number']:.4f}")
    print(f"Residual: {info['residual']:.2e}")

    # Example 2: Degenerate kernel
    print("\n--- Degenerate Kernel Method ---")
    phi = [lambda x: x]
    psi = [lambda t: t]
    grid, u, info = degenerate_kernel_solve(phi, psi, f)
    print(f"System rank: {info['rank']}")
    print(f"Coefficients: {info['coefficients']}")

    # Example 3: Neumann series
    print("\n--- Neumann Series ---")
    kernel_small = lambda x, t: 0.3 * x * t  # ‖K‖ < 1
    grid, u, info = neumann_series_solve(kernel_small, f, n=100)
    print(f"Operator norm: {info['operator_norm']:.4f}")
    print(f"Converged: {info.get('converged', 'N/A')}")
    print(f"Iterations: {info.get('n_iterations', 'N/A')}")

    # Example 4: Convergence analysis
    print("\n--- Convergence Analysis ---")
    u_exact = lambda x: 1 + 1.5 * x
    results = convergence_analysis(kernel, f, u_exact)
    for n, err in zip(results["ns"], results["errors"]):
        print(f"  n = {n:4d}: error = {err:.2e}")
