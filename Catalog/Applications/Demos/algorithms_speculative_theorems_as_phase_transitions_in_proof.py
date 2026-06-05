#!/usr/bin/env python3
"""
Algorithms for Phase Transitions in Proof Space

Type-hinted implementations of the key algorithms from the formalized theory.
"""

import math
from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class ProofSystem:
    """A formal proof system characterized by alphabet size and max proof length."""
    b: int  # alphabet size (≥ 2)
    k: int  # maximum proof length

    def __post_init__(self) -> None:
        assert self.b >= 2, f"Alphabet size must be ≥ 2, got {self.b}"
        assert self.k >= 0, f"Max proof length must be ≥ 0, got {self.k}"

    @property
    def proof_bound(self) -> int:
        """Upper bound on number of distinct proofs: b^(k+1)."""
        return self.b ** (self.k + 1)

    @property
    def critical_threshold(self) -> int:
        """Critical complexity threshold n_c = k + 1."""
        return self.k + 1

    def stmt_space(self, n: int) -> int:
        """Number of statements of length exactly n."""
        return self.b ** n

    def coverage_ratio(self, n: int) -> float:
        """Provability order parameter: proof_bound / stmt_space(n)."""
        return self.proof_bound / self.stmt_space(n) if n > 0 else float('inf')

    def entropy_gap(self, n: int) -> float:
        """Information-theoretic entropy gap in nats."""
        return max(0.0, (n - self.k - 1) * math.log(self.b))

    def hausdorff_dimension(self, n: int) -> float:
        """Proof space dimension (k+1)/n."""
        return (self.k + 1) / n if n > 0 else float('inf')

    def is_complete_phase(self, n: int) -> bool:
        """Whether complexity n is in the complete (ordered) phase."""
        return n <= self.critical_threshold

    def composite_proof_bound(self, m: int) -> int:
        """Effective proof bound with m levels of composition."""
        return self.b ** ((self.k + 1) * m)

    def composite_threshold(self, m: int) -> int:
        """Critical threshold with m composition levels."""
        return (self.k + 1) * m


def detect_phase_transition(system: ProofSystem,
                            n_range: range) -> Optional[int]:
    """
    Detect the phase transition point in the given range.

    Returns the first n where coverage_ratio drops below 1,
    or None if no transition occurs in the range.

    Algorithm: Linear scan with early termination.
    Complexity: O(|n_range|)
    """
    for n in n_range:
        if not system.is_complete_phase(n):
            return n
    return None


def compute_boltzmann_parameters(system: ProofSystem) -> Tuple[float, float]:
    """
    Compute the Boltzmann distribution parameters.

    Returns (beta, T) where:
    - beta = log(b) is the inverse temperature
    - T = 1/log(b) is the temperature

    The proof density at complexity n is:
        rho(n) = exp(-beta * (n - n_c))
    """
    beta = math.log(system.b)
    T = 1.0 / beta
    return beta, T


def proof_density_profile(system: ProofSystem,
                          n_max: int) -> List[Tuple[int, float]]:
    """
    Compute the proof density profile for n = 0, 1, ..., n_max.

    Returns list of (n, density) pairs where density = min(1, coverage_ratio(n)).

    Algorithm: Direct computation.
    Complexity: O(n_max)
    """
    profile: List[Tuple[int, float]] = []
    for n in range(n_max + 1):
        ratio = system.coverage_ratio(n)
        density = min(1.0, ratio)
        profile.append((n, density))
    return profile


def optimal_proof_search_budget(system: ProofSystem,
                                n: int,
                                verification_cost: int = 1) -> int:
    """
    Compute the optimal proof search budget for statements of complexity n.

    The budget is proportional to the entropy gap:
        budget = b^(n - n_c) * verification_cost

    This is the minimum number of proof candidates that must be examined
    to have a chance of finding a proof via brute-force search.
    """
    if system.is_complete_phase(n):
        return verification_cost  # One verification suffices in complete phase
    delta = n - system.critical_threshold
    return system.b ** delta * verification_cost


def phase_diagram(b_range: range,
                  k_range: range) -> List[Tuple[int, int, int]]:
    """
    Compute the phase diagram: critical threshold for each (b, k) pair.

    Returns list of (b, k, n_c) triples.
    """
    diagram: List[Tuple[int, int, int]] = []
    for b in b_range:
        for k in k_range:
            if b >= 2:
                system = ProofSystem(b=b, k=k)
                diagram.append((b, k, system.critical_threshold))
    return diagram


def incompleteness_certificate(system: ProofSystem,
                               n: int) -> Optional[Tuple[int, int, int]]:
    """
    Generate an incompleteness certificate for complexity n.

    If n > n_c, returns (proof_count, stmt_count, deficit) proving
    that at least `deficit` statements are unprovable.
    Returns None if n ≤ n_c (no incompleteness at this level).
    """
    if system.is_complete_phase(n):
        return None
    proof_count = system.proof_bound
    stmt_count = system.stmt_space(n)
    deficit = stmt_count - proof_count
    return (proof_count, stmt_count, deficit)


def composition_analysis(system: ProofSystem,
                         target_n: int,
                         max_levels: int = 20) -> Optional[int]:
    """
    Find the minimum number of composition levels needed to make
    complexity n reachable (i.e., to push n_c above target_n).

    Returns the minimum m such that (k+1)*m ≥ target_n, or None
    if max_levels is insufficient.
    """
    for m in range(1, max_levels + 1):
        if system.composite_threshold(m) >= target_n:
            return m
    return None


if __name__ == "__main__":
    # Example usage
    S = ProofSystem(b=2, k=10)
    print(f"Proof system: b={S.b}, k={S.k}")
    print(f"Critical threshold: n_c = {S.critical_threshold}")
    print(f"Proof bound: {S.proof_bound}")

    beta, T = compute_boltzmann_parameters(S)
    print(f"Boltzmann parameters: β={beta:.4f}, T={T:.4f}")

    transition = detect_phase_transition(S, range(1, 20))
    print(f"Phase transition detected at n = {transition}")

    cert = incompleteness_certificate(S, 15)
    if cert:
        proofs, stmts, deficit = cert
        print(f"Incompleteness at n=15: {proofs} proofs < {stmts} statements, deficit={deficit}")

    levels = composition_analysis(S, 100)
    print(f"Composition levels needed for n=100: m={levels}")
