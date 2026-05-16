"""
Algorithms for Markov-Tropical Bridge Computation

Implements the key algorithms for computing tropical cycle means
and verifying the Markov-tropical bridge theorem.
"""

import numpy as np
from typing import List, Tuple, Optional


def karp_min_cycle_mean(W: np.ndarray) -> float:
    """
    Karp's algorithm for computing the minimum cycle mean of a weighted
    directed graph.
    
    Given a weight matrix W[i][j], computes:
        μ* = min over all cycles C of (sum of weights on C) / |C|
    
    Time complexity: O(n³) where n is the number of vertices.
    Space complexity: O(n²)
    
    Args:
        W: n×n weight matrix (W[i][j] = weight of edge i→j)
    
    Returns:
        The minimum cycle mean μ*
    """
    n = W.shape[0]
    INF = float('inf')
    
    # D[k][v] = min weight of a walk of exactly k edges ending at v
    # starting from a fixed source (we try all sources)
    
    min_cycle_mean = INF
    
    for source in range(n):
        D = np.full((n + 1, n), INF)
        D[0, source] = 0.0
        
        for k in range(1, n + 1):
            for v in range(n):
                for u in range(n):
                    if D[k-1, u] < INF:
                        D[k, v] = min(D[k, v], D[k-1, u] + W[u, v])
        
        # Karp's formula: μ* = min_v max_{0≤k≤n-1} (D[n,v] - D[k,v]) / (n-k)
        for v in range(n):
            if D[n, v] < INF:
                max_val = -INF
                for k in range(n):
                    if D[k, v] < INF:
                        val = (D[n, v] - D[k, v]) / (n - k)
                        max_val = max(max_val, val)
                min_cycle_mean = min(min_cycle_mean, max_val)
    
    return min_cycle_mean


def triangle_cycle_mean(W: np.ndarray) -> float:
    """
    Compute the minimum triangle cycle mean.
    
    This is the min over all triples (i,j,k) of:
        (W[i,j] + W[j,k] + W[k,i]) / 3
    
    Time complexity: O(n³)
    
    Args:
        W: n×n weight matrix
    
    Returns:
        Minimum triangle cycle mean
    """
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = (W[i, j] + W[j, k] + W[k, i]) / 3.0
                if val < min_val:
                    min_val = val
    return min_val


def tropical_mixing_certificate(
    P: np.ndarray,
    m: int
) -> dict:
    """
    Compute the tropical mixing certificate for a Markov chain.
    
    Given a positive row-stochastic matrix P and step count m,
    computes:
    - The mixing bound α = max_{i,j} (P^m)(i,j)
    - The tropical energy barrier -log(α) / m
    - The triangle cycle mean of -log P
    - The full minimum cycle mean of -log P (via Karp's algorithm)
    
    The theorem guarantees: -log(α)/m ≤ triangleCyc(-log P) ≤ μ*(-log P)
    
    Args:
        P: Positive row-stochastic matrix
        m: Number of steps
    
    Returns:
        Dictionary with all computed quantities
    """
    n = P.shape[0]
    W = -np.log(P)
    
    Pm = np.linalg.matrix_power(P, m)
    alpha = Pm.max()
    
    tcyc = triangle_cycle_mean(W)
    full_min_cycle = karp_min_cycle_mean(W)
    
    return {
        'n': n,
        'm': m,
        'alpha': alpha,
        'neg_log_alpha': -np.log(alpha),
        'energy_barrier': -np.log(alpha) / m,
        'triangle_cycle_mean': tcyc,
        'karp_min_cycle_mean': full_min_cycle,
        'theorem_holds': -np.log(alpha) / m <= tcyc + 1e-10,
        'full_theorem_holds': -np.log(alpha) / m <= full_min_cycle + 1e-10,
    }


def mixing_time_lower_bound(
    P: np.ndarray,
    epsilon: float = 0.01
) -> int:
    """
    Compute a lower bound on the mixing time using the tropical certificate.
    
    The mixing time t_mix(ε) is the smallest m such that
    max_{i,j} |P^m(i,j) - π(j)| ≤ ε.
    
    Our theorem gives: if P^m(i,j) ≤ α, then -log(α)/m ≤ TCG.
    Rearranging: m ≥ -log(α) / TCG.
    
    For α close to 1/(n+1) + ε (near-stationary), this gives
    m ≥ log(n) / TCG approximately.
    
    Args:
        P: Positive row-stochastic matrix
        epsilon: Target mixing accuracy
    
    Returns:
        Lower bound on mixing time
    """
    n = P.shape[0]
    W = -np.log(P)
    tcyc = triangle_cycle_mean(W)
    
    if tcyc <= 0:
        return 0
    
    # For uniform stationary distribution, α → 1/n
    # Mixing time ≥ -log(1/n + ε) / tcyc
    target_alpha = 1.0 / n + epsilon
    if target_alpha >= 1:
        return 0
    
    return int(np.ceil(-np.log(target_alpha) / tcyc))


def spectral_gap_from_tropical(P: np.ndarray) -> dict:
    """
    Extract spectral information from tropical cycle geometry.
    
    The tropical cycle mean provides a computable certificate
    that is related to spectral properties of the chain.
    
    Args:
        P: Positive row-stochastic matrix
    
    Returns:
        Dictionary with tropical and spectral quantities
    """
    n = P.shape[0]
    W = -np.log(P)
    
    tcyc = triangle_cycle_mean(W)
    
    # Actual spectral gap for comparison
    eigenvalues = np.linalg.eigvals(P)
    eigenvalues_real = np.sort(np.abs(eigenvalues))[::-1]
    spectral_gap = 1 - eigenvalues_real[1] if len(eigenvalues_real) > 1 else 1.0
    
    return {
        'n': n,
        'triangle_cycle_mean': tcyc,
        'spectral_gap': spectral_gap,
        'second_eigenvalue': eigenvalues_real[1] if len(eigenvalues_real) > 1 else 0,
    }


if __name__ == "__main__":
    print("Markov-Tropical Bridge: Algorithm Demonstrations\n")
    
    # Example: 4-state random walk on a cycle
    n = 4
    eps = 0.15
    P = np.zeros((n, n))
    for i in range(n):
        P[i, i] = 1 - 2*eps
        P[i, (i+1) % n] = eps
        P[i, (i-1) % n] = eps
    
    print(f"4-state lazy random walk on cycle (ε={eps}):")
    print(f"P = \n{P}\n")
    
    for m in [1, 5, 10, 20, 50]:
        cert = tropical_mixing_certificate(P, m)
        print(f"m={m:3d}: α={cert['alpha']:.4f}, "
              f"-log(α)/m={cert['energy_barrier']:.4f}, "
              f"TCM={cert['triangle_cycle_mean']:.4f}, "
              f"Karp={cert['karp_min_cycle_mean']:.4f}, "
              f"OK={cert['theorem_holds']}")
    
    print(f"\nSpectral analysis:")
    spec = spectral_gap_from_tropical(P)
    print(f"  Triangle cycle mean: {spec['triangle_cycle_mean']:.6f}")
    print(f"  Spectral gap:        {spec['spectral_gap']:.6f}")
    print(f"  Second eigenvalue:   {spec['second_eigenvalue']:.6f}")
    
    print(f"\nMixing time lower bound (ε=0.01): {mixing_time_lower_bound(P, 0.01)}")
