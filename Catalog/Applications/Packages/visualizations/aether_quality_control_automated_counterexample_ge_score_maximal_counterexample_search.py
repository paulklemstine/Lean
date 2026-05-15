#!/usr/bin/env python3
"""
Algorithms for Certified Refutation Layers

Implements the core algorithms from the certified stress-testing framework:
1. Counterexample search with score maximization
2. False-positive count computation
3. Greedy test set design
4. Pipeline cost optimizer

All algorithms operate on finite domains with decidable predicates.
"""

from typing import Callable, Optional, TypeVar, Set, Dict, List, Tuple
from dataclasses import dataclass
from itertools import combinations

T = TypeVar('T')


@dataclass
class StressTestResult:
    """Result of a stress test on a conjecture."""
    survives: bool
    counterexample: Optional[object]
    counterexample_score: Optional[int]
    tested_points: int


@dataclass
class PipelineAnalysis:
    """Analysis of a conjecture pipeline with stress testing."""
    total_conjectures: int
    true_conjectures: int
    false_conjectures: int
    survivors: int
    false_positives: int
    test_cost: float
    proof_cost: float
    total_cost: float
    naive_cost: float
    savings: float


def find_counterexample(
    P: Callable[[T], bool],
    domain: Set[T],
    score: Optional[Callable[[T], int]] = None
) -> StressTestResult:
    """
    Find a counterexample to P in domain, maximizing score if provided.

    Algorithm:
    1. Enumerate all x in domain where ¬P(x).
    2. If score is provided, return the one with maximum score.
    3. If no counterexample exists, report survival.

    Time complexity: O(|domain|)
    Space complexity: O(|counterexamples|)

    Args:
        P: Decidable predicate (returns True if the point satisfies the conjecture)
        domain: Finite set of test inputs
        score: Optional scoring function for counterexample difficulty

    Returns:
        StressTestResult with the outcome
    """
    counterexamples = [x for x in domain if not P(x)]

    if not counterexamples:
        return StressTestResult(
            survives=True,
            counterexample=None,
            counterexample_score=None,
            tested_points=len(domain)
        )

    if score is not None:
        best = max(counterexamples, key=score)
        return StressTestResult(
            survives=False,
            counterexample=best,
            counterexample_score=score(best),
            tested_points=len(domain)
        )
    else:
        return StressTestResult(
            survives=False,
            counterexample=counterexamples[0],
            counterexample_score=None,
            tested_points=len(domain)
        )


def compute_false_positive_count(
    conjectures: Dict[str, Callable[[T], bool]],
    test_set: Set[T],
    domain: Set[T]
) -> int:
    """
    Compute the false-positive count for a conjecture family.

    FP(T) = |{i : is_false(i) ∧ passes_test(T, i)}|

    Time complexity: O(|conjectures| × |domain|)

    Args:
        conjectures: Mapping from conjecture name to predicate
        test_set: Current test set T
        domain: Full domain (universe)

    Returns:
        Number of false positives
    """
    count = 0
    for name, pred in conjectures.items():
        # Check if conjecture is false on full domain
        is_false = any(not pred(x) for x in domain)
        # Check if conjecture passes all tests
        passes = all(pred(x) for x in test_set)
        if is_false and passes:
            count += 1
    return count


def greedy_test_design(
    conjectures: Dict[str, Callable[[T], bool]],
    domain: Set[T],
    budget: int
) -> Tuple[Set[T], List[int]]:
    """
    Greedy algorithm for optimal test set design.

    At each step, add the test point that maximizes the number of
    newly killed false conjectures (greedy submodular maximization).

    The kill-count function f(T) = |{i : ∃x∈T, ¬Q_i(x)}| is submodular,
    so the greedy algorithm achieves a (1 - 1/e) approximation.

    Time complexity: O(budget × |domain| × |conjectures|)

    Args:
        conjectures: Conjecture family
        domain: Full domain
        budget: Maximum number of test points

    Returns:
        (selected_test_set, kill_counts_per_step)
    """
    T: Set = set()
    kill_history: List[int] = []
    remaining = set(domain)

    # Pre-compute which conjectures each point refutes
    refutes: Dict = {}
    for x in domain:
        refutes[x] = {name for name, pred in conjectures.items() if not pred(x)}

    killed: Set[str] = set()

    for step in range(min(budget, len(domain))):
        # Find the point that kills the most new conjectures
        best_point = None
        best_new_kills = -1

        for x in remaining:
            new_kills = len(refutes[x] - killed)
            if new_kills > best_new_kills:
                best_new_kills = new_kills
                best_point = x

        if best_point is None or best_new_kills == 0:
            break

        T.add(best_point)
        remaining.discard(best_point)
        killed |= refutes[best_point]
        kill_history.append(len(killed))

    return T, kill_history


