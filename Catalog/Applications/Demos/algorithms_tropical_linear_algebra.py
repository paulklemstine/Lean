"""
Tropical Surgery Algorithms

Efficient implementations of tropical spectral computations and surgery operations,
with complexity analysis and practical optimizations.
"""

import numpy as np
from itertools import product
from typing import Tuple, List, Optional
import time


def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j]).
    
    Time: O(n³)
    Space: O(n²)
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_matrix_power(A: np.ndarray, p: int) -> np.ndarray:
    """
    Compute A^p in min-plus algebra using repeated squaring.
    
    Time: O(n³ log p)
    Space: O(n²)
    """
    n = A.shape[0]
    if p == 1:
        return A.copy()
    
    result = np.full((n, n), np.inf)
    np.fill_diagonal(result, 0)  # tropical identity
    
    base = A.copy()
    while p > 0:
        if p % 2 == 1:
            result = tropical_matrix_multiply(result, base)
        base = tropical_matrix_multiply(base, base)
        p //= 2
    
    return result


def karp_minimum_cycle_mean(A: np.ndarray) -> Tuple[float, List[int]]:
    """
    Karp's algorithm for minimum cycle mean.
    
    Computes the tropical spectral radius λ* = min over all cycles C of
    (sum of edge weights in C) / |C|.
    
    Time: O(n³) — n iterations of O(n²) work
    Space: O(n²)
    
    Returns:
        (lambda_star, cycle): minimum cycle mean and a witness cycle
    """
    n = A.shape[0]
    INF = float('inf')
    
    # D[k][v] = minimum weight of a walk of length exactly k ending at v
    # starting from a virtual source s with zero-weight edges to all vertices
    D = np.full((n + 1, n), INF)
    parent = [[(-1, -1) for _ in range(n)] for _ in range(n + 1)]
    
    # Initialize: walks of length 0 from source have weight 0
    D[0, :] = 0
    
    # Dynamic programming: extend walks
    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                new_weight = D[k - 1][u] + A[u, v]
                if new_weight < D[k][v]:
                    D[k][v] = new_weight
                    parent[k][v] = (k - 1, u)
    
    # Karp's formula: λ* = min_v max_k (D[n][v] - D[k][v]) / (n - k)
    lambda_star = INF
    best_v = 0
    best_k = 0
    
    for v in range(n):
        max_val = -INF
        max_k = 0
        for k in range(n):
            if D[k][v] < INF and D[n][v] < INF:
                val = (D[n][v] - D[k][v]) / (n - k)
                if val > max_val:
                    max_val = val
                    max_k = k
        if max_val < lambda_star:
            lambda_star = max_val
            best_v = v
            best_k = max_k
    
    # Reconstruct cycle (simplified)
    cycle = [best_v]
    
    return lambda_star, cycle


def tropical_rank_two_surgery(A: np.ndarray, u: np.ndarray, v: np.ndarray,
                               u_prime: np.ndarray, v_prime: np.ndarray) -> np.ndarray:
    """
    Rank-2 tropical surgery: B[i,j] = min(A[i,j], u[i]+v[j], u'[i]+v'[j]).
    
    Time: O(n²)
    Space: O(n²)
    """
    R1 = np.add.outer(u, v)
    R2 = np.add.outer(u_prime, v_prime)
    return np.minimum(A, np.minimum(R1, R2))


def two_entry_surgery(A: np.ndarray, i1: int, j1: int, c1: float,
                       i2: int, j2: int, c2: float) -> np.ndarray:
    """
    Localized two-entry surgery.
    
    Time: O(n²) for copy, O(1) for modification
    Space: O(n²)
    """
    B = A.copy()
    B[i1, j1] = min(A[i1, j1], c1)
    B[i2, j2] = min(A[i2, j2], c2)
    return B


def spectral_bound_certificate(A: np.ndarray, u: np.ndarray, v: np.ndarray,
                                u_prime: np.ndarray, v_prime: np.ndarray) -> dict:
    """
    Compute the certified spectral bound for rank-2 surgery.
    
    Returns a dictionary with:
    - rho_A: spectral radius of original matrix
    - rho_B: spectral radius of surgery result
    - diag_min_1: min_i(u[i] + v[i])
    - diag_min_2: min_i(u'[i] + v'[i])
    - explicit_bound: min(rho_A, diag_min_1, diag_min_2)
    - monotonicity_verified: whether rho_B <= rho_A
    - bound_verified: whether rho_B <= explicit_bound
    
    Time: O(n³) dominated by Karp's algorithm
    """
    B = tropical_rank_two_surgery(A, u, v, u_prime, v_prime)
    
    rho_A, _ = karp_minimum_cycle_mean(A)
    rho_B, _ = karp_minimum_cycle_mean(B)
    
    diag_min_1 = min(u[i] + v[i] for i in range(len(u)))
    diag_min_2 = min(u_prime[i] + v_prime[i] for i in range(len(u_prime)))
    
    explicit_bound = min(rho_A, diag_min_1, diag_min_2)
    
    return {
        'rho_A': rho_A,
        'rho_B': rho_B,
        'diag_min_1': diag_min_1,
        'diag_min_2': diag_min_2,
        'explicit_bound': explicit_bound,
        'monotonicity_verified': rho_B <= rho_A + 1e-10,
        'bound_verified': rho_B <= explicit_bound + 1e-10,
    }


