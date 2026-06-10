#!/usr/bin/env python3
"""
Proof Compression Phase Transitions — Algorithm Implementations

This module implements the core algorithms from the proof compression
phase transition theory, including:

- Semantic complexity scoring
- Phase prediction with verified monotonicity
- Cost bound computation
- Threshold detection
- Compression instance construction

All algorithms mirror the formally verified Lean 4 definitions.
"""

from dataclasses import dataclass
from enum import IntEnum
from typing import Callable, Optional, Tuple, List


class Phase(IntEnum):
    """Phase classification for theorem instances.

    Mirrors the Lean definition:
        inductive Phase where
          | tractable | transitional | intractable
    """
    TRACTABLE = 0
    TRANSITIONAL = 1
    INTRACTABLE = 2


@dataclass
class CompressionInstance:
    """A compression instance models a theorem family with cost measures.

    Mirrors the Lean definition:
        structure CompressionInstance where
          theorem_id : Type
          semanticComplexity : theorem_id → ℕ
          humanCost : theorem_id → ℕ
          autoCost : theorem_id → ℕ

    Args:
        name: Human-readable name for the instance
        semantic_complexity: Maps theorem parameter to complexity score
        human_cost: Maps theorem parameter to structured proof cost
        auto_cost: Maps theorem parameter to flat automation cost
    """
    name: str
    semantic_complexity: Callable[[int], int]
    human_cost: Callable[[int], int]
    auto_cost: Callable[[int], int]


def complexity_score(n: int) -> int:
    """Compute the semantic complexity score.

    Mirrors: def complexityScore (n : ℕ) : ℕ := n

    Time complexity: O(1)

    Args:
        n: Theorem family parameter

    Returns:
        Semantic complexity score (identity function)

    Example:
        >>> complexity_score(10)
        10
    """
    return n


def predicted_phase(threshold: int, n: int) -> Phase:
    """Predict the proof regime phase given a threshold.

    Mirrors:
        def predictedPhase (threshold : ℕ) (n : ℕ) : Phase :=
          if n ≤ threshold then .tractable
          else if n ≤ 2 * threshold then .transitional
          else .intractable

    Verified property: monotone in n (Theorem predictedPhase_monotone)

    Time complexity: O(1)

    Args:
        threshold: Critical complexity value
        n: Semantic complexity score

    Returns:
        Predicted phase

    Example:
        >>> predicted_phase(5, 3)
        Phase.TRACTABLE
        >>> predicted_phase(5, 7)
        Phase.TRANSITIONAL
        >>> predicted_phase(5, 15)
        Phase.INTRACTABLE
    """
    if n <= threshold:
        return Phase.TRACTABLE
    elif n <= 2 * threshold:
        return Phase.TRANSITIONAL
    else:
        return Phase.INTRACTABLE


def compression_ratio(instance: CompressionInstance, n: int) -> float:
    """Compute the compression ratio at parameter n.

    Mirrors:
        def compressionRatio (I : CompressionInstance) (t : I.theorem_id) : ℚ :=
          (I.autoCost t : ℚ) / max 1 (I.humanCost t : ℚ)

    Time complexity: O(T_auto + T_human) where T_x is cost function time

    Args:
        instance: The compression instance
        n: Theorem family parameter

    Returns:
        Ratio auto_cost / max(1, human_cost)

    Example:
        >>> inst = subset_expansion_instance()
        >>> compression_ratio(inst, 10)
        93.09090909090909
    """
    h = instance.human_cost(n)
    a = instance.auto_cost(n)
    return a / max(1, h)


def has_asymptotic_gap(
    instance: CompressionInstance,
    max_k: int = 100,
    max_n: int = 1000
) -> Tuple[bool, Optional[int]]:
    """Test whether an instance appears to have an asymptotic gap.

    Mirrors:
        def HasAsymptoticGap (I : CompressionInstance) (T : ℕ → I.theorem_id) : Prop :=
          ∀ K : ℕ, ∃ n : ℕ, K * I.humanCost (T n) < I.autoCost (T n)

    This is a computational approximation — the formal property is
    universally quantified, while this checks finite ranges.

    Args:
        instance: The compression instance
        max_k: Maximum multiplier to test
        max_n: Maximum parameter to search

    Returns:
        (appears_to_have_gap, largest_k_witnessed)

    Example:
        >>> has_asymptotic_gap(subset_expansion_instance())
        (True, 100)
    """
    largest_k = 0
    for k in range(1, max_k + 1):
        found = False
        for n in range(max_n + 1):
            if k * instance.human_cost(n) < instance.auto_cost(n):
                found = True
                largest_k = k
                break
        if not found:
            return (False, largest_k - 1 if largest_k > 0 else None)
    return (True, largest_k)


def find_threshold(
    instance: CompressionInstance,
    max_n: int = 100,
    max_k: int = 100
) -> Optional[int]:
    """Find the empirical compression threshold.

    Searches for the smallest c such that:
    1. Below c: auto_cost ≤ C * human_cost for some constant C
    2. Above c: compression ratio is unbounded

    Args:
        instance: The compression instance
        max_n: Maximum parameter to search
        max_k: Maximum multiplier to test

    Returns:
        Estimated threshold, or None if no clear threshold found

    Example:
        >>> find_threshold(subset_expansion_instance())
        0
    """
    for c in range(max_n):
        # Check below threshold
        max_ratio_below = 0
        for n in range(c + 1):
            r = compression_ratio(instance, n)
            max_ratio_below = max(max_ratio_below, r)

        # Check above threshold
        found_large = True
        for k in range(1, min(max_k, 20) + 1):
            witness_found = False
            for n in range(c + 1, max_n + 1):
                if k * instance.human_cost(n) < instance.auto_cost(n):
                    witness_found = True
                    break
            if not witness_found:
                found_large = False
                break

        if max_ratio_below < 1000 and found_large:
            return c

    return None


