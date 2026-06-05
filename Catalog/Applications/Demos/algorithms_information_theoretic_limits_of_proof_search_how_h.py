"""
Information-Theoretic Limits of Proof Search: Algorithms

Implements the core algorithms and structures from the formal theory:
- SearchDensityFunction
- ProofEntropyProfile
- Search difficulty computation
- Entropy gap analysis
- Phase transition detection
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from typing import Callable, List, Tuple, Optional


@dataclass
class SearchDensityFunction:
    """Models how provable theorem density evolves with proof length.

    Attributes:
        b: Alphabet size (≥ 2)
        total_theorems: Total number of theorem statements
        provable_within: Function mapping proof length n to number of provable theorems
    """
    b: int
    total_theorems: int
    provable_within: Callable[[int], int]

    def __post_init__(self) -> None:
        assert self.b >= 2, "Alphabet size must be ≥ 2"
        assert self.total_theorems > 0, "Must have at least one theorem"

    def search_space(self, n: int) -> int:
        """Total number of candidate proofs of length n."""
        return self.b ** n

    def entropy_gap(self, n: int) -> int:
        """Excess proof space capacity at length n."""
        return self.search_space(n) - self.provable_within(n)

    def search_difficulty(self, n: int) -> float:
        """Expected candidates to examine at length n."""
        p = self.provable_within(n)
        return self.search_space(n) / (p + 1)

    def unprovable_count(self, n: int) -> int:
        """Theorems not provable at length n."""
        return self.total_theorems - self.provable_within(n)

    def density(self, n: int) -> float:
        """Fraction of search space that contains valid proofs."""
        ss = self.search_space(n)
        return self.provable_within(n) / ss if ss > 0 else 0.0

    def find_critical_length(self, max_n: int = 100) -> Optional[int]:
        """Find smallest n where provable_within(n) >= total_theorems."""
        for n in range(max_n + 1):
            if self.provable_within(n) >= self.total_theorems:
                return n
        return None

    def information_content(self, n: int) -> float:
        """Information content: -log2(density) at length n."""
        d = self.density(n)
        return -math.log2(d) if d > 0 else float('inf')


@dataclass
class ProofEntropyProfile:
    """Captures the information-theoretic signature of a proof system.

    Attributes:
        sdf: The underlying SearchDensityFunction
        entropy_rate: Function mapping proof length n to entropy rate
    """
    sdf: SearchDensityFunction
    entropy_rate: Callable[[int], int]

    def cumulative_entropy(self, n: int) -> int:
        """Total information content up to length n."""
        return sum(self.entropy_rate(k) for k in range(n))

    def structure_gap(self, n: int) -> int:
        """How much structure reduces entropy below maximum."""
        return n - self.entropy_rate(n)


def brute_force_search(
    b: int, n: int, verify: Callable[[List[int]], bool]
) -> Tuple[Optional[List[int]], int]:
    """Brute-force proof search over all strings of length n.

    Args:
        b: Alphabet size
        n: Proof length
        verify: Function that checks if a candidate is a valid proof

    Returns:
        (proof, steps): The proof found (or None) and number of steps taken
    """
    steps = 0
    candidate = [0] * n

    for _ in range(b ** n):
        steps += 1
        if verify(candidate):
            return candidate, steps
        # Increment candidate (base-b counter)
        carry = 1
        for i in range(n - 1, -1, -1):
            candidate[i] += carry
            if candidate[i] >= b:
                candidate[i] = 0
                carry = 1
            else:
                carry = 0
                break

    return None, steps


def compute_search_bounds(b: int, n: int, k: int) -> dict:
    """Compute information-theoretic search bounds.

    Args:
        b: Alphabet size
        n: Proof length (search space parameter)
        k: Provability parameter (valid proofs ≤ b^k)

    Returns:
        Dictionary with computed bounds
    """
    assert b >= 2
    assert k + 1 <= n

    search_space = b ** n
    max_valid = b ** k
    lower_bound = b ** (n - k - 1)
    difficulty = search_space // (max_valid + 1)

    return {
        "search_space": search_space,
        "max_valid_proofs": max_valid,
        "search_difficulty_lower_bound": lower_bound,
        "actual_difficulty": difficulty,
        "information_gap_bits": (n - k) * math.log2(b),
        "incompressible_fraction": (b - 1) / b,
    }


def detect_phase_transition(sdf: SearchDensityFunction, max_n: int = 50) -> dict:
    """Detect the phase transition in proof search.

    Returns information about where the system transitions from
    'not enough capacity' to 'enough capacity but hard to search'.
    """
    critical_n = None
    for n in range(max_n + 1):
        if sdf.search_space(n) >= sdf.total_theorems:
            critical_n = n
            break

    densities = []
    difficulties = []
    gaps = []

    for n in range(min(max_n + 1, 30)):
        densities.append((n, sdf.density(n)))
        difficulties.append((n, sdf.search_difficulty(n)))
        gaps.append((n, sdf.entropy_gap(n)))

    return {
        "critical_length": critical_n,
        "densities": densities,
        "difficulties": difficulties,
        "entropy_gaps": gaps,
        "total_theorems": sdf.total_theorems,
        "alphabet_size": sdf.b,
    }


def composition_cost(b: int, m: int, n: int) -> dict:
    """Compute costs for composing two proof obligations.

    Args:
        b: Alphabet size
        m: Proof length for obligation 1
        n: Proof length for obligation 2

    Returns:
        Dictionary with individual and composed costs
    """
    cost_1 = b ** m
    cost_2 = b ** n
    composed = b ** (m + n)
    sum_costs = cost_1 + cost_2

    return {
        "cost_1": cost_1,
        "cost_2": cost_2,
        "composed_cost": composed,
        "sum_of_costs": sum_costs,
        "superadditivity_factor": composed / sum_costs if sum_costs > 0 else float('inf'),
        "multiplicative_factor": composed / (cost_1 * cost_2) if cost_1 * cost_2 > 0 else 0,
    }


def log_factor_test(statement_lengths: List[int], proof_lengths: List[int]) -> dict:
    """Test the log-factor growth conjecture.

    Computes p / (s * log2(s)) for each (s, p) pair and reports statistics.
    """
    ratios = []
    for s, p in zip(statement_lengths, proof_lengths):
        if s >= 4:
            log_s = math.log2(s)
            ratio = p / (s * log_s)
            ratios.append(ratio)

    if not ratios:
        return {"error": "No valid data points (need s >= 4)"}

    mean_ratio = sum(ratios) / len(ratios)
    variance = sum((r - mean_ratio) ** 2 for r in ratios) / len(ratios)

    return {
        "num_points": len(ratios),
        "mean_ratio": mean_ratio,
        "std_ratio": math.sqrt(variance),
        "min_ratio": min(ratios),
        "max_ratio": max(ratios),
        "conjecture_support": 0.5 <= mean_ratio <= 10,
    }


if __name__ == "__main__":
    # Example: binary proof system with 1000 theorems
    sdf = SearchDensityFunction(
        b=2,
        total_theorems=1000,
        provable_within=lambda n: min(2 ** n - 1, 1000)
    )

    print("=== Search Density Function Demo ===")
    for n in range(1, 15):
        print(f"n={n:2d}: provable={sdf.provable_within(n):5d}, "
              f"space={sdf.search_space(n):10d}, "
              f"density={sdf.density(n):.6f}, "
              f"difficulty={sdf.search_difficulty(n):.1f}")

    print(f"\nCritical length: {sdf.find_critical_length()}")

    print("\n=== Information-Theoretic Bounds ===")
    bounds = compute_search_bounds(b=2, n=20, k=10)
    for key, val in bounds.items():
        print(f"  {key}: {val}")

    print("\n=== Phase Transition ===")
    pt = detect_phase_transition(sdf)
    print(f"  Critical length: {pt['critical_length']}")

    print("\n=== Composition Costs ===")
    comp = composition_cost(b=2, m=5, n=5)
    for key, val in comp.items():
        print(f"  {key}: {val}")
