#!/usr/bin/env python3
"""
Algorithms for Spectral Gap Analysis of Constraint Satisfaction Problems

Type-hinted implementations of the core algorithms:
1. Markov chain construction from CSP solution spaces
2. Spectral gap computation via eigenvalue decomposition
3. Conductance (Cheeger constant) computation
4. Mixing time estimation
5. Phase transition detection
"""

import numpy as np
from typing import List, Dict, Tuple, Optional, Callable
from dataclasses import dataclass


@dataclass
class MarkovChainResult:
    """Result of Markov chain analysis."""
    transition_matrix: np.ndarray
    spectral_gap: float
    mixing_time: float
    conductance: float
    stationary_distribution: np.ndarray
    is_irreducible: bool
    eigenvalues: np.ndarray


@dataclass
class PhaseTransitionResult:
    """Result of phase transition detection."""
    critical_density: float
    gap_function: List[Tuple[float, float]]
    transition_width: float
    subcritical_gap: float
    supercritical_gap: float


def build_stochastic_matrix(
    adjacency: np.ndarray,
    lazy: bool = True
) -> np.ndarray:
    """
    Build a stochastic matrix from an adjacency matrix.
    
    Algorithm: Lazy Random Walk Construction
    
    Pseudocode:
        for each state i:
            degree_i = sum of adjacency[i]
            if degree_i > 0:
                P[i,j] = (1/2) * adjacency[i,j] / degree_i  (lazy)
                P[i,i] += 1/2
            else:
                P[i,i] = 1  (absorbing)
    
    Args:
        adjacency: Symmetric adjacency matrix
        lazy: If True, use lazy chain (stay with prob 1/2)
    
    Returns:
        Row-stochastic transition matrix
    """
    n = adjacency.shape[0]
    P = np.zeros((n, n))
    
    for i in range(n):
        degree = np.sum(adjacency[i])
        if degree > 0:
            if lazy:
                for j in range(n):
                    if adjacency[i, j] > 0:
                        P[i, j] = 0.5 * adjacency[i, j] / degree
                P[i, i] += 0.5
            else:
                for j in range(n):
                    P[i, j] = adjacency[i, j] / degree
        else:
            P[i, i] = 1.0
    
    return P


