#!/usr/bin/env python3
"""
Algorithms for Tropical-Transport Computation

Implements the core algorithms from the research paper:
1. Tropical matrix multiplication and power computation
2. Discrete Wasserstein distance via LP
3. Optimal assignment via Hungarian algorithm
4. Tropical eigenvalue computation via Karp's algorithm
"""

import numpy as np
from typing import Tuple, List, Optional


# =============================================================================
# Tropical Matrix Algebra
# =============================================================================

def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})

    Parameters:
        A: n×m matrix
        B: m×p matrix

    Returns:
        n×p tropical product matrix

    Time complexity: O(n*m*p)
    Space complexity: O(n*p)
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def trop_pow(A: np.ndarray, m: int) -> np.ndarray:
    """
    Tropical matrix power A^⊗m (1-indexed: A^⊗1 = A).

    Parameters:
        A: n×n square matrix
        m: positive integer power

    Returns:
        A^⊗m = A ⊗ A ⊗ ... ⊗ A (m times)

    Time complexity: O(m * n^3)
    Space complexity: O(n^2)

    Interpretation: (A^⊗m)_{ij} = minimum weight of a walk
    of length m from i to j in the weighted directed graph.
    """
    assert m >= 1, "Power must be positive"
    result = A.copy()
    for _ in range(m - 1):
        result = trop_mul(result, A)
    return result


def trop_eigenvalue_karp(A: np.ndarray) -> float:
    """
    Compute the tropical eigenvalue (minimum cycle mean) using Karp's algorithm.

    λ*(A) = min_{1≤k≤n} min_i (A^⊗k)_{ii} / k

    This is the minimum average weight of a cycle in the directed graph.

    Parameters:
        A: n×n square matrix (edge weights)

    Returns:
        Tropical eigenvalue (minimum cycle mean)

    Time complexity: O(n^4)
    Space complexity: O(n^3)

    Reference: R.M. Karp, "A characterization of the minimum cycle mean
    in a digraph," Discrete Mathematics 23 (1978), 309-311.
    """
    n = A.shape[0]
    # Compute all powers up to n
    powers = [None] * (n + 1)
    powers[1] = A.copy()
    for k in range(2, n + 1):
        powers[k] = trop_mul(powers[k - 1], A)

    # Find minimum cycle mean
    best = np.inf
    for k in range(1, n + 1):
        for i in range(n):
            cycle_mean = powers[k][i, i] / k
            best = min(best, cycle_mean)

    return best


def trop_eigenvector(A: np.ndarray, lam: Optional[float] = None) -> np.ndarray:
    """
    Compute a tropical eigenvector for the tropical eigenvalue λ.

    A tropical eigenvector v satisfies: A ⊗ v = λ ⊕ v,
    i.e., min_j (A_{ij} + v_j) = λ + v_i for all i.

    Parameters:
        A: n×n square matrix
        lam: tropical eigenvalue (computed if not provided)

    Returns:
        Tropical eigenvector (n-dimensional)

    Time complexity: O(n^4) if lam is not provided
    """
    n = A.shape[0]
    if lam is None:
        lam = trop_eigenvalue_karp(A)

    # Shifted matrix B = A - λI (tropically: B_{ij} = A_{ij} - λ)
    B = A - lam

    # Compute (I ⊕ B ⊕ B^2 ⊕ ... ⊕ B^{n-1})
    # This is the Kleene star restricted to n terms
    # Start with identity (0 on diagonal, +∞ off)
    star = np.full((n, n), np.inf)
    np.fill_diagonal(star, 0)

    Bk = np.where(np.eye(n, dtype=bool), 0.0, np.inf)  # tropical identity
    for k in range(1, n):
        Bk = trop_mul(Bk, B)
        star = np.minimum(star, Bk)

    # The eigenvector is any column of the Kleene star
    # Choose the column with smallest maximum entry
    best_col = 0
    best_max = np.inf
    for j in range(n):
        col_max = np.max(star[:, j])
        if col_max < best_max:
            best_max = col_max
            best_col = j

    return star[:, best_col]


# =============================================================================
# Wasserstein Distance
# =============================================================================

