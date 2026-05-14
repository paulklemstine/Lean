#!/usr/bin/env python3
"""
Algorithms for Adversarial Stress Testing of Hypothesis Classes

Implements:
1. Exhaustive false-positive counting
2. Greedy adversarial test-set selection (submodular maximization)
3. Random baseline test-set selection
4. Pipeline composition analysis
"""

from typing import Callable, List, Set, Tuple, Dict
import random
from dataclasses import dataclass


@dataclass
class StressTestResult:
    """Result of running a stress test on a hypothesis class."""
    test_set: List[int]
    false_positive_count: int
    killed_count: int
    total_false: int
    elimination_rate: float


class HypothesisClass:
    """
    A finite hypothesis class over a finite universe.
    
    Each hypothesis is represented as a truth table: a dict mapping
    universe elements to bool.
    
    Args:
        universe: List of elements in the finite domain.
        truth_tables: List of dicts {element: bool} for each hypothesis.
    """
    
    def __init__(self, universe: List[int], truth_tables: List[Dict[int, bool]]):
        self.universe = universe
        self.truth_tables = truth_tables
        self.n_hypotheses = len(truth_tables)
        self.n_universe = len(universe)
        
        # Precompute which hypotheses are false
        self._false_mask = [
            any(not t[a] for a in universe) for t in truth_tables
        ]
        self.n_false = sum(self._false_mask)
    
    def survives(self, h_idx: int, test_set: List[int]) -> bool:
        """Check if hypothesis h_idx survives the test set."""
        t = self.truth_tables[h_idx]
        return all(t[a] for a in test_set)
    
    def is_false(self, h_idx: int) -> bool:
        """Check if hypothesis h_idx is false on the universe."""
        return self._false_mask[h_idx]
    
    def false_positive_count(self, test_set: List[int]) -> int:
        """Count false hypotheses that survive the test set."""
        return sum(
            1 for i in range(self.n_hypotheses)
            if self._false_mask[i] and self.survives(i, test_set)
        )
    
    def killed_by(self, test_set: List[int]) -> Set[int]:
        """Return indices of hypotheses killed by the test set."""
        return {
            i for i in range(self.n_hypotheses)
            if any(not self.truth_tables[i][a] for a in test_set)
        }
    
    def stress_test(self, test_set: List[int]) -> StressTestResult:
        """Run a complete stress test and return results."""
        fp = self.false_positive_count(test_set)
        killed = len(self.killed_by(test_set))
        rate = 1.0 - fp / self.n_false if self.n_false > 0 else 1.0
        return StressTestResult(
            test_set=test_set,
            false_positive_count=fp,
            killed_count=killed,
            total_false=self.n_false,
            elimination_rate=rate
        )


def greedy_test_selection(hc: HypothesisClass, budget: int) -> List[int]:
    """
    Greedy adversarial test-set selection.
    
    At each step, select the test point that maximizes the number of
    newly killed false hypotheses. This is a greedy algorithm for
    monotone submodular maximization.
    
    Complexity: O(budget * |universe| * |H|)
    
    Args:
        hc: The hypothesis class.
        budget: Maximum number of test points to select.
    
    Returns:
        List of selected test points (in selection order).
    """
    selected = []
    current_killed: Set[int] = set()
    available = set(hc.universe)
    
    for _ in range(min(budget, len(available))):
        best_point = None
        best_marginal = -1
        
        for a in available:
            # How many NEW hypotheses would adding 'a' kill?
            newly_killed = sum(
                1 for i in range(hc.n_hypotheses)
                if i not in current_killed and not hc.truth_tables[i][a]
            )
            if newly_killed > best_marginal:
                best_marginal = newly_killed
                best_point = a
        
        if best_point is None or best_marginal == 0:
            break
        
        selected.append(best_point)
        available.discard(best_point)
        current_killed |= {
            i for i in range(hc.n_hypotheses)
            if not hc.truth_tables[i][best_point]
        }
    
    return selected


def random_test_selection(hc: HypothesisClass, budget: int, seed: int = 0) -> List[int]:
    """
    Random baseline test-set selection.
    
    Args:
        hc: The hypothesis class.
        budget: Number of test points to select.
        seed: Random seed for reproducibility.
    
    Returns:
        List of randomly selected test points.
    """
    rng = random.Random(seed)
    return rng.sample(hc.universe, min(budget, len(hc.universe)))


def pipeline_analysis(hc: HypothesisClass, stages: List[List[int]]) -> List[StressTestResult]:
    """
    Analyze a multi-stage stress-test pipeline.
    
    Each stage is a test set. The cumulative test set grows with each stage.
    
    Args:
        hc: The hypothesis class.
        stages: List of test sets, one per stage.
    
    Returns:
        List of StressTestResults, one per stage (cumulative).
    """
    cumulative = []
    results = []
    for stage in stages:
        cumulative.extend(stage)
        results.append(hc.stress_test(cumulative))
    return results


# ---------------------------------------------------------------------------
# Example usage
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    # Create a random hypothesis class
    random.seed(42)
    N = 30  # universe size
    M = 100  # number of hypotheses
    universe = list(range(N))
    
    truth_tables = [
        {a: random.random() > 0.3 for a in universe}  # ~70% chance of True per element
        for _ in range(M)
    ]
    
    hc = HypothesisClass(universe, truth_tables)
    print(f"Universe size: {N}")
    print(f"Hypothesis class size: {M}")
    print(f"False hypotheses: {hc.n_false}")
    
    # Compare greedy vs random
    print("\n--- Greedy vs Random Test Selection ---")
    print(f"{'Budget':>8}  {'Greedy FP':>10}  {'Random FP':>10}  {'Greedy Elim%':>13}  {'Random Elim%':>13}")
    print("-" * 60)
    
    for budget in [1, 2, 3, 5, 8, 10, 15, 20, 30]:
        greedy_T = greedy_test_selection(hc, budget)
        random_T = random_test_selection(hc, budget, seed=123)
        
        greedy_result = hc.stress_test(greedy_T)
        random_result = hc.stress_test(random_T)
        
        print(f"{budget:>8}  {greedy_result.false_positive_count:>10}  "
              f"{random_result.false_positive_count:>10}  "
              f"{greedy_result.elimination_rate:>12.1%}  "
              f"{random_result.elimination_rate:>12.1%}")
    
    # Pipeline analysis
    print("\n--- Pipeline Analysis (3 stages of 5 points each) ---")
    stages = [
        greedy_test_selection(hc, 5),
        list(range(5, 10)),
        list(range(10, 15))
    ]
    
    results = pipeline_analysis(hc, stages)
    for i, r in enumerate(results):
        print(f"After stage {i+1}: FP={r.false_positive_count}, "
              f"Killed={r.killed_count}, Elim={r.elimination_rate:.1%}")
