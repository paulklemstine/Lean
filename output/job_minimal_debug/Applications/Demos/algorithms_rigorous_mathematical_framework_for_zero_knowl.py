#!/usr/bin/env python3
"""
Tropical Proof Complexity — Core Algorithms

Type-hinted implementations of the key algorithms from the tropical
proof complexity framework.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple


@dataclass
class ProofSystemParams:
    """Parameters of an interactive proof system."""
    soundness: float   # ε ∈ (0, 1)
    completeness: float  # c ∈ (0, 1]
    
    def __post_init__(self):
        assert 0 < self.soundness < 1, "Soundness must be in (0, 1)"
        assert 0 < self.completeness <= 1, "Completeness must be in (0, 1]"
    
    @property
    def tropical_cost(self) -> float:
        """Tropical verification cost: -log(ε)."""
        return -math.log(self.soundness)
    
    @property
    def completeness_gap(self) -> float:
        """Completeness gap: 1 - c."""
        return 1.0 - self.completeness


@dataclass
class TropicalVerificationSystem:
    """A verification system with tropical cost accounting."""
    rounds: int
    base_error: float
    barrier: float
    
    def __post_init__(self):
        assert self.rounds > 0
        assert 0 < self.base_error < 1
        assert self.barrier > 0
    
    @property
    def total_cost(self) -> float:
        """Total tropical cost = rounds × (-log base_error)."""
        return self.rounds * (-math.log(self.base_error))
    
    @property
    def is_secure(self) -> bool:
        """Whether the system meets its security barrier."""
        return self.barrier <= self.total_cost
    
    @property
    def residual_error(self) -> float:
        """Residual soundness error = base_error^rounds."""
        return self.base_error ** self.rounds


def parallel_repetition(params: ProofSystemParams, k: int) -> ProofSystemParams:
    """
    Construct the k-fold parallel repetition of a proof system.
    
    Soundness error: ε^k
    Completeness: c^k
    Tropical cost: k × (-log ε)
    
    Algorithm:
        1. Compute new soundness = ε^k
        2. Compute new completeness = c^k
        3. Return new ProofSystemParams
    
    Time: O(log k) via fast exponentiation
    """
    return ProofSystemParams(
        soundness=params.soundness ** k,
        completeness=params.completeness ** k
    )


def optimal_rounds(
    base_error: float, 
    target_security_bits: int
) -> int:
    """
    Compute minimum rounds for target security level.
    
    Algorithm:
        1. Convert security bits to tropical barrier: barrier = bits × ln(2)
        2. Compute cost per round: c = -log(base_error)
        3. Return ⌈barrier / c⌉
    
    Correctness: By Theorem 5, the system is secure iff
        rounds × (-log ε) ≥ barrier
    so minimum rounds = ⌈barrier / (-log ε)⌉.
    """
    barrier = target_security_bits * math.log(2)
    cost_per_round = -math.log(base_error)
    return math.ceil(barrier / cost_per_round)


def oracle_detection_probability(
    corruption_rate: float,
    num_queries: int
) -> float:
    """
    Compute detection probability for oracle verification.
    
    Algorithm:
        1. Miss probability = (1 - δ)^q
        2. Detection probability = 1 - miss probability
    
    Bound (Theorem 4): miss_prob ≤ exp(-δ × q)
    """
    miss_prob = (1 - corruption_rate) ** num_queries
    return 1.0 - miss_prob


def sequential_composition_error(
    errors: List[float]
) -> Tuple[float, float]:
    """
    Compute error bounds for sequential composition.
    
    Returns:
        (exact_error, union_bound)
    
    Algorithm:
        exact = 1 - ∏(1 - εᵢ)  (inclusion-exclusion)
        union = Σ εᵢ              (union bound)
    
    Theorem 3 guarantees: tropical_cost(exact) ≥ min(tropical_costs)
    """
    product = 1.0
    total = 0.0
    for e in errors:
        product *= (1 - e)
        total += e
    exact = 1.0 - product
    return exact, total


def tropical_cost_analysis(
    systems: List[ProofSystemParams]
) -> dict:
    """
    Analyze tropical costs of a collection of proof systems.
    
    Returns dictionary with:
        - individual_costs: list of -log(εᵢ) for each system
        - parallel_cost: sum of individual costs (parallel composition)
        - sequential_cost_bound: min of individual costs (sequential lower bound)
        - total_error_parallel: product of errors
        - total_error_sequential: inclusion-exclusion error
    """
    costs = [s.tropical_cost for s in systems]
    errors = [s.soundness for s in systems]
    
    parallel_error = 1.0
    for e in errors:
        parallel_error *= e
    
    seq_exact, seq_union = sequential_composition_error(errors)
    
    return {
        "individual_costs": costs,
        "parallel_cost": sum(costs),
        "sequential_cost_bound": min(costs),
        "total_error_parallel": parallel_error,
        "total_error_sequential_exact": seq_exact,
        "total_error_sequential_union": seq_union,
    }


def amplification_schedule(
    base_error: float,
    target_error: float,
    max_rounds: int = 1000
) -> List[Tuple[int, float, float]]:
    """
    Generate an amplification schedule showing error decay.
    
    Returns list of (round, error, tropical_cost) tuples.
    
    Algorithm:
        For k = 1, 2, ..., max_rounds:
            error_k = ε^k
            cost_k = k × (-log ε)
            Stop when error_k ≤ target
    """
    cost_per_round = -math.log(base_error)
    schedule = []
    
    for k in range(1, max_rounds + 1):
        error = base_error ** k
        cost = k * cost_per_round
        schedule.append((k, error, cost))
        if error <= target_error:
            break
    
    return schedule


if __name__ == "__main__":
    # Example usage
    print("=== Tropical Proof Complexity Algorithms ===\n")
    
    # Create proof systems
    sys1 = ProofSystemParams(soundness=0.5, completeness=1.0)
    sys2 = ProofSystemParams(soundness=0.3, completeness=0.9)
    sys3 = ProofSystemParams(soundness=0.1, completeness=0.95)
    
    print("Proof Systems:")
    for i, s in enumerate([sys1, sys2, sys3], 1):
        print(f"  System {i}: ε={s.soundness}, c={s.completeness}, "
              f"tropical_cost={s.tropical_cost:.4f}")
    
    # Tropical cost analysis
    analysis = tropical_cost_analysis([sys1, sys2, sys3])
    print(f"\nParallel composition cost: {analysis['parallel_cost']:.4f}")
    print(f"Sequential cost bound (min): {analysis['sequential_cost_bound']:.4f}")
    print(f"Parallel error: {analysis['total_error_parallel']:.6f}")
    print(f"Sequential error (exact): {analysis['total_error_sequential_exact']:.6f}")
    
    # Optimal rounds
    for bits in [80, 128, 256]:
        rounds = optimal_rounds(0.5, bits)
        print(f"\nFor {bits}-bit security with ε=0.5: {rounds} rounds needed")
    
    # Amplification schedule
    print("\nAmplification schedule (ε=0.4, target=1e-10):")
    schedule = amplification_schedule(0.4, 1e-10)
    for k, err, cost in schedule[-5:]:
        print(f"  Round {k}: error={err:.2e}, cost={cost:.2f}")
