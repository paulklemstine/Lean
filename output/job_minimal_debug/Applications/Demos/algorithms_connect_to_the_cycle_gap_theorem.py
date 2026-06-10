"""
Tropical Spectral Theory: Algorithms for Max-Plus Eigenvalues and
Branching Program Analysis

This module implements the core algorithms from the tropical spectral
theory connecting cycle gaps to max-plus eigenvalues, including:
- Tropical matrix multiplication and powers
- Maximum cycle mean computation (Karp's algorithm)
- Walk weight growth analysis
- Periodic branching program evaluation

All algorithms operate on standard NumPy arrays interpreted as weighted
adjacency matrices in the max-plus (tropical) semiring.
"""

import numpy as np
from typing import Tuple, List, Optional


def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj}).

    In the max-plus semiring, addition becomes max and multiplication becomes +.

    Args:
        A: n×n real matrix
        B: n×n real matrix

    Returns:
        n×n matrix where entry (i,j) = max_k(A[i,k] + B[k,j])

    Example:
        >>> A = np.array([[0, 3], [2, 1]])
        >>> B = np.array([[1, 0], [4, 2]])
        >>> trop_mul(A, B)
        array([[7., 5.],
               [5., 3.]])
    """
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = np.max(A[i, :] + B[:, j])
    return C


def trop_pow(W: np.ndarray, k: int) -> np.ndarray:
    """Tropical matrix power: W^{⊗k} via repeated tropical multiplication.

    tropPow W 0 = W (single edges)
    tropPow W k = tropMul(tropPow W (k-1), W) for k ≥ 1

    This gives the maximum weight of all walks using exactly k+1 edges.

    Args:
        W: n×n weighted adjacency matrix
        k: power index (0-based, so k=0 returns W itself)

    Returns:
        n×n matrix of optimal (k+1)-edge walk weights
    """
    result = W.copy()
    for _ in range(k):
        result = trop_mul(result, W)
    return result


def walk_weight_growth(W: np.ndarray, k: int) -> float:
    """Maximum entry of tropPow(W, k): the best walk weight at length k+1.

    Args:
        W: n×n weighted adjacency matrix
        k: power index

    Returns:
        Maximum weight achievable by any walk of k+1 edges
    """
    return np.max(trop_pow(W, k))


def max_cycle_mean(W: np.ndarray) -> Tuple[float, int, int]:
    """Compute the maximum cycle mean (tropical eigenvalue) of W.

    The maximum cycle mean λ(W) = max_{i, L} tropPow(W, L)[i,i] / (L+1)
    where L ranges over 0..n-1 (cycle lengths 1..n).

    This is the tropical analogue of the Perron-Frobenius eigenvalue.

    Args:
        W: n×n weighted adjacency matrix

    Returns:
        Tuple of (max_cycle_mean, optimal_vertex, optimal_cycle_length_minus_1)

    Example:
        >>> W = np.array([[0, 3], [2, 1]])
        >>> mcm, vertex, L = max_cycle_mean(W)
        >>> print(f"λ(W) = {mcm:.4f}, achieved at vertex {vertex}, cycle length {L+1}")
    """
    n = W.shape[0]
    best_mean = -np.inf
    best_i = 0
    best_L = 0

    Wk = W.copy()
    for L in range(n):
        for i in range(n):
            mean = Wk[i, i] / (L + 1)
            if mean > best_mean:
                best_mean = mean
                best_i = i
                best_L = L
        if L < n - 1:
            Wk = trop_mul(Wk, W)

    return best_mean, best_i, best_L


def max_cycle_mean_karp(W: np.ndarray) -> float:
    """Karp's algorithm for maximum cycle mean.

    More efficient O(n³) algorithm based on the identity:
    λ(W) = max_i min_k (D[n,i] - D[k,i]) / (n - k)
    where D[k,i] = max weight of a k-edge walk ending at i.

    Args:
        W: n×n weighted adjacency matrix

    Returns:
        The maximum cycle mean λ(W)
    """
    n = W.shape[0]

    # D[k][i] = max weight of a walk of exactly k edges ending at vertex i
    D = np.full((n + 1, n), -np.inf)
    # Initialize: 0-edge walks have weight 0 at the starting vertex
    for i in range(n):
        D[0][i] = 0.0

    for k in range(1, n + 1):
        for i in range(n):
            D[k][i] = np.max(D[k - 1] + W[:, i])

    # Karp's formula
    result = -np.inf
    for i in range(n):
        min_val = np.inf
        for k in range(n):
            if D[k][i] > -np.inf:
                val = (D[n][i] - D[k][i]) / (n - k)
                min_val = min(min_val, val)
        if min_val < np.inf:
            result = max(result, min_val)

    return result


def verify_spectral_bound(W: np.ndarray, max_steps: int = 20) -> dict:
    """Verify the cycle-gap spectral bound numerically.

    Checks that walkWeightGrowth(W, k) ≥ (k+1) * maxCycleMean(W) along
    the appropriate arithmetic subsequence.

    Args:
        W: n×n weighted adjacency matrix
        max_steps: number of periods to check

    Returns:
        Dictionary with verification results
    """
    mcm, opt_i, opt_L = max_cycle_mean(W)
    p = opt_L + 1  # period (cycle length)

    results = {
        'max_cycle_mean': mcm,
        'optimal_vertex': opt_i,
        'period': p,
        'checks': [],
        'all_passed': True
    }

    for m in range(max_steps):
        k = (m + 1) * p - 1  # tropPow index
        growth = walk_weight_growth(W, k)
        bound = (m + 1) * p * mcm
        passed = growth >= bound - 1e-10  # numerical tolerance

        results['checks'].append({
            'm': m,
            'depth': k + 1,
            'walk_weight_growth': growth,
            'spectral_bound': bound,
            'passed': passed,
            'ratio': growth / bound if abs(bound) > 1e-10 else float('inf')
        })

        if not passed:
            results['all_passed'] = False

    return results


def periodic_bp_eval(W: np.ndarray, depth: int) -> np.ndarray:
    """Evaluate a periodic branching program with all layers equal to W.

    A periodic BP of depth d+1 with layer matrix W computes tropPow(W, d).

    Args:
        W: w×w layer transition matrix
        depth: number of layers (depth = d means tropPow W (d-1))

    Returns:
        w×w output matrix
    """
    if depth <= 0:
        return np.eye(W.shape[0]) * 0  # tropical identity
    return trop_pow(W, depth - 1)


def bp_growth_analysis(W: np.ndarray, max_depth: int = 50) -> dict:
    """Analyze the growth of a periodic branching program.

    Computes max entries at each depth and compares with the spectral bound.

    Args:
        W: w×w layer matrix
        max_depth: maximum depth to analyze

    Returns:
        Dictionary with growth data and spectral analysis
    """
    mcm, _, opt_L = max_cycle_mean(W)
    p = opt_L + 1

    depths = []
    max_entries = []
    spectral_bounds = []

    Wk = W.copy()
    for d in range(max_depth):
        max_entry = np.max(Wk)
        depth = d + 1  # number of edges
        spectral_bound = depth * mcm

        depths.append(depth)
        max_entries.append(max_entry)
        spectral_bounds.append(spectral_bound)

        Wk = trop_mul(Wk, W)

    return {
        'max_cycle_mean': mcm,
        'period': p,
        'depths': depths,
        'max_entries': max_entries,
        'spectral_bounds': spectral_bounds
    }


if __name__ == '__main__':
    # Example 1: Simple 2x2 matrix
    print("=" * 60)
    print("Example 1: Simple 2x2 matrix")
    print("=" * 60)
    W1 = np.array([[0.0, 3.0], [2.0, 1.0]])
    print(f"W = \n{W1}")

    mcm1, v1, L1 = max_cycle_mean(W1)
    print(f"\nMax cycle mean λ(W) = {mcm1:.4f}")
    print(f"Achieved at vertex {v1}, cycle length {L1 + 1}")

    result1 = verify_spectral_bound(W1, max_steps=10)
    print(f"\nSpectral bound verification ({'PASSED' if result1['all_passed'] else 'FAILED'}):")
    for c in result1['checks'][:5]:
        print(f"  depth {c['depth']:3d}: growth = {c['walk_weight_growth']:8.2f}, "
              f"bound = {c['spectral_bound']:8.2f}, ratio = {c['ratio']:.4f}")

    # Example 2: 3x3 matrix with clear cycle structure
    print("\n" + "=" * 60)
    print("Example 2: 3x3 matrix with distinct cycles")
    print("=" * 60)
    W2 = np.array([
        [-1.0, 5.0, -2.0],
        [3.0, -1.0, 4.0],
        [1.0, 2.0, -3.0]
    ])
    print(f"W = \n{W2}")

    mcm2, v2, L2 = max_cycle_mean(W2)
    mcm2_karp = max_cycle_mean_karp(W2)
    print(f"\nMax cycle mean (direct):  {mcm2:.4f}")
    print(f"Max cycle mean (Karp):    {mcm2_karp:.4f}")
    print(f"Optimal vertex: {v2}, cycle length: {L2 + 1}")

    result2 = verify_spectral_bound(W2, max_steps=8)
    print(f"\nSpectral bound verification ({'PASSED' if result2['all_passed'] else 'FAILED'}):")
    for c in result2['checks']:
        print(f"  depth {c['depth']:3d}: growth = {c['walk_weight_growth']:8.2f}, "
              f"bound = {c['spectral_bound']:8.2f}")