def compute_spectral_gap(P: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute the spectral gap of a stochastic matrix.
    
    Algorithm: Eigenvalue Spectral Gap
    
    Pseudocode:
        eigenvalues = sorted eigenvalues of P (descending)
        gap = eigenvalues[0] - eigenvalues[1]
        return gap, eigenvalues
    
    The spectral gap gamma = 1 - lambda_2 for a row-stochastic matrix
    with largest eigenvalue 1.
    
    Args:
        P: Row-stochastic matrix
    
    Returns:
        (spectral_gap, sorted_eigenvalues)
    """
    n = P.shape[0]
    if n <= 1:
        return 0.0, np.array([1.0])
    
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    gap = float(eigenvalues[0] - eigenvalues[1])
    return max(gap, 0.0), eigenvalues


def compute_conductance(
    P: np.ndarray,
    stationary: np.ndarray
) -> float:
    """
    Compute the conductance (Cheeger constant) of a Markov chain.
    
    Algorithm: Brute-Force Conductance
    
    Pseudocode:
        Phi = infinity
        for each non-trivial subset S:
            if pi(S) <= 1/2:
                Q = sum_{i in S, j not in S} pi[i] * P[i,j]
                Phi = min(Phi, Q / pi(S))
        return Phi
    
    Cheeger's inequality: Phi^2/2 <= gamma <= 2*Phi
    
    Args:
        P: Transition matrix
        stationary: Stationary distribution
    
    Returns:
        Conductance value
    """
    n = P.shape[0]
    if n <= 1:
        return 0.0
    
    min_conductance = float('inf')
    
    # For small n, enumerate all subsets
    if n <= 20:
        for mask in range(1, 2**n - 1):
            S = [i for i in range(n) if mask & (1 << i)]
            Sc = [i for i in range(n) if not (mask & (1 << i))]
            
            pi_S = sum(stationary[i] for i in S)
            if pi_S > 0.5 + 1e-10:
                continue
            if pi_S < 1e-15:
                continue
            
            flow = sum(stationary[i] * P[i, j] for i in S for j in Sc)
            conductance = flow / pi_S
            min_conductance = min(min_conductance, conductance)
    else:
        # For large n, use sweep cut on Fiedler vector
        _, eigvecs = np.linalg.eigh(P)
        fiedler = eigvecs[:, -2]
        order = np.argsort(fiedler)
        
        for k in range(1, n):
            S = set(order[:k])
            pi_S = sum(stationary[i] for i in S)
            if pi_S > 0.5 + 1e-10:
                break
            if pi_S < 1e-15:
                continue
            
            flow = sum(stationary[i] * P[i, j] 
                      for i in S for j in range(n) if j not in S)
            conductance = flow / pi_S
            min_conductance = min(min_conductance, conductance)
    
    return min_conductance if min_conductance < float('inf') else 0.0


def estimate_mixing_time(
    gap: float,
    n_states: int,
    epsilon: float = 0.25
) -> float:
    """
    Estimate mixing time from spectral gap.
    
    Algorithm: Spectral Mixing Time Bound
    
    Pseudocode:
        if gap <= 0:
            return infinity
        t_mix = (1/gap) * (ln(n) + ln(1/epsilon))
        return t_mix
    
    Theorem: t_mix(eps) <= (1/gamma) * ln(1/(eps * sqrt(pi_min)))
    
    Args:
        gap: Spectral gap
        n_states: Number of states
        epsilon: Target TV distance
    
    Returns:
        Mixing time upper bound
    """
    if gap <= 1e-15:
        return float('inf')
    return (1.0 / gap) * (np.log(n_states) + np.log(1.0 / epsilon))


def detect_phase_transition(
    density_gap_pairs: List[Tuple[float, float]],
    threshold: float = 0.01
) -> PhaseTransitionResult:
    """
    Detect phase transition from density-gap data.
    
    Algorithm: Phase Transition Detection
    
    Pseudocode:
        Sort pairs by density
        Find largest gap decrease between consecutive densities
        Critical density = midpoint of largest decrease
        Transition width = density interval of steepest descent
    
    Args:
        density_gap_pairs: List of (density, spectral_gap) pairs
        threshold: Minimum gap to consider non-zero
    
    Returns:
        PhaseTransitionResult with critical density and analysis
    """
    pairs = sorted(density_gap_pairs, key=lambda x: x[0])
    
    max_decrease = 0.0
    critical_idx = 0
    
    for i in range(len(pairs) - 1):
        decrease = pairs[i][1] - pairs[i+1][1]
        if decrease > max_decrease:
            max_decrease = decrease
            critical_idx = i
    
    d_c = (pairs[critical_idx][0] + pairs[critical_idx + 1][0]) / 2
    
    # Find transition width
    subcritical_gaps = [g for d, g in pairs if d < d_c and g > threshold]
    supercritical_gaps = [g for d, g in pairs if d > d_c]
    
    subcritical_gap = np.mean(subcritical_gaps) if subcritical_gaps else 0.0
    supercritical_gap = np.mean(supercritical_gaps) if supercritical_gaps else 0.0
    
    # Transition width: density range where gap changes most
    high_gap_density = min(d for d, g in pairs if g > 0.5 * subcritical_gap) if subcritical_gap > 0 else pairs[0][0]
    low_gap_density = max(d for d, g in pairs if g < 2 * supercritical_gap) if supercritical_gap > 0 else pairs[-1][0]
    
    return PhaseTransitionResult(
        critical_density=d_c,
        gap_function=pairs,
        transition_width=low_gap_density - high_gap_density,
        subcritical_gap=subcritical_gap,
        supercritical_gap=supercritical_gap
    )


def analyze_markov_chain(P: np.ndarray) -> MarkovChainResult:
    """
    Complete analysis of a Markov chain.
    
    Args:
        P: Transition matrix
    
    Returns:
        MarkovChainResult with all computed quantities
    """
    n = P.shape[0]
    
    # Compute spectral gap and eigenvalues
    gap, eigenvalues = compute_spectral_gap(P)
    
    # Compute stationary distribution
    # For a doubly stochastic matrix, it's uniform
    eigenvalues_full, eigvecs = np.linalg.eig(P.T)
    idx = np.argmin(np.abs(eigenvalues_full - 1.0))
    stationary = np.real(eigvecs[:, idx])
    stationary = np.abs(stationary)
    stationary /= np.sum(stationary)
    
    # Compute conductance
    conductance = compute_conductance(P, stationary)
    
    # Check irreducibility
    # A chain is irreducible if P^n has all positive entries
    Pn = np.linalg.matrix_power(P, n)
    is_irreducible = np.all(Pn > 1e-10)
    
    # Mixing time
    mixing_time = estimate_mixing_time(gap, n)
    
    return MarkovChainResult(
        transition_matrix=P,
        spectral_gap=gap,
        mixing_time=mixing_time,
        conductance=conductance,
        stationary_distribution=stationary,
        is_irreducible=is_irreducible,
        eigenvalues=eigenvalues
    )


def verify_cheeger_inequality(
    gap: float,
    conductance: float
) -> Tuple[bool, str]:
    """
    Verify Cheeger's inequality: Phi^2/2 <= gamma <= 2*Phi
    
    Args:
        gap: Spectral gap
        conductance: Cheeger constant
    
    Returns:
        (is_satisfied, description)
    """
    lower = conductance ** 2 / 2
    upper = 2 * conductance
    
    lower_ok = lower <= gap + 1e-10
    upper_ok = gap <= upper + 1e-10
    
    desc = (f"Phi = {conductance:.6f}, gamma = {gap:.6f}\n"
            f"  Lower (Phi^2/2 = {lower:.6f}): {'✓' if lower_ok else '✗'}\n"
            f"  Upper (2*Phi = {upper:.6f}): {'✓' if upper_ok else '✗'}")
    
    return lower_ok and upper_ok, desc


if __name__ == "__main__":
    # Example: two-state chain
    p = 0.3
    P = np.array([[1-p, p], [p, 1-p]])
    
    result = analyze_markov_chain(P)
    print(f"Two-state chain (p={p}):")
    print(f"  Spectral gap: {result.spectral_gap:.4f}")
    print(f"  Conductance: {result.conductance:.4f}")
    print(f"  Mixing time: {result.mixing_time:.4f}")
    print(f"  Irreducible: {result.is_irreducible}")
    
    ok, desc = verify_cheeger_inequality(result.spectral_gap, result.conductance)
    print(f"\nCheeger's inequality:\n{desc}")
