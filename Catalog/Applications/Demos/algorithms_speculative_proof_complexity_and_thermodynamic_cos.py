"""
Thermodynamic Proof Complexity: Algorithms and Data Structures

This module implements the core algorithms for computing thermodynamic
properties of formal proof systems, including partition functions,
Boltzmann weights, and free energy landscapes.
"""

import math
from typing import List, Tuple, Callable, Optional
from dataclasses import dataclass


@dataclass
class ProofEnergyLandscape:
    """A proof system with thermodynamic structure.

    Attributes:
        alphabet_size: Number of symbols in the proof alphabet (b >= 2)
        max_length: Maximum proof length (N > 0)
        density_of_states: Function mapping length k -> number of valid proofs at length k
    """
    alphabet_size: int
    max_length: int
    density_of_states: Callable[[int], int]

    def __post_init__(self) -> None:
        assert self.alphabet_size >= 2, "Alphabet must have at least 2 symbols"
        assert self.max_length > 0, "Max length must be positive"

    def total_strings(self, k: int) -> int:
        """Total number of strings of length k."""
        return self.alphabet_size ** k

    def scaled_cost(self, k: int, temperature: float) -> float:
        """Thermodynamic cost of a proof of length k at temperature T.
        cost(k, T) = k * T * ln(2) [Landauer's principle]
        """
        return k * temperature * math.log(2)

    def total_valid_proofs(self, n: int) -> int:
        """Total valid proofs up to length n."""
        return sum(self.density_of_states(k) for k in range(n + 1))

    def partition_function(self, beta: float, n: Optional[int] = None) -> float:
        """Boltzmann partition function Z(β) = Σ_k ν(k) * exp(-β*k).

        Args:
            beta: Inverse temperature parameter
            n: Maximum length to sum over (defaults to max_length)
        """
        if n is None:
            n = self.max_length
        return sum(
            self.density_of_states(k) * math.exp(-beta * k)
            for k in range(n + 1)
        )

    def mean_proof_length(self, beta: float) -> float:
        """Expected proof length under Boltzmann distribution.
        <k> = Σ_k k * ν(k) * exp(-β*k) / Z(β)
        """
        Z = self.partition_function(beta)
        if Z == 0:
            return 0.0
        return sum(
            k * self.density_of_states(k) * math.exp(-beta * k)
            for k in range(self.max_length + 1)
        ) / Z

    def proof_length_variance(self, beta: float) -> float:
        """Variance of proof length under Boltzmann distribution."""
        mean = self.mean_proof_length(beta)
        Z = self.partition_function(beta)
        if Z == 0:
            return 0.0
        mean_sq = sum(
            k**2 * self.density_of_states(k) * math.exp(-beta * k)
            for k in range(self.max_length + 1)
        ) / Z
        return mean_sq - mean**2

    def free_energy(self, beta: float) -> float:
        """Helmholtz free energy F = -T * ln(Z) = -(1/β) * ln(Z)."""
        Z = self.partition_function(beta)
        if Z <= 0 or beta <= 0:
            return float('inf')
        return -math.log(Z) / beta

    def entropy(self, beta: float) -> float:
        """Thermodynamic entropy S = β*(⟨E⟩ - F)."""
        Z = self.partition_function(beta)
        if Z <= 0 or beta <= 0:
            return 0.0
        F = self.free_energy(beta)
        E_mean = self.mean_proof_length(beta)  # E = k in natural units
        return beta * (E_mean - F)

    def incompressible_count(self, k: int) -> int:
        """Number of incompressible strings at length k."""
        if k == 0:
            return 1
        return self.alphabet_size ** k - self.alphabet_size ** (k - 1)

    def incompressible_fraction(self, k: int) -> float:
        """Fraction of strings at length k that are incompressible."""
        if k == 0:
            return 1.0
        return 1.0 - 1.0 / self.alphabet_size

    def weighted_total_cost(self, n: int) -> int:
        """Sum of k * ν(k) for k from 0 to n."""
        return sum(k * self.density_of_states(k) for k in range(n + 1))

    def cost_gap(self, k1: int, k2: int, temperature: float) -> float:
        """Thermodynamic cost gap between proofs of length k2 and k1."""
        return (k2 - k1) * temperature * math.log(2)


def geometric_sum(b: int, n: int) -> int:
    """Compute Σ_{k=0}^{n} b^k = (b^(n+1) - 1) / (b - 1)."""
    if b == 1:
        return n + 1
    return (b ** (n + 1) - 1) // (b - 1)


def find_phase_transition(landscape: ProofEnergyLandscape,
                          beta_min: float = 0.01,
                          beta_max: float = 10.0,
                          num_points: int = 1000) -> Tuple[float, float]:
    """Find the critical inverse temperature where proof length variance peaks.

    Returns:
        (beta_critical, max_variance): The critical point and peak variance.
    """
    best_beta = beta_min
    best_var = 0.0
    for i in range(num_points):
        beta = beta_min + (beta_max - beta_min) * i / num_points
        var = landscape.proof_length_variance(beta)
        if var > best_var:
            best_var = var
            best_beta = beta
    return best_beta, best_var


def chaitin_bound_search(alphabet_size: int, max_length: int) -> List[Tuple[int, int]]:
    """Search for the Chaitin-like bound: how proof cost grows with statement length.

    For each 'statement length' s, compute the maximum proof length needed.
    Returns list of (statement_length, max_proof_cost) pairs.
    """
    results = []
    for s in range(1, max_length + 1):
        # The maximum number of statements of length s
        num_statements = alphabet_size ** s
        # By pigeonhole, at least one statement needs proof of length ≥ log_b(num_statements)
        min_proof_length = s  # since log_b(b^s) = s
        results.append((s, min_proof_length))
    return results


def compute_boltzmann_distribution(landscape: ProofEnergyLandscape,
                                    beta: float) -> List[Tuple[int, float]]:
    """Compute the Boltzmann probability distribution over proof lengths.

    Returns list of (length, probability) pairs.
    """
    Z = landscape.partition_function(beta)
    if Z == 0:
        return [(k, 0.0) for k in range(landscape.max_length + 1)]
    return [
        (k, landscape.density_of_states(k) * math.exp(-beta * k) / Z)
        for k in range(landscape.max_length + 1)
    ]
