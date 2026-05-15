#!/usr/bin/env python3
"""
Bottleneck Upgrade Algorithms

Implements the algorithms from the research paper:
1. ComputeBottleneckSet — O(n) bottleneck identification
2. GreedyBottleneckUpgrade — iterative upgrade to target throughput
3. OptimalBudgetAllocation — maximize min-capacity under budget constraint
4. CompareStrategies — empirical comparison of upgrade strategies
"""

from typing import List, Set, Dict, Tuple, Optional
from dataclasses import dataclass
import heapq


def compute_bottleneck_set(capacities: List[int]) -> Set[int]:
    """
    Identify the bottleneck set: all indices achieving the minimum capacity.

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        capacities: List of non-negative integer capacities.

    Returns:
        Set of indices where capacity equals the minimum.

    >>> compute_bottleneck_set([8, 5, 12, 5, 9])
    {1, 3}
    >>> compute_bottleneck_set([3, 3, 3])
    {0, 1, 2}
    """
    if not capacities:
        return set()
    m = min(capacities)
    return {i for i, c in enumerate(capacities) if c == m}


def greedy_bottleneck_upgrade(
    capacities: List[int],
    target: int,
    max_rounds: Optional[int] = None
) -> Tuple[List[int], int, List[List[int]]]:
    """
    Greedy upgrade strategy: repeatedly upgrade bottleneck set by 1.

    Guaranteed to increase throughput by exactly 1 per round (when gap
    condition holds), reaching target in at most (target - min) rounds.

    Time complexity: O(n * (target - min(capacities)))
    Space complexity: O(n * rounds) for history

    Args:
        capacities: Initial capacity list.
        target: Target throughput.
        max_rounds: Optional limit on number of rounds.

    Returns:
        Tuple of (final_capacities, rounds_used, history).

    >>> caps, rounds, _ = greedy_bottleneck_upgrade([3, 7, 5], 6)
    >>> min(caps) >= 6
    True
    """
    current = capacities[:]
    history = [current[:]]
    rounds = 0

    while min(current) < target:
        if max_rounds is not None and rounds >= max_rounds:
            break
        B = compute_bottleneck_set(current)
        current = [c + (1 if i in B else 0) for i, c in enumerate(current)]
        history.append(current[:])
        rounds += 1

    return current, rounds, history


def optimal_budget_allocation(
    capacities: List[int],
    budget: int
) -> Tuple[List[int], List[int]]:
    """
    Optimally allocate a fixed budget to maximize minimum throughput.

    Implements Algorithm 3 from the research paper: sort by capacity,
    then level up from the bottom, distributing budget greedily.

    Time complexity: O(n log n)
    Space complexity: O(n)

    Args:
        capacities: Initial capacity list.
        budget: Total number of upgrade units available.

    Returns:
        Tuple of (allocation, final_capacities) where allocation[i]
        is the number of upgrade units assigned to component i.

    >>> alloc, final = optimal_budget_allocation([3, 7, 5, 3, 9], 10)
    >>> min(final)
    5
    """
    n = len(capacities)
    if n == 0:
        return [], []

    # Sort indices by capacity
    sorted_indices = sorted(range(n), key=lambda i: capacities[i])
    sorted_caps = [capacities[i] for i in sorted_indices]

    allocation = [0] * n
    remaining = budget

    for i in range(n - 1):
        if remaining <= 0:
            break
        gap = sorted_caps[i + 1] - sorted_caps[i]
        count = i + 1  # number of components at or below current level
        needed = count * gap

        if needed <= remaining:
            remaining -= needed
            for j in range(count):
                allocation[sorted_indices[j]] += gap
                sorted_caps[j] = sorted_caps[i + 1]
        else:
            uniform = remaining // count
            remainder = remaining % count
            for j in range(count):
                extra = 1 if j < remainder else 0
                allocation[sorted_indices[j]] += uniform + extra
            remaining = 0
            break

    # Distribute any remaining budget across all components
    if remaining > 0:
        uniform = remaining // n
        remainder = remaining % n
        for j in range(n):
            extra = 1 if j < remainder else 0
            allocation[sorted_indices[j]] += uniform + extra

    final = [c + a for c, a in zip(capacities, allocation)]
    return allocation, final


@dataclass
class UpgradeResult:
    """Result of an upgrade strategy comparison."""
    strategy_name: str
    upgrade_set: Set[int]
    new_capacities: List[int]
    new_throughput: int
    improvement: int


