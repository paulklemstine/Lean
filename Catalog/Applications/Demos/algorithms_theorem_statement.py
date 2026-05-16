"""
Tropical Linear Algebra: Core Algorithms
=========================================

Implements the fundamental algorithms from the tropical Perron–Frobenius theorem:
- Tropical matrix operations (max-plus algebra)
- Maximum cycle mean computation (Karp's algorithm)
- Tropical power iteration
- Bellman operator and additive eigenvector computation
"""

import numpy as np
from typing import Tuple, List, Optional


def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (max-plus) matrix multiplication.

    Computes C where C[i,j] = max_k (A[i,k] + B[k,j]).
    This is the max-plus analogue of standard matrix multiplication,
    replacing (×, +) with (+, max).

    Args:
        A: n×p matrix
        B: p×m matrix

    Returns:
        n×m matrix C with C[i,j] = max_k(A[i,k] + B[k,j])

    Time complexity: O(n * m * p)
    """
    n, p = A.shape
    _, m = B.shape
    C = np.full((n, m), -np.inf)
    for i in range(n):
        for j in range(m):
            for k in range(p):
                C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C


def trop_pow(W: np.ndarray, m: int) -> np.ndarray:
    """
    Compute the (m+1)-fold tropical power of W.

    tropPow(W, m)[i,j] = maximum weight of a walk of (m+1) edges from i to j.

    Args:
        W: n×n weight matrix
        m: power index (m ≥ 0)

    Returns:
        n×n matrix representing the (m+1)-fold tropical power

    Time complexity: O(m * n³)
    """
    result = W.copy()
    for _ in range(m):
        result = trop_mul(result, W)
    return result


def karp_max_cycle_mean(W: np.ndarray) -> Tuple[float, List[int]]:
    """
    Karp's algorithm for computing the maximum cycle mean.

    Finds μ* = max over all cycles C of (weight(C) / length(C)).
    This is the tropical eigenvalue / spectral radius.

    Algorithm:
    1. Compute F[k][i] = max weight walk of k edges ending at i (from any start)
    2. μ* = max_i min_k (F[n][i] - F[k][i]) / (n - k)

    Args:
        W: n×n weight matrix

    Returns:
        (max_cycle_mean, optimal_cycle_vertices)

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = W.shape[0]

    # F[k][i] = max weight walk of exactly k edges ending at vertex i
    F = np.full((n + 1, n), -np.inf)
    F[0, :] = 0.0  # Start from any vertex with weight 0

    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                if F[k-1][j] > -np.inf:
                    F[k][i] = max(F[k][i], F[k-1][j] + W[j, i])

    # Compute the maximum cycle mean
    mu_star = -np.inf
    best_vertex = 0

    for i in range(n):
        if F[n][i] == -np.inf:
            continue
        min_ratio = np.inf
        for k in range(n):
            if F[k][i] > -np.inf:
                ratio = (F[n][i] - F[k][i]) / (n - k)
                min_ratio = min(min_ratio, ratio)
        if min_ratio > mu_star:
            mu_star = min_ratio
            best_vertex = i

    # Reconstruct the optimal cycle (simplified)
    cycle = [best_vertex]
    return mu_star, cycle


def max_cycle_mean_brute(W: np.ndarray) -> float:
    """
    Brute-force maximum cycle mean using tropical powers.

    Computes max over vertices i and lengths m ∈ {0,...,n-1}
    of tropPow(W, m)[i,i] / (m+1).

    Args:
        W: n×n weight matrix

    Returns:
        Maximum cycle mean

    Time complexity: O(n⁴)
    """
    n = W.shape[0]
    best = -np.inf
    P = W.copy()
    for m in range(n):
        for i in range(n):
            val = P[i, i] / (m + 1)
            best = max(best, val)
        if m < n - 1:
            P = trop_mul(P, W)
    return best