def wasserstein1_lp(c: np.ndarray, mu: np.ndarray, nu: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute Wasserstein-1 distance via linear programming.

    W(μ, ν) = min_{π ∈ Π(μ,ν)} ∑_{ij} π_{ij} c_{ij}

    where Π(μ,ν) = {π ≥ 0 : π1 = μ, π^T1 = ν}

    Parameters:
        c: n×n cost matrix
        mu: n-dim probability vector (source)
        nu: n-dim probability vector (target)

    Returns:
        (distance, optimal_plan): Wasserstein distance and optimal coupling

    Time complexity: O(n^3) typical for LP (simplex)
    Space complexity: O(n^2)
    """
    from scipy.optimize import linprog

    n = len(mu)
    c_flat = c.flatten()

    # Equality constraints: row sums = mu, col sums = nu
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

    return result.fun, result.x.reshape(n, n)


def pushforward(e: List[int], mu: np.ndarray) -> np.ndarray:
    """
    Pushforward of probability vector μ by permutation e.

    (e_*μ)(i) = μ(e^{-1}(i))

    Parameters:
        e: permutation as list (e[i] = image of i)
        mu: probability vector

    Returns:
        Pushed-forward probability vector
    """
    n = len(mu)
    e_inv = [0] * n
    for i in range(n):
        e_inv[e[i]] = i
    return np.array([mu[e_inv[i]] for i in range(n)])


# =============================================================================
# Assignment Problem (Hungarian Algorithm - simplified)
# =============================================================================

def hungarian_assignment(c: np.ndarray) -> Tuple[List[int], float]:
    """
    Solve the assignment problem using the Hungarian algorithm.

    Find σ minimizing ∑_i c(i, σ(i)) over all permutations σ.

    Parameters:
        c: n×n cost matrix

    Returns:
        (assignment, cost): optimal permutation and its cost

    Time complexity: O(n^3)
    Space complexity: O(n^2)
    """
    from scipy.optimize import linear_sum_assignment

    row_ind, col_ind = linear_sum_assignment(c)
    assignment = list(col_ind)
    cost = c[row_ind, col_ind].sum()
    return assignment, cost


def verify_conjugation_invariance(
    c: np.ndarray, sigma: List[int], e: List[int]
) -> Tuple[float, float, bool]:
    """
    Verify that assignment cost is invariant under conjugation
    when e preserves the cost function.

    ∑_i c(i, (e⁻¹∘σ∘e)(i)) = ∑_i c(i, σ(i))

    Parameters:
        c: cost matrix (must satisfy c[e[i],e[j]] = c[i,j])
        sigma: permutation
        e: cost-preserving bijection

    Returns:
        (cost_sigma, cost_conjugated, equal): costs and whether they match
    """
    n = len(sigma)
    e_inv = [0] * n
    for i in range(n):
        e_inv[e[i]] = i

    # Conjugated permutation: e⁻¹ ∘ σ ∘ e
    conj = [e_inv[sigma[e[i]]] for i in range(n)]

    cost_sigma = sum(c[i, sigma[i]] for i in range(n))
    cost_conj = sum(c[i, conj[i]] for i in range(n))

    return cost_sigma, cost_conj, abs(cost_sigma - cost_conj) < 1e-10


# =============================================================================
# Main demonstration
# =============================================================================

if __name__ == "__main__":
    print("Tropical-Transport Algorithms")
    print("=" * 50)

    # Tropical eigenvalue computation
    A = np.array([
        [5, 1, 8],
        [3, 7, 2],
        [6, 4, 3]
    ], dtype=float)

    lam = trop_eigenvalue_karp(A)
    v = trop_eigenvector(A, lam)
    print(f"\nMatrix A:\n{A}")
    print(f"Tropical eigenvalue: {lam:.4f}")
    print(f"Tropical eigenvector: {v}")

    # Verify eigenvector equation
    Av = np.array([min(A[i, j] + v[j] for j in range(3)) for i in range(3)])
    print(f"A ⊗ v = {Av}")
    print(f"λ + v = {lam + v}")
    print(f"Eigenvector equation satisfied: {np.allclose(Av, lam + v, atol=1e-10)}")

    # Wasserstein computation
    print(f"\n{'='*50}")
    c = np.array([[0, 2, 5], [2, 0, 3], [5, 3, 0]], dtype=float)
    mu = np.array([0.5, 0.3, 0.2])
    nu = np.array([0.2, 0.3, 0.5])

    w, pi = wasserstein1_lp(c, mu, nu)
    print(f"\nWasserstein distance W(μ,ν) = {w:.4f}")
    print(f"Optimal plan:\n{pi}")

    # Assignment problem
    print(f"\n{'='*50}")
    assignment, cost = hungarian_assignment(c)
    print(f"Optimal assignment: {assignment}, cost = {cost:.4f}")
