#!/usr/bin/env python3
"""
Algorithms for Quantum Random Walks on Cayley Graphs

Type-hinted implementations of the core algorithms for constructing
Cayley graphs, computing spectral gaps, and estimating mixing times.
"""

from typing import List, Tuple, Callable, TypeVar, Dict, Optional
import numpy as np
from numpy.typing import NDArray

T = TypeVar('T')


def construct_cayley_adjacency(
    elements: List[T],
    generators: List[T],
    group_op: Callable[[T, T], T],
    group_inv: Callable[[T], T]
) -> NDArray[np.float64]:
    """
    Construct the adjacency matrix of the Cayley graph Cay(G, S).
    
    The Cayley graph has vertex set G and edges {(g, g·s) : g ∈ G, s ∈ S}.
    Equivalently, A[g][h] = 1 iff g⁻¹·h ∈ S.
    
    Time complexity: O(|G|² · |S|)
    Space complexity: O(|G|²)
    
    Args:
        elements: List of all group elements
        generators: Symmetric generating set S (s ∈ S ⟹ s⁻¹ ∈ S)
        group_op: Group multiplication (g, h) → g·h
        group_inv: Group inversion g → g⁻¹
    
    Returns:
        Adjacency matrix A where A[i][j] = 1 iff elements[i]⁻¹ · elements[j] ∈ S
    """
    n: int = len(elements)
    elem_to_idx: Dict[T, int] = {}
    for i, g in enumerate(elements):
        # Handle unhashable types by converting to tuple if needed
        key = tuple(g) if isinstance(g, (list, np.ndarray)) else g
        elem_to_idx[key] = i
    
    A: NDArray[np.float64] = np.zeros((n, n), dtype=np.float64)
    
    gen_set = set()
    for s in generators:
        key = tuple(s) if isinstance(s, (list, np.ndarray)) else s
        gen_set.add(key)
    
    for i, g in enumerate(elements):
        g_inv = group_inv(g)
        for j, h in enumerate(elements):
            prod = group_op(g_inv, h)
            key = tuple(prod) if isinstance(prod, (list, np.ndarray)) else prod
            if key in gen_set:
                A[i, j] = 1.0
    
    return A


def compute_transition_matrix(
    A: NDArray[np.float64]
) -> NDArray[np.float64]:
    """
    Compute the transition matrix P = (1/d) · A for a d-regular graph.
    
    For a Cayley graph Cay(G, S), d = |S| and P represents the random walk
    where at each step we multiply by a uniform random element of S.
    
    Args:
        A: Adjacency matrix of a regular graph
    
    Returns:
        Row-stochastic transition matrix P
    """
    d: float = float(A.sum(axis=1)[0])
    if d == 0:
        return np.eye(A.shape[0])
    return A / d


def compute_spectral_gap(
    A: NDArray[np.float64]
) -> Tuple[float, NDArray[np.float64]]:
    """
    Compute the spectral gap of the normalized adjacency matrix.
    
    The spectral gap γ = 1 - |λ₂| where λ₂ is the second-largest
    eigenvalue of P = A/d in absolute value.
    
    For symmetric matrices (which Cayley graphs with symmetric generators
    always produce), all eigenvalues are real.
    
    Args:
        A: Adjacency matrix (must be symmetric for real eigenvalues)
    
    Returns:
        Tuple of (spectral_gap, sorted_eigenvalues)
    """
    P: NDArray[np.float64] = compute_transition_matrix(A)
    eigenvalues: NDArray[np.float64] = np.linalg.eigvalsh(P)
    sorted_eigs: NDArray[np.float64] = np.sort(np.abs(eigenvalues))[::-1]
    
    if len(sorted_eigs) < 2:
        return 1.0, sorted_eigs
    
    gap: float = float(1.0 - sorted_eigs[1])
    return gap, sorted_eigs


def classical_mixing_time(
    n: int,
    spectral_gap: float,
    epsilon: float = 0.25
) -> float:
    """
    Estimate classical mixing time from spectral gap.
    
    τ_mix(ε) ≤ (1/γ) · log(n/ε)
    
    This follows from the bound: d_TV(P^t · δ_x, π) ≤ √n · (1-γ)^t
    
    Args:
        n: Number of vertices (= |G|)
        spectral_gap: γ = 1 - |λ₂|
        epsilon: Target total variation distance
    
    Returns:
        Upper bound on mixing time
    """
    if spectral_gap <= 0:
        return float('inf')
    return np.log(n / epsilon) / spectral_gap


def quantum_mixing_time(
    n: int,
    spectral_gap: float,
    epsilon: float = 0.25
) -> float:
    """
    Estimate quantum mixing time from spectral gap.
    
    τ_Q(ε) ≤ √n · (1/γ) · log(n/ε)
    
    The √n factor comes from the quantum amplitude amplification:
    the quantum walk's amplitude gap is √γ, giving mixing in
    O(1/√γ · log(n)) = O(√n/γ · log(n)) steps when γ ~ 1/n.
    
    Args:
        n: Number of vertices (= |G|)
        spectral_gap: γ = 1 - |λ₂|
        epsilon: Target total variation distance
    
    Returns:
        Upper bound on quantum mixing time
    """
    if spectral_gap <= 0:
        return float('inf')
    return np.sqrt(n) * np.log(n / epsilon) / spectral_gap


