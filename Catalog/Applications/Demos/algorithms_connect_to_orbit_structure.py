#!/usr/bin/env python3
"""
Tropical Orbit Complexity — Algorithms

Implements the core algorithms from the research paper:
1. Tropical matrix multiplication and power computation
2. Tropical spectral radius computation (max cycle mean)
3. Tropical eigenvector computation
4. Normalized orbit analysis
5. Orbit entropy estimation
"""

import numpy as np
from typing import Tuple, List, Dict, Optional


# ============================================================================
# Core Tropical Operations
# ============================================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition (max-plus): a ⊕ b = max(a, b)."""
    return max(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication (max-plus): a ⊗ b = a + b."""
    return a + b


def trop_mul_mat(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication: (A⊗B)_{ij} = max_k (A_{ik} + B_{kj}).

    Time complexity: O(n³) where n is the matrix dimension.
    Space complexity: O(n²) for the result matrix.

    Args:
        A: n×n matrix
        B: n×n matrix
    Returns:
        n×n matrix C where C[i,j] = max_k(A[i,k] + B[k,j])
    """
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = max(A[i, k] + B[k, j] for k in range(n))
    return C


def trop_pow(G: np.ndarray, k: int) -> np.ndarray:
    """
    Compute the k-th tropical power of G via repeated multiplication.

    Time complexity: O(k · n³)
    Space complexity: O(n²)

    Args:
        G: n×n matrix
        k: power (k ≥ 0)
    Returns:
        G^⊗k
    """
    n = G.shape[0]
    if k == 0:
        return np.zeros((n, n))
    result = G.copy()
    for _ in range(k - 1):
        result = trop_mul_mat(result, G)
    return result


def trop_mat_vec_mul(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Tropical matrix-vector multiplication: (A⊗v)_i = max_j(A_{ij} + v_j).

    Time complexity: O(n²)

    Args:
        A: n×n matrix
        v: n-vector
    Returns:
        n-vector w where w[i] = max_j(A[i,j] + v[j])
    """
    n = A.shape[0]
    return np.array([max(A[i, j] + v[j] for j in range(n)) for i in range(n)])


# ============================================================================
# Spectral Analysis
# ============================================================================

def tropical_spectral_radius(G: np.ndarray) -> float:
    """
    Compute the tropical spectral radius (maximum cycle mean) of G.

    The tropical spectral radius is:
        ρ(G) = max over all cycles (i₁,...,iₖ) of
               (G[i₁,i₂] + G[i₂,i₃] + ... + G[iₖ,i₁]) / k

    Algorithm: Karp's algorithm via tropical matrix powers.
    Time complexity: O(n⁴) via computing all powers up to n.
    Space complexity: O(n³) for storing intermediate powers.

    Args:
        G: n×n matrix
    Returns:
        Maximum cycle mean ρ(G)
    """
    n = G.shape[0]

    # Compute G, G², ..., G^n
    powers = [None] * (n + 1)
    powers[1] = G.copy()
    for k in range(2, n + 1):
        powers[k] = trop_mul_mat(powers[k - 1], G)

    # Karp's algorithm: ρ = max_i min_k (G^n[i,i] - G^k[i,i]) / (n-k)
    rho = -np.inf
    for i in range(n):
        min_val = np.inf
        for k in range(1, n):
            if powers[n][i, i] != -np.inf and powers[k][i, i] != -np.inf:
                val = (powers[n][i, i] - powers[k][i, i]) / (n - k)
                min_val = min(min_val, val)
        if min_val != np.inf:
            rho = max(rho, min_val)

    # Also check diagonal entries directly (self-loops)
    for i in range(n):
        rho = max(rho, G[i, i])

    # And check all 2-cycles
    for i in range(n):
        for j in range(i + 1, n):
            rho = max(rho, (G[i, j] + G[j, i]) / 2)

    return rho


def find_tropical_eigenvector(G: np.ndarray, rho: Optional[float] = None,
                                max_iter: int = 1000) -> Tuple[np.ndarray, float]:
    """
    Find a tropical eigenvector of G: a vector v such that G⊗v = ρ+v.

    Algorithm: Power iteration in the tropical semiring.
    After subtracting ρ at each step, iterate v ← G⊗v - ρ until convergence.

    Time complexity: O(max_iter · n²)

    Args:
        G: n×n matrix
        rho: eigenvalue (computed if None)
        max_iter: maximum iterations
    Returns:
        (v, rho) where G⊗v = ρ + v (approximately)
    """
    n = G.shape[0]
    if rho is None:
        rho = tropical_spectral_radius(G)

    v = np.zeros(n)
    for _ in range(max_iter):
        v_new = trop_mat_vec_mul(G, v) - rho
        if np.allclose(v_new, v):
            break
        v = v_new

    return v, rho


# ============================================================================
# Orbit Analysis
# ============================================================================

def normalized_orbit(G: np.ndarray, rho: float, N: int) -> Dict[tuple, int]:
    """
    Compute the normalized orbit {G̃^(1), ..., G̃^(N)} where G̃^(k) = G^⊗k - kρ.

    Time complexity: O(N · n³)
    Space complexity: O(|orbit| · n²)

    Args:
        G: n×n matrix
        rho: spectral radius / drift parameter
        N: maximum power
    Returns:
        Dictionary mapping matrix tuples to first occurrence time
    """
    seen = {}
    Gk = G.copy()
    for k in range(1, N + 1):
        if k > 1:
            Gk = trop_mul_mat(Gk, G)
        normalized = Gk - k * rho
        key = tuple(np.round(normalized, 10).flatten())
        if key not in seen:
            seen[key] = k
    return seen


def orbit_cardinality_sequence(G: np.ndarray, rho: float, N: int) -> List[int]:
    """
    Compute the orbit cardinality sequence |{G̃^(1),...,G̃^(k)}| for k=1,...,N.

    Time complexity: O(N · n³)

    Args:
        G: n×n matrix
        rho: spectral radius
        N: maximum power
    Returns:
        List of orbit cardinalities
    """
    seen = set()
    sizes = []
    Gk = G.copy()
    for k in range(1, N + 1):
        if k > 1:
            Gk = trop_mul_mat(Gk, G)
        normalized = Gk - k * rho
        key = tuple(np.round(normalized, 10).flatten())
        seen.add(key)
        sizes.append(len(seen))
    return sizes


def orbit_entropy_sequence(G: np.ndarray, rho: float, N: int) -> List[float]:
    """
    Compute the orbit entropy rate sequence log(|orbit_k|)/k for k=1,...,N.

    Time complexity: O(N · n³)

    Args:
        G: n×n matrix
        rho: spectral radius
        N: maximum power
    Returns:
        List of entropy rates
    """
    sizes = orbit_cardinality_sequence(G, rho, N)
    rates = []
    for k, s in enumerate(sizes, 1):
        if s > 0:
            rates.append(np.log(s) / k)
        else:
            rates.append(0.0)
    return rates


def entry_bound_from_eigenvector(G: np.ndarray, v: np.ndarray, rho: float,
                                   k: int) -> np.ndarray:
    """
    Compute the eigenvector-based upper bound on G^⊗k entries.

    By Theorem B: G^⊗k_{ij} ≤ k·ρ + v_i - v_j

    Args:
        G: n×n matrix
        v: tropical eigenvector
        rho: tropical eigenvalue
        k: power
    Returns:
        n×n matrix of upper bounds
    """
    n = G.shape[0]
    bounds = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            bounds[i, j] = k * rho + v[i] - v[j]
    return bounds


# ============================================================================
# Application: Discrete Event Systems
# ============================================================================

def des_cycle_time(G: np.ndarray, num_cycles: int = 100) -> Tuple[float, np.ndarray]:
    """
    Compute the cycle time and transient behavior of a discrete event system.

    In a DES modeled by max-plus linear system x(k+1) = G⊗x(k),
    the cycle time equals the tropical spectral radius.
    The transient is the number of steps before periodicity.

    Args:
        G: n×n transition matrix (processing times + routing)
        num_cycles: number of cycles to simulate
    Returns:
        (cycle_time, trajectory) where trajectory[k] = x(k)
    """
    n = G.shape[0]
    rho = tropical_spectral_radius(G)
    x = np.zeros(n)
    trajectory = [x.copy()]

    for k in range(num_cycles):
        x = trop_mat_vec_mul(G, x)
        trajectory.append(x.copy())

    return rho, np.array(trajectory)


if __name__ == "__main__":
    # Quick test
    G = np.array([[3, 1], [2, 4]], dtype=float)
    rho = tropical_spectral_radius(G)
    print(f"Spectral radius of [[3,1],[2,4]]: {rho}")

    v, rho = find_tropical_eigenvector(G)
    print(f"Eigenvector: {v}, eigenvalue: {rho}")

    orbit = normalized_orbit(G, rho, 100)
    print(f"Orbit size (N=100): {len(orbit)}")

    entropy = orbit_entropy_sequence(G, rho, 20)
    print(f"Entropy rates: {[f'{e:.4f}' for e in entropy]}")
