#!/usr/bin/env python3
"""
Tropical-Probabilistic Bridge: Core Algorithms

Type-hinted implementations of the key algorithms connecting
the probabilistic method to tropical algebra.
"""

from typing import TypeVar, Callable, Optional, List, Set, Tuple
from dataclasses import dataclass
import math
import random

T = TypeVar('T')


# ============================================================
# Algorithm 1: Tropical Witness Search
# ============================================================

@dataclass
class TropicalCostWitness:
    """A tropical cost witness certifying that a zero-cost element exists."""
    universe: List[int]
    cost: Callable[[int], int]
    total_cost: int
    universe_size: int

    @property
    def is_valid(self) -> bool:
        """Check the first moment condition: sum < |universe|."""
        return self.total_cost < self.universe_size


def tropical_witness_search(
    universe: List[T],
    cost: Callable[[T], int]
) -> Optional[T]:
    """
    Search for a zero-cost element in the universe.

    By the Tropical Witness Theorem, if sum(cost(x) for x in universe) < len(universe),
    a zero-cost element is guaranteed to exist.

    Args:
        universe: Finite collection of candidate objects
        cost: Function mapping each object to its cost (number of violations)

    Returns:
        An element with cost 0, or None if no such element exists
    """
    for x in universe:
        if cost(x) == 0:
            return x
    return None


# ============================================================
# Algorithm 2: LLL Witness Checker
# ============================================================

@dataclass
class LLLConfig:
    """Configuration for an algebraic LLL argument."""
    n: int
    probs: List[float]
    witnesses: List[float]
    deps: List[Set[int]]

    def check_validity(self) -> bool:
        """Verify all LLL conditions hold."""
        for i in range(self.n):
            if not (0 < self.witnesses[i] < 1):
                return False
            if not (0 <= self.probs[i] < 1):
                return False
            product = self.witnesses[i]
            for j in self.deps[i]:
                product *= (1 - self.witnesses[j])
            if self.probs[i] > product:
                return False
        return True

    def product_bound(self) -> float:
        """Compute the LLL product bound: prod(1 - x_i)."""
        result = 1.0
        for i in range(self.n):
            result *= (1 - self.witnesses[i])
        return result

    def tropical_cost(self) -> float:
        """Compute the tropical (negative log) cost: -sum(log(1 - x_i))."""
        return sum(-math.log(1 - self.witnesses[i]) for i in range(self.n))


def lll_product_positivity(witnesses: List[float]) -> Tuple[bool, float]:
    """
    Check LLL product positivity: prod(1 - x_i) > 0 for x_i in (0,1).

    Args:
        witnesses: List of values in (0,1)

    Returns:
        (is_positive, product_value)
    """
    product = 1.0
    for x in witnesses:
        assert 0 < x < 1, f"Witness {x} not in (0,1)"
        product *= (1 - x)
    return product > 0, product


# ============================================================
# Algorithm 3: Moser-Tardos (Tropical Iteration)
# ============================================================

def moser_tardos_tropical(
    n_vars: int,
    events: List[Callable[[List[bool]], bool]],
    deps: List[Set[int]],
    max_iterations: int = 10000
) -> Optional[List[bool]]:
    """
    Moser-Tardos algorithm viewed as tropical fixed-point iteration.

    Each step resamples a violated event and its dependencies,
    corresponding to a tropical update in the dependency graph.

    Args:
        n_vars: Number of Boolean variables
        events: List of bad event predicates (True = bad)
        deps: Variable dependencies for each event
        max_iterations: Maximum resampling steps

    Returns:
        Assignment avoiding all bad events, or None if limit exceeded
    """
    # Initial random assignment
    assignment = [random.choice([True, False]) for _ in range(n_vars)]

    for iteration in range(max_iterations):
        # Find a violated event
        violated = None
        for i, event in enumerate(events):
            if event(assignment):
                violated = i
                break

        if violated is None:
            return assignment  # All events avoided - fixed point reached

        # Resample variables in the dependency set (tropical update)
        for var in deps[violated]:
            if var < n_vars:
                assignment[var] = random.choice([True, False])

    return None  # Did not converge


# ============================================================
# Algorithm 4: Tropical Deletion
# ============================================================

