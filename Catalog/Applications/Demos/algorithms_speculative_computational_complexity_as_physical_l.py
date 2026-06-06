#!/usr/bin/env python3
"""
Computational Thermodynamics Algorithms
========================================

Type-hinted implementations of the core algorithms from the CEA framework.
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from typing import Callable, List, Tuple, Set, Optional


@dataclass
class CEA:
    """Computational Entropy Automaton.

    A finite-state machine with a step budget and per-step entropy cost,
    modeling computation as a physical process with thermodynamic constraints.
    """
    n: int                          # State space size |σ|
    step: Callable[[int], int]      # Transition function σ → σ
    step_budget: int                # Maximum steps allowed
    entropy_cost: float             # Per-step Landauer cost (≥ 0)

    def __post_init__(self) -> None:
        assert self.n > 0, "State space must be nonempty"
        assert self.step_budget >= 0, "Budget must be nonneg"
        assert self.entropy_cost >= 0, "Entropy cost must be nonneg (Landauer bound)"

    def iterate(self, k: int, x: int) -> int:
        """Compute step^k(x)."""
        for _ in range(k):
            x = self.step(x)
        return x

    def total_entropy_cost(self, k: int) -> float:
        """Total entropy cost of k steps."""
        return k * self.entropy_cost

    def image_size(self, k: int) -> int:
        """Compute |step^k({0, ..., n-1})|."""
        return len({self.iterate(k, x) for x in range(self.n)})

    def is_reversible(self) -> bool:
        """Check if the step function is bijective (reversible)."""
        image = {self.step(x) for x in range(self.n)}
        return len(image) == self.n

    def is_erasing(self) -> bool:
        """Check if the step function is not injective (erasing)."""
        return not self.is_reversible()

    def fiber_card(self, y: int) -> int:
        """Compute |{x : step(x) = y}|."""
        return sum(1 for x in range(self.n) if self.step(x) == y)

    def max_fiber(self) -> int:
        """Maximum fiber cardinality (measures non-injectivity)."""
        return max(self.fiber_card(y) for y in range(self.n))

    def entropy_profile(self, max_steps: Optional[int] = None) -> List[Tuple[int, int, float]]:
        """Compute (step, image_size, entropy) for each step up to budget.

        Returns list of (k, |img(step^k)|, ln(|img(step^k)|)).
        """
        steps = max_steps or self.step_budget
        profile: List[Tuple[int, int, float]] = []
        for k in range(steps + 1):
            sz = self.image_size(k)
            ent = math.log(sz) if sz > 0 else 0.0
            profile.append((k, sz, ent))
        return profile

    def stabilization_point(self) -> int:
        """Find the step k₀ where image size stabilizes.

        By the antitone property, image sizes form a non-increasing
        sequence bounded below by 1, so stabilization is guaranteed
        within |σ| steps.
        """
        prev_size = self.n
        for k in range(1, self.n + 1):
            curr_size = self.image_size(k)
            if curr_size == prev_size:
                return k - 1
            prev_size = curr_size
        return self.n


@dataclass
class MaxwellDemon(CEA):
    """A Maxwell Demon: a CEA with a state classifier.

    The demon classifies states as 'hot' or 'cold' and attempts
    to sort them, reducing entropy.
    """
    is_hot: Callable[[int], bool] = lambda x: x % 2 == 0

    def hot_count(self) -> int:
        """Number of 'hot' states."""
        return sum(1 for x in range(self.n) if self.is_hot(x))

    def cold_count(self) -> int:
        """Number of 'cold' states."""
        return self.n - self.hot_count()

    def sorting_entropy_cost(self) -> float:
        """Minimum entropy cost to fully sort hot from cold.

        This is log(n!) - log(h!) - log(c!) where h = hot count, c = cold count.
        """
        h = self.hot_count()
        c = self.cold_count()
        if h == 0 or c == 0:
            return 0.0
        return (math.lgamma(self.n + 1) - math.lgamma(h + 1) - math.lgamma(c + 1))


def find_exp_dominance_threshold(d: int) -> int:
    """Find the smallest N such that n^d < 2^n for all n ≥ N.

    Implements the constructive content of exp_dominates_poly.
    """
    n = 1
    while n ** d >= 2 ** n:
        n += 1
    # Verify for a few more values
    for check in range(n, n + 100):
        assert check ** d < 2 ** check, f"Failed at n={check}"
    return n


def polynomial_hierarchy_capacity(n: int, d: int, c: float) -> float:
    """Compute the entropy capacity of a CEA with budget n^d and cost c.

    Capacity = n^d * c
    """
    return (n ** d) * c


def composition_bound(k1: int, c1: float, k2: int, c2: float) -> float:
    """Upper bound on total entropy cost of composing two CEAs.

    Returns (k1 + k2) * max(c1, c2).
    """
    return (k1 + k2) * max(c1, c2)


def entropy_rate(total_reduction: float, total_steps: int) -> float:
    """Average entropy reduction per step."""
    if total_steps == 0:
        return float('inf')
    return total_reduction / total_steps


# Pseudocode for the CEA simulation algorithm:
CEA_SIMULATION_PSEUDOCODE = """
Algorithm: CEA Entropy Profile Computation
Input: Transition function f, state space size n, max steps K
Output: Entropy profile [(k, |img(f^k)|, H(f^k))]

1. Initialize image ← {0, 1, ..., n-1}
2. For k = 0 to K:
   a. Compute image_k = f^k(image) = {f^k(x) : x ∈ {0,...,n-1}}
   b. Record (k, |image_k|, ln(|image_k|))
3. Return profile

Complexity: O(K × n) time, O(n) space
Correctness: By imageSize_antitone, |image_k| is non-increasing
"""

DOMINANCE_THRESHOLD_PSEUDOCODE = """
Algorithm: Exponential Dominance Threshold
Input: Polynomial degree d
Output: Threshold N such that n^d < 2^n for all n ≥ N

1. Set n ← 1
2. While n^d ≥ 2^n:
   a. n ← n + 1
3. Return n

Correctness: By exp_dominates_poly, this terminates.
The loop body runs at most O(d · 2^d) times.
"""


if __name__ == "__main__":
    # Example: non-injective CEA
    cea = CEA(n=16, step=lambda x: x // 2, step_budget=10, entropy_cost=0.5)
    print("CEA Profile (f(x) = x // 2):")
    for k, sz, ent in cea.entropy_profile(max_steps=6):
        print(f"  Step {k}: image={sz}, entropy={ent:.4f}")
    print(f"  Stabilization point: {cea.stabilization_point()}")
    print(f"  Max fiber: {cea.max_fiber()}")
    print(f"  Reversible: {cea.is_reversible()}")

    # Example: dominance thresholds
    print("\nExponential Dominance Thresholds:")
    for d in range(1, 8):
        N = find_exp_dominance_threshold(d)
        print(f"  d={d}: N={N} (2^{N} = {2**N} > {N}^{d} = {N**d})")
