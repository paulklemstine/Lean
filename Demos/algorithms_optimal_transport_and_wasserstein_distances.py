#!/usr/bin/env python3
"""
Optimal Transport Algorithms with Verified Certificates

Implements:
1. Monotone transport solver for 1D quadratic cost
2. Primal-dual certificate generation
3. Sinkhorn entropic regularization
4. Coupling verification utilities
"""

import numpy as np
from typing import Tuple, Optional
from scipy.optimize import linprog


def monotone_transport_1d(
    x: np.ndarray, y: np.ndarray,
    mu: np.ndarray, nu: np.ndarray
) -> Tuple[np.ndarray, float]:
    """
    Compute the monotone (north-west corner) transport plan for 1D distributions
    with quadratic cost c(x_i, y_j) = (x_i - y_j)^2.
    
    For sorted source and target points, monotone transport is optimal
    (discrete Brenier theorem). This function assumes x and y are sorted.
    
    Args:
        x: Source point locations (sorted ascending), shape (m,)
        y: Target point locations (sorted ascending), shape (n,)
        mu: Source weights, shape (m,), sum to 1
        nu: Target weights, shape (n,), sum to 1
    
    Returns:
        pi: Optimal coupling matrix, shape (m, n)
        cost: Optimal transport cost
        
    Complexity: O(m + n) time, O(mn) space for the coupling matrix.
    
    Example:
        >>> x = np.array([0.0, 1.0, 2.0])
        >>> y = np.array([0.5, 1.5, 2.5])
        >>> mu = np.array([1/3, 1/3, 1/3])
        >>> nu = np.array([1/3, 1/3, 1/3])
        >>> pi, cost = monotone_transport_1d(x, y, mu, nu)
    """
    m, n = len(mu), len(nu)
    pi = np.zeros((m, n))
    
    # North-west corner rule for sorted distributions
    mu_remaining = mu.copy()
    nu_remaining = nu.copy()
    
    i, j = 0, 0
    while i < m and j < n:
        transport = min(mu_remaining[i], nu_remaining[j])
        pi[i, j] = transport
        mu_remaining[i] -= transport
        nu_remaining[j] -= transport
        
        if mu_remaining[i] < 1e-15:
            i += 1
        if nu_remaining[j] < 1e-15:
            j += 1
    
    # Compute quadratic cost
    cost_matrix = (x[:, np.newaxis] - y[np.newaxis, :]) ** 2
    cost = np.sum(cost_matrix * pi)
    
    return pi, cost


def primal_dual_certificate(
    c: np.ndarray, mu: np.ndarray, nu: np.ndarray
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, float, float, bool]:
    """
    Compute optimal transport with a verified primal-dual certificate.
    
    Returns a coupling π, dual potentials (φ, ψ), and verifies:
    1. Admissibility: φ(a) + ψ(b) ≤ c(a,b) for all a, b
    2. Marginals: π has correct marginals
    3. Strong duality: transport_cost(c, π) = dual_value(μ, ν, φ, ψ)
    4. Complementary slackness: π(a,b) > 0 → φ(a) + ψ(b) = c(a,b)
    
    Args:
        c: Cost matrix, shape (m, n)
        mu: Source distribution, shape (m,)
        nu: Target distribution, shape (n,)
    
    Returns:
        pi: Optimal coupling
        phi: Dual potential on source
        psi: Dual potential on target
        primal_cost: Transport cost
        dual_val: Dual objective value
        certified: True if all certificate checks pass
        
    Complexity: O(m*n * max(m,n)) via LP solver.
    """
    m, n = c.shape
    
    # Solve primal LP
    c_flat = c.flatten()
    A_eq = np.zeros((m + n, m * n))
    b_eq = np.concatenate([mu, nu])
    
    for i in range(m):
        for j in range(n):
            A_eq[i, i * n + j] = 1.0
            A_eq[m + j, i * n + j] = 1.0
    
    result = linprog(c_flat, A_eq=A_eq, b_eq=b_eq,
                     bounds=[(0, None)] * (m * n), method='highs')
    
    pi = result.x.reshape(m, n)
    primal_cost = result.fun
    
    # Compute dual potentials via c-transform
    phi = np.zeros(m)
    psi = np.zeros(n)
    
    # c-transform iteration
    for _ in range(200):
        psi_new = np.array([np.min(c[:, j] - phi) for j in range(n)])
        phi_new = np.array([np.min(c[i, :] - psi_new) for i in range(m)])
        if np.max(np.abs(phi_new - phi)) + np.max(np.abs(psi_new - psi)) < 1e-14:
            phi, psi = phi_new, psi_new
            break
        phi, psi = phi_new, psi_new
    
    dual_val = np.dot(phi, mu) + np.dot(psi, nu)
    
    # Certificate checks
    tol = 1e-8
    
    # 1. Admissibility
    admissible = np.all(phi[:, np.newaxis] + psi[np.newaxis, :] <= c + tol)
    
    # 2. Marginals
    left_ok = np.allclose(pi.sum(axis=1), mu, atol=tol)
    right_ok = np.allclose(pi.sum(axis=0), nu, atol=tol)
    
    # 3. Nonnegativity
    nonneg = np.all(pi >= -tol)
    
    # 4. Strong duality (gap)
    gap = abs(primal_cost - dual_val)
    duality_ok = gap < tol
    
    # 5. Complementary slackness
    cs_ok = True
    for i in range(m):
        for j in range(n):
            if pi[i, j] > tol:
                if abs(phi[i] + psi[j] - c[i, j]) > tol:
                    cs_ok = False
    
    certified = admissible and left_ok and right_ok and nonneg and duality_ok and cs_ok
    
    return pi, phi, psi, primal_cost, dual_val, certified