def compare_strategies(
    capacities: List[int],
    k: Optional[int] = None
) -> List[UpgradeResult]:
    """
    Compare bottleneck upgrade against alternatives of equal size.

    Args:
        capacities: Initial capacity list.
        k: Number of components to upgrade (default: bottleneck set size).

    Returns:
        List of UpgradeResult for each strategy tried.
    """
    from itertools import combinations

    B = compute_bottleneck_set(capacities)
    if k is None:
        k = len(B)
    m = min(capacities)
    n = len(capacities)

    results = []

    # Bottleneck strategy
    bn_caps = [c + (1 if i in B else 0) for i, c in enumerate(capacities)]
    results.append(UpgradeResult(
        strategy_name="Bottleneck-first",
        upgrade_set=B,
        new_capacities=bn_caps,
        new_throughput=min(bn_caps),
        improvement=min(bn_caps) - m
    ))

    # All alternative strategies
    for u_tuple in combinations(range(n), k):
        u = set(u_tuple)
        if u == B:
            continue
        new_caps = [c + (1 if i in u else 0) for i, c in enumerate(capacities)]
        results.append(UpgradeResult(
            strategy_name=f"Upgrade {u}",
            upgrade_set=u,
            new_capacities=new_caps,
            new_throughput=min(new_caps),
            improvement=min(new_caps) - m
        ))

    return sorted(results, key=lambda r: -r.new_throughput)


def verify_theorem(capacities: List[int], verbose: bool = True) -> bool:
    """
    Verify both theorems (exact improvement and optimality) on a concrete instance.

    Returns True if both theorems hold.
    """
    B = compute_bottleneck_set(capacities)
    m = min(capacities)
    n = len(capacities)

    # Check gap condition
    gap_holds = all(c >= m + 1 for i, c in enumerate(capacities) if i not in B)

    # Test exact improvement
    new_caps = [c + (1 if i in B else 0) for i, c in enumerate(capacities)]
    new_min = min(new_caps)
    exact_ok = (not gap_holds) or (new_min == m + 1)

    # Test optimality
    from itertools import combinations
    k = len(B)
    bn_throughput = new_min
    optimal_ok = True
    for u_tuple in combinations(range(n), k):
        u = set(u_tuple)
        alt_caps = [c + (1 if i in u else 0) for i, c in enumerate(capacities)]
        if min(alt_caps) > bn_throughput:
            optimal_ok = False
            break

    if verbose:
        print(f"Capacities: {capacities}")
        print(f"  Bottleneck: {B}, min = {m}")
        print(f"  Gap condition: {gap_holds}")
        print(f"  Exact improvement: {'✓' if exact_ok else '✗'} (new min = {new_min})")
        print(f"  Optimality: {'✓' if optimal_ok else '✗'}")

    return exact_ok and optimal_ok


if __name__ == "__main__":
    import random

    print("=== Algorithm Demonstrations ===\n")

    # Demo 1: Bottleneck identification
    caps = [15, 12, 18, 12, 20, 15, 12, 22, 18, 15]
    print(f"1. Bottleneck set of {caps}:")
    print(f"   B = {compute_bottleneck_set(caps)}\n")

    # Demo 2: Greedy upgrade
    print(f"2. Greedy upgrade from throughput {min(caps)} to 16:")
    final, rounds, history = greedy_bottleneck_upgrade(caps, 16)
    for i, h in enumerate(history):
        print(f"   Round {i}: {h} → min = {min(h)}")
    print(f"   Completed in {rounds} rounds\n")

    # Demo 3: Optimal budget allocation
    print(f"3. Optimal budget allocation with B=15:")
    alloc, final = optimal_budget_allocation(caps, 15)
    print(f"   Allocation: {alloc}")
    print(f"   Final caps: {final}")
    print(f"   New throughput: {min(final)}\n")

    # Demo 4: Strategy comparison
    small_caps = [3, 7, 3, 10]
    print(f"4. Strategy comparison for {small_caps}:")
    results = compare_strategies(small_caps)
    for r in results[:5]:
        print(f"   {r.strategy_name}: throughput = {r.new_throughput}")

    # Demo 5: Theorem verification
    print(f"\n5. Theorem verification on random instances:")
    random.seed(42)
    all_ok = True
    for _ in range(100):
        test_caps = [random.randint(1, 20) for _ in range(random.randint(3, 8))]
        if not verify_theorem(test_caps, verbose=False):
            print(f"   FAILED on {test_caps}")
            all_ok = False
    print(f"   All 100 random tests passed ✓" if all_ok else "   SOME TESTS FAILED")
