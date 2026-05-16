#!/usr/bin/env python3
"""
Algorithms for Transport-Tropical Duality

Implements core algorithms from the research:
1. Discrete Wasserstein distance via LP
2. Tropical (min-plus) matrix multiplication and powers
3. Minimum cycle mean (tropical eigenvalue) computation
4. Assignment problem via Hungarian method
5. Permutation plan construction and cost computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional
from scipy.optimize import linear_sum_assignment


# ============================================================
# TROPICAL MATRIX ALGEBRA
# ============================================================

def tropical_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    Computes C where C[i,j] = min_k (A[i,k] + B[k,j]).

    Time complexity: O(n³) where n is the matrix dimension.
    Space complexity: O(n²) for the output matrix.

    Args:
        A: n×n matrix
        B: n×n matrix

    Returns:
        n×n tropical product matrix

    Example:
        >>> A = np.array([[0, 3], [2, 1]])
        >>> B = np.array([[1, 4], [0, 2]])
        >>> tropical_multiply(A, B)
        array([[1., 2.],
               [1., 3.]])
    """
    n = A.shape[0]
    # Vectorized: for each (i,j), compute min over k of A[i,k] + B[k,j]
    # A[:, :, None] has shape (n, n, 1), B[None, :, :] has shape (1, n, n)
    # Sum has shape (n, n, n) and we take min over axis 1
    return np.min(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)


def tropical_power(A: np.ndarray, m: int) -> np.ndarray:
    """
    Compute the m-th tropical power of matrix A.

    A^{⊗0} = A (identity convention: 1-step paths)
    A^{⊗m} = A^{⊗(m-1)} ⊗ A for m ≥ 1

    Time complexity: O(m · n³)
    Space complexity: O(n²)

    Args:
        A: n×n matrix
        m: power (non-negative integer)

    Returns:
        n×n tropical power matrix
    """
    if m == 0:
        return A.copy()
    result = A.copy()
    for _ in range(m):
        result = tropical_multiply(result, A)
    return result


