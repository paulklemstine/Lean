#!/usr/bin/env python3
"""
Algorithms for Tropical Ecosystem Dynamics

Implements the core algorithms from the tropical predator-prey framework,
including eigenvalue computation, eigenvector finding, stability analysis,
and n-species generalizations.
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Tropical Matrix-Vector Product (Min-Plus)
# ─────────────────────────────────────────────────────────────

def tropical_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Min-plus matrix-vector multiplication.
    
    (A ⊗ x)_i = min_j (A_{ij} + x_j)
    
    Time: O(n²) for n×n matrix
    Space: O(n)
    
    Args:
        A: n×n matrix of real weights (use np.inf for absent edges)
        x: n-vector
    
    Returns:
        n-vector result of min-plus product
    
    Example:
        >>> A = np.array([[1.0, 2.0], [3.0, 0.5]])
        >>> x = np.array([1.0, 2.0])
        >>> tropical_matvec(A, x)
        array([2., 2.5])
    """
    n = A.shape[0]
    result = np.full(n, np.inf)
    for i in range(n):
        for j in range(n):
            result[i] = min(result[i], A[i, j] + x[j])
    return result


def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication.
    
    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})
    
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


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Minimum Cycle Mean (Karp's Algorithm)
# ─────────────────────────────────────────────────────────────

def min_cycle_mean_karp(W: np.ndarray) -> float:
    """Compute the minimum cycle mean of a weighted digraph using Karp's algorithm.
    
    The minimum cycle mean is:
        λ* = min over all simple cycles C of (sum of weights on C) / |C|
    
    This is the tropical eigenvalue of the min-plus matrix W.
    
    Time: O(n³) using dynamic programming
    Space: O(n²)
    
    Args:
        W: n×n weight matrix (np.inf for absent edges)
    
    Returns:
        Minimum cycle mean (np.inf if no cycles exist)
    
    Example:
        >>> W = np.array([[1.0, 2.0], [3.0, 0.5]])
        >>> min_cycle_mean_karp(W)  # min(1, 0.5, (2+3)/2) = 0.5
        0.5
    """
    n = W.shape[0]
    
    # D[k][v] = minimum weight path of exactly k edges ending at v
    D = np.full((n + 1, n), np.inf)
    
    # Base case: zero-length path from each node to itself
    for v in range(n):
        D[0][v] = 0.0
    
    # Fill DP table
    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                if D[k-1][u] < np.inf and W[u][v] < np.inf:
                    D[k][v] = min(D[k][v], D[k-1][u] + W[u][v])
    
    # Karp's formula: λ* = min_v max_k (D[n][v] - D[k][v]) / (n - k)
    lambda_star = np.inf
    for v in range(n):
        if D[n][v] < np.inf:
            max_ratio = -np.inf
            for k in range(n):
                if D[k][v] < np.inf:
                    ratio = (D[n][v] - D[k][v]) / (n - k)
                    max_ratio = max(max_ratio, ratio)
            lambda_star = min(lambda_star, max_ratio)
    
    return lambda_star


def min_cycle_mean_2x2(a: float, b: float, c: float, d: float) -> float:
    """Direct formula for 2×2 minimum cycle mean.
    
    For the matrix [[a, b], [c, d]], the minimum cycle mean is:
        μ = min(a, d, (b+c)/2)
    
    This enumerates all simple cycles in the 2-node digraph:
    - Self-loop at node 0: weight a, length 1 → mean a
    - Self-loop at node 1: weight d, length 1 → mean d
    - 2-cycle 0→1→0: weight b+c, length 2 → mean (b+c)/2
    
    Time: O(1)
    Space: O(1)
    """
    return min(a, min(d, (b + c) / 2))


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Tropical Eigenvector Computation
# ─────────────────────────────────────────────────────────────

def tropical_eigenvector_2x2(a: float, b: float, c: float, d: float) -> Optional[Tuple[float, np.ndarray]]:
    """Find a tropical eigenvector for a 2×2 min-plus system.
    
    Finds μ and v such that:
        min(a + v₀, b + v₁) = μ + v₀
        min(c + v₀, d + v₁) = μ + v₁
    
    Strategy: set v₀ = 0 (projective normalization) and solve for v₁.
    
    Time: O(1)
    Space: O(1)
    
    Returns:
        (eigenvalue, eigenvector) or None if no eigenvector exists
    """
    mu = min_cycle_mean_2x2(a, b, c, d)
    
    # With v₀ = 0, we need:
    # min(a, b + v₁) = μ        ... (i)
    # min(c, d + v₁) = μ + v₁   ... (ii)
    
    # From the cycle analysis, try candidate eigenvectors:
    # Case 1: μ = a. Then min(a, b + v₁) = a ⟹ b + v₁ ≥ a ⟹ v₁ ≥ a - b.
    #   And min(c, d + v₁) = a + v₁ ⟹ either c = a + v₁ or d = a.
    # Case 2: μ = d. Symmetric.
    # Case 3: μ = (b+c)/2.
    
    # General approach: try v₁ = μ - c (from the 2-cycle path 1→0→1)
    # and v₁ = d - μ (from the self-loop at 1)
    
    candidates = []
    
    # Candidate from 2-cycle: v = (0, c - b) / normalized
    # Actually: set v₀ = 0. If μ comes from (b+c)/2:
    #   v₁ = μ - c + v₀ = (b+c)/2 - c = (b-c)/2
    v1_try = (b - c) / 2.0
    v = np.array([0.0, v1_try])
    Fv = np.array([min(a + v[0], b + v[1]), min(c + v[0], d + v[1])])
    shifted = np.array([mu + v[0], mu + v[1]])
    if np.allclose(Fv, shifted, atol=1e-10):
        candidates.append((mu, v))
    
    # Candidate: v₁ = a - b (from self-loop at 0 dominating first coord)
    v1_try = a - b
    v = np.array([0.0, v1_try])
    Fv = np.array([min(a + v[0], b + v[1]), min(c + v[0], d + v[1])])
    shifted = np.array([mu + v[0], mu + v[1]])
    if np.allclose(Fv, shifted, atol=1e-10):
        candidates.append((mu, v))
    
    # Candidate: v₁ = 0
    v = np.array([0.0, 0.0])
    Fv = np.array([min(a + v[0], b + v[1]), min(c + v[0], d + v[1])])
    shifted = np.array([mu + v[0], mu + v[1]])
    if np.allclose(Fv, shifted, atol=1e-10):
        candidates.append((mu, v))
    
    if candidates:
        return candidates[0]
    return None


def tropical_eigenvector_power(W: np.ndarray, max_iter: int = 1000,
                                tol: float = 1e-10) -> Tuple[float, np.ndarray]:
    """Compute tropical eigenvalue and eigenvector via power iteration.
    
    Repeatedly applies the min-plus matrix W to a starting vector,
    normalizing projectively (subtract min coordinate) at each step.
    
    Time: O(n² · max_iter) per iteration
    Space: O(n)
    
    Convergence: guaranteed for irreducible matrices in O(n²) iterations.
    
    Args:
        W: n×n min-plus weight matrix
        max_iter: maximum iterations
        tol: convergence tolerance
    
    Returns:
        (eigenvalue, eigenvector)
    """
    n = W.shape[0]
    x = np.zeros(n)
    
    eigenvalue = 0.0
    for iteration in range(max_iter):
        y = tropical_matvec(W, x)
        
        # Projective normalization: subtract minimum
        shift = np.min(y)
        y_normalized = y - shift
        
        if np.max(np.abs(y_normalized - x)) < tol:
            eigenvalue = shift
            return eigenvalue, y_normalized
        
        x = y_normalized
        eigenvalue = shift
    
    return eigenvalue, x


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Tropical Predator-Prey Simulation
# ─────────────────────────────────────────────────────────────

@dataclass
class TropicalTrajectory:
    """Record of a tropical predator-prey trajectory."""
    params: Tuple[float, float, float, float]
    initial: Tuple[float, float]
    states: List[Tuple[float, float]]
    eigenvalue: float
    distances: List[float]  # sup-distances between consecutive states


def simulate_tropical_ecosystem(
    a: float, b: float, c: float, d: float,
    initial: Tuple[float, float],
    n_steps: int = 100
) -> TropicalTrajectory:
    """Simulate the tropical predator-prey system.
    
    Computes the trajectory F^[0](v), F^[1](v), ..., F^[n](v)
    and records distances between consecutive states.
    
    Time: O(n_steps)
    Space: O(n_steps)
    """
    mu = min_cycle_mean_2x2(a, b, c, d)
    states = [initial]
    distances = []
    
    current = initial
    for _ in range(n_steps):
        nxt = (min(a + current[0], b + current[1]),
               min(c + current[0], d + current[1]))
        distances.append(max(abs(nxt[0] - current[0]), abs(nxt[1] - current[1])))
        states.append(nxt)
        current = nxt
    
    return TropicalTrajectory(
        params=(a, b, c, d),
        initial=initial,
        states=states,
        eigenvalue=mu,
        distances=distances
    )


# ─────────────────────────────────────────────────────────────
# Algorithm 5: N-Species Tropical Ecosystem
# ─────────────────────────────────────────────────────────────

def n_species_tropical_update(W: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Update step for an n-species tropical ecosystem.
    
    x_i' = min_j (W_{ij} + x_j)
    
    This generalizes TropPredPrey to n species.
    
    Time: O(n²)
    Space: O(n)
    """
    return tropical_matvec(W, x)


def n_species_simulate(W: np.ndarray, x0: np.ndarray,
                        n_steps: int = 100) -> np.ndarray:
    """Simulate n-species tropical ecosystem.
    
    Returns: (n_steps+1) × n array of states
    
    Time: O(n² · n_steps)
    Space: O(n · n_steps)
    """
    n = W.shape[0]
    trajectory = np.zeros((n_steps + 1, n))
    trajectory[0] = x0
    
    for t in range(n_steps):
        trajectory[t + 1] = n_species_tropical_update(W, trajectory[t])
    
    return trajectory


# ─────────────────────────────────────────────────────────────
# Algorithm 6: Stability Analysis
# ─────────────────────────────────────────────────────────────

def analyze_stability(a: float, b: float, c: float, d: float,
                      n_samples: int = 100) -> dict:
    """Comprehensive stability analysis of a tropical predator-prey system.
    
    Computes:
    - Tropical eigenvalue
    - Contraction ratios (empirical)
    - Eigenvector (if exists)
    - Long-term drift rate
    
    Time: O(n_samples · n_iter)
    Space: O(n_samples)
    """
    mu = min_cycle_mean_2x2(a, b, c, d)
    
    # Empirical contraction ratios
    np.random.seed(42)
    ratios = []
    for _ in range(n_samples):
        p = tuple(np.random.randn(2) * 5)
        q = tuple(np.random.randn(2) * 5)
        d0 = max(abs(p[0]-q[0]), abs(p[1]-q[1]))
        fp = (min(a+p[0], b+p[1]), min(c+p[0], d+p[1]))
        fq = (min(a+q[0], b+q[1]), min(c+q[0], d+q[1]))
        d1 = max(abs(fp[0]-fq[0]), abs(fp[1]-fq[1]))
        if d0 > 1e-10:
            ratios.append(d1 / d0)
    
    eigvec_result = tropical_eigenvector_2x2(a, b, c, d)
    
    return {
        'eigenvalue': mu,
        'mean_contraction_ratio': np.mean(ratios) if ratios else 1.0,
        'max_contraction_ratio': np.max(ratios) if ratios else 1.0,
        'eigenvector': eigvec_result[1] if eigvec_result else None,
        'dominant_cycle': 'self-loop prey' if mu == a else
                         ('self-loop predator' if mu == d else '2-cycle'),
    }


# ─────────────────────────────────────────────────────────────
# Main: Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Ecosystem Dynamics — Algorithm Demonstrations")
    print("=" * 60)
    
    # 2×2 system
    a, b, c, d_param = 1.0, 3.0, 2.0, 0.5
    W = np.array([[a, b], [c, d_param]])
    
    print(f"\n1. Min-Plus Matrix: \n{W}")
    print(f"   Min cycle mean (direct): {min_cycle_mean_2x2(a, b, c, d_param):.4f}")
    print(f"   Min cycle mean (Karp):   {min_cycle_mean_karp(W):.4f}")
    
    # Eigenvector
    result = tropical_eigenvector_2x2(a, b, c, d_param)
    if result:
        mu, v = result
        print(f"\n2. Tropical eigenvector: μ = {mu:.4f}, v = {v}")
        Fv = tropical_matvec(W, v)
        print(f"   W ⊗ v = {Fv}")
        print(f"   μ + v = {mu + v}")
    
    # Power iteration
    mu_pow, v_pow = tropical_eigenvector_power(W)
    print(f"\n3. Power iteration: μ = {mu_pow:.4f}, v = {v_pow}")
    
    # Stability analysis
    analysis = analyze_stability(a, b, c, d_param)
    print(f"\n4. Stability analysis:")
    for key, val in analysis.items():
        print(f"   {key}: {val}")
    
    # 3-species example
    print(f"\n5. Three-species ecosystem:")
    W3 = np.array([
        [0.5, 2.0, 3.0],
        [1.0, 0.8, 2.5],
        [3.0, 1.5, 0.3]
    ])
    x0 = np.array([0.0, 0.0, 0.0])
    mu3 = min_cycle_mean_karp(W3)
    print(f"   Weight matrix:\n{W3}")
    print(f"   Min cycle mean: {mu3:.4f}")
    
    traj = n_species_simulate(W3, x0, 10)
    print(f"   First 10 states:")
    for t in range(11):
        print(f"     t={t:2d}: {traj[t]}")
    
    print("\nAll algorithms completed successfully.")