def simulate_quantum_walk(
    H: NDArray[np.complex128],
    initial_state: NDArray[np.complex128],
    times: List[float]
) -> List[NDArray[np.float64]]:
    """
    Simulate a continuous-time quantum walk.
    
    The evolution is |ψ(t)⟩ = e^{-iHt} |ψ(0)⟩ where H is the
    adjacency matrix (Hamiltonian) of the Cayley graph.
    
    The probability of being at vertex g at time t is P_t(g) = |⟨g|ψ(t)⟩|².
    
    Args:
        H: Hamiltonian (adjacency matrix), must be Hermitian
        initial_state: Initial state vector |ψ(0)⟩
        times: List of times at which to compute the distribution
    
    Returns:
        List of probability distributions at each time
    """
    # Diagonalize H = V Λ V†
    eigenvalues: NDArray[np.float64]
    eigenvectors: NDArray[np.complex128]
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    
    # Transform initial state to eigenbasis
    coeffs: NDArray[np.complex128] = eigenvectors.conj().T @ initial_state
    
    distributions: List[NDArray[np.float64]] = []
    for t in times:
        # Evolve: e^{-iλt} for each eigenvalue
        phase_factors: NDArray[np.complex128] = np.exp(-1j * eigenvalues * t)
        evolved_coeffs: NDArray[np.complex128] = coeffs * phase_factors
        state: NDArray[np.complex128] = eigenvectors @ evolved_coeffs
        prob: NDArray[np.float64] = np.abs(state) ** 2
        distributions.append(prob)
    
    return distributions


def estimate_quantum_mixing_from_simulation(
    H: NDArray[np.complex128],
    max_time: float = 1000.0,
    num_samples: int = 10000,
    epsilon: float = 0.1
) -> Optional[float]:
    """
    Estimate quantum mixing time by simulation.
    
    Searches for the first time t where the time-averaged distribution
    is ε-close to uniform in total variation distance.
    
    Args:
        H: Hamiltonian of the walk
        max_time: Maximum simulation time
        num_samples: Number of time samples
        epsilon: Target TV distance
    
    Returns:
        Estimated mixing time, or None if not mixed within max_time
    """
    n: int = H.shape[0]
    uniform: NDArray[np.float64] = np.ones(n) / n
    initial: NDArray[np.complex128] = np.zeros(n, dtype=complex)
    initial[0] = 1.0
    
    times: List[float] = list(np.linspace(0, max_time, num_samples))
    distributions: List[NDArray[np.float64]] = simulate_quantum_walk(H, initial, times)
    
    # Time-averaged distribution
    cumulative: NDArray[np.float64] = np.zeros(n)
    for i, dist in enumerate(distributions):
        cumulative += dist
        avg_dist: NDArray[np.float64] = cumulative / (i + 1)
        tv: float = float(0.5 * np.sum(np.abs(avg_dist - uniform)))
        if tv < epsilon:
            return times[i]
    
    return None


def cayley_graph_cyclic(n: int) -> NDArray[np.float64]:
    """Construct adjacency matrix of Cay(Z/nZ, {1, n-1})."""
    A: NDArray[np.float64] = np.zeros((n, n))
    for i in range(n):
        A[i, (i + 1) % n] = 1.0
        A[i, (i - 1) % n] = 1.0
    return A


def cayley_graph_dihedral(n: int) -> NDArray[np.float64]:
    """
    Construct adjacency matrix of Cay(D_n, {r, r⁻¹, s})
    where D_n is the dihedral group of order 2n.
    
    Elements: (k, 0) for rotations, (k, 1) for reflections, k = 0..n-1
    r = (1, 0), r⁻¹ = (n-1, 0), s = (0, 1)
    """
    N: int = 2 * n
    A: NDArray[np.float64] = np.zeros((N, N))
    
    def elem_idx(k: int, flip: int) -> int:
        return k + flip * n
    
    for k in range(n):
        for flip in range(2):
            i: int = elem_idx(k, flip)
            # Apply r: rotation
            if flip == 0:
                A[i, elem_idx((k + 1) % n, 0)] = 1.0
                A[i, elem_idx((k - 1) % n, 0)] = 1.0
            else:
                A[i, elem_idx((k - 1) % n, 1)] = 1.0
                A[i, elem_idx((k + 1) % n, 1)] = 1.0
            # Apply s: reflection
            A[i, elem_idx(k, 1 - flip)] = 1.0
    
    return A


if __name__ == "__main__":
    # Quick test
    print("Testing cyclic group Z/8Z:")
    A = cayley_graph_cyclic(8)
    gap, eigs = compute_spectral_gap(A)
    print(f"  Spectral gap: {gap:.6f}")
    print(f"  Eigenvalues: {eigs}")
    print(f"  Classical mixing: {classical_mixing_time(8, gap):.1f}")
    print(f"  Quantum mixing: {quantum_mixing_time(8, gap):.1f}")
    
    print("\nTesting dihedral group D_4:")
    A = cayley_graph_dihedral(4)
    gap, eigs = compute_spectral_gap(A)
    print(f"  Spectral gap: {gap:.6f}")
    print(f"  Classical mixing: {classical_mixing_time(8, gap):.1f}")
    print(f"  Quantum mixing: {quantum_mixing_time(8, gap):.1f}")