def minimum_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the minimum cycle mean (tropical eigenvalue) of matrix A.

    Uses Karp's algorithm: λ = min_i min_{0≤k<n} (A^{⊗n}[i,i] - A^{⊗k}[i,i]) / (n - k)

    Time complexity: O(n⁴) (n powers of n×n matrices)
    Space complexity: O(n³) (storing all powers)

    Args:
        A: n×n matrix (should represent a complete weighted digraph)

    Returns:
        Minimum cycle mean (tropical eigenvalue)

    Example:
        >>> A = np.array([[0, 1, 5], [2, 0, 3], [4, 1, 0]])
        >>> minimum_cycle_mean(A)  # minimum average weight cycle
        0.0
    """
    n = A.shape[0]
    # Compute all tropical powers A^{⊗0}, ..., A^{⊗n}
    powers = [tropical_power(A, k) for k in range(n + 1)]

    # Karp's formula
    lambda_star = float('inf')
    for i in range(n):
        max_over_k = -float('inf')
        for k in range(n):
            if n - k > 0:
                val = (powers[n][i, i] - powers[k][i, i]) / (n - k)
                max_over_k = max(max_over_k, val)
        lambda_star = min(lambda_star, max_over_k)

    return lambda_star


def verify_subadditivity(A: np.ndarray, max_power: int = 10) -> List[Tuple[int, int, int, float, float, bool]]:
    """
    Verify the subadditivity inequality for all diagonal entries
    of tropical powers up to max_power.

    Checks: A^{⊗(m+k+1)}[i,i] ≤ A^{⊗m}[i,i] + A^{⊗k}[i,i]

    Args:
        A: n×n matrix
        max_power: maximum power to check

    Returns:
        List of (i, m, k, lhs, rhs, satisfied) tuples for violated cases
    """
    n = A.shape[0]
    powers = [tropical_power(A, p) for p in range(max_power)]
    violations = []

    for i in range(n):
        for m in range(max_power):
            for k in range(max_power):
                if m + k + 1 < max_power:
                    lhs = powers[m + k + 1][i, i]
                    rhs = powers[m][i, i] + powers[k][i, i]
                    satisfied = lhs <= rhs + 1e-12
                    if not satisfied:
                        violations.append((i, m, k, lhs, rhs, satisfied))

    return violations


# ============================================================
# OPTIMAL TRANSPORT
# ============================================================

def wasserstein_distance(c: np.ndarray, mu: np.ndarray, nu: np.ndarray) -> float:
    """
    Compute discrete Wasserstein-1 distance via scipy's LP solver.

    Time complexity: O(n³) via interior point or simplex method.
    Space complexity: O(n²)

    Args:
        c: n×n cost matrix (nonnegative)
        mu: source probability distribution (length n, sums to 1)
        nu: target probability distribution (length n, sums to 1)

    Returns:
        Wasserstein-1 distance

    Example:
        >>> c = np.array([[0, 1], [1, 0]], dtype=float)
        >>> mu = np.array([0.7, 0.3])
        >>> nu = np.array([0.3, 0.7])
        >>> wasserstein_distance(c, mu, nu)
        0.4
    """
    from scipy.optimize import linprog
    n = len(mu)
    c_flat = c.flatten()
    A_eq = np.zeros((2*n, n*n))
    b_eq = np.zeros(2*n)

    for i in range(n):
        for j in range(n):
            A_eq[i, i*n + j] = 1.0
            A_eq[n + j, i*n + j] = 1.0
        b_eq[i] = mu[i]
        b_eq[n + i] = nu[i]

    bounds = [(0, None)] * (n * n)
    result = linprog(c_flat, A_eq=A_eq, b_eq=b_eq, bounds=bounds, method='highs')

    if not result.success:
        raise ValueError(f"LP failed: {result.message}")
    return result.fun


def optimal_assignment(c: np.ndarray) -> Tuple[np.ndarray, float]:
    """
    Solve the assignment problem using the Hungarian algorithm.

    Find the permutation σ minimizing Σ_i c[i, σ(i)].

    Time complexity: O(n³) via the Hungarian algorithm.
    Space complexity: O(n²)

    Args:
        c: n×n cost matrix

    Returns:
        (optimal_permutation, minimum_cost) tuple

    Example:
        >>> c = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 0]])
        >>> sigma, cost = optimal_assignment(c)
        >>> cost
        6.0
    """
    row_ind, col_ind = linear_sum_assignment(c)
    sigma = np.zeros(len(row_ind), dtype=int)
    sigma[row_ind] = col_ind
    cost = c[row_ind, col_ind].sum()
    return sigma, cost


def permutation_plan(sigma: np.ndarray) -> np.ndarray:
    """
    Construct the transport plan for a permutation.

    π(i,j) = 1/n if σ(i) = j, else 0.

    Time complexity: O(n)
    Space complexity: O(n²)

    Args:
        sigma: permutation as array of indices

    Returns:
        n×n transport plan matrix
    """
    n = len(sigma)
    pi = np.zeros((n, n))
    for i in range(n):
        pi[i, sigma[i]] = 1.0 / n
    return pi


def verify_wasserstein_invariance(
    c: np.ndarray, mu: np.ndarray, nu: np.ndarray,
    e: np.ndarray, tol: float = 1e-8
) -> Tuple[float, float, bool]:
    """
    Verify Wasserstein invariance under a cost-preserving permutation.

    Args:
        c: cost matrix
        mu, nu: probability distributions
        e: permutation (as index array) preserving c
        tol: numerical tolerance

    Returns:
        (w_original, w_pushed, invariant) tuple
    """
    e_inv = np.argsort(e)
    mu_push = mu[e_inv]
    nu_push = nu[e_inv]

    w_orig = wasserstein_distance(c, mu, nu)
    w_push = wasserstein_distance(c, mu_push, nu_push)

    return w_orig, w_push, abs(w_orig - w_push) < tol


# ============================================================
# EXAMPLE USAGE
# ============================================================

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 50)

    # Tropical multiplication example
    A = np.array([[0, 3, 7], [2, 0, 4], [5, 1, 0]], dtype=float)
    print("\nMatrix A:")
    print(A)

    A2 = tropical_multiply(A, A)
    print("\nA ⊗ A (2-step shortest paths):")
    print(A2)

    A3 = tropical_multiply(A2, A)
    print("\nA ⊗ A ⊗ A (3-step shortest paths):")
    print(A3)

    # Minimum cycle mean
    mcm = minimum_cycle_mean(A)
    print(f"\nMinimum cycle mean (tropical eigenvalue): {mcm:.4f}")

    # Subadditivity verification
    violations = verify_subadditivity(A, max_power=8)
    print(f"Subadditivity violations (should be 0): {len(violations)}")

    # Optimal assignment
    sigma, cost = optimal_assignment(A)
    print(f"\nOptimal assignment: {sigma}, cost = {cost:.4f}")

    # Wasserstein invariance
    n = 4
    c = np.array([[abs(i-j) for j in range(n)] for i in range(n)], dtype=float)
    mu = np.array([0.4, 0.3, 0.2, 0.1])
    nu = np.array([0.1, 0.2, 0.3, 0.4])
    e = np.array([3, 0, 1, 2])  # reverse cyclic shift

    w1, w2, ok = verify_wasserstein_invariance(c, mu, nu, e)
    print(f"\nWasserstein invariance: W1={w1:.6f}, W2={w2:.6f}, invariant={ok}")
