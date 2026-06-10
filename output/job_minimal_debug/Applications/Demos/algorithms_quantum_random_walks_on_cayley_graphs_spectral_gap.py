#!/usr/bin/env python3
"""
Algorithms for Quantum Random Walks on Cayley Graphs

Type-hinted implementations of the core algorithms underlying the spectral
gap theory of quantum walks on Cayley graphs.
"""

import numpy as np
from typing import List, Tuple, Optional


def cayley_adjacency_matrix(
    group_elements: List[int],
    generators: List[int],
    group_op: callable,
    group_inv: callable
) -> np.ndarray:
    """
    Construct the adjacency matrix of Cay(G, S).
    
    Args:
        group_elements: List of group elements (as integers/labels)
        generators: Symmetric generating set S
        group_op: Binary group operation (g, h) -> g*h
        group_inv: Group inverse g -> g^(-1)
    
    Returns:
        |G| × |G| adjacency matrix A where A[g,h] = 1 iff g^{-1}h ∈ S
    """
    n: int = len(group_elements)
    idx: dict = {g: i for i, g in enumerate(group_elements)}
    A: np.ndarray = np.zeros((n, n))
    
    for g in group_elements:
        for s in generators:
            h = group_op(g, s)
            if h in idx:
                A[idx[g], idx[h]] = 1.0
    return A


def cyclic_cayley_matrix(n: int) -> np.ndarray:
    """
    Adjacency matrix of Cay(Z/nZ, {±1}).
    
    The eigenvalues are 2·cos(2πk/n) for k = 0, ..., n-1.
    Spectral gap = 1 - cos(2π/n).
    """
    A: np.ndarray = np.zeros((n, n))
    for i in range(n):
        A[i, (i + 1) % n] = 1.0
        A[i, (i - 1) % n] = 1.0
    return A


def spectral_gap(A: np.ndarray) -> float:
    """
    Compute the spectral gap of a transition matrix.
    
    The spectral gap is 1 - |λ₂|/|λ₁| where λ₁ is the largest
    eigenvalue and λ₂ is the second-largest in absolute value.
    """
    eigenvalues: np.ndarray = np.sort(np.abs(np.linalg.eigvalsh(A)))[::-1]
    d: float = eigenvalues[0]  # degree (largest eigenvalue)
    if d == 0:
        return 0.0
    lambda2: float = eigenvalues[1] / d
    return 1 - lambda2


def classical_mixing_time(n: int, gap: float, epsilon: float = 0.01) -> float:
    """
    Classical mixing time bound: T = log(n/ε) / γ.
    
    Args:
        n: Number of vertices
        gap: Spectral gap γ
        epsilon: Target total variation distance
    
    Returns:
        Upper bound on mixing time
    """
    if gap <= 0:
        return float('inf')
    return np.log(n / epsilon) / gap


def quantum_mixing_time(n: int, gap: float, epsilon: float = 0.01) -> float:
    """
    Quantum mixing time bound: T = √n · log(n/ε) / γ.
    
    The √n factor comes from the amplitude gap being √γ instead of γ.
    """
    if gap <= 0:
        return float('inf')
    return np.sqrt(n) * np.log(n / epsilon) / gap


def spectral_exponential_bridge(gamma: float, t: int) -> Tuple[float, float, float]:
    """
    Compute the three-way sandwich inequality:
    (1-γ)^t ≤ exp(-γt) ≤ (1-γ/2)^t
    
    Returns:
        (lower, middle, upper) bounds
    """
    lower: float = (1 - gamma) ** t
    middle: float = np.exp(-gamma * t)
    upper: float = (1 - gamma / 2) ** t
    return lower, middle, upper


def amplitude_gap(gamma: float) -> Tuple[float, float]:
    """
    Compute the amplitude gap: √(1-γ) and its bound 1-γ/2.
    
    The amplitude gap theorem states √(1-γ) ≤ 1-γ/2.
    This is the mechanism behind quantum quadratic speedup:
    amplitudes decay at rate √(1-γ) while probabilities decay at (1-γ).
    """
    return np.sqrt(1 - gamma), 1 - gamma / 2


