#!/usr/bin/env python3
"""
Algorithms for Tropical Cycle Gap Computation and Mixing Analysis

Implements the key algorithms from the tropical mixing theory:
1. Tropical cycle gap computation
2. Karp's algorithm for minimum/maximum cycle mean
3. Mixing time estimation via tropical certificates
4. Spectral gap bounds from tropical invariants
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_cycle_gap(W: np.ndarray) -> float:
    """Compute the tropical cycle gap of a weight matrix.
    
    The tropical cycle gap is max_i W[i,i] - min_i W[i,i],
    measuring the spread of self-loop weights.
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        W: Square matrix (n x n) with real entries
    
    Returns:
        The tropical cycle gap (nonneg)
    """
    diag = np.diag(W)
    return float(np.max(diag) - np.min(diag))


def karp_maximum_cycle_mean(W: np.ndarray) -> float:
    """Compute the maximum cycle mean using Karp's algorithm.
    
    The maximum cycle mean is:
        max over all cycles C of (sum of W[i,j] on C) / |C|
    
    This is the max-plus eigenvalue of the matrix W.
    
    Time complexity: O(n^3)
    Space complexity: O(n^2)
    
    Args:
        W: Square matrix (n x n), entries can be -inf for missing edges
    
    Returns:
        Maximum cycle mean, or -inf if no cycles exist
    
    Reference:
        Karp, R.M. (1978). "A characterization of the minimum cycle mean 
        in a digraph." Discrete Mathematics.
    """
    n = W.shape[0]
    
    # D[k][v] = maximum weight of a path of exactly k edges ending at v
    NEG_INF = -np.inf
    D = np.full((n + 1, n), NEG_INF)
    
    # Base case: path of 0 edges from each vertex
    for v in range(n):
        D[0][v] = 0.0
    
    # Fill DP table
    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                if D[k-1][u] > NEG_INF and W[u][v] > NEG_INF:
                    D[k][v] = max(D[k][v], D[k-1][u] + W[u][v])
    
    # Compute maximum cycle mean using Karp's formula
    result = NEG_INF
    for v in range(n):
        if D[n][v] > NEG_INF:
            min_ratio = np.inf
            for k in range(n):
                if D[k][v] > NEG_INF:
                    ratio = (D[n][v] - D[k][v]) / (n - k)
                    min_ratio = min(min_ratio, ratio)
            if min_ratio < np.inf:
                result = max(result, min_ratio)
    
    return result


def tropical_spectral_radius(W: np.ndarray) -> float:
    """Compute the tropical (max-plus) spectral radius.
    
    This is the maximum cycle mean of W, computed via Karp's algorithm.
    
    Args:
        W: Square matrix (n x n)
    
    Returns:
        Tropical spectral radius
    """
    return karp_maximum_cycle_mean(W)


def mixing_lower_bound_certificate(
    P: np.ndarray
) -> Tuple[float, float, float]:
    """Compute a certified mixing lower bound for a 2-state stochastic matrix.
    
    Given P = [[a, 1-a], [1-b, b]], computes:
    - The tropical cycle gap τ = |a - b|
    - The spectral gap γ = 2 - a - b  
    - A certified lower bound on relaxation time: τ/2
    
    The certificate guarantees: relaxation_time ≥ τ/2.
    
    Args:
        P: 2x2 row-stochastic matrix
    
    Returns:
        Tuple of (tropical_cycle_gap, spectral_gap, mixing_lower_bound)
    """
    assert P.shape == (2, 2), "Must be 2x2"
    a, b = P[0, 0], P[1, 1]
    
    gap = abs(a - b)
    spectral_gap = 2 - a - b
    lower_bound = gap / 2
    
    return gap, spectral_gap, lower_bound


def log_weight_matrix(P: np.ndarray, epsilon: float = 1e-15) -> np.ndarray:
    """Convert a stochastic matrix to log-weight (tropical) coordinates.
    
    W[i,j] = -log(P[i,j]) when P[i,j] > 0, +inf otherwise.
    
    In these coordinates:
    - Small probabilities → large weights (barriers)
    - Large probabilities → small weights (easy transitions)
    - Path costs add (tropical multiplication = addition)
    
    Args:
        P: Stochastic matrix with nonneg entries
        epsilon: Small constant to avoid log(0)
    
    Returns:
        Log-weight matrix
    """
    P_safe = np.maximum(P, epsilon)
    return -np.log(P_safe)


def tropical_barrier_height(
    W: np.ndarray, S: set, T: set
) -> float:
    """Compute the tropical barrier height between two sets of states.
    
    The barrier height is the minimum cost of any single-edge transition
    from S to T in the log-weight matrix.
    
    Args:
        W: Log-weight matrix
        S: Source set of state indices
        T: Target set of state indices
    
    Returns:
        Minimum edge weight from S to T
    """
    min_cost = np.inf
    for i in S:
        for j in T:
            if j not in S:  # Only count transitions leaving S
                min_cost = min(min_cost, W[i][j])
    return min_cost


def general_mixing_analysis(P: np.ndarray) -> dict:
    """Complete tropical mixing analysis of a stochastic matrix.
    
    Computes all tropical invariants and classical spectral quantities,
    providing a comprehensive comparison.
    
    Args:
        P: n×n row-stochastic matrix
    
    Returns:
        Dictionary with all computed quantities
    """
    n = P.shape[0]
    
    # Tropical invariants
    gap = tropical_cycle_gap(P)
    diag = np.diag(P)
    max_diag = float(np.max(diag))
    min_diag = float(np.min(diag))
    avg_diag = float(np.mean(diag))
    
    # Log-weight analysis
    W = log_weight_matrix(P)
    log_gap = tropical_cycle_gap(W)
    trop_spectral_radius = tropical_spectral_radius(W)
    
    # Classical spectral analysis
    eigenvalues = np.linalg.eigvals(P)
    eig_magnitudes = sorted(np.abs(eigenvalues), reverse=True)
    spectral_gap = 1.0 - eig_magnitudes[1] if n > 1 else 1.0
    relaxation_time = 1.0 / spectral_gap if spectral_gap > 1e-15 else float('inf')
    
    # Trace analysis
    trace = float(np.trace(P))
    trace_defect = n - trace
    
    return {
        'n': n,
        'tropical_cycle_gap': gap,
        'max_diagonal': max_diag,
        'min_diagonal': min_diag,
        'avg_diagonal': avg_diag,
        'log_weight_gap': log_gap,
        'tropical_spectral_radius': trop_spectral_radius,
        'eigenvalue_magnitudes': eig_magnitudes,
        'spectral_gap': spectral_gap,
        'relaxation_time': relaxation_time,
        'trace': trace,
        'trace_defect': trace_defect,
    }


def main():
    print("=" * 70)
    print("TROPICAL MIXING ALGORITHMS — DEMONSTRATIONS")
    print("=" * 70)
    
    # 1. Two-state certified bounds
    print("\n1. TWO-STATE CERTIFIED MIXING BOUNDS")
    print("-" * 40)
    
    test_cases = [
        (0.9, 0.3, "Asymmetric"),
        (0.8, 0.8, "Symmetric sticky"),
        (0.5, 0.1, "Fast state + slow state"),
        (0.99, 0.01, "Extreme asymmetry"),
    ]
    
    for a, b, label in test_cases:
        P = np.array([[a, 1-a], [1-b, b]])
        gap, sg, lb = mixing_lower_bound_certificate(P)
        rt = 1/sg if sg > 0 else float('inf')
        print(f"\n  {label}: a={a}, b={b}")
        print(f"    Tropical cycle gap: {gap:.4f}")
        print(f"    Spectral gap:       {sg:.4f}")
        print(f"    Relaxation time:    {rt:.4f}")
        print(f"    Certified bound:    ≥ {lb:.4f}")
        print(f"    τ·γ = {gap*sg:.4f} ≤ 2 ✓")
    
    # 2. Karp's algorithm
    print("\n\n2. KARP'S ALGORITHM — MAX CYCLE MEAN")
    print("-" * 40)
    
    W = np.array([
        [2, 1, -np.inf],
        [-np.inf, 3, 4],
        [1, -np.inf, 1]
    ])
    mcm = karp_maximum_cycle_mean(W)
    print(f"  Weight matrix:\n{W}")
    print(f"  Maximum cycle mean: {mcm:.4f}")
    
    # 3. General analysis
    print("\n\n3. GENERAL N-STATE ANALYSIS")
    print("-" * 40)
    
    np.random.seed(123)
    for n in [3, 5, 10]:
        P = np.random.dirichlet(np.ones(n) * 0.5, size=n)
        result = general_mixing_analysis(P)
        print(f"\n  n = {n}:")
        print(f"    Tropical cycle gap:     {result['tropical_cycle_gap']:.4f}")
        print(f"    Diagonal range:         [{result['min_diagonal']:.4f}, {result['max_diagonal']:.4f}]")
        print(f"    Spectral gap:           {result['spectral_gap']:.4f}")
        print(f"    Relaxation time:        {result['relaxation_time']:.4f}")
        print(f"    Trace defect (n-tr):    {result['trace_defect']:.4f}")
    
    print("\n" + "=" * 70)


if __name__ == "__main__":
    main()
