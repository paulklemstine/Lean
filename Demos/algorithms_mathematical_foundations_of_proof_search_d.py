#!/usr/bin/env python3
"""
Proof Search Dimension — Algorithm Implementations

Type-hinted implementations of the core algorithms for computing
and estimating proof search dimension.
"""

import math
import random
from dataclasses import dataclass


@dataclass
class SearchParams:
    """Parameters for a uniform proof search tree."""
    surviving: int  # k: number of successful branches
    branching: int  # b: total branching factor

    def __post_init__(self) -> None:
        assert 1 <= self.surviving <= self.branching, (
            f"Need 1 ≤ k ≤ b, got k={self.surviving}, b={self.branching}"
        )
        assert 2 <= self.branching, f"Need b ≥ 2, got b={self.branching}"


@dataclass
class LevelParams:
    """Parameters for a single depth level in a heterogeneous tree."""
    surviving: int
    branching: int

    def __post_init__(self) -> None:
        assert 1 <= self.surviving <= self.branching and self.branching >= 2


def compute_search_dimension(params: SearchParams) -> float:
    """
    Compute the search dimension D = log(k) / log(b).

    Algorithm: Direct computation using natural logarithms.
    Time complexity: O(1)
    Space complexity: O(1)

    Returns a value in [0, 1].
    """
    if params.surviving == 1:
        return 0.0
    if params.surviving == params.branching:
        return 1.0
    return math.log(params.surviving) / math.log(params.branching)


def compute_entropy_deficit(params: SearchParams) -> float:
    """
    Compute the entropy deficit Δ = 1 - D.

    Measures the fraction of the search tree that leads to dead ends.
    """
    return 1.0 - compute_search_dimension(params)


def compute_het_search_dimension(levels: list[LevelParams]) -> float:
    """
    Compute the heterogeneous search dimension.

    D = Σ log(k_i) / Σ log(b_i)

    Algorithm: Single pass over the levels, accumulating sums.
    Time complexity: O(d) where d = len(levels)
    Space complexity: O(1)
    """
    assert len(levels) >= 1, "Need at least one level"
    log_k_sum = sum(math.log(level.surviving) for level in levels)
    log_b_sum = sum(math.log(level.branching) for level in levels)
    return log_k_sum / log_b_sum


def compute_product_params(p1: SearchParams, p2: SearchParams) -> SearchParams:
    """
    Compute the product search parameters.

    The product of (k₁, b₁) and (k₂, b₂) is (k₁·k₂, b₁·b₂).
    """
    return SearchParams(
        surviving=p1.surviving * p2.surviving,
        branching=p1.branching * p2.branching,
    )


def compute_success_probability(params: SearchParams, depth: int) -> float:
    """
    Compute the success probability P(d) = (k/b)^d.

    Time complexity: O(log d) using fast exponentiation.
    """
    return (params.surviving / params.branching) ** depth


def estimate_dimension_empirical(
    branching: int,
    oracle: callable,
    depth: int,
    num_trials: int,
) -> tuple[float, float]:
    """
    Estimate search dimension empirically from random search trials.

    Algorithm:
    1. Run num_trials random walks of the given depth.
    2. At each step, choose a random branch and query the oracle.
    3. Count successful walks.
    4. Estimate D = 1 + log(P̂) / (d · log(b)).

    Args:
        branching: branching factor b
        oracle: function (depth_level, branch_index) -> bool
        depth: search depth d
        num_trials: number of random walks N

    Returns:
        (estimated_dimension, standard_error)
    """
    successes = 0
    for _ in range(num_trials):
        success = True
        for level in range(depth):
            branch = random.randint(0, branching - 1)
            if not oracle(level, branch):
                success = False
                break
        if success:
            successes += 1

    p_hat = successes / num_trials
    if p_hat == 0:
        return 0.0, float('inf')
    if p_hat >= 1.0:
        return 1.0, 0.0

    D_hat = 1.0 + math.log(p_hat) / (depth * math.log(branching))
    # Standard error via delta method
    se_p = math.sqrt(p_hat * (1 - p_hat) / num_trials)
    se_D = se_p / (p_hat * depth * math.log(branching))

    return max(0.0, min(1.0, D_hat)), se_D


def classify_difficulty(params: SearchParams) -> str:
    """
    Classify the difficulty of a search problem based on its dimension.

    Returns one of:
    - "DETERMINISTIC" (D = 0, k = 1)
    - "VERY_HARD" (0 < D ≤ 0.2)
    - "HARD" (0.2 < D ≤ 0.5)
    - "MODERATE" (0.5 < D ≤ 0.8)
    - "EASY" (0.8 < D < 1)
    - "TRIVIAL" (D = 1, k = b)
    """
    D = compute_search_dimension(params)
    if D == 0.0:
        return "DETERMINISTIC"
    elif D <= 0.2:
        return "VERY_HARD"
    elif D <= 0.5:
        return "HARD"
    elif D <= 0.8:
        return "MODERATE"
    elif D < 1.0:
        return "EASY"
    else:
        return "TRIVIAL"


def optimal_search_budget(
    params: SearchParams,
    target_success_prob: float,
) -> int:
    """
    Compute the maximum depth for which the expected success probability
    exceeds the target.

    Uses: P(d) = (k/b)^d ≥ p_target
    => d ≤ log(p_target) / log(k/b)
    """
    if params.surviving == params.branching:
        return 10**9  # Trivial: always succeeds
    ratio = params.surviving / params.branching
    if ratio <= 0:
        return 0
    max_depth = math.log(target_success_prob) / math.log(ratio)
    return max(0, int(max_depth))


if __name__ == "__main__":
    # Quick self-test
    T = SearchParams(3, 10)
    D = compute_search_dimension(T)
    print(f"SearchParams(3, 10): D = {D:.6f}")
    print(f"  Deficit = {compute_entropy_deficit(T):.6f}")
    print(f"  Difficulty = {classify_difficulty(T)}")
    print(f"  P(depth=5) = {compute_success_probability(T, 5):.6e}")
    print(f"  Max depth for P ≥ 0.01 = {optimal_search_budget(T, 0.01)}")

    # Heterogeneous
    levels = [LevelParams(2, 5), LevelParams(3, 8), LevelParams(1, 4)]
    D_het = compute_het_search_dimension(levels)
    print(f"\nHeterogeneous tree: D = {D_het:.6f}")

    # Empirical estimation
    T_true = SearchParams(4, 10)
    D_true = compute_search_dimension(T_true)

    def oracle(level: int, branch: int) -> bool:
        return branch < T_true.surviving

    D_est, se = estimate_dimension_empirical(
        T_true.branching, oracle, depth=5, num_trials=10000
    )
    print(f"\nEmpirical estimation: D_true = {D_true:.4f}, "
          f"D_est = {D_est:.4f} ± {se:.4f}")
