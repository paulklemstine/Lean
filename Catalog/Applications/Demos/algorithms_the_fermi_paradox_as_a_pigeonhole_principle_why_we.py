#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the Cascade Filter framework.

Type-hinted implementations of the mathematical structures and algorithms
developed in the Lean 4 formalization.
"""

from __future__ import annotations
from dataclasses import dataclass
import math


@dataclass
class CascadeFilter:
    """A cascade filter with n independent probability-reducing stages.
    
    Attributes:
        stage_probs: List of per-stage probabilities in [0, 1].
        base_population: The initial population / base rate.
    """
    stage_probs: list[float]
    base_population: float

    def __post_init__(self) -> None:
        for i, p in enumerate(self.stage_probs):
            if not (0.0 <= p <= 1.0):
                raise ValueError(f"Stage {i} probability {p} not in [0, 1]")
        if self.base_population < 0:
            raise ValueError(f"Base population {self.base_population} is negative")

    @property
    def stages(self) -> int:
        """Number of filter stages."""
        return len(self.stage_probs)

    def throughput(self) -> float:
        """Product of all stage probabilities (Lean: CascadeFilter.throughput)."""
        result = 1.0
        for p in self.stage_probs:
            result *= p
        return result

    def expected_survivors(self) -> float:
        """Expected survivors = base × throughput (Lean: CascadeFilter.expectedSurvivors)."""
        return self.base_population * self.throughput()

    def cofactor(self, i: int) -> float:
        """Product of all probabilities except stage i (Lean: CascadeFilter.cofactor)."""
        result = 1.0
        for j, p in enumerate(self.stage_probs):
            if j != i:
                result *= p
        return result

    def bottleneck_index(self) -> int:
        """Index of the stage with smallest probability (the bottleneck).
        
        By the bottleneck_dominates theorem, this stage has the highest
        cofactor and thus the highest absolute sensitivity.
        """
        return min(range(self.stages), key=lambda i: self.stage_probs[i])

    def sensitivity_ranking(self) -> list[tuple[int, float, float]]:
        """Return stages sorted by sensitivity (cofactor), highest first.
        
        Returns list of (stage_index, probability, cofactor).
        """
        data = [(i, self.stage_probs[i], self.cofactor(i)) for i in range(self.stages)]
        data.sort(key=lambda x: -x[2])  # Sort by cofactor descending
        return data

    def silence_threshold(self) -> float | None:
        """If all stages have same probability p, return the critical p
        such that expected_survivors = 1. Returns None for non-uniform filters."""
        if self.stages == 0 or self.base_population <= 0:
            return None
        # B * p^n = 1 => p = B^(-1/n)
        return self.base_population ** (-1.0 / self.stages)

    @staticmethod
    def uniform(n_stages: int, p: float, base_population: float) -> CascadeFilter:
        """Create a uniform cascade filter (all stages have same probability)."""
        return CascadeFilter([p] * n_stages, base_population)

    @staticmethod
    def critical_stage_count(p: float, base_population: float) -> int:
        """Minimum number of stages for silence (E[survivors] < 1).
        
        n* = ceil(log(B) / log(1/p))
        """
        if p <= 0 or p >= 1 or base_population <= 1:
            return 0
        return math.ceil(math.log(base_population) / math.log(1 / p))


@dataclass
class DrakeParams:
    """Parameters for the Drake equation."""
    star_formation: float = 1.5
    fraction_planets: float = 0.5
    habitable_planets: float = 0.01
    fraction_life: float = 0.01
    fraction_intelligence: float = 0.01
    fraction_technology: float = 0.01
    civilization_lifetime: float = 100.0

    def drake_n(self) -> float:
        """Expected number of detectable civilizations."""
        return (self.star_formation * self.fraction_planets *
                self.habitable_planets * self.fraction_life *
                self.fraction_intelligence * self.fraction_technology *
                self.civilization_lifetime)

    def to_cascade_filter(self) -> CascadeFilter:
        """Convert to a CascadeFilter representation.
        
        The non-probability factors (star_formation, civilization_lifetime)
        are absorbed into the base_population.
        """
        return CascadeFilter(
            stage_probs=[
                self.fraction_planets,
                self.habitable_planets,
                self.fraction_life,
                self.fraction_intelligence,
                self.fraction_technology,
            ],
            base_population=self.star_formation * self.civilization_lifetime
        )


def birthday_collision_probability(k: int, n: int) -> float:
    """Probability that k items in n slots have at least one collision.
    
    Uses the exact formula: P(collision) = 1 - n!/(n^k * (n-k)!)
    Related to Lean theorem: injection_count
    """
    if k > n:
        return 1.0
    if k <= 1:
        return 0.0
    # Compute P(no collision) = prod_{i=0}^{k-1} (1 - i/n)
    p_no_collision = 1.0
    for i in range(k):
        p_no_collision *= (1.0 - i / n)
    return 1.0 - p_no_collision


def descending_factorial(n: int, k: int) -> int:
    """n * (n-1) * ... * (n-k+1)"""
    result = 1
    for i in range(k):
        result *= (n - i)
    return result


# ──────────────────────────────────────────────────────────
# Monte Carlo silence estimator
# ──────────────────────────────────────────────────────────
def monte_carlo_silence_probability(
    n_factors: int = 7,
    log_min: float = -6.0,
    log_max: float = 0.0,
    base_rate: float = 1.5e10,
    n_samples: int = 100_000,
    seed: int = 42,
) -> float:
    """Estimate P(N < 1) when each Drake factor is log-uniform on [10^log_min, 10^log_max].
    
    Tests the conjecture that silence is the generic outcome for uncertain Drake parameters.
    """
    import random
    rng = random.Random(seed)
    n_silence = 0
    for _ in range(n_samples):
        throughput = 1.0
        for _ in range(n_factors):
            throughput *= 10 ** rng.uniform(log_min, log_max)
        if base_rate * throughput < 1:
            n_silence += 1
    return n_silence / n_samples


if __name__ == "__main__":
    # Demo: Pessimistic Drake
    drake = DrakeParams()
    print(f"Pessimistic Drake N = {drake.drake_n():.2e}")

    # Demo: Cascade filter
    cf = drake.to_cascade_filter()
    print(f"Cascade throughput = {cf.throughput():.2e}")
    print(f"Expected survivors = {cf.expected_survivors():.2e}")
    print(f"Bottleneck: stage {cf.bottleneck_index()}")

    # Demo: Critical stage count
    n_star = CascadeFilter.critical_stage_count(0.1, 1e22)
    print(f"Critical stages for B=10^22, p=0.1: n* = {n_star}")

    # Demo: Monte Carlo
    p_silence = monte_carlo_silence_probability()
    print(f"Monte Carlo P(silence): {p_silence:.4f}")
