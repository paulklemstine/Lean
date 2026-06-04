#!/usr/bin/env python3
"""
Algorithms for Quantum Random Walks on Cayley Graphs

Type-hinted implementations of key algorithms from the research.
"""
import math
from typing import List, Tuple, Optional


def spectral_gap_cayley(
    group_order: int,
    eigenvalues: List[float]
) -> float:
    """
    Compute the spectral gap of a Cayley graph transition matrix.

    The spectral gap γ = 1 - max_{i≥2} |λ_i| where λ_1 = 1 is the
    trivial eigenvalue.

    Args:
        group_order: Order of the group |G|.
        eigenvalues: List of eigenvalues of the transition matrix,
                     sorted in decreasing order. Must start with 1.0.

    Returns:
        The spectral gap γ ∈ (0, 1].
    """
    if len(eigenvalues) < 2:
        return 1.0
    second_largest = max(abs(ev) for ev in eigenvalues[1:])
    return 1.0 - second_largest


def mixing_time_classical(
    group_order: int,
    spectral_gap: float,
    epsilon: float = 0.01
) -> float:
    """
    Classical mixing time bound: τ = (1/γ) · log(N/ε).

    Args:
        group_order: Number of vertices N = |G|.
        spectral_gap: The spectral gap γ > 0.
        epsilon: Target total variation distance.

    Returns:
        Upper bound on the classical mixing time.
    """
    return (1.0 / spectral_gap) * (math.log(group_order) + math.log(1.0 / epsilon))


def mixing_time_quantum(
    group_order: int,
    spectral_gap: float,
    epsilon: float = 0.01
) -> float:
    """
    Quantum mixing time bound: τ = (1/√γ) · log(N/ε).

    Args:
        group_order: Number of vertices N = |G|.
        spectral_gap: The spectral gap γ > 0.
        epsilon: Target total variation distance.

    Returns:
        Upper bound on the quantum mixing time.
    """
    return (1.0 / math.sqrt(spectral_gap)) * (math.log(group_order) + math.log(1.0 / epsilon))


def quantum_speedup_ratio(spectral_gap: float) -> float:
    """
    Quantum speedup factor: √(1/γ).

    This is the ratio of classical to quantum mixing times.
    Proven in Lean 4 as `quantum_classical_gap_ratio`.

    Args:
        spectral_gap: The spectral gap γ > 0.

    Returns:
        The speedup factor √(1/γ).
    """
    return math.sqrt(1.0 / spectral_gap)


def cyclic_group_spectrum(n: int) -> Tuple[float, float, List[float]]:
    """
    Compute the full spectrum of the Cayley graph of Z/nZ with S={1,-1}.

    Eigenvalues: λ_k = cos(2πk/n) for k = 0, 1, ..., n-1.
    Spectral gap: γ = 1 - cos(2π/n).

    Args:
        n: Order of the cyclic group (must be ≥ 3).

    Returns:
        Tuple of (spectral_gap, second_eigenvalue, all_eigenvalues).
    """
    eigenvalues = [math.cos(2 * math.pi * k / n) for k in range(n)]
    eigenvalues.sort(reverse=True)
    gap = 1.0 - eigenvalues[1]
    return gap, eigenvalues[1], eigenvalues


def complete_graph_spectrum(n: int) -> Tuple[float, float]:
    """
    Spectrum of the complete graph K_n.

    Eigenvalues: λ_1 = 1 (multiplicity 1), λ_2 = -1/(n-1) (multiplicity n-1).
    Spectral gap: γ = 1 - 1/(n-1) = (n-2)/(n-1).

    Args:
        n: Number of vertices (must be ≥ 3).

    Returns:
        Tuple of (spectral_gap, second_eigenvalue_magnitude).
    """
    second_eval = 1.0 / (n - 1)
    gap = 1.0 - second_eval
    return gap, second_eval


def is_expander(spectral_gap: float, threshold: float = 0.01) -> bool:
    """
    Check if a graph is an expander (spectral gap bounded from below).

    Args:
        spectral_gap: The spectral gap γ.
        threshold: Minimum gap for expander classification.

    Returns:
        True if γ ≥ threshold.
    """
    return spectral_gap >= threshold


def quantum_advantage_classification(spectral_gap: float) -> str:
    """
    Classify the quantum advantage based on spectral gap.

    - γ < 1/4: meaningful quantum advantage (speedup > 2)
    - γ ≥ 1/4: marginal quantum advantage (speedup ≤ 2)

    Proven in Lean 4 as `quantum_advantage_threshold` and
    `quantum_advantage_bounded`.

    Args:
        spectral_gap: The spectral gap γ > 0.

    Returns:
        Classification string.
    """
    if spectral_gap < 0.25:
        su = quantum_speedup_ratio(spectral_gap)
        return f"MEANINGFUL (speedup = {su:.2f}x)"
    else:
        su = quantum_speedup_ratio(spectral_gap)
        return f"MARGINAL (speedup = {su:.2f}x)"


def exp_decay_bound(gamma: float, t: int) -> float:
    """
    Upper bound on geometric decay: (1-γ)^t ≤ exp(-γt).

    Proven in Lean 4 as `exp_decay_bound`.

    Args:
        gamma: Spectral gap γ ∈ (0, 1].
        t: Number of steps.

    Returns:
        The exponential bound exp(-γt).
    """
    return math.exp(-gamma * t)


def explicit_mixing_steps(
    group_order: int,
    spectral_gap: float,
    epsilon: float = 0.01
) -> int:
    """
    Compute the explicit number of steps for ε-mixing.

    T = ⌈(1/γ) · log(√N/ε)⌉

    Proven in Lean 4 as `explicit_mixing_time`.

    Args:
        group_order: Number of vertices N.
        spectral_gap: Spectral gap γ.
        epsilon: Target TV distance.

    Returns:
        Number of steps T.
    """
    sqrt_N = math.sqrt(group_order)
    return math.ceil((1.0 / spectral_gap) * math.log(sqrt_N / epsilon))


if __name__ == "__main__":
    # Demo: cyclic group Z/100Z
    n = 100
    gap, second_ev, evals = cyclic_group_spectrum(n)
    print(f"Z/{n}Z: gap = {gap:.6f}, |λ₂| = {second_ev:.6f}")
    print(f"  Classical mixing: {mixing_time_classical(n, gap):.1f} steps")
    print(f"  Quantum mixing:   {mixing_time_quantum(n, gap):.1f} steps")
    print(f"  Speedup:          {quantum_speedup_ratio(gap):.1f}x")
    print(f"  Classification:   {quantum_advantage_classification(gap)}")
    print(f"  Explicit T:       {explicit_mixing_steps(n, gap)} steps")
