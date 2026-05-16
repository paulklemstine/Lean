#!/usr/bin/env python3
"""
Algorithms for Tropical Cycle Analysis of Markov Chains.

Implements the core algorithms underlying the Markov-Tropical Bridge theorem:
1. Triangle cycle mean computation
2. Karp's algorithm for general cycle means
3. Tropical gap verification
4. Mixing time estimation from tropical invariants
"""

import numpy as np
from typing import Tuple, List, Optional
from itertools import product as cartesian_product


def tropical_cost_matrix(P: np.ndarray) -> np.ndarray:
    """
    Compute the tropical cost matrix W = -log(P).
    
    Converts multiplicative transition probabilities into additive
    tropical edge weights (information costs).
    
    Args:
        P: Positive row-stochastic matrix.
        
    Returns:
        W: Tropical cost matrix where W[i,j] = -log(P[i,j]).
        
    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    assert np.all(P > 0), "Matrix must have strictly positive entries"
    return -np.log(P)


def triangle_cycle_mean(W: np.ndarray) -> Tuple[float, Tuple[int, int, int]]:
    """
    Compute the minimum triangle cycle mean and the achieving triple.
    
    Finds min_{i,j,k} (W[i,j] + W[j,k] + W[k,i]) / 3.
    
    Args:
        W: Weight matrix (tropical cost matrix).
        
    Returns:
        (min_mean, (i_opt, j_opt, k_opt)): Minimum mean and achieving triple.
        
    Time complexity: O(n³)
    Space complexity: O(1)
    
    Pseudocode:
        min_mean ← ∞
        for i in 0..n-1:
            for j in 0..n-1:
                for k in 0..n-1:
                    mean ← (W[i,j] + W[j,k] + W[k,i]) / 3
                    if mean < min_mean:
                        min_mean ← mean
                        best ← (i, j, k)
        return (min_mean, best)
    """
    n = W.shape[0]
    min_mean = float('inf')
    best = (0, 0, 0)
    
    for i in range(n):
        for j in range(n):
            for k in range(n):
                mean = (W[i, j] + W[j, k] + W[k, i]) / 3.0
                if mean < min_mean:
                    min_mean = mean
                    best = (i, j, k)
    
    return min_mean, best


def karp_minimum_cycle_mean(W: np.ndarray) -> Tuple[float, List[int]]:
    """
    Karp's algorithm for minimum cycle mean.
    
    Computes the minimum average weight over all directed cycles
    in the graph with weight matrix W.
    
    Args:
        W: Weight matrix (n×n).
        
    Returns:
        (min_mean, cycle): Minimum cycle mean and a cycle achieving it.
        
    Time complexity: O(n³)
    Space complexity: O(n²)
    
    Pseudocode:
        // Phase 1: Compute shortest path costs
        D[0][v] ← 0 for all v
        for k = 1 to n:
            for v in 0..n-1:
                D[k][v] ← min_{u} (D[k-1][u] + W[u,v])
        
        // Phase 2: Extract minimum cycle mean
        λ* ← min_v max_k (D[n][v] - D[k][v]) / (n - k)
        
        return λ*
    """
    n = W.shape[0]
    INF = float('inf')
    
    # D[k][v] = minimum weight of a walk of exactly k edges ending at v
    # Starting from each vertex with weight 0
    D = np.full((n + 1, n), INF)
    parent = np.full((n + 1, n), -1, dtype=int)
    
    # Initialize: zero-length paths from a virtual source
    D[0, :] = 0
    
    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                new_cost = D[k-1, u] + W[u, v]
                if new_cost < D[k, v]:
                    D[k, v] = new_cost
                    parent[k, v] = u
    
    # Extract minimum cycle mean using Karp's formula
    min_mean = INF
    best_v = 0
    best_k = 0
    
    for v in range(n):
        max_val = -INF
        max_k = 0
        for k in range(n):
            if D[k, v] < INF and D[n, v] < INF:
                val = (D[n, v] - D[k, v]) / (n - k)
                if val > max_val:
                    max_val = val
                    max_k = k
        if max_val < min_mean:
            min_mean = max_val
            best_v = v
            best_k = max_k
    
    # Reconstruct cycle (approximate)
    cycle = [best_v]
    v = best_v
    for step in range(n, best_k, -1):
        v = parent[step, v]
        if v == -1:
            break
        cycle.append(v)
    cycle.reverse()
    
    return min_mean, cycle


def verify_tropical_gap(P: np.ndarray, m: int) -> dict:
    """
    Verify the multi-step tropical gap theorem numerically.
    
    Checks: -log(α) / m ≤ triangleCyc(-log P)
    where α = max_{i,j} (P^m)(i,j).
    
    Args:
        P: Positive row-stochastic matrix.
        m: Number of steps.
        
    Returns:
        Dictionary with verification results.
        
    Time complexity: O(n³ · m) for matrix power, O(n³) for triangle cycle mean.
    """
    n = P.shape[0]
    Pm = np.linalg.matrix_power(P, m)
    alpha = Pm.max()
    
    W = tropical_cost_matrix(P)
    tc, best_triple = triangle_cycle_mean(W)
    
    bound = -np.log(alpha) / m if alpha > 0 else float('inf')
    
    return {
        'n': n,
        'm': m,
        'alpha': alpha,
        'neg_log_alpha_over_m': bound,
        'triangle_cyc': tc,
        'best_triple': best_triple,
        'gap_satisfied': tc >= bound - 1e-10,
        'margin': tc - bound,
        'speed_limit': np.exp(-m * tc),
    }


def estimate_mixing_time(P: np.ndarray, epsilon: float = 0.01) -> dict:
    """
    Estimate mixing time using both classical and tropical methods.
    
    Classical: Find smallest m such that max|P^m(i,j) - π(j)| ≤ ε.
    Tropical: Use the speed limit exp(-m·triangleCyc) as a lower bound predictor.
    
    Args:
        P: Positive row-stochastic matrix.
        epsilon: Mixing threshold.
        
    Returns:
        Dictionary with mixing time estimates.
    """
    n = P.shape[0]
    
    # Compute stationary distribution
    eigenvalues, eigenvectors = np.linalg.eig(P.T)
    idx = np.argmin(np.abs(eigenvalues - 1.0))
    pi = np.real(eigenvectors[:, idx])
    pi = pi / pi.sum()
    
    # Classical mixing time
    mix_time = None
    Pm = np.eye(n)
    for m in range(1, 1000):
        Pm = Pm @ P
        max_dev = np.max(np.abs(Pm - pi[np.newaxis, :]))
        if max_dev <= epsilon:
            mix_time = m
            break
    
    # Tropical invariants
    W = tropical_cost_matrix(P)
    tc, _ = triangle_cycle_mean(W)
    karp_mean, karp_cycle = karp_minimum_cycle_mean(W)
    
    # Second eigenvalue (spectral gap)
    sorted_eigenvalues = sorted(np.abs(eigenvalues), reverse=True)
    lambda2 = sorted_eigenvalues[1] if len(sorted_eigenvalues) > 1 else 0
    
    return {
        'n': n,
        'epsilon': epsilon,
        'stationary': pi,
        'classical_mixing_time': mix_time,
        'triangle_cyc': tc,
        'karp_cycle_mean': karp_mean,
        'spectral_gap': 1 - lambda2,
        'second_eigenvalue': lambda2,
    }


def tropical_metastability_analysis(P: np.ndarray) -> dict:
    """
    Analyze metastability structure using tropical cycle means.
    
    Computes the triangle mean landscape and identifies bottleneck
    structures that indicate metastable states.
    
    Args:
        P: Positive row-stochastic matrix.
        
    Returns:
        Dictionary with metastability analysis.
    """
    n = P.shape[0]
    W = tropical_cost_matrix(P)
    
    # Compute all triangle means
    means = np.zeros((n, n, n))
    for i, j, k in cartesian_product(range(n), repeat=3):
        means[i, j, k] = (W[i, j] + W[j, k] + W[k, i]) / 3.0
    
    tc = means.min()
    max_mean = means.max()
    mean_mean = means.mean()
    
    # Identify bottleneck triples (high triangle mean)
    threshold = mean_mean + (max_mean - mean_mean) * 0.5
    bottleneck_triples = []
    for i, j, k in cartesian_product(range(n), repeat=3):
        if means[i, j, k] >= threshold:
            bottleneck_triples.append((i, j, k, means[i, j, k]))
    
    # Metastability gap
    gap = max_mean - tc
    
    return {
        'n': n,
        'triangle_cyc': tc,
        'max_triangle_mean': max_mean,
        'mean_triangle_mean': mean_mean,
        'metastability_gap': gap,
        'num_bottleneck_triples': len(bottleneck_triples),
        'bottleneck_examples': bottleneck_triples[:5],
    }


if __name__ == "__main__":
    print("Tropical Cycle Analysis Algorithms")
    print("=" * 50)
    
    # Example: 4-state chain with metastability
    P = np.array([
        [0.7, 0.2, 0.05, 0.05],
        [0.15, 0.7, 0.1, 0.05],
        [0.05, 0.1, 0.7, 0.15],
        [0.05, 0.05, 0.2, 0.7]
    ])
    
    print("\n1. Tropical Gap Verification:")
    for m in [1, 5, 10, 50]:
        result = verify_tropical_gap(P, m)
        print(f"   m={m:3d}: α={result['alpha']:.4f}, "
              f"bound={result['neg_log_alpha_over_m']:.4f}, "
              f"tc={result['triangle_cyc']:.4f}, "
              f"ok={'✓' if result['gap_satisfied'] else '✗'}")
    
    print("\n2. Mixing Time Analysis:")
    mix = estimate_mixing_time(P)
    print(f"   Classical mixing time (ε=0.01): {mix['classical_mixing_time']}")
    print(f"   Triangle cycle mean: {mix['triangle_cyc']:.4f}")
    print(f"   Karp cycle mean: {mix['karp_cycle_mean']:.4f}")
    print(f"   Spectral gap: {mix['spectral_gap']:.4f}")
    
    print("\n3. Metastability Analysis:")
    meta = tropical_metastability_analysis(P)
    print(f"   Triangle cycle mean (min): {meta['triangle_cyc']:.4f}")
    print(f"   Max triangle mean: {meta['max_triangle_mean']:.4f}")
    print(f"   Metastability gap: {meta['metastability_gap']:.4f}")
    print(f"   Bottleneck triples: {meta['num_bottleneck_triples']}")
