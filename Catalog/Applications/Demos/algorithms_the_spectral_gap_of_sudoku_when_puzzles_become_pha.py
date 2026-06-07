#!/usr/bin/env python3
"""
Algorithms for Spectral Gap Analysis of Constraint Satisfaction Systems

Type-hinted implementations of the key algorithms from the Cheeger Chain framework.
"""

from typing import List, Dict, Tuple, Optional, Set
import numpy as np
from dataclasses import dataclass


@dataclass
class ReversibleChain:
    """A reversible Markov chain with transition matrix and stationary distribution."""
    P: np.ndarray           # n x n transition matrix
    mu: np.ndarray          # stationary distribution (length n)
    n: int                  # number of states

    def __post_init__(self) -> None:
        assert self.P.shape == (self.n, self.n), "P must be n x n"
        assert self.mu.shape == (self.n,), "mu must have length n"
        assert np.allclose(self.P.sum(axis=1), 1.0), "Rows must sum to 1"
        assert np.allclose(self.mu.sum(), 1.0), "mu must sum to 1"
        assert np.all(self.P >= -1e-10), "P must be non-negative"
        assert np.all(self.mu >= -1e-10), "mu must be non-negative"

    def is_reversible(self) -> bool:
        """Check detailed balance: mu[i]*P[i,j] = mu[j]*P[j,i]."""
        for i in range(self.n):
            for j in range(self.n):
                if not np.isclose(self.mu[i] * self.P[i, j],
                                  self.mu[j] * self.P[j, i]):
                    return False
        return True


@dataclass
class CheegerChainData:
    """A Cheeger Chain: reversible chain + Cheeger constant + spectral gap."""
    chain: ReversibleChain
    cheeger_h: float        # Cheeger constant
    spectral_gap: float     # spectral gap γ = 1 - λ₂

    def verify_sandwich(self) -> Tuple[bool, str]:
        """Verify the Cheeger sandwich: h²/2 ≤ γ ≤ 2h."""
        lower_ok = self.cheeger_h ** 2 / 2 <= self.spectral_gap + 1e-10
        upper_ok = self.spectral_gap <= 2 * self.cheeger_h + 1e-10
        msg = f"h²/2 = {self.cheeger_h**2/2:.6f} ≤ γ = {self.spectral_gap:.6f} ≤ 2h = {2*self.cheeger_h:.6f}"
        return (lower_ok and upper_ok, msg)


def compute_spectral_gap(P: np.ndarray) -> float:
    """Compute the spectral gap γ = 1 - |λ₂| of a stochastic matrix P.

    Algorithm:
    1. Compute all eigenvalues of P
    2. Sort by absolute value (descending)
    3. Return λ₁ - |λ₂|

    Time complexity: O(n³) via eigenvalue decomposition
    Space complexity: O(n²)
    """
    n = P.shape[0]
    if n <= 1:
        return 1.0

    eigenvalues = np.linalg.eigvals(P)
    abs_eigs = np.sort(np.abs(eigenvalues))[::-1]

    return float(abs_eigs[0] - abs_eigs[1])


