#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Tropical Matrix Surgery

Implements the core algorithms from the tropical surgery spectral theory,
including efficient spectral radius computation, surgery operations, and
sensitivity analysis.
"""

import numpy as np
from itertools import product
from typing import List, Tuple, Optional


def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication: (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j]).
    
    Time complexity: O(n³)
    Space complexity: O(n²)
    
    Args:
        A: n×n matrix
        B: n×n matrix
    Returns:
        n×n min-plus product
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
    Compute the p-th min-plus power of A.
    
    Time complexity: O(n³ · p)
    Space complexity: O(n²)
    """
    n = A.shape[0]
    result = A.copy()
    for _ in range(p - 1):
        result = tropical_matrix_multiply(result, A)
    return result


def karp_minimum_cycle_mean(A: np.ndarray) -> float:
    """
    Karp's algorithm for minimum cycle mean.
    
    Computes the tropical spectral radius (minimum cycle mean) of matrix A
    using Karp's (1978) classical algorithm.
    
    Time complexity: O(n³)  (n matrix-vector products of size n)
    Space complexity: O(n²)
    
    Pseudocode:
        1. Compute F[k][v] = min weight of any walk of length k ending at v
           (from a fixed source, or equivalently using all sources)
        2. λ* = min_v max_k (F[n][v] - F[k][v]) / (n - k)
    
    Args:
        A: n×n real matrix (weights of directed graph)
    Returns:
        Minimum cycle mean (tropical spectral radius)
    """
    n = A.shape[0]
    
    # F[k][v] = minimum weight walk of exactly k edges ending at v
    # We compute from each starting vertex and take the global minimum
    INF = float('inf')
    
    best_mean = INF
    
    for s in range(n):
        # F[k][v] for starting vertex s
        F = np.full((n + 1, n), INF)
        F[0, s] = 0.0
        
        for k in range(1, n + 1):
            for v in range(n):
                for u in range(n):
                    if F[k-1, u] < INF:
                        F[k, v] = min(F[k, v], F[k-1, u] + A[u, v])
        
        # Karp's formula: min_v max_{0≤k<n} (F[n][v] - F[k][v]) / (n - k)
        for v in range(n):
            if F[n, v] < INF:
                max_ratio = -INF
                for k in range(n):
                    if F[k, v] < INF:
                        ratio = (F[n, v] - F[k, v]) / (n - k)
                        max_ratio = max(max_ratio, ratio)
                if max_ratio < INF:
                    best_mean = min(best_mean, max_ratio)
    
    return best_mean


def tropical_spectral_radius_bruteforce(A: np.ndarray) -> float:
    """
    Brute-force computation of tropical spectral radius.
    Enumerates all cycles up to length n.
    
    Time complexity: O(n^(n+1))  — exponential, for small n only
    """
    n = A.shape[0]
    best = float('inf')
    
    for length in range(1, n + 1):
        for cycle in product(range(n), repeat=length):
            weight = sum(A[cycle[t], cycle[(t+1) % length]] for t in range(length))
            mean = weight / length
            best = min(best, mean)
    
    return best


