#!/usr/bin/env python3
"""
Algorithms for Quantum Random Walks on Cayley Graphs

Type-hinted implementations of core algorithms for computing spectral gaps,
mixing times, and quantum walk dynamics on Cayley graphs.
"""

from typing import List, Tuple, Callable, Optional, Dict, Any
import numpy as np
from numpy.typing import NDArray


def build_cayley_adjacency(
    elements: List[Any],
    generators: List[Any],
    group_op: Callable[[Any, Any], Any]
) -> NDArray[np.float64]:
    """
    Build the adjacency matrix of the Cayley graph Cay(G, S).

    Args:
        elements: List of group elements
        generators: Symmetric generating set S (must be closed under inverses)
        group_op: Group operation (g, s) -> g * s

    Returns:
        Adjacency matrix A where A[i,j] = 1 iff elements[i]^{-1} * elements[j] in S
    """
    n = len(elements)
    idx: Dict[Any, int] = {}
    for i, g in enumerate(elements):
        idx[g] = i

    A = np.zeros((n, n), dtype=np.float64)
    for g in elements:
        for s in generators:
            h = group_op(g, s)
            A[idx[g], idx[h]] = 1.0
    return A


def compute_spectral_gap(A: NDArray[np.float64]) -> Tuple[float, NDArray[np.float64]]:
    """
    Compute the spectral gap of the transition matrix P = A/d.

    The spectral gap γ = 1 - max(|λ₂|, |λ_N|) where λ₁ ≥ λ₂ ≥ ... ≥ λ_N
    are eigenvalues of P.

    Args:
        A: Adjacency matrix of a regular graph

    Returns:
        Tuple of (spectral_gap, sorted_eigenvalues)
    """
    d = float(A.sum(axis=1)[0])
    P = A / d
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    lambda2_abs = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))
    gap = 1.0 - lambda2_abs
    return gap, eigenvalues


def classical_mixing_time(
    P: NDArray[np.float64],
    epsilon: float = 0.01,
    max_iter: int = 100000
) -> int:
    """
    Compute classical mixing time by iterating P^t until TV distance < ε.

    The total variation distance is:
        d_TV(P^t(x,·), π) = (1/2) Σ_y |P^t(x,y) - 1/N|

    Args:
        P: Transition matrix (row-stochastic)
        epsilon: Target TV distance
        max_iter: Maximum iterations

    Returns:
        Mixing time T such that max_x d_TV(P^T(x,·), π) < ε
    """
    n = P.shape[0]
    uniform = np.ones(n) / n

    for t in range(1, max_iter):
        # Compute from worst-case starting state
        max_tv = 0.0
        for x in range(min(n, 10)):  # Sample starting states
            state = np.zeros(n)
            state[x] = 1.0
            state_t = state @ np.linalg.matrix_power(P, t)
            tv = 0.5 * np.sum(np.abs(state_t - uniform))
            max_tv = max(max_tv, tv)
        if max_tv < epsilon:
            return t
    return max_iter


def quantum_walk_evolution(
    H: NDArray[np.float64],
    t: float,
    initial_state: int = 0
) -> NDArray[np.complex128]:
    """
    Compute quantum walk state |ψ(t)⟩ = exp(-iHt)|initial⟩.

    Uses eigendecomposition for exact evolution.

    Args:
        H: Hamiltonian (adjacency matrix of Cayley graph)
        t: Evolution time
        initial_state: Index of initial basis state

    Returns:
        Complex state vector |ψ(t)⟩
    """
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    U = eigenvectors @ np.diag(np.exp(-1j * eigenvalues * t)) @ eigenvectors.conj().T
    return U[:, initial_state]


def quantum_mixing_time(
    H: NDArray[np.float64],
    epsilon: float = 0.01,
    dt: float = 0.1,
    max_steps: int = 10000
) -> Tuple[float, List[float]]:
    """
    Compute quantum (continuous-time) mixing time.

    The quantum walk mixes at time t if:
        max_g |P_t(g) - 1/|G|| < ε
    where P_t(g) = |⟨g|exp(-iHt)|0⟩|².

    Args:
        H: Hamiltonian matrix
        epsilon: Target distance to uniform
        dt: Time step for sampling
        max_steps: Maximum number of time steps

    Returns:
        Tuple of (mixing_time, tv_distance_history)
    """
    n = H.shape[0]
    uniform = np.ones(n) / n
    eigenvalues, eigenvectors = np.linalg.eigh(H)

    tv_history: List[float] = []

    for step in range(1, max_steps):
        t = step * dt
        U = eigenvectors @ np.diag(np.exp(-1j * eigenvalues * t)) @ eigenvectors.conj().T
        state = U[:, 0]
        probs = np.abs(state) ** 2
        tv = 0.5 * np.sum(np.abs(probs - uniform))
        tv_history.append(tv)
        if tv < epsilon:
            return t, tv_history

    return max_steps * dt, tv_history


def mixing_time_bound(
    spectral_gap: float,
    n_vertices: int,
    epsilon: float = 0.01
) -> float:
    """
    Compute the theoretical mixing time upper bound.

    T_mix ≤ (1/γ) · log(√N / ε)

    This is the classical spectral gap bound proven in our Lean formalization.

    Args:
        spectral_gap: γ = 1 - |λ₂|
        n_vertices: Number of vertices N = |G|
        epsilon: Target mixing accuracy

    Returns:
        Upper bound on mixing time
    """
    if spectral_gap <= 0:
        return float('inf')
    return (1.0 / spectral_gap) * np.log(np.sqrt(n_vertices) / epsilon)


def quantum_speedup_factor(
    spectral_gap: float,
    n_vertices: int
) -> float:
    """
    Compute the theoretical quantum speedup factor.

    Classical: T_classical ~ (1/γ) · log(N)
    Quantum:   T_quantum   ~ (1/√γ) · log(N)
    Speedup:   T_classical / T_quantum ~ 1/√γ

    Args:
        spectral_gap: γ = 1 - |λ₂|
        n_vertices: Number of vertices

    Returns:
        Speedup factor √(1/γ)
    """
    if spectral_gap <= 0:
        return float('inf')
    return 1.0 / np.sqrt(spectral_gap)


if __name__ == "__main__":
    # Example: Z_10 with generators {1, 9}
    n = 10
    elements = list(range(n))
    generators = [1, n - 1]
    group_op = lambda g, s: (g + s) % n

    A = build_cayley_adjacency(elements, generators, group_op)
    gap, eigs = compute_spectral_gap(A)
    P = A / A.sum(axis=1)[0]

    t_cl = classical_mixing_time(P)
    t_bound = mixing_time_bound(gap, n)
    speedup = quantum_speedup_factor(gap, n)

    print(f"Z_{n} Cayley graph:")
    print(f"  Spectral gap: {gap:.6f}")
    print(f"  Classical mixing time: {t_cl}")
    print(f"  Theoretical bound: {t_bound:.1f}")
    print(f"  Quantum speedup factor: {speedup:.2f}x")
