#!/usr/bin/env python3
"""
Algorithms for Thermodynamic Proof Complexity

Type-hinted implementations of the key algorithms from the formalized theory.
"""

import math
from dataclasses import dataclass
from typing import Optional


# Physical constants
K_BOLTZMANN: float = 1.380649e-23  # J/K


@dataclass
class ProofCostModel:
    """Thermodynamic cost model for proofs.
    
    Attributes:
        temperature: System temperature in Kelvin (must be > 0).
        alphabet_size: Size of the proof alphabet (must be >= 2).
    """
    temperature: float
    alphabet_size: int = 2
    
    def __post_init__(self) -> None:
        assert self.temperature > 0, "Temperature must be positive"
        assert self.alphabet_size >= 2, "Alphabet size must be at least 2"
    
    @property
    def kT(self) -> float:
        """Boltzmann constant times temperature (joules)."""
        return K_BOLTZMANN * self.temperature
    
    @property
    def cost_per_symbol(self) -> float:
        """Energy cost per proof symbol (joules)."""
        return self.kT * math.log(self.alphabet_size)
    
    def proof_cost(self, length: int) -> float:
        """Minimum thermodynamic cost of a proof of given length.
        
        cost(n) = n · kT · ln(b)
        
        Args:
            length: Number of symbols in the proof.
        Returns:
            Minimum energy cost in joules.
        """
        return length * self.cost_per_symbol
    
    def max_affordable_length(self, energy_budget: float) -> int:
        """Maximum proof length affordable within energy budget.
        
        Args:
            energy_budget: Available energy in joules.
        Returns:
            Maximum number of proof symbols processable.
        """
        return int(energy_budget / self.cost_per_symbol)
    
    def proofs_of_length_at_most(self, n: int) -> int:
        """Number of proof strings of length ≤ n.
        
        Σᵢ₌₀ⁿ bⁱ = (b^(n+1) - 1) / (b - 1)
        """
        b = self.alphabet_size
        return (b ** (n + 1) - 1) // (b - 1)
    
    def capacity_bound(self, n: int) -> int:
        """Upper bound on proofs of length ≤ n: 2·bⁿ.
        
        Theorem: Σᵢ₌₀ⁿ bⁱ ≤ 2·bⁿ for b ≥ 2.
        """
        return 2 * self.alphabet_size ** n


@dataclass
class ProofTask:
    """A theorem-proving task with known search space bounds.
    
    Attributes:
        alphabet_size: Size of the proof alphabet.
        max_length: Maximum proof length to search.
        valid_proofs: Number of valid proofs in the space.
        verification_length: Length of the shortest proof (verification cost).
    """
    alphabet_size: int
    max_length: int
    valid_proofs: int
    verification_length: int
    
    def __post_init__(self) -> None:
        assert self.alphabet_size >= 2
        assert self.valid_proofs <= self.alphabet_size ** self.verification_length
        assert self.verification_length <= self.max_length
        assert self.valid_proofs > 0
    
    @property
    def total_candidates(self) -> int:
        """Total number of candidate proof strings."""
        return self.alphabet_size ** self.max_length
    
    @property
    def search_cost(self) -> int:
        """Search cost: total candidates / (valid proofs + 1)."""
        return self.total_candidates // (self.valid_proofs + 1)
    
    @property
    def energy_gap_exponent(self) -> int:
        """Exponent of the search-verification energy gap."""
        return self.max_length - self.verification_length - 1
    
    def search_verification_gap(self) -> dict[str, float]:
        """Compute the search-verification energy gap.
        
        Returns dictionary with gap metrics.
        """
        gap = self.energy_gap_exponent
        return {
            'gap_exponent': gap,
            'search_cost_lower_bound': self.alphabet_size ** gap,
            'search_cost_actual': self.search_cost,
            'verification_cost': self.verification_length,
            'energy_ratio': gap / self.verification_length if self.verification_length > 0 else float('inf'),
        }


def geometric_capacity_bound(b: int, n: int) -> int:
    """Compute the geometric capacity bound 2·bⁿ.
    
    Theorem: For b ≥ 2, Σᵢ₌₀ⁿ bⁱ ≤ 2·bⁿ.
    
    Args:
        b: Alphabet size (≥ 2).
        n: Maximum proof length.
    Returns:
        Upper bound on number of strings of length ≤ n.
    """
    assert b >= 2
    return 2 * b ** n


def incompressible_count(b: int, n: int) -> int:
    """Number of incompressible strings of length n.
    
    Theorem: At least (b-1)·b^(n-1) strings of length n are incompressible.
    
    Args:
        b: Alphabet size (≥ 2).
        n: String length (≥ 1).
    Returns:
        Lower bound on incompressible string count.
    """
    assert b >= 2 and n >= 1
    return (b - 1) * b ** (n - 1)


def computability_barrier_check(b: int, f: int, n: int) -> bool:
    """Check whether the computability barrier applies.
    
    Theorem: For b ≥ 2 and f+2 ≤ n, we have 2·bᶠ < bⁿ.
    This means some statements of length n have no proof of length ≤ f.
    
    Args:
        b: Alphabet size.
        f: Fixed proof length bound.
        n: Statement length.
    Returns:
        True if the barrier applies (some statements lack short proofs).
    """
    return b >= 2 and f + 2 <= n


def meta_proof_space_log(b: int, n: int) -> int:
    """Log_b of the meta-proof space size.
    
    Theorem: For b ≥ 2, n ≥ 1: meta-proof space = b^(b^n).
    The log_b of this is b^n, which exceeds n.
    
    Args:
        b: Alphabet size.
        n: Proof length parameter.
    Returns:
        b^n (the log_b of the meta-proof space size).
    """
    return b ** n


def proof_entropy(b: int, n: int) -> float:
    """Shannon entropy of uniform distribution over b^n proof strings.
    
    H = n · ln(b) nats = n · log₂(b) bits.
    
    Args:
        b: Alphabet size.
        n: Proof length.
    Returns:
        Entropy in nats.
    """
    return n * math.log(b)


def average_search_cost_exponent(b: int, n: int, k: int) -> int:
    """Exponent of the average search cost.
    
    Theorem: When valid proofs ≤ b^k out of b^n candidates,
    average search cost ≥ b^(n-k-1).
    
    Args:
        b: Alphabet size.
        n: Total search space exponent.
        k: Valid proof space exponent.
    Returns:
        Exponent n-k-1 of the average search cost.
    """
    assert k + 1 <= n
    return n - k - 1


def hierarchy_gap(b: int, k: int) -> int:
    """Gap between adjacent levels of the proof hierarchy.
    
    Theorem: b^(k+1) - b^k = (b-1)·b^k.
    
    Args:
        b: Alphabet size.
        k: Current level.
    Returns:
        (b-1) * b^k
    """
    return (b - 1) * b ** k


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Create a cost model at room temperature with binary alphabet
    model = ProofCostModel(temperature=300.0, alphabet_size=2)
    
    print(f"Cost per bit at 300K: {model.cost_per_symbol:.4e} J")
    print(f"Cost of 1000-bit proof: {model.proof_cost(1000):.4e} J")
    print(f"Max proof length with 1 J: {model.max_affordable_length(1.0)} bits")
    print(f"Capacity bound for n=20: {model.capacity_bound(20)} strings")
    
    # Create a proof task
    task = ProofTask(
        alphabet_size=2,
        max_length=100,
        valid_proofs=1000,
        verification_length=10
    )
    
    gap_info = task.search_verification_gap()
    print(f"\nProof task gap analysis:")
    for key, value in gap_info.items():
        print(f"  {key}: {value}")
