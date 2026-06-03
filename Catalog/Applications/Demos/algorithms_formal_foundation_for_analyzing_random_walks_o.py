#!/usr/bin/env python3
"""
Spectral Walk Theory — Algorithm Implementations

Type-hinted implementations of key algorithms from the spectral gap theory.
"""

import math
from typing import List, Tuple, Optional


def spectral_gap_cycle(n: int) -> float:
    """
    Compute the spectral gap of the cycle graph C_n.

    The transition matrix of the random walk on C_n has eigenvalues
    λ_k = cos(2πk/n) for k = 0, ..., n-1.
    The spectral gap is γ = 1 - λ₁ = 1 - cos(2π/n).

    Formally verified bounds: 8/n² ≤ γ ≤ 2π²/n².

    Args:
        n: Number of vertices (n ≥ 3)

    Returns:
        The spectral gap γ = 1 - cos(2π/n)
    """
    if n < 3:
        raise ValueError("Cycle graph requires n ≥ 3")
    return 1.0 - math.cos(2 * math.pi / n)


def mixing_time_upper_bound(gamma: float, n: int, epsilon: float = 0.01) -> int:
    """
    Compute an upper bound on the ε-mixing time from the spectral gap.

    The L² mixing distance satisfies d(t) ≤ (1-γ)^t · √n.
    Setting d(t) ≤ ε gives t ≥ ln(√n/ε) / ln(1/(1-γ)) ≈ (1/γ)·ln(√n/ε).

    Args:
        gamma: Spectral gap (0 < γ ≤ 1)
        n: Number of vertices
        epsilon: Target distance from stationarity

    Returns:
        Upper bound on mixing time (ceiling)
    """
    if gamma <= 0 or gamma > 1:
        raise ValueError("Spectral gap must satisfy 0 < γ ≤ 1")
    if n < 2:
        raise ValueError("Need n ≥ 2")
    if epsilon <= 0:
        raise ValueError("Need ε > 0")

    log_ratio = math.log(math.sqrt(n) / epsilon)
    if gamma >= 1:
        return 0
    return math.ceil(log_ratio / math.log(1 / (1 - gamma)))


def quantum_mixing_time(gamma: float, n: int) -> float:
    """
    Estimate the quantum mixing time from the spectral gap.

    For quantum walks on Cayley graphs, the phase gap δ ≥ √γ,
    giving quantum mixing time ≈ (1/√γ) · √(log n).

    Formally verified: 1/√γ ≤ 1/γ (quadratic speedup).

    Args:
        gamma: Classical spectral gap (0 < γ ≤ 1)
        n: Number of vertices

    Returns:
        Estimated quantum mixing time
    """
    return (1.0 / math.sqrt(gamma)) * math.sqrt(math.log(n))


def product_walk_spectral_gap(gaps: List[float]) -> float:
    """
    Compute the spectral gap of a product of independent random walks.

    For k independent walks with gaps γ₁, ..., γ_k, the product walk has
    spectral gap 1 - ∏(1 - γᵢ) ≥ min(γ₁, ..., γ_k).

    Formally verified for k=2: 1 - (1-γ₁)(1-γ₂) ≥ min(γ₁, γ₂).

    Args:
        gaps: List of spectral gaps (each in (0, 1])

    Returns:
        Product walk spectral gap
    """
    product = 1.0
    for g in gaps:
        if g <= 0 or g > 1:
            raise ValueError(f"Each gap must be in (0,1], got {g}")
        product *= (1 - g)
    return 1.0 - product


def laplacian_eigenvalues_cycle(n: int) -> List[float]:
    """
    Compute the Laplacian eigenvalues of the cycle graph C_n.

    The normalized Laplacian has eigenvalues μ_k = 1 - cos(2πk/n)
    for k = 0, ..., n-1.

    Args:
        n: Number of vertices (n ≥ 3)

    Returns:
        Sorted list of eigenvalues
    """
    eigenvalues = [1 - math.cos(2 * math.pi * k / n) for k in range(n)]
    return sorted(eigenvalues)


def mixing_distance_trajectory(
    gamma: float, n: int, max_steps: int
) -> List[Tuple[int, float]]:
    """
    Compute the mixing distance d(t) = (1-γ)^t · √n for t = 0, ..., max_steps.

    Args:
        gamma: Spectral gap
        n: Number of vertices
        max_steps: Maximum number of steps

    Returns:
        List of (time, distance) pairs
    """
    lam2 = 1 - gamma
    sqrt_n = math.sqrt(n)
    trajectory = []
    power = 1.0
    for t in range(max_steps + 1):
        trajectory.append((t, power * sqrt_n))
        power *= lam2
    return trajectory


def spectral_gap_bounds(n: int) -> Tuple[float, float, float]:
    """
    Return (lower_bound, exact_gap, upper_bound) for cycle graph C_n.

    Formally verified bounds: 8/n² ≤ 1-cos(2π/n) ≤ 2π²/n².

    Args:
        n: Number of vertices (n ≥ 3)

    Returns:
        Tuple of (8/n², 1-cos(2π/n), 2π²/n²)
    """
    return (
        8.0 / n**2,
        1 - math.cos(2 * math.pi / n),
        2 * math.pi**2 / n**2,
    )


def classical_vs_quantum_comparison(
    n_values: List[int],
) -> List[Tuple[int, float, float, float]]:
    """
    Compare classical and quantum relaxation times for cycle graphs.

    Args:
        n_values: List of cycle graph sizes

    Returns:
        List of (n, gamma, classical_time, quantum_time) tuples
    """
    results = []
    for n in n_values:
        gamma = spectral_gap_cycle(n)
        classical = 1.0 / gamma
        quantum = 1.0 / math.sqrt(gamma)
        results.append((n, gamma, classical, quantum))
    return results


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")

    # Test cycle gap bounds
    for n in range(3, 101):
        lb, exact, ub = spectral_gap_bounds(n)
        assert lb <= exact + 1e-12, f"Lower bound failed for n={n}"
        assert exact <= ub + 1e-12, f"Upper bound failed for n={n}"

    # Test product walk gap
    assert product_walk_spectral_gap([0.1, 0.2]) >= min(0.1, 0.2) - 1e-12

    # Test quantum speedup
    for n in [10, 100, 1000]:
        gamma = spectral_gap_cycle(n)
        assert 1/math.sqrt(gamma) <= 1/gamma + 1e-10

    print("All self-tests passed!")