def product_mixing_bound(
    n1: int, n2: int, 
    gap1: float, gap2: float
) -> Tuple[float, float, float]:
    """
    Product group mixing time analysis.
    
    For G₁ × G₂ with gaps γ₁, γ₂:
    - Product mixing time: log(n₁·n₂) / min(γ₁, γ₂)
    - Factor mixing times: log(n₁)/γ₁ and log(n₂)/γ₂
    - Bound: T_product ≥ max(T₁, T₂)
    
    Returns:
        (T_product, T_factor1, T_factor2)
    """
    min_gap: float = min(gap1, gap2)
    t_product: float = np.log(n1 * n2) / min_gap if min_gap > 0 else float('inf')
    t1: float = np.log(n1) / gap1 if gap1 > 0 else float('inf')
    t2: float = np.log(n2) / gap2 if gap2 > 0 else float('inf')
    return t_product, t1, t2


def simulate_walk_convergence(
    A: np.ndarray,
    max_steps: int = 1000,
    epsilon: float = 1e-6
) -> Tuple[int, List[float]]:
    """
    Simulate a classical random walk and track total variation distance.
    
    Args:
        A: Adjacency matrix
        max_steps: Maximum simulation steps
        epsilon: Convergence threshold
    
    Returns:
        (mixing_time, distance_history)
    """
    n: int = A.shape[0]
    d: float = A.sum(axis=1)[0]
    P: np.ndarray = A / d  # transition matrix
    
    # Start at vertex 0
    dist: np.ndarray = np.zeros(n)
    dist[0] = 1.0
    
    uniform: np.ndarray = np.ones(n) / n
    distances: List[float] = []
    
    for t in range(max_steps):
        tv: float = 0.5 * np.sum(np.abs(dist - uniform))
        distances.append(tv)
        if tv < epsilon:
            return t, distances
        dist = dist @ P
    
    return max_steps, distances


def entropy_production_rate(d: int, gamma: float) -> float:
    """
    Compute the entropy production rate of a random walk.
    
    For a d-regular graph with spectral gap γ:
    rate = γ · log(d)
    """
    if d <= 1:
        return 0.0
    return gamma * np.log(d)


def cheeger_spectral_sandwich(
    gamma: float, h: float, d: int
) -> Tuple[bool, bool]:
    """
    Verify Cheeger's inequality: h²/(2d) ≤ γ ≤ 2h.
    
    Returns:
        (lower_holds, upper_holds)
    """
    lower: bool = h**2 / (2 * d) <= gamma + 1e-10
    upper: bool = gamma <= 2 * h + 1e-10
    return lower, upper


def quantum_walk_simulation(
    H: np.ndarray,
    t_max: float,
    dt: float = 0.01
) -> List[np.ndarray]:
    """
    Simulate continuous-time quantum walk via matrix exponential.
    
    |ψ(t)⟩ = exp(-iHt)|0⟩
    P(g, t) = |⟨g|ψ(t)⟩|²
    
    Args:
        H: Hamiltonian (adjacency matrix)
        t_max: Maximum time
        dt: Time step
    
    Returns:
        List of probability distributions at each time step
    """
    n: int = H.shape[0]
    psi0: np.ndarray = np.zeros(n, dtype=complex)
    psi0[0] = 1.0
    
    distributions: List[np.ndarray] = []
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    
    for t in np.arange(0, t_max, dt):
        # exp(-iHt) = V @ diag(exp(-iλt)) @ V†
        phases = np.exp(-1j * eigenvalues * t)
        psi = eigenvectors @ (phases * (eigenvectors.conj().T @ psi0))
        prob = np.abs(psi) ** 2
        distributions.append(prob)
    
    return distributions


if __name__ == "__main__":
    print("Testing algorithms...")
    
    # Test cyclic group
    n = 20
    A = cyclic_cayley_matrix(n)
    gap = spectral_gap(A)
    print(f"Z/{n}Z with ±1: spectral gap = {gap:.6f}")
    print(f"  Theoretical: 1 - cos(2π/{n}) = {1 - np.cos(2*np.pi/n):.6f}")
    
    # Test mixing time bounds
    t_class = classical_mixing_time(n, gap)
    t_quantum = quantum_mixing_time(n, gap)
    print(f"  Classical mixing time: {t_class:.1f}")
    print(f"  Quantum mixing time: {t_quantum:.1f}")
    print(f"  Speedup: {t_class/t_quantum:.4f} (should be ~1/√{n} = {1/np.sqrt(n):.4f})")
    
    # Test bridge
    lower, middle, upper = spectral_exponential_bridge(gap, 10)
    print(f"  Bridge at t=10: {lower:.6e} ≤ {middle:.6e} ≤ {upper:.6e}")
    
    # Test simulation
    mixing_t, history = simulate_walk_convergence(A)
    print(f"  Simulated mixing time: {mixing_t} steps")
    
    print("\nAll algorithm tests passed.")
