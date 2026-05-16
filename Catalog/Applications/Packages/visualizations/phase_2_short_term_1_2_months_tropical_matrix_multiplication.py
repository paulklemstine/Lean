#!/usr/bin/env python3
"""
Algorithms for Tropical-Transport Theory

Implements the core algorithms arising from the formalized theory:
1. Tropical matrix multiplication and powers
2. Tropical eigenvalue computation (cycle mean)
3. Wasserstein distance via LP
4. Assignment problem (Hungarian-style)
5. Sinkhorn projections for transport plans
"""

import numpy as np
from typing import Tuple, List, Optional


# ============================================================
# TROPICAL MATRIX ALGEBRA
# ============================================================

def tropical_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus (tropical) matrix multiplication.

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    Complexity: O(n³) where n is the matrix dimension.

    Args:
        A: n×n real matrix
        B: n×n real matrix

    Returns:
        n×n matrix with (A⊗B)[i,j] = min_k(A[i,k] + B[k,j])
    """
    n = A.shape[0]
    # Vectorized: for each (i,j), compute min over k
    # A[i,:] has shape (n,), B[:,j] has shape (n,)
    # We want min_k A[i,k] + B[k,j]
    C = np.min(A[:, :, None] + B[None, :, :], axis=1)
    return C


def tropical_power(A: np.ndarray, m: int) -> np.ndarray:
    """Compute the m-th tropical power A^⊗m.

    Uses repeated squaring for efficiency when m is large.

    Complexity: O(n³ log m)

    Args:
        A: n×n real matrix
        m: power (must be ≥ 1)

    Returns:
        A^⊗m (m-fold tropical product)
    """
    if m <= 0:
        raise ValueError("Power must be positive")
    if m == 1:
        return A.copy()

    result = A.copy()
    base = A.copy()
    m -= 1
    while m > 0:
        if m % 2 == 1:
            result = tropical_multiply(result, base)
        base = tropical_multiply(base, base)
        m //= 2
    return result


def tropical_eigenvalue(A: np.ndarray, max_power: int = 100) -> Tuple[float, np.ndarray]:
    """Compute the tropical eigenvalue (minimum cycle mean) of A.

    By the subadditivity theorem (tropPow_diag_subadditive),
    the diagonal entries of tropical powers satisfy
        a_{m+k} ≤ a_m + a_k
    and by Fekete's lemma, the limit
        λ = lim_{n→∞} a_n / n = inf_{n≥1} a_n / n
    exists and equals the minimum cycle mean.

    Complexity: O(n⁴) via Karp's algorithm (we use the naive approach here).

    Args:
        A: n×n real matrix
        max_power: maximum power to compute

    Returns:
        (eigenvalue, cycle_means) where eigenvalue is the minimum
        cycle mean and cycle_means[i] is the cycle mean for vertex i.
    """
    n = A.shape[0]
    cycle_means = np.full(n, np.inf)

    current = A.copy()
    for m in range(1, max_power + 1):
        for i in range(n):
            cycle_means[i] = min(cycle_means[i], current[i, i] / m)
        if m < max_power:
            current = tropical_multiply(current, A)

    eigenvalue = np.min(cycle_means)
    return eigenvalue, cycle_means


def karp_cycle_mean(A: np.ndarray) -> Tuple[float, List[int]]:
    """Karp's algorithm for minimum cycle mean.

    Computes the minimum average weight cycle in a weighted digraph
    represented by matrix A. This is the tropical eigenvalue.

    Complexity: O(n³) time, O(n²) space.

    Args:
        A: n×n weight matrix (A[i,j] = weight of edge i→j, np.inf if no edge)

    Returns:
        (min_mean, cycle) where min_mean is the minimum cycle mean
        and cycle is a list of vertices forming the optimal cycle.
    """
    n = A.shape[0]

    # D[k][v] = minimum weight of a k-edge walk ending at v
    D = np.full((n + 1, n), np.inf)
    # Predecessor for path reconstruction
    pred = np.full((n + 1, n), -1, dtype=int)

    # Base case: 0-edge walks
    for v in range(n):
        D[0][v] = 0  # Start anywhere with cost 0

    # Fill DP table
    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                if D[k-1][u] + A[u][v] < D[k][v]:
                    D[k][v] = D[k-1][u] + A[u][v]
                    pred[k][v] = u

    # Compute cycle means using Karp's formula
    # λ* = min_v max_k (D[n][v] - D[k][v]) / (n - k)
    min_mean = np.inf
    best_v = 0

    for v in range(n):
        max_val = -np.inf
        for k in range(n):
            if D[n][v] < np.inf and D[k][v] < np.inf:
                val = (D[n][v] - D[k][v]) / (n - k)
                max_val = max(max_val, val)
        if max_val < min_mean:
            min_mean = max_val
            best_v = v

    # Reconstruct cycle (simplified)
    cycle = [best_v]
    v = best_v
    for k in range(n, 0, -1):
        v = pred[k][v]
        if v == -1:
            break
        cycle.append(v)
        if v == best_v and len(cycle) > 1:
            break
    cycle.reverse()

    return min_mean, cycle


# ============================================================
# OPTIMAL TRANSPORT
# ============================================================

def wasserstein_lp(c: np.ndarray, mu: np.ndarray, nu: np.ndarray) -> Tuple[float, np.ndarray]:
    """Compute Wasserstein-1 distance via linear programming.

    Solves: min_{π ≥ 0} Σ_{i,j} π_{ij} c_{ij}
            s.t. Σ_j π_{ij} = μ_i  (row marginals)
                 Σ_i π_{ij} = ν_j  (column marginals)

    Complexity: O(n³) via network simplex (using scipy's HiGHS solver).

    Args:
        c: n×n cost matrix
        mu: probability vector of length n
        nu: probability vector of length n

    Returns:
        (distance, optimal_plan) where distance is W₁(μ,ν)
        and optimal_plan is the optimal coupling.
    """
    from scipy.optimize import linprog
    n = len(mu)

    c_flat = c.flatten()
    A_eq = np.zeros((2 * n, n * n))
    b_eq = np.zeros(2 * n)

    for i in range(n):
        for j in range(n):
            A_eq[i, i * n + j] = 1
            A_eq[n + j, i * n + j] = 1
        b_eq[i] = mu[i]
        b_eq[n + i] = nu[i]

    bounds = [(0, None)] * (n * n)
    result = linprog(c_flat, A_eq=A_eq, b_eq=b_eq, bounds=bounds, method='highs')

    if result.success:
        plan = result.x.reshape(n, n)
        return result.fun, plan
    else:
        return float('inf'), np.zeros((n, n))


def sinkhorn_transport(c: np.ndarray, mu: np.ndarray, nu: np.ndarray,
                       epsilon: float = 0.1, max_iter: int = 1000,
                       tol: float = 1e-8) -> Tuple[float, np.ndarray]:
    """Compute regularized optimal transport via Sinkhorn iterations.

    Solves the entropy-regularized problem:
        min_{π ≥ 0} Σ_{i,j} π_{ij} c_{ij} + ε Σ_{i,j} π_{ij} log(π_{ij})

    Complexity: O(n² × iterations)

    Args:
        c: n×n cost matrix
        mu: source probability vector
        nu: target probability vector
        epsilon: regularization parameter
        max_iter: maximum iterations
        tol: convergence tolerance

    Returns:
        (cost, plan) where cost is the regularized transport cost
    """
    n = len(mu)
    K = np.exp(-c / epsilon)

    u = np.ones(n)
    v = np.ones(n)

    for iteration in range(max_iter):
        u_old = u.copy()
        u = mu / (K @ v)
        v = nu / (K.T @ u)

        if np.max(np.abs(u - u_old)) < tol:
            break

    plan = np.diag(u) @ K @ np.diag(v)
    cost = np.sum(plan * c)
    return cost, plan


# ============================================================
# ASSIGNMENT PROBLEM
# ============================================================

def assignment_cost(c: np.ndarray, sigma: List[int]) -> float:
    """Compute the assignment cost Σᵢ c[i, σ(i)].

    Args:
        c: n×n cost matrix
        sigma: permutation as list

    Returns:
        Total assignment cost
    """
    return sum(c[i, sigma[i]] for i in range(len(sigma)))


def brute_force_assignment(c: np.ndarray) -> Tuple[float, List[int]]:
    """Solve assignment problem by brute force (for small n).

    Complexity: O(n! × n)

    Args:
        c: n×n cost matrix

    Returns:
        (min_cost, optimal_permutation)
    """
    from itertools import permutations
    n = c.shape[0]
    best_cost = float('inf')
    best_perm = list(range(n))

    for perm in permutations(range(n)):
        cost = sum(c[i, perm[i]] for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = list(perm)

    return best_cost, best_perm


# ============================================================
# VERIFICATION UTILITIES
# ============================================================

def verify_subadditivity(A: np.ndarray, max_power: int = 10) -> bool:
    """Verify the tropical power diagonal subadditivity theorem numerically.

    Checks: tropPow(A, m+k+1)[i,i] ≤ tropPow(A, m)[i,i] + tropPow(A, k)[i,i]
    for all valid m, k, and i.

    Args:
        A: n×n matrix
        max_power: maximum power to check

    Returns:
        True if subadditivity holds for all tested cases
    """
    n = A.shape[0]
    powers = {}
    current = A.copy()
    powers[0] = A.copy()
    for m in range(1, max_power + 1):
        current = tropical_multiply(current, A)
        powers[m] = current.copy()

    for i in range(n):
        for m in range(max_power):
            for k in range(max_power - m):
                if m + k + 1 <= max_power:
                    lhs = powers[m + k + 1][i, i]
                    rhs = powers[m][i, i] + powers[k][i, i]
                    if lhs > rhs + 1e-10:
                        return False
    return True


def verify_wasserstein_invariance(c: np.ndarray, mu: np.ndarray, nu: np.ndarray,
                                   e: np.ndarray) -> bool:
    """Verify Wasserstein invariance under a cost-preserving bijection.

    Checks: W_c(μ,ν) = W_c(e_*μ, e_*ν) when c(e(i),e(j)) = c(i,j).

    Args:
        c: n×n cost matrix
        mu, nu: probability vectors
        e: permutation (as array)

    Returns:
        True if invariance holds
    """
    n = len(mu)
    e_inv = np.argsort(e)

    # Check cost preservation
    for i in range(n):
        for j in range(n):
            if abs(c[e[i], e[j]] - c[i, j]) > 1e-10:
                return False

    # Compute pushforwards
    mu_push = mu[e_inv]
    nu_push = nu[e_inv]

    # Compute Wasserstein distances
    w1, _ = wasserstein_lp(c, mu, nu)
    w2, _ = wasserstein_lp(c, mu_push, nu_push)

    return abs(w1 - w2) < 1e-8


if __name__ == "__main__":
    print("Algorithms module - run demo.py for demonstrations")

    # Quick self-test
    n = 3
    A = np.array([[1, 2, 3], [4, 0, 1], [2, 3, 2]], dtype=float)

    print(f"\nTest matrix:\n{A}")

    # Tropical multiplication
    A2 = tropical_multiply(A, A)
    print(f"\nA⊗A:\n{A2}")

    # Tropical eigenvalue
    lam, means = tropical_eigenvalue(A, max_power=20)
    print(f"\nTropical eigenvalue: {lam:.4f}")
    print(f"Cycle means: {means}")

    # Karp's algorithm
    lam_karp, cycle = karp_cycle_mean(A)
    print(f"Karp's min cycle mean: {lam_karp:.4f}")

    # Subadditivity
    print(f"\nSubadditivity verified: {verify_subadditivity(A)}")
