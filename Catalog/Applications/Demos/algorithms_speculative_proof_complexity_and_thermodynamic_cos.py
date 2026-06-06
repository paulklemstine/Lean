#!/usr/bin/env python3
"""
Algorithms for Proof Complexity and Thermodynamic Cost

Type-hinted implementations of the key algorithms from the research.
"""

import math
from typing import List, Tuple, Optional
from dataclasses import dataclass


# Physical constants
K_BOLTZMANN: float = 1.380649e-23  # J/K
LN2: float = math.log(2)


@dataclass
class ProofThermodynamicSystem:
    """A proof system with thermodynamic parameters."""
    alphabet_size: int
    max_proof_len: int
    temperature: float  # Kelvin
    valid_count: int

    def __post_init__(self) -> None:
        assert self.alphabet_size >= 2, "Alphabet must have ≥ 2 symbols"
        assert self.temperature > 0, "Temperature must be positive"
        assert self.valid_count <= self.alphabet_size ** self.max_proof_len

    @property
    def total_candidates(self) -> int:
        """Total number of candidate proof strings."""
        return self.alphabet_size ** self.max_proof_len

    def proof_cost(self, proof_len: int) -> float:
        """Thermodynamic cost of a proof: |π| * kT * ln(2)."""
        return proof_len * K_BOLTZMANN * self.temperature * LN2

    def search_cost(self, candidates_examined: int) -> float:
        """Thermodynamic cost of examining candidates."""
        return candidates_examined * K_BOLTZMANN * self.temperature * LN2

    @property
    def search_difficulty(self) -> int:
        """Search difficulty: total / (valid + 1)."""
        return self.total_candidates // (self.valid_count + 1)

    @property
    def landauer_unit(self) -> float:
        """One Landauer unit: kT * ln(2)."""
        return K_BOLTZMANN * self.temperature * LN2


def geometric_sum(b: int, n: int) -> int:
    """
    Compute ∑_{i=0}^{n-1} b^i = (b^n - 1) / (b - 1).

    This counts the total number of strings of length < n
    over an alphabet of size b.
    """
    if b == 1:
        return n
    return (b ** n - 1) // (b - 1)


def incompressible_count(b: int, n: int) -> int:
    """
    Count of incompressible strings of length n over alphabet b.

    By the pigeonhole principle, at least b^n - geom_sum(b, n)
    strings of length n cannot be injectively mapped to shorter strings.
    """
    return b ** n - geometric_sum(b, n)


def search_candidates_lower_bound(b: int, n: int, k: int) -> int:
    """
    Lower bound on search candidates when valid proofs ≤ b^k in space b^n.

    Returns b^(n - k - 1), the minimum number of candidates to examine.
    """
    assert b >= 2, "Alphabet size must be ≥ 2"
    assert k + 1 <= n, "Need k + 1 ≤ n"
    return b ** (n - k - 1)


def classify_thermodynamic_class(
    proof_lengths: List[int],
    statement_lengths: List[int]
) -> str:
    """
    Classify a proof system's thermodynamic complexity class.

    Given empirical (statement_length, proof_length) pairs, determine
    whether the system is linear, polynomial, or exponential.
    """
    if not proof_lengths or not statement_lengths:
        return "unknown"

    # Check if linear: proof_len ≤ c * statement_len for some constant c
    max_ratio = max(p / s for p, s in zip(proof_lengths, statement_lengths) if s > 0)

    # Check if polynomial: proof_len ≤ statement_len^d for some d
    max_degree = max(
        math.log(p) / math.log(s) if s > 1 and p > 0 else 0
        for p, s in zip(proof_lengths, statement_lengths)
    )

    # Check if exponential: proof_len grows as 2^n
    log_ratios = [
        math.log2(p) / s if p > 0 and s > 0 else 0
        for p, s in zip(proof_lengths, statement_lengths)
    ]
    exp_ratio = max(log_ratios) if log_ratios else 0

    if max_ratio <= 10:
        return f"linear (c ≈ {max_ratio:.1f})"
    elif max_degree <= 5:
        return f"polynomial (d ≈ {max_degree:.1f})"
    else:
        return f"exponential (ratio ≈ {exp_ratio:.2f})"


def discovery_verification_gap(
    b: int, n: int, k: int, proof_len: int
) -> Tuple[float, float, float]:
    """
    Compute the discovery-verification thermodynamic gap.

    Returns: (search_energy, verification_energy, ratio)
    """
    search_cands = search_candidates_lower_bound(b, n, k)
    kT_ln2 = K_BOLTZMANN * 300 * LN2  # at room temperature

    search_energy = search_cands * kT_ln2
    verify_energy = proof_len * kT_ln2
    ratio = search_cands / proof_len if proof_len > 0 else float('inf')

    return search_energy, verify_energy, ratio


def average_proof_length_bound(b: int, num_theorems: int) -> int:
    """
    Lower bound on average proof length for distinct theorems.

    If num_theorems theorems each have distinct proofs over alphabet b,
    the maximum proof length is at least ⌈log_b(num_theorems)⌉.
    """
    if num_theorems <= 1:
        return 0
    return math.ceil(math.log(num_theorems) / math.log(b))


def exp_strictly_larger_threshold(c: int) -> int:
    """
    Find the threshold n where c * n < 2^n is guaranteed.

    Returns 2*c + 2, the formal threshold from the theorem.
    """
    return 2 * c + 2


def proof_cost_hierarchy(
    system: ProofThermodynamicSystem, max_level: int
) -> List[Tuple[int, float, float]]:
    """
    Compute the proof cost hierarchy up to max_level.

    Returns list of (level, cost, gap_from_previous).
    """
    result: List[Tuple[int, float, float]] = []
    for k in range(max_level + 1):
        cost = system.proof_cost(k)
        gap = system.landauer_unit if k > 0 else 0.0
        result.append((k, cost, gap))
    return result


if __name__ == "__main__":
    # Quick self-test
    system = ProofThermodynamicSystem(
        alphabet_size=2,
        max_proof_len=20,
        temperature=300,
        valid_count=1000
    )

    print(f"Landauer unit: {system.landauer_unit:.4e} J")
    print(f"Proof cost (len=10): {system.proof_cost(10):.4e} J")
    print(f"Search difficulty: {system.search_difficulty}")
    print(f"Incompressible count (b=2, n=10): {incompressible_count(2, 10)}")
    print(f"Avg proof length bound (b=2, T=1024): {average_proof_length_bound(2, 1024)}")

    hierarchy = proof_cost_hierarchy(system, 5)
    print("\nHierarchy:")
    for level, cost, gap in hierarchy:
        print(f"  Level {level}: cost={cost:.4e} J, gap={gap:.4e} J")