def tropical_deletion(
    universe: List[T],
    cost: Callable[[T], int],
    delta: int
) -> List[T]:
    """
    Tropical deletion method: find elements with cost ≤ delta.

    By the Tropical Deletion Bound, if sum(cost) <= delta * |universe|,
    at least one element has cost ≤ delta.

    Args:
        universe: Collection of objects
        cost: Cost function
        delta: Maximum acceptable cost

    Returns:
        List of elements with cost ≤ delta
    """
    return [x for x in universe if cost(x) <= delta]


# ============================================================
# Algorithm 5: MinPlus Moment Computation
# ============================================================

def minplus_moment(costs: List[int]) -> int:
    """
    Compute the min-plus moment (tropical expected value).

    This is simply the minimum of the cost function.
    The MinPlus-Arithmetic Duality says:
      sum(costs) < len(costs)  <=>  minplus_moment(costs) == 0

    Args:
        costs: List of non-negative integer costs

    Returns:
        The minimum cost (tropical expected value)
    """
    if not costs:
        return 0
    return min(costs)


def verify_minplus_duality(costs: List[int]) -> dict:
    """
    Verify the MinPlus-Arithmetic Duality for given costs.

    Returns a dictionary with the verification results.
    """
    n = len(costs)
    total = sum(costs)
    minimum = min(costs) if costs else 0

    return {
        "n": n,
        "sum": total,
        "min": minimum,
        "sum_lt_n": total < n,
        "min_eq_zero": minimum == 0,
        "forward_holds": (total < n) <= (minimum == 0),  # implication
        "reverse_holds": (minimum == 0) or (total >= n),  # contrapositive
    }


# ============================================================
# Algorithm 6: Ramsey Bound via Tropical Counting
# ============================================================

def erdos_ramsey_bound(k: int) -> int:
    """
    Compute the Erdős lower bound on R(k,k) using tropical counting.

    The bound: R(k,k) > n  if  2 * C(n,k) < 2^C(k,2).
    Equivalently, in tropical language:
      log2(2 * C(n,k)) < C(k,2)

    Args:
        k: Clique size (k >= 2)

    Returns:
        Largest n such that R(k,k) > n is certified
    """
    edges_in_clique = k * (k - 1) // 2
    threshold = 2 ** edges_in_clique

    best_n = 1
    for n in range(1, 10000):
        lhs = 2 * math.comb(n, k)
        if lhs < threshold:
            best_n = n
        else:
            break

    return best_n


# ============================================================
# Algorithm 7: Weighted First Moment
# ============================================================

def weighted_first_moment(
    weights: List[int],
    costs: List[int]
) -> Optional[int]:
    """
    Weighted first moment method: find a zero-cost element with positive weight.

    If sum(w_i * c_i) < sum(w_i), then there exists i with w_i > 0 and c_i = 0.

    Args:
        weights: Non-negative integer weights
        costs: Non-negative integer costs

    Returns:
        Index of a zero-cost element with positive weight, or None
    """
    assert len(weights) == len(costs)
    total_weight = sum(weights)
    weighted_cost = sum(w * c for w, c in zip(weights, costs))

    if weighted_cost >= total_weight:
        return None  # First moment condition not satisfied

    for i in range(len(weights)):
        if weights[i] > 0 and costs[i] == 0:
            return i

    return None  # Should not reach here if condition is satisfied


if __name__ == "__main__":
    # Quick test
    print("Ramsey bounds via tropical counting:")
    for k in range(3, 10):
        bound = erdos_ramsey_bound(k)
        print(f"  R({k},{k}) > {bound}  (≈ 2^({k}/2) = {2**(k/2):.1f})")

    print("\nLLL product positivity test:")
    witnesses = [0.1, 0.2, 0.3, 0.4, 0.5]
    is_pos, val = lll_product_positivity(witnesses)
    print(f"  witnesses = {witnesses}")
    print(f"  prod(1-x_i) = {val:.6f}, positive = {is_pos}")

    print("\nMinPlus-Arithmetic Duality:")
    costs = [0, 3, 1, 0, 2, 5, 0, 1]
    result = verify_minplus_duality(costs)
    print(f"  costs = {costs}")
    print(f"  {result}")
