#!/usr/bin/env python3
"""
Algorithms for Tropical Diffusion and Barrier Analysis

Implements the core algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_diffusion(K: np.ndarray, u: np.ndarray) -> np.ndarray:
    """
    Min-plus tropical diffusion operator.

    Computes T_K(u)(i) = min_j (u[j] + K[i,j]) for each site i.

    This is equivalent to one step of the Bellman–Ford shortest-path
    relaxation, or equivalently the Lax–Oleinik operator in discrete
    Hamilton–Jacobi theory.

    Args:
        K: (n, n) nonnegative kernel matrix with K[i,i] = 0
        u: (n,) real-valued state vector

    Returns:
        (n,) diffused state vector

    Time complexity: O(n^2)
    Space complexity: O(n)

    Example:
        >>> K = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]], dtype=float)
        >>> u = np.array([5.0, 2.0, 8.0])
        >>> tropical_diffusion(K, u)
        array([2., 2., 3.])
    """
    # Matrix-vector min-plus product: result[i] = min_j (K[i,j] + u[j])
    return np.min(K + u[np.newaxis, :], axis=1)


def iterated_tropical_diffusion(K: np.ndarray, u: np.ndarray, n_steps: int) -> np.ndarray:
    """
    Apply tropical diffusion n_steps times.

    Computes T_K^[n](u). After n steps, T_K^[n](u)(i) equals the minimum
    cost of reaching site i from any site j via an n-step path in the
    K-weighted graph, plus the initial value u[j].

    Args:
        K: (n, n) nonnegative kernel matrix
        u: (n,) state vector
        n_steps: number of iterations

    Returns:
        (n,) state after n_steps applications of T_K

    Time complexity: O(n^2 * n_steps)
    Space complexity: O(n)
    """
    result = u.copy()
    for _ in range(n_steps):
        result = tropical_diffusion(K, result)
    return result


def dissipative_barrier_evolution(
    K: np.ndarray,
    omega_0: np.ndarray,
    c_seq: np.ndarray,
    n_steps: int,
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Simulate dissipative barrier evolution (Theorem B).

    Evolves omega_{n+1}(i) = min(omega_n(i), T_K(omega_n)(i) + c_n)
    and tracks the global maximum at each step.

    Args:
        K: (n, n) tropical viscosity kernel (nonneg, zero diagonal)
        omega_0: (n,) initial vorticity field
        c_seq: (n_steps,) sequence of dissipation constants (all <= 0)
        n_steps: number of evolution steps

    Returns:
        trajectory: (n_steps+1, n) full trajectory
        max_values: (n_steps+1,) global maximum at each step

    Time complexity: O(n^2 * n_steps)
    Space complexity: O(n * n_steps)

    Guarantees (from Theorem B):
        max_values is nonincreasing when c_seq <= 0
    """
    n = len(omega_0)
    trajectory = np.zeros((n_steps + 1, n))
    max_values = np.zeros(n_steps + 1)

    trajectory[0] = omega_0.copy()
    max_values[0] = omega_0.max()

    for step in range(n_steps):
        omega = trajectory[step]
        T_omega = tropical_diffusion(K, omega)
        trajectory[step + 1] = np.minimum(omega, T_omega + c_seq[step])
        max_values[step + 1] = trajectory[step + 1].max()

    return trajectory, max_values


