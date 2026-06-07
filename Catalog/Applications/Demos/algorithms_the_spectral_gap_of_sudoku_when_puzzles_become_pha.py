"""
Spectral Gap Phase Transition Algorithms

Type-hinted implementations of the core algorithms for computing
spectral gaps, conductance, and mixing times of Markov chains
on constraint satisfaction solution spaces.
"""

from typing import List, Tuple, Optional, Callable
import numpy as np
from numpy.typing import NDArray


def build_transition_matrix(
    adjacency: NDArray[np.float64],
) -> NDArray[np.float64]:
    """Build a stochastic transition matrix from an adjacency matrix.

    For the swap Markov chain, each state is a valid solution.
    Two states are adjacent if one can be obtained from the other
    by swapping two compatible entries.

    Args:
        adjacency: Binary adjacency matrix (n x n) of the solution graph

    Returns:
        Row-stochastic transition matrix (lazy random walk)
    """
    n = adjacency.shape[0]
    if n == 0:
        return np.array([[]], dtype=np.float64)

    P = np.zeros((n, n), dtype=np.float64)
    for i in range(n):
        degree = adjacency[i].sum()
        if degree > 0:
            for j in range(n):
                if adjacency[i, j] > 0:
                    P[i, j] = adjacency[i, j] / (2 * degree)
            P[i, i] += 0.5  # lazy chain
        else:
            P[i, i] = 1.0  # absorbing state
    return P


def compute_spectral_gap(P: NDArray[np.float64]) -> float:
    """Compute the spectral gap of a stochastic matrix.

    The spectral gap is 1 - λ₂ where λ₂ is the second largest
    eigenvalue magnitude.

    Args:
        P: Row-stochastic transition matrix

    Returns:
        Spectral gap γ = 1 - |λ₂|
    """
    n = P.shape[0]
    if n <= 1:
        return 1.0

    eigenvalues = np.linalg.eigvals(P)
    eigenvalues_sorted = sorted(np.abs(eigenvalues), reverse=True)

    lambda1 = eigenvalues_sorted[0]
    lambda2 = eigenvalues_sorted[1] if len(eigenvalues_sorted) > 1 else 0.0

    return float(lambda1 - lambda2)


def compute_conductance(
    P: NDArray[np.float64],
    stationary: NDArray[np.float64],
) -> float:
    """Compute the Cheeger conductance of a reversible Markov chain.

    h = min_{S: π(S) ≤ 1/2} Q(S, Sᶜ) / π(S)

    Args:
        P: Transition matrix
        stationary: Stationary distribution

    Returns:
        Cheeger conductance h
    """
    n = P.shape[0]
    if n <= 1:
        return 1.0

    min_conductance = float('inf')

    # Iterate over all non-empty proper subsets (exponential but exact)
    for mask in range(1, 2**n - 1):
        S = [i for i in range(n) if mask & (1 << i)]
        Sc = [i for i in range(n) if not (mask & (1 << i))]

        pi_S = sum(stationary[i] for i in S)
        if pi_S > 0.5 + 1e-12:
            continue
        if pi_S < 1e-15:
            continue

        flow = sum(
            stationary[i] * P[i, j]
            for i in S
            for j in Sc
        )

        conductance = flow / pi_S
        min_conductance = min(min_conductance, conductance)

    return float(min_conductance)


def mixing_time_bound(
    gap: float,
    pi_min: float,
    epsilon: float,
) -> float:
    """Compute the mixing time bound from spectral gap.

    t_mix(ε) ≤ (1/γ) · ln(1/(ε · π_min))

    Args:
        gap: Spectral gap γ > 0
        pi_min: Minimum stationary probability
        epsilon: Target total variation distance

    Returns:
        Upper bound on mixing time
    """
    if gap <= 0 or pi_min <= 0 or epsilon <= 0:
        return float('inf')

    import math
    return (1.0 / gap) * math.log(1.0 / (epsilon * pi_min))


def cheeger_bounds(conductance: float) -> Tuple[float, float]:
    """Compute Cheeger's inequality bounds on the spectral gap.

    h²/2 ≤ γ ≤ 2h

    Args:
        conductance: Cheeger conductance h

    Returns:
        (lower_bound, upper_bound) for spectral gap
    """
    return (conductance**2 / 2.0, 2.0 * conductance)


def classify_phase(density: float) -> str:
    """Classify a constraint density into a phase regime.

    Args:
        density: Ratio of clues to total cells

    Returns:
        Phase name: 'underconstrained', 'critical', or 'overconstrained'
    """
    CRITICAL_DENSITY = 17.0 / 81.0
    FROZEN_DENSITY = 30.0 / 81.0

    if density < CRITICAL_DENSITY:
        return 'underconstrained'
    elif density < FROZEN_DENSITY:
        return 'critical'
    else:
        return 'overconstrained'


def product_chain_gap(gaps: List[float]) -> float:
    """Compute the spectral gap of a product chain.

    For independent product chains, the gap equals min of component gaps.

    Args:
        gaps: List of component spectral gaps

    Returns:
        Product chain spectral gap
    """
    if not gaps:
        return 0.0
    return min(gaps)


def generate_random_stochastic_matrix(
    n: int,
    seed: Optional[int] = None,
) -> NDArray[np.float64]:
    """Generate a random doubly stochastic matrix (Birkhoff approximation).

    Args:
        n: Size of the matrix
        seed: Random seed

    Returns:
        Approximately doubly stochastic matrix
    """
    rng = np.random.RandomState(seed)
    M = rng.exponential(size=(n, n))
    # Sinkhorn iteration for doubly stochastic approximation
    for _ in range(100):
        M = M / M.sum(axis=1, keepdims=True)
        M = M / M.sum(axis=0, keepdims=True)
    M = M / M.sum(axis=1, keepdims=True)
    return M


def spectral_gap_vs_density(
    n_states_func: Callable[[float], int],
    densities: NDArray[np.float64],
    seed: int = 42,
) -> List[Tuple[float, float]]:
    """Compute spectral gap as a function of constraint density.

    Args:
        n_states_func: Function mapping density to number of states
        densities: Array of density values
        seed: Random seed

    Returns:
        List of (density, spectral_gap) pairs
    """
    results = []
    for d in densities:
        n = n_states_func(d)
        if n <= 1:
            results.append((float(d), 0.0))
        else:
            P = generate_random_stochastic_matrix(n, seed=seed + int(d * 1000))
            gap = compute_spectral_gap(P)
            results.append((float(d), gap))
    return results
