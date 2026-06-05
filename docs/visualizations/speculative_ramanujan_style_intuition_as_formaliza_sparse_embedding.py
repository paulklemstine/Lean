#!/usr/bin/env python3
"""
Ramanujan Oracle: Core Algorithms

Type-hinted implementations of the key constructions from the Ramanujan
oracle non-computability theory.
"""

from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass
import math


# Type aliases
Oracle = Callable[[int], bool]
TruthAssignment = Callable[[int], bool]


@dataclass
class AccuracyReport:
    """Report of oracle accuracy on an initial segment."""
    segment_size: int
    correct: int
    errors: int
    accuracy: float
    is_ramanujan_accurate: bool  # errors * 20 <= segment_size


def oracle_errors(oracle: Oracle, truth: TruthAssignment, n: int) -> int:
    """Count the number of errors an oracle makes on [0, n).
    
    Corresponds to Lean definition:
        def oracleErrors (o : Oracle) (t : TruthAssignment) (n : ℕ) : ℕ :=
          ((Finset.range n).filter (fun i => o i ≠ t i)).card
    
    Time complexity: O(n)
    """
    return sum(1 for i in range(n) if oracle(i) != truth(i))


def oracle_correct(oracle: Oracle, truth: TruthAssignment, n: int) -> int:
    """Count correct predictions on [0, n).
    
    Satisfies: oracle_correct + oracle_errors = n (errors_plus_correct theorem)
    """
    return n - oracle_errors(oracle, truth, n)


def evaluate_accuracy(oracle: Oracle, truth: TruthAssignment, n: int) -> AccuracyReport:
    """Evaluate oracle accuracy on [0, n) and return a detailed report."""
    errors = oracle_errors(oracle, truth, n)
    correct = n - errors
    accuracy = correct / n if n > 0 else 1.0
    is_accurate = errors * 20 <= n
    return AccuracyReport(n, correct, errors, accuracy, is_accurate)


