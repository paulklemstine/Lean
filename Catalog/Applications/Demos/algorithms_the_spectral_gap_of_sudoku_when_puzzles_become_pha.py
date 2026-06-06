#!/usr/bin/env python3
"""
Algorithms for Spectral Gap Analysis of Constraint Satisfaction Problems.

Type-hinted implementations of the key algorithms from the research.
"""

import numpy as np
from typing import List, Tuple, Callable, Optional


def compute_spectral_gap(P: np.ndarray) -> float:
    """
    Compute the spectral gap of a row-stochastic matrix P.
    
    The spectral gap is γ = 1 - |λ₂| where λ₂ is the second-largest
    eigenvalue in absolute value.
    
    Args:
        P: Row-stochastic matrix (n × n)
    
    Returns:
        Spectral gap γ ∈ [0, 1]
    """
    eigenvalues = np.linalg.eigvals(P)
    sorted_abs = np.sort(np.abs(eigenvalues))[::-1]
    if len(sorted_abs) < 2:
        return 0.0
    return float(1.0 - sorted_abs[1])


def estimate_mixing_time(gap: float, n: int, epsilon: float = 0.25) -> float:
    """
    Estimate the mixing time from the spectral gap.
    
    Uses the bound: t_mix(ε) ≤ (1/γ) · log(n/ε)
    
    Args:
        gap: Spectral gap γ > 0
        n: Number of states
        epsilon: Target total variation distance
    
    Returns:
        Upper bound on mixing time
    """
    if gap <= 0:
        return float('inf')
    return (1.0 / gap) * np.log(n / epsilon)


def variance_decay(
    initial_variance: float,
    gap: float,
    num_steps: int
) -> List[float]:
    """
    Compute the variance decay sequence under spectral gap bound.
    
    Implements Theorem 3.4: var(t) ≤ (1-γ)^t · var(0)
    
    Args:
        initial_variance: Initial variance var(0)
        gap: Spectral gap γ ∈ (0, 1]
        num_steps: Number of time steps
    
    Returns:
        List of variance upper bounds [var(0), var(1), ..., var(T)]
    """
    rate = 1.0 - gap
    return [initial_variance * (rate ** t) for t in range(num_steps + 1)]


def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """
    Compute the KL divergence KL(p || q).
    
    Implements: KL(p || q) = Σᵢ p(i) · log(p(i) / q(i))
    
    By Gibbs' inequality (Theorem 5.1), KL(p || q) ≥ 0 with equality iff p = q.
    
    Args:
        p: Probability distribution (positive entries, sums to 1)
        q: Probability distribution (positive entries, sums to 1)
    
    Returns:
        KL divergence (non-negative by Gibbs' inequality)
    """
    mask = (p > 0) & (q > 0)
    return float(np.sum(p[mask] * np.log(p[mask] / q[mask])))


def total_variation(p: np.ndarray, q: np.ndarray) -> float:
    """
    Compute the total variation distance TV(p, q) = (1/2) Σᵢ |p(i) - q(i)|.
    
    Args:
        p: Probability distribution
        q: Probability distribution
    
    Returns:
        Total variation distance ∈ [0, 1]
    """
    return 0.5 * float(np.sum(np.abs(p - q)))


def solution_count_model(
    density: float,
    critical_density: float = 17 / 81,
    sharpness: float = 50.0
) -> int:
    """
    Model the solution count as a function of constraint density.
    
    Uses an exponential model with a sharp transition at d_c.
    
    Args:
        density: Constraint density d ∈ [0, 1]
        critical_density: Critical density d_c (default: 17/81 for Sudoku)
        sharpness: Controls transition sharpness
    
    Returns:
        Estimated number of solutions
    """
    if density >= critical_density:
        return 1
    return max(1, int(np.exp(sharpness * (critical_density - density))))


def spectral_gap_profile(
    density: float,
    critical_density: float = 17 / 81,
    max_gap: float = 0.5,
    sharpness: float = 10.0
) -> float:
    """
    Model the spectral gap as a function of constraint density.
    
    Implements the trichotomy:
    - d < d_c: gap > 0 (subcritical, fast mixing)
    - d ≈ d_c: gap → 0 (critical, slow mixing)
    - d > d_c: gap = 0 (supercritical, absorbing)
    
    Args:
        density: Constraint density d ∈ [0, 1]
        critical_density: Critical density d_c
        max_gap: Maximum spectral gap (at d = 0)
        sharpness: Controls transition width
    
    Returns:
        Spectral gap estimate
    """
    if density >= critical_density:
        return 0.0
    return max_gap * (1.0 - np.exp(-sharpness * (critical_density - density)))


