#!/usr/bin/env python3
"""
Algorithms for the Entropy-Bounded Computation framework.

Type-hinted implementations of the core computational structures
and algorithms, including entropy budget tracking, Maxwell's demon
simulation, and entropy-optimal search.
"""

import math
from dataclasses import dataclass
from typing import List, Optional, Callable, TypeVar, Generic

T = TypeVar('T')

# Physical constants
K_BOLTZMANN: float = 1.380649e-23  # J/K
PLANCK_REDUCED: float = 1.054571817e-34  # J·s


@dataclass
class LandauerCost:
    """Represents the Landauer cost of an operation in units of kT·ln(2)."""
    bits_erased: float

    def joules(self, temperature: float = 300.0) -> float:
        """Convert to Joules at given temperature."""
        return self.bits_erased * K_BOLTZMANN * temperature * math.log(2)

    def __add__(self, other: 'LandauerCost') -> 'LandauerCost':
        return LandauerCost(self.bits_erased + other.bits_erased)


@dataclass
class EntropyBudgetSystem:
    """
    Models a computational system with a finite entropy budget.

    Each step has a non-negative entropy cost, and the total cost
    must not exceed the budget.
    """
    step_costs: List[float]  # Cost per step in bits
    budget: float  # Total budget in bits

    def __post_init__(self) -> None:
        assert all(c >= 0 for c in self.step_costs), "All costs must be non-negative"
        assert self.budget > 0, "Budget must be positive"
        assert sum(self.step_costs) <= self.budget, "Total cost exceeds budget"

    @property
    def num_steps(self) -> int:
        return len(self.step_costs)

    @property
    def total_cost(self) -> float:
        return sum(self.step_costs)

    def remaining_budget(self) -> float:
        return self.budget - self.total_cost

    def can_add_step(self, cost: float) -> bool:
        return cost >= 0 and self.total_cost + cost <= self.budget

    @staticmethod
    def max_steps(budget: float, min_cost_per_step: float) -> int:
        """Maximum number of steps given budget and minimum per-step cost."""
        assert min_cost_per_step > 0
        return int(budget / min_cost_per_step)


@dataclass
class MaxwellDemon:
    """
    Models Maxwell's demon with Landauer constraints.

    The demon observes particles, gaining information, and uses that
    information to sort particles. The entropy decrease is bounded by
    the information cost times kT·ln(2).
    """
    num_particles: int
    info_bits_per_particle: float
    entropy_decrease_per_particle: float
    temperature: float  # Kelvin

    def __post_init__(self) -> None:
        assert self.temperature > 0
        assert self.info_bits_per_particle >= 0
        kT_ln2 = K_BOLTZMANN * self.temperature * math.log(2)
        assert self.entropy_decrease_per_particle <= (
            self.info_bits_per_particle * kT_ln2
        ), "Landauer constraint violated"

    @property
    def total_info(self) -> float:
        return self.num_particles * self.info_bits_per_particle

    @property
    def total_entropy_decrease(self) -> float:
        return self.num_particles * self.entropy_decrease_per_particle

    @property
    def kT_ln2(self) -> float:
        return K_BOLTZMANN * self.temperature * math.log(2)

    def efficiency(self) -> float:
        """Ratio of actual entropy decrease to Landauer limit."""
        limit = self.total_info * self.kT_ln2
        if limit == 0:
            return 0.0
        return self.total_entropy_decrease / limit


