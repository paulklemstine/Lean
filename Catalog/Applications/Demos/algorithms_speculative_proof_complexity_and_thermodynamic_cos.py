#!/usr/bin/env python3
"""
Thermodynamic Proof Complexity — Core Algorithms

Type-hinted implementations of the key algorithms from the
Thermodynamic Proof Complexity framework.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class ThermodynamicProofSystem:
    """A proof system with thermodynamic cost accounting.
    
    Attributes:
        alphabet_size: Number of symbols in the proof language (≥ 2)
        max_proof_len: Maximum proof length
        statement_count: Number of distinct statements
        temperature: Physical temperature T > 0
    """
    alphabet_size: int
    max_proof_len: int
    statement_count: int
    temperature: float
    
    def __post_init__(self) -> None:
        assert self.alphabet_size >= 2, "Alphabet must have ≥ 2 symbols"
        assert self.temperature > 0, "Temperature must be positive"
        assert self.statement_count > 0, "Must have ≥ 1 statement"
    
    def proof_cost(self, proof_length: int) -> float:
        """Thermodynamic cost of a proof of given length.
        
        cost(ℓ) = ℓ · T · ln(2)
        """
        return proof_length * self.temperature * math.log(2)
    
    def min_proof_cost(self, min_proof_length: int) -> float:
        """Minimum thermodynamic cost for a statement with given min proof length."""
        return self.proof_cost(min_proof_length)
    
    def total_candidates(self) -> int:
        """Total number of candidate proof strings."""
        return self.alphabet_size ** self.max_proof_len
    
    def search_overhead(self, valid_proofs: int) -> float:
        """Search overhead: ratio of total candidates to valid proofs."""
        return self.total_candidates() / (valid_proofs + 1)
    
    def incompressible_count(self, n: int) -> int:
        """Number of incompressible strings of length n."""
        total = self.alphabet_size ** n
        compressible = self.alphabet_size ** (n - 1) if n >= 1 else 0
        return total - compressible
    
    def incompressible_fraction(self) -> float:
        """Fraction of strings that are incompressible."""
        return (self.alphabet_size - 1) / self.alphabet_size


@dataclass
class ProofEnergyLandscape:
    """Energy landscape over proof space.
    
    Models the geometric structure of proof search, with valid proofs
    as global minima and invalid near-misses as local minima.
    """
    dim: int
    total_points: int
    valid_minima: int
    local_minima: int
    global_min_energy: float
    local_min_avg_energy: float
    
    def __post_init__(self) -> None:
        assert self.total_points > 0
        assert self.valid_minima <= self.local_minima
        assert self.local_minima <= self.total_points
        assert self.global_min_energy <= self.local_min_avg_energy
    
    def ruggedness_ratio(self) -> float:
        """Ruggedness ratio: local minima per global minimum."""
        return self.local_minima / (self.valid_minima + 1)
    
    def energy_gap(self) -> float:
        """Energy gap between local and global minima."""
        return self.local_min_avg_energy - self.global_min_energy
    
    def trapping_probability(self) -> float:
        """Probability of landing in a trap (non-global local minimum)."""
        if self.local_minima == 0:
            return 0.0
        return 1 - self.valid_minima / self.local_minima
    
    def is_rugged(self) -> bool:
        """Whether the landscape is rugged (trapping prob > 0.5)."""
        return self.valid_minima * 2 <= self.local_minima


@dataclass
class ProofComplexityProfile:
    """Profile of proof complexity across statement lengths.
    
    Captures how proof difficulty scales with statement complexity.
    """
    alphabet_size: int
    proof_len_fn: List[int]  # proof_len_fn[s] = min proof length for statement s
    proof_count_fn: List[int]  # proof_count_fn[s] = number of valid proofs for statement s
    
    def difficulty_at(self, s: int) -> float:
        """Search difficulty at statement length s."""
        if s >= len(self.proof_len_fn):
            return float('inf')
        total = self.alphabet_size ** self.proof_len_fn[s]
        return total / (self.proof_count_fn[s] + 1)
    
    def cumulative_difficulty(self, s: int) -> float:
        """Cumulative difficulty up to statement length s."""
        return sum(self.difficulty_at(i) for i in range(s))


def compute_hierarchy_gaps(
    tps: ThermodynamicProofSystem,
    max_level: int
) -> List[Tuple[int, float, float]]:
    """Compute the proof cost hierarchy.
    
    Returns list of (level, cost_at_level, gap_from_previous).
    Each gap should be exactly T · ln(2).
    """
    result: List[Tuple[int, float, float]] = []
    prev_cost = 0.0
    for k in range(max_level + 1):
        cost = tps.proof_cost(k)
        gap = cost - prev_cost
        result.append((k, cost, gap))
        prev_cost = cost
    return result


def chaitin_bound_threshold(
    alphabet_size: int,
    cost_level: int
) -> int:
    """Compute the Chaitin threshold: number of statements needed
    to guarantee some statement has proof cost > cost_level · T · ln(2).
    
    Returns b^cost_level + 1.
    """
    return alphabet_size ** cost_level + 1


def sparse_search_lower_bound(
    b: int, n: int, k: int
) -> int:
    """Lower bound on search overhead when valid proofs ≤ b^k out of b^n.
    
    Returns b^(n-k-1).
    """
    if n <= k + 1:
        return 1
    return b ** (n - k - 1)


def analyze_sorting_cost(n: int, temperature: float = 300.0) -> dict:
    """Analyze the thermodynamic cost of sorting n items.
    
    Sorting is a special case of proof search where the "proof"
    is the correct permutation.
    """
    if n <= 1:
        return {"n": n, "factorial": 1, "info_bits": 0.0, "cost": 0.0}
    
    factorial = math.factorial(n)
    info_bits = math.log2(factorial)
    cost = info_bits * temperature * math.log(2)
    two_pow_bound = 2 ** (n - 1)
    
    return {
        "n": n,
        "factorial": factorial,
        "info_bits": info_bits,
        "cost_natural_units": cost,
        "two_pow_lower_bound": two_pow_bound,
        "factorial_ge_two_pow": factorial >= two_pow_bound,
    }


def landscape_analysis(
    b: int, n: int,
    valid_proof_density: float = 0.001
) -> ProofEnergyLandscape:
    """Create a proof energy landscape for given parameters.
    
    Args:
        b: alphabet size
        n: proof length
        valid_proof_density: fraction of strings that are valid proofs
    """
    total = b ** n
    valid = max(1, int(total * valid_proof_density))
    # Estimate local minima as ~sqrt(total) (typical for random landscapes)
    local = max(valid, int(math.sqrt(total)))
    
    return ProofEnergyLandscape(
        dim=n,
        total_points=total,
        valid_minima=valid,
        local_minima=local,
        global_min_energy=0.0,
        local_min_avg_energy=n * math.log(2) * 0.5  # half of max energy
    )


if __name__ == "__main__":
    # Quick self-test
    tps = ThermodynamicProofSystem(
        alphabet_size=2,
        max_proof_len=100,
        statement_count=1000,
        temperature=1.0  # natural units
    )
    
    print("Cost of proof length 10:", tps.proof_cost(10))
    print("Cost of proof length 5:", tps.proof_cost(5))
    print("Cost monotonicity:", tps.proof_cost(5) < tps.proof_cost(10))
    print("Incompressible fraction:", tps.incompressible_fraction())
    
    gaps = compute_hierarchy_gaps(tps, 5)
    print("\nHierarchy gaps:")
    for level, cost, gap in gaps:
        print(f"  Level {level}: cost={cost:.4f}, gap={gap:.4f}")
    
    sorting = analyze_sorting_cost(10, temperature=1.0)
    print(f"\nSorting 10 items: {sorting['info_bits']:.1f} bits, "
          f"cost={sorting['cost_natural_units']:.2f}")
    
    landscape = landscape_analysis(2, 20)
    print(f"\nLandscape (b=2, n=20):")
    print(f"  Ruggedness: {landscape.ruggedness_ratio():.1f}")
    print(f"  Trapping prob: {landscape.trapping_probability():.4f}")
    print(f"  Is rugged: {landscape.is_rugged()}")
