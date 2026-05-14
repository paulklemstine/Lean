#!/usr/bin/env python3
"""
Tropical Diffusion Regularity: Core Algorithms

Implements the tropical diffusion operators, oscillation tracking,
and regularity analysis algorithms from the formal theory.
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_diffusion_max(K: np.ndarray, u: np.ndarray) -> np.ndarray:
    """
    Max-plus tropical diffusion operator.

    T(u)(i) = max_j (u(j) - K(i,j))

    This is the discrete Lax-Oleinik / Bellman operator.

    Args:
        K: n×n nonneg kernel matrix with zero diagonal
        u: n-dimensional state vector

    Returns:
        n-dimensional diffused state

    Time complexity: O(n²)
    Space complexity: O(n)
    """
    n = len(u)
    # Vectorized: for each row i, compute max over j of (u[j] - K[i,j])
    return np.max(u[np.newaxis, :] - K, axis=1)


def tropical_diffusion_min(K: np.ndarray, u: np.ndarray) -> np.ndarray:
    """
    Min-plus tropical diffusion operator (dual).

    T'(u)(i) = min_j (K(i,j) + u(j))

    Args:
        K: n×n nonneg kernel matrix with zero diagonal
        u: n-dimensional state vector

    Returns:
        n-dimensional diffused state

    Time complexity: O(n²)
    Space complexity: O(n)
    """
    return np.min(K + u[np.newaxis, :], axis=1)


def oscillation(u: np.ndarray) -> float:
    """
    Oscillation seminorm: max(u) - min(u).

    Measures total spread of the state. Invariant under translation.

    Time complexity: O(n)
    """
    return float(np.max(u) - np.min(u))


def tropical_energy(u: np.ndarray) -> float:
    """
    Tropical energy: max(u).

    Time complexity: O(n)
    """
    return float(np.max(u))


def tropical_dissipation(K: np.ndarray, u: np.ndarray) -> float:
    """
    Tropical dissipation: max_i (u(i) - T(u)(i)).

    Measures the energy lost in one step. Always ≥ 0.

    Time complexity: O(n²)
    """
    Tu = tropical_diffusion_max(K, u)
    return float(np.max(u - Tu))


def discrete_vorticity(A: np.ndarray, u: np.ndarray) -> float:
    """
    Discrete vorticity: max_{i,j} |A(i,j) * (u(j) - u(i))|.

    Bounded by osc(u) when A entries are in [0, 1].

    Time complexity: O(n²)
    """
    n = len(u)
    diff = u[np.newaxis, :] - u[:, np.newaxis]  # diff[i,j] = u[j] - u[i]
    return float(np.max(np.abs(A * diff)))


def iterate_tropical_diffusion(
    K: np.ndarray,
    u0: np.ndarray,
    n_steps: int,
    track_metrics: bool = True
) -> dict:
    """
    Iterate tropical diffusion and track regularity metrics.

    Implements the iterated evolution u_{n+1} = T(u_n) and verifies
    the a priori bounds from the regularity theory.

    Args:
        K: n×n nonneg kernel matrix with zero diagonal
        u0: initial state
        n_steps: number of iterations
        track_metrics: whether to compute metrics at each step

    Returns:
        Dictionary with:
        - 'states': list of state vectors
        - 'sup': list of sup values
        - 'inf': list of inf values
        - 'osc': list of oscillation values
        - 'energy': list of energy values
        - 'dissipation': list of dissipation values

    Time complexity: O(n_steps × n²)
    Space complexity: O(n_steps × n) for states
    """
    states = [u0.copy()]
    metrics = {
        'sup': [float(np.max(u0))],
        'inf': [float(np.min(u0))],
        'osc': [oscillation(u0)],
        'energy': [tropical_energy(u0)],
        'dissipation': [tropical_dissipation(K, u0)]
    }

    current = u0.copy()
    for step in range(n_steps):
        current = tropical_diffusion_max(K, current)
        states.append(current.copy())

        if track_metrics:
            metrics['sup'].append(float(np.max(current)))
            metrics['inf'].append(float(np.min(current)))
            metrics['osc'].append(oscillation(current))
            metrics['energy'].append(tropical_energy(current))
            metrics['dissipation'].append(tropical_dissipation(K, current))

    return {'states': states, **metrics}


def verify_regularity(
    K: np.ndarray,
    u0: np.ndarray,
    n_steps: int = 100,
    A: Optional[np.ndarray] = None,
    tol: float = 1e-10
) -> dict:
    """
    Verify all regularity bounds from the formal theory.

    Checks:
    1. sup(T^n(u)) ≤ sup(u) for all n (maximum principle)
    2. osc(T^n(u)) ≤ osc(u) for all n (oscillation contraction)
    3. If A provided: vorticity(T^n(u)) ≤ osc(u) for all n

    Args:
        K: kernel matrix
        u0: initial state
        n_steps: iterations to check
        A: optional weight matrix for vorticity
        tol: numerical tolerance

    Returns:
        Dictionary with verification results
    """
    initial_sup = float(np.max(u0))
    initial_osc = oscillation(u0)

    result = iterate_tropical_diffusion(K, u0, n_steps)

    sup_violations = sum(1 for s in result['sup'] if s > initial_sup + tol)
    osc_violations = sum(1 for o in result['osc'] if o > initial_osc + tol)

    verification = {
        'sup_bound_holds': sup_violations == 0,
        'osc_bound_holds': osc_violations == 0,
        'sup_violations': sup_violations,
        'osc_violations': osc_violations,
        'initial_sup': initial_sup,
        'initial_osc': initial_osc,
        'final_sup': result['sup'][-1],
        'final_osc': result['osc'][-1],
        'convergence_step': None,
    }

    # Check convergence
    for i in range(1, len(result['osc'])):
        if abs(result['osc'][i] - result['osc'][i-1]) < tol:
            verification['convergence_step'] = i
            break

    if A is not None:
        vorticities = [discrete_vorticity(A, s) for s in result['states']]
        vort_violations = sum(1 for v in vorticities if v > initial_osc + tol)
        verification['vorticity_bound_holds'] = vort_violations == 0
        verification['vorticity_violations'] = vort_violations
        verification['max_vorticity'] = max(vorticities)

    return verification


def build_graph_kernel(n: int, graph_type: str = 'cycle',
                       scale: float = 1.0) -> np.ndarray:
    """
    Build a kernel matrix from a graph structure.

    Args:
        n: number of nodes
        graph_type: 'cycle', 'path', 'complete', 'grid'
        scale: scaling factor for distances

    Returns:
        n×n kernel matrix (shortest path distances × scale)
    """
    if graph_type == 'cycle':
        K = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                K[i, j] = min(abs(i - j), n - abs(i - j)) * scale
    elif graph_type == 'path':
        K = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                K[i, j] = abs(i - j) * scale
    elif graph_type == 'complete':
        K = np.ones((n, n)) * scale
        np.fill_diagonal(K, 0)
    elif graph_type == 'grid':
        side = int(np.sqrt(n))
        assert side * side == n, "n must be a perfect square for grid"
        K = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                ri, ci = divmod(i, side)
                rj, cj = divmod(j, side)
                K[i, j] = (abs(ri - rj) + abs(ci - cj)) * scale
    else:
        raise ValueError(f"Unknown graph type: {graph_type}")

    return K


def find_fixed_point(K: np.ndarray, u0: np.ndarray,
                     max_iter: int = 1000, tol: float = 1e-12
                     ) -> Tuple[np.ndarray, int]:
    """
    Find the fixed point of tropical diffusion iteration.

    Since oscillation is nonincreasing and bounded below by 0,
    the iteration converges. The fixed point satisfies T(u*) = u*.

    Args:
        K: kernel matrix
        u0: initial state
        max_iter: maximum iterations
        tol: convergence tolerance

    Returns:
        Tuple of (fixed point, number of iterations)

    Convergence: Guaranteed by oscillation monotonicity theorem.
    """
    current = u0.copy()
    for step in range(max_iter):
        next_state = tropical_diffusion_max(K, current)
        if np.max(np.abs(next_state - current)) < tol:
            return next_state, step + 1
        current = next_state
    return current, max_iter


if __name__ == "__main__":
    # Quick test
    n = 5
    K = build_graph_kernel(n, 'cycle', scale=0.5)
    u0 = np.array([10.0, -5.0, 8.0, -3.0, 12.0])

    print("Kernel (cycle, scale=0.5):")
    print(K)
    print(f"\nInitial state: {u0}")

    result = verify_regularity(K, u0, n_steps=50)
    print(f"\nRegularity verification:")
    for key, val in result.items():
        print(f"  {key}: {val}")

    fp, steps = find_fixed_point(K, u0)
    print(f"\nFixed point found in {steps} steps: {fp}")
    print(f"Fixed point is constant: {np.allclose(fp, fp[0])}")