def sparse_embed(truth: TruthAssignment, g: Callable[[int], bool],
                 spacing: int = 21) -> Oracle:
    """Sparse embedding: the core construction for proving uncountability.
    
    Places g's values at positions divisible by `spacing`, copies truth elsewhere.
    Achieves error rate ≤ 1/spacing on all sufficiently large initial segments.
    
    Corresponds to Lean definition:
        def sparseEmbed (t : TruthAssignment) (g : ℕ → Bool) : Oracle :=
          fun i => if i % 21 = 0 then g (i / 21) else t i
    
    Properties (proven in Lean):
    - Injective in g (sparseEmbed_injective)
    - Error rate ≤ 1/spacing (sparseEmbed_errors_bound)
    - Is a Ramanujan oracle for spacing ≥ 21 (sparseEmbed_is_ramanujan)
    
    Args:
        truth: The truth assignment
        g: Arbitrary function (the "seed" determining the oracle)
        spacing: Distance between free positions (default 21 for 95% accuracy)
    
    Returns:
        An oracle that is (1 - 1/spacing)-accurate
    """
    def oracle(i: int) -> bool:
        if i % spacing == 0:
            return g(i // spacing)
        else:
            return truth(i)
    return oracle


def sparse_embed_k(truth: TruthAssignment, k: int,
                   g: Callable[[int], bool]) -> Oracle:
    """Parameterized sparse embedding for accuracy 1 - 1/k.
    
    Uses spacing k+1, achieving error rate ≤ 1/(k+1) < 1/k.
    
    Corresponds to Lean definition:
        def sparseEmbedK (t : TruthAssignment) (k : ℕ) (g : ℕ → Bool) : Oracle :=
          fun i => if i % (k + 1) = 0 then g (i / (k + 1)) else t i
    """
    spacing = k + 1
    return sparse_embed(truth, g, spacing)


def count_accurate_behaviors(n: int, truth_bits: List[bool],
                             max_error_fraction: float = 0.05) -> int:
    """Count the number of functions Fin n → Bool with error rate ≤ max_error_fraction.
    
    WARNING: Exponential time in n. Only feasible for n ≤ 20.
    
    The theoretical lower bound is 2^(n/21) for max_error_fraction = 1/21.
    """
    max_errors = int(n * max_error_fraction)
    count = 0
    for mask in range(2 ** n):
        errors = sum(1 for i in range(n)
                     if ((mask >> i) & 1 == 1) != truth_bits[i])
        if errors <= max_errors:
            count += 1
    return count


def accurate_oracle_lower_bound(n: int, spacing: int = 21) -> int:
    """Compute the theoretical lower bound 2^(n/spacing) on accurate behaviors.
    
    Corresponds to theorem accurate_oracle_exponential_lower_bound.
    """
    return 2 ** (n // spacing)


@dataclass
class OracleHierarchyLevel:
    """A single level of an oracle hierarchy."""
    level_number: int
    witness: int  # The position where this level is wrong
    oracle: Oracle


def build_oracle_hierarchy(truth: TruthAssignment,
                           witnesses: List[int]) -> List[OracleHierarchyLevel]:
    """Construct an oracle hierarchy from a list of witnesses.
    
    Each level n disagrees with truth only at witness[n].
    
    Properties (proven in Lean in oracle_hierarchy_exists):
    - Level n is wrong at witness[n]
    - Level n+1 is correct at witness[n] (since witness[n] != witness[n+1])
    - Level n is correct everywhere except witness[n]
    
    Args:
        truth: The truth assignment
        witnesses: Strictly increasing sequence of positions
    
    Returns:
        List of OracleHierarchyLevel objects
    """
    levels = []
    for n, w in enumerate(witnesses):
        def make_oracle(witness: int) -> Oracle:
            def oracle(i: int) -> bool:
                if i == witness:
                    return not truth(i)
                return truth(i)
            return oracle
        
        levels.append(OracleHierarchyLevel(
            level_number=n,
            witness=w,
            oracle=make_oracle(w)
        ))
    return levels


def verify_hierarchy_strictly_improving(
    levels: List[OracleHierarchyLevel],
    truth: TruthAssignment
) -> List[Tuple[int, int, bool, bool]]:
    """Verify that each consecutive pair of levels is strictly improving.
    
    Returns list of (level_n, witness, level_n_correct, level_n1_correct).
    """
    results = []
    for n in range(len(levels) - 1):
        w = levels[n].witness
        level_n_val = levels[n].oracle(w)
        level_n1_val = levels[n + 1].oracle(w)
        truth_val = truth(w)
        
        results.append((
            n,
            w,
            level_n_val == truth_val,    # Should be False
            level_n1_val == truth_val     # Should be True
        ))
    return results


def warmup_period(k: int) -> int:
    """Compute the warm-up period for accuracy parameter k.
    
    For accuracy 1 - 1/k, the warm-up is k * (k + 1).
    After this many inputs, the accuracy guarantee holds.
    """
    return k * (k + 1)


def information_lower_bound(n: int, spacing: int = 21) -> float:
    """Compute the information-theoretic lower bound for specifying
    a Ramanujan oracle on n inputs.
    
    Returns the minimum number of bits needed.
    """
    return n / spacing


def is_ramanujan_oracle(oracle: Oracle, truth: TruthAssignment,
                        warmup: int = 420, check_up_to: int = 10000) -> bool:
    """Check if an oracle satisfies the Ramanujan accuracy condition
    on initial segments from warmup to check_up_to.
    
    Note: This can only verify the condition on finite segments.
    The true Ramanujan property requires ∀ n ≥ warmup.
    """
    for n in range(warmup, check_up_to + 1, max(1, (check_up_to - warmup) // 100)):
        errors = oracle_errors(oracle, truth, n)
        if errors * 20 > n:
            return False
    return True


if __name__ == "__main__":
    import random
    random.seed(42)
    
    # Example: construct a Ramanujan oracle for primality
    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        return all(n % d != 0 for d in range(2, int(n**0.5) + 1))
    
    g = lambda i: random.choice([True, False])
    oracle = sparse_embed(is_prime, g)
    
    report = evaluate_accuracy(oracle, is_prime, 1000)
    print(f"Oracle accuracy on [0, 1000): {report.accuracy:.4f}")
    print(f"Is 95%-accurate: {report.is_ramanujan_accurate}")
    print(f"Errors: {report.errors}")
    
    # Build hierarchy
    levels = build_oracle_hierarchy(is_prime, [2, 5, 11, 23, 47])
    results = verify_hierarchy_strictly_improving(levels, is_prime)
    print("\nHierarchy verification:")
    for n, w, n_correct, n1_correct in results:
        print(f"  Level {n} → {n+1} at witness {w}: "
              f"L{n} {'✓' if n_correct else '✗'}, L{n+1} {'✓' if n1_correct else '✗'}")