def analyze_pipeline(
    conjectures: Dict[str, Callable[[T], bool]],
    test_set: Set[T],
    domain: Set[T],
    cost_per_test: float = 1.0,
    cost_per_proof: float = 50.0
) -> PipelineAnalysis:
    """
    Analyze the cost of a conjecture pipeline with stress testing.

    Compares:
    - Naive pipeline: attempt proof on all conjectures
    - Stress-test pipeline: test first, only prove survivors

    Time complexity: O(|conjectures| × |domain|)

    Args:
        conjectures: Conjecture family
        test_set: Stress test points
        domain: Full domain
        cost_per_test: Cost of evaluating one predicate on one test point
        cost_per_proof: Cost of attempting to prove one conjecture

    Returns:
        PipelineAnalysis with detailed cost breakdown
    """
    n = len(conjectures)
    n_true = 0
    n_false = 0
    n_survivors = 0
    n_fp = 0

    for name, pred in conjectures.items():
        is_false = any(not pred(x) for x in domain)
        passes_test = all(pred(x) for x in test_set)

        if is_false:
            n_false += 1
        else:
            n_true += 1

        if passes_test:
            n_survivors += 1
            if is_false:
                n_fp += 1

    test_cost = n * len(test_set) * cost_per_test
    proof_cost = n_survivors * cost_per_proof
    total_cost = test_cost + proof_cost
    naive_cost = n * cost_per_proof

    return PipelineAnalysis(
        total_conjectures=n,
        true_conjectures=n_true,
        false_conjectures=n_false,
        survivors=n_survivors,
        false_positives=n_fp,
        test_cost=test_cost,
        proof_cost=proof_cost,
        total_cost=total_cost,
        naive_cost=naive_cost,
        savings=naive_cost - total_cost
    )


def bounded_exhaustive_search(
    P: Callable[[T], bool],
    domain: Set[T],
    complexity: Callable[[T], int],
    bound: int
) -> Optional[T]:
    """
    Search for counterexamples up to a complexity bound.

    Enumerates all x with complexity(x) ≤ bound and checks P(x).
    By Theorem 4 (bounded counterexample detection), this catches
    all counterexamples of bounded complexity.

    Time complexity: O(|{x : complexity(x) ≤ bound}|)

    Args:
        P: Predicate to test
        domain: Full domain
        complexity: Complexity measure
        bound: Maximum complexity to search

    Returns:
        A counterexample of complexity ≤ bound, or None
    """
    bounded_domain = {x for x in domain if complexity(x) <= bound}
    for x in sorted(bounded_domain, key=complexity):
        if not P(x):
            return x
    return None


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    import random
    random.seed(42)

    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Setup
    domain = set(range(30))

    # Generate conjecture family
    conjectures = {}
    for i in range(50):
        bad = set(random.sample(range(30), random.randint(0, 6)))
        conjectures[f"Q_{i}"] = lambda x, b=bad: x not in b

    # Demo: Greedy test design
    print("\n--- Greedy Test Design ---")
    T_greedy, kills = greedy_test_design(conjectures, domain, budget=10)
    print(f"Selected test set ({len(T_greedy)} points): {sorted(T_greedy)}")
    print(f"Cumulative kills per step: {kills}")

    fp_greedy = compute_false_positive_count(conjectures, T_greedy, domain)
    fp_empty = compute_false_positive_count(conjectures, set(), domain)
    print(f"False positives: {fp_empty} → {fp_greedy} "
          f"({fp_empty - fp_greedy} eliminated)")

    # Demo: Pipeline analysis
    print("\n--- Pipeline Analysis ---")
    analysis = analyze_pipeline(conjectures, T_greedy, domain)
    print(f"Total conjectures: {analysis.total_conjectures}")
    print(f"  True: {analysis.true_conjectures}, False: {analysis.false_conjectures}")
    print(f"Survivors after testing: {analysis.survivors} (FP: {analysis.false_positives})")
    print(f"Test cost: {analysis.test_cost:.0f}")
    print(f"Proof cost: {analysis.proof_cost:.0f}")
    print(f"Total cost: {analysis.total_cost:.0f}")
    print(f"Naive cost: {analysis.naive_cost:.0f}")
    print(f"Savings: {analysis.savings:.0f} ({100*analysis.savings/analysis.naive_cost:.1f}%)")

    # Demo: Score-maximal counterexample
    print("\n--- Score-Maximal Counterexample ---")
    P_demo = lambda x: x % 7 != 0  # "not divisible by 7"
    result = find_counterexample(P_demo, domain, score=lambda x: x)
    print(f"Conjecture: 'x not divisible by 7' on {{0,...,29}}")
    print(f"Max-scored counterexample: {result.counterexample} "
          f"(score: {result.counterexample_score})")