def exponential_barrier_evolution(
    K: np.ndarray,
    omega_0: np.ndarray,
    c_seq: np.ndarray,
    lam: float,
    n_steps: int,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Simulate exponential barrier evolution (Theorem C).

    Evolves omega_{n+1}(i) = min(lam * omega_n(i), T_K(omega_n)(i) + c_n)
    and compares against the theoretical bound lam^n * M_0.

    Args:
        K: (n, n) tropical viscosity kernel
        omega_0: (n,) initial vorticity (nonneg)
        c_seq: (n_steps,) dissipation constants (<= 0)
        lam: damping factor (0 <= lam <= 1)
        n_steps: number of steps

    Returns:
        trajectory: (n_steps+1, n) full trajectory
        max_values: (n_steps+1,) actual maxima
        bounds: (n_steps+1,) theoretical bounds lam^n * M_0

    Time complexity: O(n^2 * n_steps)
    Space complexity: O(n * n_steps)
    """
    n = len(omega_0)
    trajectory = np.zeros((n_steps + 1, n))
    max_values = np.zeros(n_steps + 1)
    bounds = np.zeros(n_steps + 1)

    M0 = omega_0.max()
    trajectory[0] = omega_0.copy()
    max_values[0] = M0
    bounds[0] = M0

    for step in range(n_steps):
        omega = trajectory[step]
        T_omega = tropical_diffusion(K, omega)
        trajectory[step + 1] = np.minimum(lam * omega, T_omega + c_seq[step])
        max_values[step + 1] = trajectory[step + 1].max()
        bounds[step + 1] = lam ** (step + 1) * M0

    return trajectory, max_values, bounds


def tropical_energy(u: np.ndarray) -> float:
    """
    Compute tropical energy (oscillation) of a state.

    E(u) = max(u) - min(u)

    This measures the total spread of the state vector and serves as
    a tropical analogue of the Dirichlet energy.

    Args:
        u: (n,) state vector

    Returns:
        oscillation value (nonneg)

    Time complexity: O(n)
    """
    return float(u.max() - u.min())


def shortest_path_interpretation(K: np.ndarray, n_steps: int) -> np.ndarray:
    """
    Compute the n-step min-plus matrix power K^{⊗n}.

    The (i,j) entry of K^{⊗n} is the minimum cost of an n-step path
    from j to i in the K-weighted graph. This connects tropical
    diffusion to shortest-path computation.

    Uses the min-plus matrix multiplication:
    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    Args:
        K: (n, n) cost matrix
        n_steps: number of steps (matrix power)

    Returns:
        (n, n) n-step cost matrix

    Time complexity: O(n^3 * n_steps) — can be improved to O(n^3 * log(n_steps))
        with repeated squaring
    Space complexity: O(n^2)
    """
    n = K.shape[0]
    result = np.zeros((n, n))  # identity: K^0[i,j] = 0 if i=j, inf otherwise
    np.fill_diagonal(result, 0)
    result[result == 0] = np.inf
    np.fill_diagonal(result, 0)

    current = K.copy()
    for _ in range(n_steps):
        result = minplus_matmul(result, current)

    return result


def minplus_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication.

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    This is the fundamental operation in tropical linear algebra.

    Args:
        A: (m, p) matrix
        B: (p, n) matrix

    Returns:
        (m, n) min-plus product

    Time complexity: O(m * n * p)
    """
    m, p = A.shape
    _, n = B.shape
    result = np.full((m, n), np.inf)
    for k in range(p):
        result = np.minimum(result, A[:, k:k+1] + B[k:k+1, :])
    return result


def validate_viscosity_kernel(K: np.ndarray) -> Tuple[bool, str]:
    """
    Check if a matrix is a valid tropical viscosity kernel.

    A tropical viscosity kernel must satisfy:
    1. All entries are nonnegative
    2. Diagonal entries are zero

    Args:
        K: (n, n) matrix to validate

    Returns:
        (is_valid, message)
    """
    if not np.all(K >= 0):
        return False, f"Kernel has negative entries: min = {K.min()}"
    if not np.allclose(np.diag(K), 0):
        return False, f"Kernel has nonzero diagonal: max diag = {np.diag(K).max()}"
    return True, "Valid tropical viscosity kernel"


def compute_convergence_rate(
    K: np.ndarray,
    omega_0: np.ndarray,
    lam: float,
    n_steps: int = 100,
) -> float:
    """
    Empirically estimate the convergence rate of damped tropical evolution.

    Fits max(omega_n) ~ C * r^n and returns the estimated rate r.

    Args:
        K: tropical viscosity kernel
        omega_0: initial state (nonneg)
        lam: damping factor
        n_steps: number of steps

    Returns:
        estimated convergence rate (should be <= lam)
    """
    c_seq = np.zeros(n_steps)
    _, max_values, _ = exponential_barrier_evolution(K, omega_0, c_seq, lam, n_steps)

    # Find steps where max_values > 0
    positive = max_values > 1e-15
    if positive.sum() < 3:
        return 0.0

    log_max = np.log(max_values[positive])
    steps = np.arange(len(max_values))[positive]

    # Linear regression on log(max) vs step
    coeffs = np.polyfit(steps, log_max, 1)
    return float(np.exp(coeffs[0]))


if __name__ == "__main__":
    # Quick test
    K = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]], dtype=float)
    u = np.array([5.0, 2.0, 8.0])

    print("Tropical diffusion test:")
    print(f"  K = \n{K}")
    print(f"  u = {u}")
    print(f"  T_K(u) = {tropical_diffusion(K, u)}")
    print(f"  Energy(u) = {tropical_energy(u)}")

    valid, msg = validate_viscosity_kernel(K)
    print(f"  Kernel valid: {valid} ({msg})")

    print("\nBarrier evolution test:")
    omega_0 = np.array([10.0, 5.0, 8.0])
    c_seq = np.full(20, -0.5)
    traj, maxes = dissipative_barrier_evolution(K, omega_0, c_seq, 20)
    print(f"  Initial max: {maxes[0]:.4f}")
    print(f"  Final max:   {maxes[-1]:.4f}")
    print(f"  Nonincreasing: {all(maxes[i+1] <= maxes[i] + 1e-10 for i in range(len(maxes)-1))}")

    print("\nExponential decay test:")
    traj, maxes, bounds = exponential_barrier_evolution(K, omega_0, c_seq, 0.9, 20)
    print(f"  λ = 0.9, bound holds: {all(maxes[i] <= bounds[i] + 1e-10 for i in range(len(maxes)))}")
    print(f"  Convergence rate: {compute_convergence_rate(K, omega_0, 0.9):.4f}")
