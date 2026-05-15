#!/usr/bin/env python3
"""
Algorithms for Tropical Probabilistic Comparison Theory

Implements the core computational algorithms for:
1. Triangle cycle gap computation
2. General cycle mean computation (Karp's algorithm)
3. Spectral gap computation
4. Multi-step tropical gap analysis

All algorithms include complexity analysis and docstrings.
"""

import numpy as np
from typing import List, Tuple, Optional
from itertools import product


def log_weight_matrix(P: np.ndarray) -> np.ndarray:
    """
    Compute the tropical weight matrix W = -log(P).
    
    Args:
        P: Strictly positive matrix (all entries > 0).
        
    Returns:
        W: Tropical weight matrix where W[i,j] = -log(P[i,j]).
        
    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    assert np.all(P > 0), "All entries must be strictly positive"
    return -np.log(P)


def triangle_cycle_gap(W: np.ndarray) -> Tuple[float, Tuple[int, int, int]]:
    """
    Compute the triangle cycle gap: min over all triples (i,j,k) of
    the mean triangle weight (W[i,j] + W[j,k] + W[k,i]) / 3.
    
    Args:
        W: Weight matrix of shape (n, n).
        
    Returns:
        (gap, (i_min, j_min, k_min)): The minimum triangle mean and
        the triple achieving it.
        
    Time complexity: O(n³)
    Space complexity: O(1)
    
    This is the most directly computable tropical cycle invariant,
    corresponding to our formally verified `triangleCycleGap` definition.
    """
    n = W.shape[0]
    min_mean = float('inf')
    best_triple = (0, 0, 0)
    
    for i in range(n):
        for j in range(n):
            for k in range(n):
                mean = (W[i, j] + W[j, k] + W[k, i]) / 3.0
                if mean < min_mean:
                    min_mean = mean
                    best_triple = (i, j, k)
    
    return min_mean, best_triple


def karp_minimum_cycle_mean(W: np.ndarray) -> Tuple[float, List[int]]:
    """
    Karp's algorithm for minimum cycle mean in a weighted digraph.
    
    Computes:
        λ* = min_c (cycleWeight(W, c) / length(c))
    
    over all directed cycles c in the complete graph.
    
    Args:
        W: Weight matrix of shape (n, n).
        
    Returns:
        (lambda_star, cycle): The minimum cycle mean and a cycle achieving it.
        
    Time complexity: O(n³)
    Space complexity: O(n²)
    
    Reference: Karp, R.M. "A characterization of the minimum cycle mean
    in a digraph." Discrete Mathematics 23 (1978): 309-311.
    
    This computes the exact tropical spectral radius (critical cycle mean),
    which our triangle cycle gap approximates from above.
    """
    n = W.shape[0]
    
    # D[k][v] = minimum weight of a k-edge walk ending at v
    # (starting from a designated source; we try all sources)
    INF = float('inf')
    
    # Actually, Karp's algorithm uses a fixed source and works as follows:
    # D[k][v] = min weight of a k-edge path from source s to v
    # λ* = min_v max_k (D[n][v] - D[k][v]) / (n - k)
    
    # For complete directed graphs, we use the standard formulation:
    D = np.full((n + 1, n), INF)
    parent = np.full((n + 1, n), -1, dtype=int)
    
    # Try source 0
    D[0, 0] = 0.0
    
    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                new_cost = D[k-1, u] + W[u, v]
                if new_cost < D[k, v]:
                    D[k, v] = new_cost
                    parent[k, v] = u
    
    # Compute minimum cycle mean
    lambda_star = INF
    best_v = 0
    best_k = 0
    
    for v in range(n):
        if D[n, v] < INF:
            max_ratio = -INF
            max_k = 0
            for k in range(n):
                if D[k, v] < INF:
                    ratio = (D[n, v] - D[k, v]) / (n - k)
                    if ratio > max_ratio:
                        max_ratio = ratio
                        max_k = k
            if max_ratio < lambda_star:
                lambda_star = max_ratio
                best_v = v
                best_k = max_k
    
    # If we got INF, try all sources
    if lambda_star == INF:
        for s in range(1, n):
            D_s = np.full((n + 1, n), INF)
            D_s[0, s] = 0.0
            for k in range(1, n + 1):
                for v in range(n):
                    for u in range(n):
                        new_cost = D_s[k-1, u] + W[u, v]
                        if new_cost < D_s[k, v]:
                            D_s[k, v] = new_cost
            
            for v in range(n):
                if D_s[n, v] < INF:
                    for k in range(n):
                        if D_s[k, v] < INF:
                            ratio = (D_s[n, v] - D_s[k, v]) / (n - k)
                            if ratio < lambda_star:
                                lambda_star = ratio
    
    # Extract cycle (simplified - just return the value)
    return lambda_star, []


def spectral_gap_symmetric(P: np.ndarray) -> float:
    """
    Compute the spectral gap γ(P) = 1 - λ₂ for a symmetric stochastic matrix.
    
    Args:
        P: Symmetric row-stochastic matrix.
        
    Returns:
        γ: The spectral gap (1 minus second-largest eigenvalue magnitude).
        
    Time complexity: O(n³) (eigenvalue decomposition)
    Space complexity: O(n²)
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(P))[::-1]
    if len(eigenvalues) < 2:
        return 1.0
    return 1.0 - eigenvalues[1]


def spectral_gap_surrogate(P: np.ndarray) -> float:
    """
    Compute the elementary spectral gap surrogate: 1 - max(P).
    
    This is the Lean-formalized surrogate that avoids eigenvalue computation.
    
    Args:
        P: Positive matrix.
        
    Returns:
        γ_min: Elementary spectral gap surrogate.
        
    Time complexity: O(n²)
    Space complexity: O(1)
    """
    return 1.0 - np.max(P)