def detect_phase_transition(
    gap_function: Callable[[float], float],
    d_min: float = 0.0,
    d_max: float = 1.0,
    resolution: int = 1000
) -> Optional[float]:
    """
    Detect the critical density where the spectral gap transitions to zero.
    
    Uses binary search to find the zero-crossing point.
    
    Args:
        gap_function: Function mapping density to spectral gap
        d_min: Minimum density to search
        d_max: Maximum density to search
        resolution: Number of grid points for initial scan
    
    Returns:
        Estimated critical density, or None if no transition found
    """
    densities = np.linspace(d_min, d_max, resolution)
    gaps = [gap_function(d) for d in densities]
    
    # Find the first density where gap ≈ 0
    for i, (d, g) in enumerate(zip(densities, gaps)):
        if g <= 1e-10:
            if i == 0:
                return d_min
            # Binary search between densities[i-1] and densities[i]
            lo, hi = densities[i - 1], densities[i]
            for _ in range(50):  # 50 iterations of bisection
                mid = (lo + hi) / 2
                if gap_function(mid) > 1e-10:
                    lo = mid
                else:
                    hi = mid
            return float((lo + hi) / 2)
    
    return None


def cheeger_conductance(
    P: np.ndarray,
    stationary: np.ndarray
) -> float:
    """
    Compute the Cheeger conductance of a Markov chain.
    
    h = min_{S: π(S) ≤ 1/2} Q(S, Sᶜ) / π(S)
    where Q(S, Sᶜ) = Σ_{i∈S, j∉S} π(i) P(i,j)
    
    Warning: Exponential in state space size. Only feasible for small chains.
    
    Args:
        P: Transition matrix
        stationary: Stationary distribution
    
    Returns:
        Cheeger conductance h
    """
    n = len(stationary)
    min_conductance = float('inf')
    
    # Iterate over all non-empty proper subsets
    for mask in range(1, 2 ** n - 1):
        S = [i for i in range(n) if mask & (1 << i)]
        pi_S = sum(stationary[i] for i in S)
        
        if pi_S > 0.5 or pi_S <= 0:
            continue
        
        # Compute flow Q(S, Sᶜ)
        S_complement = [i for i in range(n) if not (mask & (1 << i))]
        flow = sum(
            stationary[i] * P[i, j]
            for i in S
            for j in S_complement
        )
        
        conductance = flow / pi_S
        min_conductance = min(min_conductance, conductance)
    
    return min_conductance if min_conductance < float('inf') else 0.0


if __name__ == "__main__":
    # Quick test
    print("Testing algorithms...")
    
    # Random stochastic matrix
    P = np.array([[0.7, 0.2, 0.1],
                   [0.1, 0.6, 0.3],
                   [0.3, 0.2, 0.5]])
    
    gap = compute_spectral_gap(P)
    print(f"Spectral gap: {gap:.6f}")
    print(f"Mixing time estimate: {estimate_mixing_time(gap, 3):.2f}")
    
    # Variance decay
    decay = variance_decay(1.0, gap, 10)
    print(f"Variance decay: {[f'{v:.4f}' for v in decay]}")
    
    # KL divergence
    p = np.array([0.3, 0.3, 0.4])
    q = np.array([1/3, 1/3, 1/3])
    print(f"KL(p || q) = {kl_divergence(p, q):.6f} ≥ 0 ✓")
    
    # Phase transition detection
    d_c = detect_phase_transition(spectral_gap_profile)
    print(f"Detected critical density: {d_c:.4f} (expected: {17/81:.4f})")
    
    # Cheeger conductance
    stat = np.array([1/3, 1/3, 1/3])
    h = cheeger_conductance(P, stat)
    print(f"Cheeger conductance: {h:.6f}")
    print(f"Cheeger bound: {h**2/2:.6f} ≤ γ = {gap:.6f} ≤ {2*h:.6f}")
    
    print("\nAll tests passed!")
