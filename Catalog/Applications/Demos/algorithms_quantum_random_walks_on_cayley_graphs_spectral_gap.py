"""
Quantum Random Walk Algorithms on Cayley Graphs

Implements quantum walk simulation, spectral gap computation,
and mixing time analysis for Cayley graphs of finite groups.
"""

import numpy as np
from typing import List, Tuple, Dict, Callable, Optional
from itertools import permutations
import math


def cayley_adjacency_matrix(
    group_elements: List,
    generators: List,
    group_op: Callable,
    group_inv: Callable,
) -> np.ndarray:
    """
    Compute the adjacency matrix of the Cayley graph Cay(G, S).

    Args:
        group_elements: List of all group elements.
        generators: List of generators (symmetric generating set S).
        group_op: Group operation (g, h) -> g*h.
        group_inv: Group inverse g -> g^{-1}.

    Returns:
        Adjacency matrix A where A[i,j] = 1 if g_i^{-1} * g_j in S.
    """
    n = len(group_elements)
    elem_to_idx = {str(g): i for i, g in enumerate(group_elements)}
    A = np.zeros((n, n), dtype=float)

    for i, g in enumerate(group_elements):
        for s in generators:
            h = group_op(g, s)
            j = elem_to_idx[str(h)]
            A[i, j] = 1.0

    return A


def transition_matrix(adjacency: np.ndarray) -> np.ndarray:
    """
    Normalize the adjacency matrix to get the transition matrix T = A / degree.

    Args:
        adjacency: Adjacency matrix of a regular graph.

    Returns:
        Row-stochastic transition matrix.
    """
    row_sums = adjacency.sum(axis=1, keepdims=True)
    row_sums = np.where(row_sums == 0, 1, row_sums)
    return adjacency / row_sums


def spectral_gap(matrix: np.ndarray) -> float:
    """
    Compute the spectral gap of a transition matrix.

    The spectral gap is γ = 1 - |λ₂| where λ₂ is the second-largest
    eigenvalue in magnitude.

    Args:
        matrix: Transition matrix (row-stochastic).

    Returns:
        Spectral gap γ > 0.
    """
    # Symmetrize to avoid numerical issues with complex eigenvalues
    sym_matrix = (matrix + matrix.T) / 2
    eigenvalues = np.linalg.eigvalsh(sym_matrix)
    # Sort eigenvalues in decreasing order (not absolute value)
    sorted_eigs = sorted(eigenvalues.real, reverse=True)
    if len(sorted_eigs) < 2:
        return 1.0
    # The spectral gap is 1 - λ₂ where λ₂ is the second-largest eigenvalue
    return max(0.0, sorted_eigs[0] - sorted_eigs[1])


def classical_mixing_time(
    n_group: int, gap: float, epsilon: float = 0.01
) -> float:
    """
    Classical mixing time bound: τ = (1/γ) · (log N + log(1/ε)).

    Args:
        n_group: Order of the group |G|.
        gap: Spectral gap γ.
        epsilon: Mixing precision ε.

    Returns:
        Classical mixing time bound.
    """
    if gap <= 0:
        return float('inf')
    return (1.0 / gap) * (math.log(n_group) + math.log(1.0 / epsilon))


def quantum_mixing_time(
    n_group: int, gap: float, epsilon: float = 0.01
) -> float:
    """
    Quantum mixing time bound: τ = √(1/γ) · (log N + log(1/ε)).

    Args:
        n_group: Order of the group |G|.
        gap: Spectral gap γ.
        epsilon: Mixing precision ε.

    Returns:
        Quantum mixing time bound.
    """
    if gap <= 0:
        return float('inf')
    return math.sqrt(1.0 / gap) * (math.log(n_group) + math.log(1.0 / epsilon))


def speedup_ratio(gap: float) -> float:
    """
    Compute the quantum speedup ratio: √(1/γ).

    Args:
        gap: Spectral gap γ.

    Returns:
        Speedup ratio.
    """
    if gap <= 0:
        return float('inf')
    return math.sqrt(1.0 / gap)


def quantum_walk_evolution(
    hamiltonian: np.ndarray, initial_state: np.ndarray, time: float
) -> np.ndarray:
    """
    Evolve a quantum walk state under Hamiltonian H for time t.

    |ψ(t)⟩ = e^{-iHt} |ψ(0)⟩

    Args:
        hamiltonian: Hermitian matrix H (adjacency matrix).
        initial_state: Initial state vector |ψ(0)⟩.
        time: Evolution time t.

    Returns:
        Evolved state vector |ψ(t)⟩.
    """
    eigenvalues, eigenvectors = np.linalg.eigh(hamiltonian)
    # e^{-iHt} = V · diag(e^{-iλt}) · V†
    phases = np.exp(-1j * eigenvalues * time)
    evolution = eigenvectors @ np.diag(phases) @ eigenvectors.conj().T
    return evolution @ initial_state