class EntropyOptimalSearch(Generic[T]):
    """
    Search algorithm that minimizes entropy production.

    Uses binary search to find an element, tracking Landauer cost
    of each comparison.
    """

    def __init__(self, candidates: List[T], budget_bits: float,
                 temperature: float = 300.0):
        self.candidates = candidates
        self.budget_bits = budget_bits
        self.temperature = temperature
        self.bits_used: float = 0.0
        self.comparisons: int = 0

    def search(self, predicate: Callable[[T], bool]) -> Optional[T]:
        """
        Binary search using predicate, tracking entropy cost.

        Each comparison costs 1 bit of entropy.
        Returns None if budget exhausted before finding result.
        """
        lo, hi = 0, len(self.candidates) - 1

        while lo <= hi:
            if self.bits_used + 1 > self.budget_bits:
                return None  # Budget exhausted

            mid = (lo + hi) // 2
            self.bits_used += 1  # Each comparison costs 1 bit
            self.comparisons += 1

            if predicate(self.candidates[mid]):
                hi = mid - 1
            else:
                lo = mid + 1

        if lo < len(self.candidates):
            return self.candidates[lo]
        return None

    def entropy_used_joules(self) -> float:
        return self.bits_used * K_BOLTZMANN * self.temperature * math.log(2)

    def entropy_efficiency(self) -> float:
        """Fraction of budget used."""
        return self.bits_used / self.budget_bits if self.budget_bits > 0 else 0


def entropy_gap(c: float, n: int) -> float:
    """
    Compute the entropy gap c*n - c*log(n).

    This quantity grows without bound (Theorem 12),
    representing the thermodynamic signature of P ≠ NP.
    """
    if n <= 0:
        return 0.0
    return c * n - c * math.log(n)


def find_entropy_gap_witness(c: float, M: float) -> int:
    """
    Find the smallest n such that c*n - c*log(n) > M.

    This is the constructive version of the entropy gap theorem.
    """
    n = 1
    while entropy_gap(c, n) <= M:
        n += 1
        if n > 10**9:
            raise ValueError(f"No witness found below 10^9 for c={c}, M={M}")
    return n


def compute_sorting_landauer_cost(n: int) -> float:
    """
    Compute the minimum Landauer cost of comparison-based sorting.

    Returns the cost in bits: ceil(log2(n!)).
    """
    if n <= 1:
        return 0.0
    log2_factorial = sum(math.log2(i) for i in range(1, n + 1))
    return math.ceil(log2_factorial)


def reversible_computation_demo(n: int) -> bool:
    """
    Demonstrate that reversible computation has zero Landauer cost.

    Applies a permutation and its inverse, showing f(g(x)) = x for all x.
    """
    # A reversible computation: cyclic shift
    forward = [(i + 1) % n for i in range(n)]
    backward = [(i - 1) % n for i in range(n)]

    # Verify: forward(backward(x)) = x for all x
    for x in range(n):
        if forward[backward[x]] != x:
            return False
    # Verify: backward(forward(x)) = x for all x
    for x in range(n):
        if backward[forward[x]] != x:
            return False
    return True


if __name__ == "__main__":
    # Demo: entropy-optimal search
    candidates = list(range(1000))
    searcher = EntropyOptimalSearch(candidates, budget_bits=20)
    target = 42
    result = searcher.search(lambda x: x >= target)
    print(f"Search for {target} in [0..999]:")
    print(f"  Found: {result}")
    print(f"  Comparisons: {searcher.comparisons}")
    print(f"  Bits used: {searcher.bits_used}")
    print(f"  Theoretical minimum: {math.ceil(math.log2(1000))}")
    print(f"  Entropy used: {searcher.entropy_used_joules():.4e} J")

    # Demo: entropy gap witnesses
    print("\nEntropy gap witnesses (c=1):")
    for M in [10, 100, 1000]:
        n = find_entropy_gap_witness(1.0, M)
        print(f"  M={M}: smallest n = {n}, gap = {entropy_gap(1.0, n):.2f}")

    # Demo: sorting Landauer cost
    print("\nSorting Landauer cost (bits):")
    for n in [2, 4, 8, 16, 32, 64]:
        cost = compute_sorting_landauer_cost(n)
        print(f"  n={n:>2}: ceil(log2(n!)) = {cost:.0f} bits")

    # Demo: reversible computation
    print(f"\nReversible computation (n=10): {reversible_computation_demo(10)}")