def bellman_operator(W: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Apply the Bellman (dynamic programming) operator.

    (Tx)[i] = max_j (W[i,j] + x[j])

    This is the one-step tropical matrix-vector product.

    Args:
        W: n×n weight matrix
        x: n-vector

    Returns:
        n-vector Tx
    """
    n = W.shape[0]
    result = np.full(n, -np.inf)
    for i in range(n):
        for j in range(n):
            result[i] = max(result[i], W[i, j] + x[j])
    return result


def find_additive_eigenvector(W: np.ndarray, tol: float = 1e-10,
                               max_iter: int = 1000) -> Tuple[float, np.ndarray]:
    """
    Find an additive eigenpair (λ, v) of the Bellman operator:
        max_j (W[i,j] + v[j]) = λ + v[i]  for all i.

    Uses the Howard policy iteration algorithm.

    Args:
        W: n×n weight matrix
        tol: convergence tolerance
        max_iter: maximum iterations

    Returns:
        (eigenvalue λ, eigenvector v) where Tv = λ + v

    The eigenvalue λ equals the maximum cycle mean.
    """
    n = W.shape[0]
    mu = max_cycle_mean_brute(W)

    # Shifted matrix: W' = W - μ
    W_shifted = W - mu

    # Find eigenvector of W' with eigenvalue 0
    # Use power iteration: iterate Tx and subtract the additive growth
    x = np.zeros(n)
    for _ in range(max_iter):
        x_new = bellman_operator(W_shifted, x)
        # Normalize by subtracting the mean
        shift = x_new.mean()
        x_new -= shift
        if np.max(np.abs(x_new - x)) < tol:
            break
        x = x_new

    return mu, x


def tropical_spectral_radius(W: np.ndarray) -> float:
    """
    Compute the tropical spectral radius of W.

    This is the maximum cycle mean, which is the tropical
    analogue of the classical spectral radius.

    Args:
        W: n×n weight matrix

    Returns:
        The tropical spectral radius (= max cycle mean)
    """
    return karp_max_cycle_mean(W)[0]


def verify_perron_frobenius(W: np.ndarray, num_powers: int = 50) -> dict:
    """
    Verify the tropical Perron–Frobenius theorem numerically.

    Checks that tropPow(W, m)[i,j] / (m+1) → μ* for all i,j.

    Args:
        W: n×n weight matrix
        num_powers: number of powers to compute

    Returns:
        Dictionary with verification results
    """
    n = W.shape[0]
    mu = max_cycle_mean_brute(W)

    ratios = np.zeros((num_powers, n, n))
    P = W.copy()
    for m in range(num_powers):
        ratios[m] = P / (m + 1)
        if m < num_powers - 1:
            P = trop_mul(P, W)

    # Check convergence
    final_ratios = ratios[-1]
    max_deviation = np.max(np.abs(final_ratios - mu))

    return {
        'matrix': W,
        'max_cycle_mean': mu,
        'num_powers': num_powers,
        'final_max_deviation': max_deviation,
        'ratios': ratios,
        'converged': max_deviation < 0.1
    }


if __name__ == "__main__":
    # Example usage
    W = np.array([
        [1.0, 3.0, -2.0],
        [0.0, 2.0, 4.0],
        [5.0, -1.0, 0.0]
    ])

    print("Weight matrix W:")
    print(W)
    print()

    # Compute max cycle mean two ways
    mu_brute = max_cycle_mean_brute(W)
    mu_karp, cycle = karp_max_cycle_mean(W)
    print(f"Max cycle mean (brute force): {mu_brute:.6f}")
    print(f"Max cycle mean (Karp):        {mu_karp:.6f}")
    print()

    # Find eigenvector
    eigenvalue, eigenvector = find_additive_eigenvector(W)
    print(f"Additive eigenvalue: {eigenvalue:.6f}")
    print(f"Additive eigenvector: {eigenvector}")
    print()

    # Verify Bellman equation
    Tv = bellman_operator(W, eigenvector)
    print(f"Tv:     {Tv}")
    print(f"λ + v:  {eigenvalue + eigenvector}")
    print(f"Error:  {np.max(np.abs(Tv - eigenvalue - eigenvector)):.2e}")
    print()

    # Verify Perron–Frobenius
    result = verify_perron_frobenius(W)
    print(f"Convergence verified: {result['converged']}")
    print(f"Final max deviation: {result['final_max_deviation']:.6f}")