def sinkhorn_transport(
    c: np.ndarray, mu: np.ndarray, nu: np.ndarray,
    epsilon: float = 0.1, max_iter: int = 1000, tol: float = 1e-9
) -> Tuple[np.ndarray, float, int]:
    """
    Sinkhorn algorithm for entropy-regularized optimal transport.
    
    Solves: min_π ∑ c_{ij} π_{ij} + ε ∑ π_{ij} log(π_{ij})
    subject to marginal constraints.
    
    The solution is of the form π_{ij} = u_i K_{ij} v_j where K = exp(-c/ε).
    
    Args:
        c: Cost matrix, shape (m, n)
        mu: Source distribution, shape (m,)
        nu: Target distribution, shape (n,)
        epsilon: Regularization parameter
        max_iter: Maximum Sinkhorn iterations
        tol: Convergence tolerance
    
    Returns:
        pi: Approximate optimal coupling
        cost: Transport cost (without entropy term)
        n_iter: Number of iterations used
        
    Complexity: O(mn * max_iter) time.
    """
    K = np.exp(-c / epsilon)
    
    u = np.ones(len(mu))
    v = np.ones(len(nu))
    
    for it in range(max_iter):
        u_new = mu / (K @ v)
        v_new = nu / (K.T @ u_new)
        
        if np.max(np.abs(u_new - u)) + np.max(np.abs(v_new - v)) < tol:
            u, v = u_new, v_new
            break
        u, v = u_new, v_new
    
    pi = np.diag(u) @ K @ np.diag(v)
    cost = np.sum(c * pi)
    
    return pi, cost, it + 1


def verify_coupling(
    pi: np.ndarray, mu: np.ndarray, nu: np.ndarray, tol: float = 1e-8
) -> dict:
    """
    Verify all properties of a coupling matrix.
    
    Returns a dictionary with verification results.
    """
    results = {
        'nonneg': bool(np.all(pi >= -tol)),
        'left_marginal': bool(np.allclose(pi.sum(axis=1), mu, atol=tol)),
        'right_marginal': bool(np.allclose(pi.sum(axis=0), nu, atol=tol)),
        'total_mass': float(pi.sum()),
        'max_violation_left': float(np.max(np.abs(pi.sum(axis=1) - mu))),
        'max_violation_right': float(np.max(np.abs(pi.sum(axis=0) - nu))),
        'support_size': int(np.sum(pi > tol)),
    }
    results['valid'] = results['nonneg'] and results['left_marginal'] and results['right_marginal']
    return results


def wasserstein_1(
    d: np.ndarray, mu: np.ndarray, nu: np.ndarray
) -> float:
    """
    Compute the Wasserstein-1 distance between two distributions
    on a finite metric space.
    
    Args:
        d: Distance matrix, shape (n, n)
        mu, nu: Probability distributions, shape (n,)
    
    Returns:
        W1 distance
    """
    _, cost, _, _, _, _ = primal_dual_certificate(d, mu, nu)
    return cost


if __name__ == "__main__":
    # Example usage
    print("=== Monotone Transport (1D) ===")
    x = np.array([0.0, 1.0, 2.0, 3.0])
    y = np.array([0.5, 1.5, 2.5, 3.5])
    mu = np.array([0.25, 0.25, 0.25, 0.25])
    nu = np.array([0.25, 0.25, 0.25, 0.25])
    
    pi, cost = monotone_transport_1d(x, y, mu, nu)
    print(f"Optimal coupling:\n{pi}")
    print(f"Cost: {cost:.6f}")
    
    print("\n=== Primal-Dual Certificate ===")
    c = (x[:, None] - y[None, :]) ** 2
    pi, phi, psi, pc, dv, cert = primal_dual_certificate(c, mu, nu)
    print(f"Primal cost: {pc:.6f}")
    print(f"Dual value: {dv:.6f}")
    print(f"Certified: {cert}")
    
    print("\n=== Sinkhorn (ε=0.1) ===")
    pi_sink, cost_sink, iters = sinkhorn_transport(c, mu, nu, epsilon=0.1)
    print(f"Sinkhorn cost: {cost_sink:.6f}")
    print(f"Iterations: {iters}")
    print(f"Coupling valid: {verify_coupling(pi_sink, mu, nu)['valid']}")