def measurement_probabilities(state: np.ndarray) -> np.ndarray:
    """
    Compute measurement probabilities from a quantum state.

    P(g) = |⟨g|ψ⟩|²

    Args:
        state: Quantum state vector.

    Returns:
        Probability distribution.
    """
    return np.abs(state) ** 2


def total_variation_distance(p: np.ndarray, q: np.ndarray) -> float:
    """
    Compute total variation distance between distributions p and q.

    d_TV(p, q) = (1/2) Σ |p(g) - q(g)|

    Args:
        p: First probability distribution.
        q: Second probability distribution.

    Returns:
        Total variation distance.
    """
    return 0.5 * np.sum(np.abs(p - q))


def find_quantum_mixing_time_empirical(
    hamiltonian: np.ndarray,
    epsilon: float = 0.1,
    max_time: float = 1000.0,
    dt: float = 0.1,
) -> Tuple[float, List[float]]:
    """
    Find the quantum mixing time empirically by simulating the walk.

    Args:
        hamiltonian: Walk Hamiltonian (adjacency matrix).
        epsilon: Mixing precision.
        max_time: Maximum simulation time.
        dt: Time step.

    Returns:
        Tuple of (mixing_time, list of TV distances at each step).
    """
    n = hamiltonian.shape[0]
    initial_state = np.zeros(n, dtype=complex)
    initial_state[0] = 1.0
    uniform = np.ones(n) / n

    tv_distances = []
    t = 0.0
    mixing_time = max_time

    while t <= max_time:
        state = quantum_walk_evolution(hamiltonian, initial_state, t)
        probs = measurement_probabilities(state)
        tv = total_variation_distance(probs, uniform)
        tv_distances.append(tv)

        if tv < epsilon and mixing_time == max_time:
            mixing_time = t

        t += dt

    return mixing_time, tv_distances


# --- Group implementations ---

def cyclic_group(n: int) -> Tuple[List[int], List[int], Callable, Callable]:
    """
    Generate ℤ/nℤ with standard generators {1, n-1}.

    Returns:
        (elements, generators, group_op, group_inv)
    """
    elements = list(range(n))
    generators = [1, n - 1]
    group_op = lambda a, b: (a + b) % n
    group_inv = lambda a: (-a) % n
    return elements, generators, group_op, group_inv


def symmetric_group(n: int) -> Tuple[List, List, Callable, Callable]:
    """
    Generate S_n with transposition generators.

    Returns:
        (elements, generators, group_op, group_inv)
    """
    elements = list(permutations(range(n)))

    # Generators: all transpositions (i, j) for i < j
    generators = []
    for i in range(n):
        for j in range(i + 1, n):
            perm = list(range(n))
            perm[i], perm[j] = perm[j], perm[i]
            generators.append(tuple(perm))

    def compose(p: tuple, q: tuple) -> tuple:
        return tuple(p[q[i]] for i in range(len(p)))

    def inverse(p: tuple) -> tuple:
        inv = [0] * len(p)
        for i, pi in enumerate(p):
            inv[pi] = i
        return tuple(inv)

    return elements, generators, compose, inverse


def cyclic_spectral_gap_exact(n: int) -> float:
    """
    Exact spectral gap for ℤ/nℤ with generators {±1}.

    γ = 1 - cos(2π/n)
    """
    return 1.0 - math.cos(2 * math.pi / n)


def analyze_group(
    name: str,
    elements: List,
    generators: List,
    group_op: Callable,
    group_inv: Callable,
    epsilon: float = 0.1,
) -> Dict:
    """
    Complete analysis of quantum vs classical mixing for a group.

    Args:
        name: Group name for display.
        elements: Group elements.
        generators: Generating set.
        group_op: Group operation.
        group_inv: Group inverse.
        epsilon: Mixing precision.

    Returns:
        Dictionary with analysis results.
    """
    A = cayley_adjacency_matrix(elements, generators, group_op, group_inv)
    T = transition_matrix(A)
    gap = spectral_gap(T)
    n = len(elements)

    tau_classical = classical_mixing_time(n, gap, epsilon)
    tau_quantum = quantum_mixing_time(n, gap, epsilon)
    ratio = speedup_ratio(gap)

    return {
        "name": name,
        "group_order": n,
        "num_generators": len(generators),
        "spectral_gap": gap,
        "classical_mixing_time": tau_classical,
        "quantum_mixing_time": tau_quantum,
        "speedup_ratio": ratio,
        "theoretical_speedup": math.sqrt(1.0 / gap) if gap > 0 else float('inf'),
    }