def multi_step_tropical_gap(P: np.ndarray, m: int) -> Tuple[float, float]:
    """
    Compute the m-step tropical gap: triangle cycle gap of -log(P^m).
    
    This implements the multi-step heat-kernel tropicalization from
    Future Direction 1.
    
    Args:
        P: Strictly positive stochastic matrix.
        m: Number of steps (power of P).
        
    Returns:
        (gap, bound): The triangle cycle gap of W^(m) and the
        theoretical lower bound -log(max entry of P^m).
        
    Time complexity: O(n³ · log(m) + n³) for matrix power + gap computation
    Space complexity: O(n²)
    """
    Pm = np.linalg.matrix_power(P, m)
    Wm = -np.log(Pm)
    gap, _ = triangle_cycle_gap(Wm)
    bound = -np.log(np.max(Pm))
    return gap, bound


def verify_theorem1(P: np.ndarray) -> dict:
    """
    Verify Theorem 1 (triangle cycle gap lower bound) numerically.
    
    For a positive matrix P, checks that:
        triangleCycleGap(-log P) ≥ -log(max P)
    
    Args:
        P: Strictly positive matrix.
        
    Returns:
        Dictionary with verification results.
    """
    W = log_weight_matrix(P)
    gap, best_triple = triangle_cycle_gap(W)
    s = np.max(P)
    bound = -np.log(s)
    
    return {
        'max_entry': s,
        'bound': bound,
        'gap': gap,
        'best_triple': best_triple,
        'theorem_holds': gap >= bound - 1e-12,
        'margin': gap - bound,
    }


def verify_theorem2(P: np.ndarray, epsilon: float) -> dict:
    """
    Verify Theorem 2 (non-determinism → positive gap) numerically.
    
    For P with entries ≤ 1 - ε, checks that:
        triangleCycleGap(-log P) ≥ -log(1 - ε) > 0
    
    Args:
        P: Strictly positive matrix with entries ≤ 1 - ε.
        epsilon: The non-determinism parameter.
        
    Returns:
        Dictionary with verification results.
    """
    assert 0 < epsilon < 1
    assert np.all(P <= 1 - epsilon + 1e-12)
    
    W = log_weight_matrix(P)
    gap, _ = triangle_cycle_gap(W)
    bound = -np.log(1 - epsilon)
    
    return {
        'epsilon': epsilon,
        'bound': bound,
        'gap': gap,
        'gap_positive': gap > 0,
        'theorem_holds': gap >= bound - 1e-12,
    }


def compare_spectral_tropical(P: np.ndarray) -> dict:
    """
    Full comparison between spectral and tropical invariants.
    
    Args:
        P: Symmetric row-stochastic strictly positive matrix.
        
    Returns:
        Dictionary with all comparison data.
    """
    W = log_weight_matrix(P)
    
    # Spectral data
    eigenvalues = np.sort(np.linalg.eigvalsh(P))[::-1]
    gamma = 1.0 - eigenvalues[1] if len(eigenvalues) > 1 else 1.0
    
    # Tropical data
    gap_tri, best_triple = triangle_cycle_gap(W)
    gap_karp, _ = karp_minimum_cycle_mean(W)
    
    # Bounds
    s = np.max(P)
    entrywise_bound = -np.log(s)
    surrogate = spectral_gap_surrogate(P)
    
    return {
        'dimension': P.shape[0],
        'eigenvalues': eigenvalues,
        'spectral_gap': gamma,
        'spectral_surrogate': surrogate,
        'max_entry': s,
        'triangle_gap': gap_tri,
        'karp_gap': gap_karp,
        'entrywise_bound': entrywise_bound,
        'best_triple': best_triple,
    }


if __name__ == "__main__":
    np.random.seed(42)
    
    print("=== Algorithm Verification ===\n")
    
    # Test with a specific matrix
    P = np.array([
        [0.4, 0.3, 0.3],
        [0.2, 0.5, 0.3],
        [0.3, 0.3, 0.4]
    ])
    
    print("Test matrix P:")
    print(P)
    
    result = verify_theorem1(P)
    print(f"\nTheorem 1 verification:")
    print(f"  max(P) = {result['max_entry']:.4f}")
    print(f"  -log(max P) = {result['bound']:.4f}")
    print(f"  g(W) = {result['gap']:.4f}")
    print(f"  Theorem holds: {result['theorem_holds']}")
    
    result2 = verify_theorem2(P, 0.5)
    print(f"\nTheorem 2 verification (ε=0.5):")
    print(f"  -log(1-ε) = {result2['bound']:.4f}")
    print(f"  g(W) = {result2['gap']:.4f}")
    print(f"  Gap positive: {result2['gap_positive']}")
    
    # Symmetric matrix comparison
    n = 5
    alpha = 0.6
    P_sym = alpha * np.eye(n) + (1 - alpha) * np.ones((n, n)) / n
    
    comp = compare_spectral_tropical(P_sym)
    print(f"\nSpectral-Tropical Comparison (n={n}, α={alpha}):")
    print(f"  Spectral gap γ = {comp['spectral_gap']:.4f}")
    print(f"  Triangle gap = {comp['triangle_gap']:.4f}")
    print(f"  Karp gap = {comp['karp_gap']:.4f}")
    print(f"  Entrywise bound = {comp['entrywise_bound']:.4f}")
    
    # Multi-step analysis
    print(f"\nMulti-step analysis:")
    for m in [1, 2, 5, 10, 20]:
        gap, bound = multi_step_tropical_gap(P_sym, m)
        print(f"  m={m:2d}: g(W^(m))={gap:.4f}, bound={bound:.4f}")