def tropical_rank_two_surgery(
    A: np.ndarray,
    u: np.ndarray, v: np.ndarray,
    u_prime: np.ndarray, v_prime: np.ndarray
) -> np.ndarray:
    """
    Rank-2 tropical surgery.
    
    B[i,j] = min(A[i,j], u[i]+v[j], u'[i]+v'[j])
    
    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    R1 = np.add.outer(u, v)
    R2 = np.add.outer(u_prime, v_prime)
    return np.minimum(A, np.minimum(R1, R2))


def two_entry_surgery(
    A: np.ndarray,
    i1: int, j1: int, c1: float,
    i2: int, j2: int, c2: float
) -> np.ndarray:
    """
    Localized two-entry surgery.
    
    Time complexity: O(n²) for copy, O(1) for the two updates
    """
    B = A.copy()
    B[i1, j1] = min(A[i1, j1], c1)
    B[i2, j2] = min(A[i2, j2], c2)
    return B


def surgery_support(A: np.ndarray, B: np.ndarray) -> List[Tuple[int, int]]:
    """
    Compute the surgery support: positions where B[i,j] < A[i,j].
    
    Time complexity: O(n²)
    """
    n = A.shape[0]
    return [(i, j) for i in range(n) for j in range(n) if B[i, j] < A[i, j] - 1e-12]


def explicit_spectral_bound(
    A: np.ndarray,
    u: np.ndarray, v: np.ndarray,
    u_prime: np.ndarray, v_prime: np.ndarray
) -> float:
    """
    Compute the explicit spectral bound for rank-2 surgery:
    min(ρ(A), min_i(u_i + v_i), min_i(u'_i + v'_i))
    
    Time complexity: O(n³) for Karp + O(n) for diagonal minima
    """
    rho_A = karp_minimum_cycle_mean(A)
    diag_min_1 = min(u[i] + v[i] for i in range(len(u)))
    diag_min_2 = min(u_prime[i] + v_prime[i] for i in range(len(u_prime)))
    return min(rho_A, min(diag_min_1, diag_min_2))


def spectral_sensitivity_analysis(
    A: np.ndarray,
    epsilon: float = 0.1,
) -> np.ndarray:
    """
    Compute spectral sensitivity: for each edge (i,j), how much does
    decreasing A[i,j] by epsilon change the spectral radius?
    
    Returns an n×n matrix of sensitivities.
    
    Time complexity: O(n⁵) — O(n²) entries × O(n³) Karp per entry
    """
    n = A.shape[0]
    rho_A = karp_minimum_cycle_mean(A)
    sensitivity = np.zeros((n, n))
    
    for i in range(n):
        for j in range(n):
            B = A.copy()
            B[i, j] -= epsilon
            rho_B = karp_minimum_cycle_mean(B)
            sensitivity[i, j] = (rho_A - rho_B) / epsilon
    
    return sensitivity


def find_critical_cycles(A: np.ndarray, tol: float = 1e-8) -> List[List[int]]:
    """
    Find all critical cycles (those achieving the minimum cycle mean).
    
    Time complexity: O(n^(n+1)) — brute force for small n
    
    Args:
        A: n×n matrix
        tol: tolerance for cycle mean comparison
    Returns:
        List of critical cycles (as vertex sequences)
    """
    n = A.shape[0]
    rho = tropical_spectral_radius_bruteforce(A)
    critical = []
    
    for length in range(1, n + 1):
        for cycle in product(range(n), repeat=length):
            weight = sum(A[cycle[t], cycle[(t+1) % length]] for t in range(length))
            mean = weight / length
            if abs(mean - rho) < tol:
                # Normalize cycle (rotate to smallest starting vertex)
                min_start = min(range(length), key=lambda i: cycle[i:] + cycle[:i])
                normalized = list(cycle[min_start:] + cycle[:min_start])
                if normalized not in critical:
                    critical.append(normalized)
    
    return critical


def is_surgery_off_critical(
    A: np.ndarray,
    B: np.ndarray,
    tol: float = 1e-8
) -> bool:
    """
    Check if surgery is off-critical: no critical cycle of A uses
    an edge in the surgery support.
    
    Time complexity: O(n^(n+1))
    """
    support = surgery_support(A, B)
    critical = find_critical_cycles(A, tol)
    
    for cycle in critical:
        k = len(cycle)
        for t in range(k):
            edge = (cycle[t], cycle[(t+1) % k])
            if edge in support:
                return False
    return True


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Tropical Surgery Algorithms — Example Usage")
    print("=" * 50)
    
    # Example matrix
    A = np.array([
        [2.0, 5.0, 8.0],
        [3.0, 1.0, 4.0],
        [7.0, 6.0, 3.0]
    ])
    
    # Compute spectral radius two ways
    rho_karp = karp_minimum_cycle_mean(A)
    rho_brute = tropical_spectral_radius_bruteforce(A)
    print(f"\nSpectral radius (Karp):       {rho_karp:.6f}")
    print(f"Spectral radius (brute-force): {rho_brute:.6f}")
    print(f"Agreement: {abs(rho_karp - rho_brute) < 1e-8}")
    
    # Surgery
    u = np.array([1.0, 0.5, 2.0])
    v = np.array([0.0, 1.0, 0.5])
    up = np.array([0.5, 1.5, 0.0])
    vp = np.array([1.0, 0.5, 2.0])
    
    B = tropical_rank_two_surgery(A, u, v, up, vp)
    rho_B = karp_minimum_cycle_mean(B)
    bound = explicit_spectral_bound(A, u, v, up, vp)
    
    print(f"\nAfter rank-2 surgery:")
    print(f"  ρ(B) = {rho_B:.6f}")
    print(f"  ρ(A) = {rho_karp:.6f}")
    print(f"  Explicit bound = {bound:.6f}")
    print(f"  ρ(B) ≤ ρ(A)? {rho_B <= rho_karp + 1e-8}")
    print(f"  ρ(B) ≤ bound? {rho_B <= bound + 1e-8}")
    
    # Sensitivity
    print(f"\nSpectral sensitivity matrix (ε=0.1):")
    sens = spectral_sensitivity_analysis(A, 0.1)
    for row in sens:
        print("  [" + ", ".join(f"{x:+.4f}" for x in row) + "]")
    
    # Critical cycles
    print(f"\nCritical cycles of A:")
    for c in find_critical_cycles(A):
        weight = sum(A[c[t], c[(t+1) % len(c)]] for t in range(len(c)))
        print(f"  {c} (mean = {weight/len(c):.4f})")
    
    # Off-critical check
    print(f"\nSurgery support: {surgery_support(A, B)}")
    print(f"Surgery is off-critical? {is_surgery_off_critical(A, B)}")