def certified_cost_bounds(n: int) -> dict:
    """Compute certified cost bounds for the subset expansion family.

    Returns human cost, auto cost, augmented cost, and compression ratio
    with mathematical guarantees from the formalized theory.

    Time complexity: O(n) for the exponentiation

    Args:
        n: Theorem family parameter

    Returns:
        Dictionary with cost bounds and ratio

    Example:
        >>> certified_cost_bounds(10)
        {'n': 10, 'human_cost': 11, 'auto_cost': 1024,
         'augmented_cost': 11, 'ratio': 93.1, 'augmented_ratio': 1.0,
         'phase': 'intractable'}
    """
    human = n + 1
    auto = 2 ** n
    augmented = n + 1
    ratio = auto / max(1, human)
    aug_ratio = augmented / max(1, human)
    threshold = 5  # default threshold for phase prediction
    phase = predicted_phase(threshold, n).name.lower()

    return {
        'n': n,
        'human_cost': human,
        'auto_cost': auto,
        'augmented_cost': augmented,
        'ratio': round(ratio, 1),
        'augmented_ratio': round(aug_ratio, 1),
        'phase': phase,
    }


# === Pre-built Compression Instances ===

def subset_expansion_instance() -> CompressionInstance:
    """The subset expansion compression instance.

    Models ∏ (1 + f_i) = ∑_{S ⊆ [n]} ∏_{i∈S} f_i
    - Human cost: n + 1 (inductive proof)
    - Auto cost: 2^n (one term per subset)
    """
    return CompressionInstance(
        name="Subset Expansion",
        semantic_complexity=lambda n: n,
        human_cost=lambda n: n + 1,
        auto_cost=lambda n: 2 ** n,
    )


def augmented_subset_instance() -> CompressionInstance:
    """Augmented subset expansion (with inductive lemma)."""
    return CompressionInstance(
        name="Augmented Subset Expansion",
        semantic_complexity=lambda n: n,
        human_cost=lambda n: n + 1,
        auto_cost=lambda n: n + 1,
    )


def telescoping_instance() -> CompressionInstance:
    """The telescoping identity compression instance.

    Models (x-1) * ∑ x^i = x^n - 1
    - Human cost: n + 1 (inductive proof)
    - Auto cost: n² + 1 (quadratic expansion)
    """
    return CompressionInstance(
        name="Telescoping Identity",
        semantic_complexity=lambda n: n,
        human_cost=lambda n: n + 1,
        auto_cost=lambda n: n * n + 1,
    )


def augmented_telescoping_instance() -> CompressionInstance:
    """Augmented telescoping (with telescoping lemma)."""
    return CompressionInstance(
        name="Augmented Telescoping",
        semantic_complexity=lambda n: n,
        human_cost=lambda n: n + 1,
        auto_cost=lambda n: n + 1,
    )


# === Verification ===

def verify_phase_monotonicity(threshold: int, max_n: int = 1000) -> bool:
    """Verify that phase prediction is monotone.

    Mirrors Theorem predictedPhase_monotone:
        ∀ a b, a ≤ b → (predictedPhase threshold a).index ≤ (predictedPhase threshold b).index

    Args:
        threshold: Phase prediction threshold
        max_n: Maximum n to check

    Returns:
        True if monotonicity holds for all tested values
    """
    prev = Phase.TRACTABLE
    for n in range(max_n + 1):
        curr = predicted_phase(threshold, n)
        if curr < prev:
            return False
        prev = curr
    return True


if __name__ == "__main__":
    print("=== Proof Compression Phase Transitions: Algorithm Tests ===\n")

    # Test instances
    subset = subset_expansion_instance()
    telescoping = telescoping_instance()
    aug_subset = augmented_subset_instance()

    # Test asymptotic gap
    print("Asymptotic gap detection:")
    gap_s, k_s = has_asymptotic_gap(subset)
    print(f"  Subset expansion: gap={gap_s}, max_k={k_s}")
    gap_t, k_t = has_asymptotic_gap(telescoping)
    print(f"  Telescoping: gap={gap_t}, max_k={k_t}")
    gap_a, k_a = has_asymptotic_gap(aug_subset, max_k=10)
    print(f"  Augmented subset: gap={gap_a}, max_k={k_a}")

    # Test threshold
    print(f"\nThreshold detection:")
    print(f"  Subset expansion threshold: {find_threshold(subset)}")

    # Test phase monotonicity
    print(f"\nPhase monotonicity verification:")
    for t in [0, 1, 5, 10, 50]:
        print(f"  threshold={t}: monotone={verify_phase_monotonicity(t)}")

    # Certified bounds
    print(f"\nCertified cost bounds:")
    for n in [1, 5, 10, 15, 20]:
        bounds = certified_cost_bounds(n)
        print(f"  n={n}: {bounds}")