def sensitivity_analysis(A: np.ndarray, perturbation_range: np.ndarray = None) -> dict:
    """
    Sensitivity analysis: how much does the spectral radius change
    under single-entry decreases?
    
    Time: O(n⁵) — O(n²) entries × O(n³) per Karp evaluation
    """
    n = A.shape[0]
    rho_A, _ = karp_minimum_cycle_mean(A)
    
    if perturbation_range is None:
        perturbation_range = np.array([0.5, 1.0, 2.0, 5.0])
    
    results = {}
    for i in range(n):
        for j in range(n):
            entry_results = []
            for delta in perturbation_range:
                B = A.copy()
                B[i, j] = A[i, j] - delta
                rho_B, _ = karp_minimum_cycle_mean(B)
                entry_results.append({
                    'delta': delta,
                    'rho_B': rho_B,
                    'rho_change': rho_B - rho_A,
                })
            results[(i, j)] = entry_results
    
    return {'rho_A': rho_A, 'entries': results}


def optimal_two_entry_surgery(A: np.ndarray, budget: float) -> dict:
    """
    Find the two-entry surgery that minimizes the spectral radius
    subject to a total decrease budget.
    
    For each pair of entries (i1,j1), (i2,j2), find the optimal
    allocation of budget between them.
    
    Time: O(n⁴ · K) where K is the number of budget splits tried
    """
    n = A.shape[0]
    rho_A, _ = karp_minimum_cycle_mean(A)
    
    best_rho = rho_A
    best_config = None
    num_splits = 10
    
    for i1 in range(n):
        for j1 in range(n):
            for i2 in range(n):
                for j2 in range(n):
                    if (i1, j1) >= (i2, j2):
                        continue
                    
                    for s in range(num_splits + 1):
                        frac = s / num_splits
                        c1 = A[i1, j1] - frac * budget
                        c2 = A[i2, j2] - (1 - frac) * budget
                        
                        B = two_entry_surgery(A, i1, j1, c1, i2, j2, c2)
                        rho_B, _ = karp_minimum_cycle_mean(B)
                        
                        if rho_B < best_rho:
                            best_rho = rho_B
                            best_config = {
                                'entries': [(i1, j1), (i2, j2)],
                                'values': [c1, c2],
                                'budget_split': [frac, 1 - frac],
                            }
    
    return {
        'rho_original': rho_A,
        'rho_optimal': best_rho,
        'improvement': rho_A - best_rho,
        'config': best_config,
    }


# ---- Benchmarking ----

def benchmark_karp(sizes: List[int] = None) -> List[dict]:
    """Benchmark Karp's algorithm across matrix sizes."""
    if sizes is None:
        sizes = [5, 10, 20, 50, 100]
    
    results = []
    for n in sizes:
        np.random.seed(42)
        A = np.random.uniform(1, 10, (n, n))
        
        start = time.time()
        rho, _ = karp_minimum_cycle_mean(A)
        elapsed = time.time() - start
        
        results.append({'n': n, 'time': elapsed, 'rho': rho})
        print(f"  n={n:4d}: ρ={rho:.4f}, time={elapsed:.4f}s")
    
    return results


if __name__ == "__main__":
    print("Tropical Surgery Algorithms — Test Suite")
    print("=" * 50)
    
    # Test min-plus multiplication
    A = np.array([[0, 3], [7, 0]])
    B = np.array([[0, 1], [2, 0]])
    C = tropical_matrix_multiply(A, B)
    print(f"\nMin-plus multiply:\n{A}\n⊗\n{B}\n=\n{C}")
    
    # Test Karp's algorithm
    print("\nKarp's algorithm test:")
    A = np.array([
        [5., 2., 8.],
        [3., 6., 1.],
        [7., 4., 9.]
    ])
    rho, cycle = karp_minimum_cycle_mean(A)
    print(f"  Matrix:\n{A}")
    print(f"  Min cycle mean: {rho:.4f}")
    
    # Test spectral bound certificate
    print("\nSpectral bound certificate:")
    n = 4
    np.random.seed(42)
    A = np.random.uniform(1, 10, (n, n))
    u = np.random.uniform(0, 3, n)
    v = np.random.uniform(0, 3, n)
    u_prime = np.random.uniform(0, 3, n)
    v_prime = np.random.uniform(0, 3, n)
    
    cert = spectral_bound_certificate(A, u, v, u_prime, v_prime)
    for k, val in cert.items():
        print(f"  {k}: {val}")
    
    # Benchmark
    print("\nBenchmark Karp's algorithm:")
    benchmark_karp([5, 10, 20, 50])