def compute_cheeger_constant(P: np.ndarray, mu: np.ndarray,
                              max_subsets: int = 10000) -> float:
    """Compute (or estimate) the Cheeger constant of a reversible chain.

    Algorithm (exact for small n, sampling for large n):
    1. For each non-empty proper subset S with mu(S) ≤ 1/2:
       h(S) = Q(S, Sᶜ) / mu(S)
    2. Return min over all such S

    Time complexity: O(2^n · n²) exact, O(max_subsets · n²) approximate
    """
    n = P.shape[0]
    if n <= 1:
        return 1.0

    best_h = float('inf')

    if n <= 15:  # Exact enumeration for small n
        for mask in range(1, 2**n - 1):
            S = [i for i in range(n) if mask & (1 << i)]
            mu_S = sum(mu[i] for i in S)
            if mu_S <= 0 or mu_S > 0.5 + 1e-10:
                continue
            flow = sum(mu[i] * P[i, j]
                       for i in S
                       for j in range(n)
                       if j not in S)
            h = flow / mu_S
            best_h = min(best_h, h)
    else:  # Sampling for large n
        for _ in range(max_subsets):
            size = np.random.randint(1, n // 2 + 1)
            S = list(np.random.choice(n, size, replace=False))
            S_set = set(S)
            mu_S = sum(mu[i] for i in S)
            if mu_S <= 0 or mu_S > 0.5 + 1e-10:
                continue
            flow = sum(mu[i] * P[i, j]
                       for i in S
                       for j in range(n)
                       if j not in S_set)
            h = flow / mu_S
            best_h = min(best_h, h)

    return best_h if best_h < float('inf') else 0.0


def mixing_time_bound(gap: float, eps: float, n: int) -> float:
    """Compute the mixing time bound: t_mix(ε) ≤ (1/γ) · log(n/ε).

    This is the classical bound from Markov chain theory.
    """
    if gap <= 0:
        return float('inf')
    return (1.0 / gap) * (np.log(n) + np.log(1.0 / eps))


def relaxation_time(gap: float) -> float:
    """Compute the relaxation time: τ_rel = 1/γ."""
    if gap <= 0:
        return float('inf')
    return 1.0 / gap


def contraction_factor(gap: float, t: int) -> float:
    """Compute the L² contraction factor after t steps: (1-γ)^t."""
    return max(0.0, (1.0 - gap)) ** t


def build_constraint_chain(
    solutions: List[np.ndarray],
    adjacency_fn: Optional[callable] = None
) -> Optional[CheegerChainData]:
    """Build a CheegerChain from a set of constraint satisfaction solutions.

    Args:
        solutions: List of valid solutions (as numpy arrays)
        adjacency_fn: Function(sol1, sol2) -> bool for connectivity
                      Default: differ by exactly one swap

    Returns:
        CheegerChainData or None if no solutions
    """
    n = len(solutions)
    if n == 0:
        return None

    if adjacency_fn is None:
        def adjacency_fn(s1: np.ndarray, s2: np.ndarray) -> bool:
            return np.sum(s1 != s2) == 2

    # Build transition matrix
    P = np.zeros((n, n))
    for i in range(n):
        neighbors = []
        for j in range(n):
            if i != j and adjacency_fn(solutions[i], solutions[j]):
                neighbors.append(j)
        if neighbors:
            prob = 1.0 / len(neighbors)
            for j in neighbors:
                P[i, j] = prob
        else:
            P[i, i] = 1.0

    # Make lazy for aperiodicity
    P = 0.5 * np.eye(n) + 0.5 * P

    # Uniform stationary distribution (doubly stochastic for uniform)
    mu = np.ones(n) / n

    chain = ReversibleChain(P=P, mu=mu, n=n)
    gap = compute_spectral_gap(P)
    h = compute_cheeger_constant(P, mu)

    return CheegerChainData(chain=chain, cheeger_h=h, spectral_gap=gap)


def spectral_density_profile(
    gap_values: Dict[float, float]
) -> Dict[str, any]:
    """Analyze the spectral density profile and identify phase transitions.

    Args:
        gap_values: Dictionary mapping density -> spectral gap

    Returns:
        Analysis results including critical density estimate
    """
    densities = sorted(gap_values.keys())
    gaps = [gap_values[d] for d in densities]

    # Find minimum gap (candidate critical point)
    min_idx = np.argmin(gaps)
    critical_density = densities[min_idx]
    min_gap = gaps[min_idx]

    # Classify phases
    phases = []
    for d, g in zip(densities, gaps):
        if g > 0.5:
            phases.append("underconstrained")
        elif g > 0.01:
            phases.append("critical")
        else:
            phases.append("overconstrained")

    return {
        "critical_density": critical_density,
        "min_gap": min_gap,
        "phases": dict(zip(densities, phases)),
        "gap_profile": dict(zip(densities, gaps)),
    }


if __name__ == "__main__":
    # Example: 3-state chain
    P = np.array([
        [0.5, 0.3, 0.2],
        [0.3, 0.5, 0.2],
        [0.2, 0.2, 0.6]
    ])
    mu = np.array([1/3, 1/3, 1/3])

    chain = ReversibleChain(P=P, mu=mu, n=3)
    print(f"Reversible: {chain.is_reversible()}")

    gap = compute_spectral_gap(P)
    h = compute_cheeger_constant(P, mu)
    print(f"Spectral gap: {gap:.6f}")
    print(f"Cheeger constant: {h:.6f}")
    print(f"Sandwich: h²/2 = {h**2/2:.6f} ≤ γ = {gap:.6f} ≤ 2h = {2*h:.6f}")
    print(f"Mixing time (ε=0.01): {mixing_time_bound(gap, 0.01, 3):.1f}")
    print(f"Relaxation time: {relaxation_time(gap):.2f}")
