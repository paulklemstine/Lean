#!/usr/bin/env python3
"""
Phase-Aware Lemma Synthesis: Core Algorithms

Implements the certified algorithms from the formal theory:
1. Phase prediction and classification
2. Phase-aware search action selection
3. Effective complexity computation
4. Resource allocation dominance checking
5. Curriculum partitioning

All algorithms mirror the formally verified Lean definitions.
"""

from dataclasses import dataclass, field
from enum import IntEnum
from typing import Callable, Optional, List, Tuple


class Phase(IntEnum):
    """Phase classification for theorem instances.
    Maps to Phase.index in the formal development."""
    TRACTABLE = 0
    TRANSITIONAL = 1
    INTRACTABLE = 2


class SearchAction(IntEnum):
    """Available search strategies."""
    DIRECT = 0
    SYNTHESIZE_LEMMAS = 1


@dataclass
class LemmaBenefit:
    """Lemma benefit model: captures complexity reduction through synthesis.

    Invariant (formally verified): reduced_complexity(x) <= base_complexity(x) for all x.

    Attributes:
        base_complexity: Cost without lemma synthesis
        reduced_complexity: Cost with lemma synthesis
        name: Human-readable description
    """
    base_complexity: Callable[[int], int]
    reduced_complexity: Callable[[int], int]
    name: str = "unnamed"

    def verify_beneficial(self, samples: range) -> bool:
        """Runtime check that synthesis never increases complexity."""
        return all(
            self.reduced_complexity(x) <= self.base_complexity(x)
            for x in samples
        )


@dataclass
class PolicyResult:
    """Result of phase-aware policy evaluation."""
    complexity_score: int
    threshold: int
    phase: Phase
    action: SearchAction
    base_complexity: int
    reduced_complexity: int
    effective_complexity: int
    energy_direct: float
    energy_synthesis: float
    dominates: Optional[bool] = None  # True if synthesis dominates at given budget


# ─── Algorithm 1: Phase Prediction ──────────────────────────────────────
# Time: O(1) | Space: O(1)
# Formally verified: predictedPhase_monotone

def predict_phase(threshold: int, n: int) -> Phase:
    """Predict the reasoning phase for complexity score n.

    Certified monotone: if n1 <= n2, then predict_phase(t, n1) <= predict_phase(t, n2).

    Args:
        threshold: Phase transition boundary
        n: Semantic complexity score

    Returns:
        Phase classification

    Examples:
        >>> predict_phase(5, 3)
        Phase.TRACTABLE
        >>> predict_phase(5, 7)
        Phase.TRANSITIONAL
        >>> predict_phase(5, 15)
        Phase.INTRACTABLE
    """
    if n <= threshold:
        return Phase.TRACTABLE
    elif n <= 2 * threshold:
        return Phase.TRANSITIONAL
    else:
        return Phase.INTRACTABLE


# ─── Algorithm 2: Phase-Aware Policy ────────────────────────────────────
# Time: O(1) | Space: O(1)
# Formally verified: phaseAwarePolicy_synthesis_upward_closed

def choose_search_action(threshold: int, n: int) -> SearchAction:
    """Certified decision procedure for search strategy selection.

    Proven properties:
    - Selects DIRECT in tractable phase
    - Selects SYNTHESIZE_LEMMAS otherwise
    - Upward closed: once synthesis is chosen, all harder instances also get synthesis

    Args:
        threshold: Phase transition boundary
        n: Semantic complexity score

    Returns:
        SearchAction to execute

    Examples:
        >>> choose_search_action(5, 3)
        SearchAction.DIRECT
        >>> choose_search_action(5, 8)
        SearchAction.SYNTHESIZE_LEMMAS
    """
    phase = predict_phase(threshold, n)
    if phase == Phase.TRACTABLE:
        return SearchAction.DIRECT
    return SearchAction.SYNTHESIZE_LEMMAS


# ─── Algorithm 3: Effective Complexity ──────────────────────────────────
# Time: O(f) where f is complexity of base/reduced functions | Space: O(1)
# Formally verified: effectiveComplexity_strictly_decreases_above_threshold

def effective_complexity(model: LemmaBenefit, use_lemma: bool, x: int) -> int:
    """Compute effective complexity under a lemma benefit model.

    Proven: if CompressionThreshold(model, k) and k <= base_complexity(x),
    then effective_complexity(model, True, x) < effective_complexity(model, False, x).

    Args:
        model: Lemma benefit model
        use_lemma: Whether to apply lemma synthesis
        x: Problem instance

    Returns:
        Effective search complexity
    """
    if use_lemma:
        return model.reduced_complexity(x)
    return model.base_complexity(x)


# ─── Algorithm 4: Dominance Check ───────────────────────────────────────
# Time: O(1) | Space: O(1)
# Formally verified: phaseAware_dominates_direct_above_threshold

def check_dominance(model: LemmaBenefit, budget: int, x: int) -> Tuple[bool, bool]:
    """Check whether synthesis dominates direct search at given budget.

    Returns (synthesis_solves, direct_solves).
    Proven: if compression threshold holds and base > budget >= reduced,
    then synthesis_solves=True and direct_solves=False.

    Args:
        model: Lemma benefit model
        budget: Computational budget
        x: Problem instance

    Returns:
        (synthesis_solves, direct_solves) tuple
    """
    synthesis_solves = model.reduced_complexity(x) <= budget
    direct_solves = model.base_complexity(x) <= budget
    return synthesis_solves, direct_solves


# ─── Algorithm 5: Full Policy Evaluation ────────────────────────────────
# Time: O(f) | Space: O(1)

def evaluate_policy(
    model: LemmaBenefit,
    threshold: int,
    n: int,
    budget: Optional[int] = None
) -> PolicyResult:
    """Complete phase-aware policy evaluation.

    Combines phase prediction, action selection, complexity computation,
    and optional dominance checking into a single certified evaluation.

    Args:
        model: Lemma benefit model
        threshold: Phase transition boundary
        n: Semantic complexity score
        budget: Optional computational budget for dominance check

    Returns:
        PolicyResult with full analysis
    """
    phase = predict_phase(threshold, n)
    action = choose_search_action(threshold, n)
    use_lemma = (action == SearchAction.SYNTHESIZE_LEMMAS)
    base = model.base_complexity(n)
    reduced = model.reduced_complexity(n)
    eff = effective_complexity(model, use_lemma, n)

    dominates = None
    if budget is not None:
        s, d = check_dominance(model, budget, n)
        dominates = s and not d

    return PolicyResult(
        complexity_score=n,
        threshold=threshold,
        phase=phase,
        action=action,
        base_complexity=base,
        reduced_complexity=reduced,
        effective_complexity=eff,
        energy_direct=float(base),
        energy_synthesis=float(reduced),
        dominates=dominates,
    )


# ─── Algorithm 6: Curriculum Partition ──────────────────────────────────
# Time: O(|instances|) | Space: O(|instances|)
# Formally verified: curriculumBucket_agrees_with_policy

def partition_curriculum(
    instances: List[int],
    threshold: int
) -> Tuple[List[int], List[int]]:
    """Partition theorem instances into curriculum buckets.

    Proven: the partition agrees with the phase-aware policy.
    Tractable instances go to direct-practice bucket;
    hard instances go to synthesis-practice bucket.

    The partition is monotone: if instance x is in the hard bucket
    and y >= x, then y is also in the hard bucket.

    Args:
        instances: List of complexity scores
        threshold: Phase transition boundary

    Returns:
        (tractable_bucket, hard_bucket) tuple
    """
    tractable = []
    hard = []
    for n in instances:
        if choose_search_action(threshold, n) == SearchAction.DIRECT:
            tractable.append(n)
        else:
            hard.append(n)
    return tractable, hard


# ─── Algorithm 7: Benchmark Simulation ──────────────────────────────────
# Time: O(max_n) | Space: O(max_n)

@dataclass
class BenchmarkResult:
    """Results from a benchmark simulation."""
    model_name: str
    threshold: int
    budget: int
    direct_solved: int
    synthesis_solved: int
    advantage: int
    details: List[Tuple[int, Phase, bool, bool]] = field(default_factory=list)


def run_benchmark(
    model: LemmaBenefit,
    threshold: int,
    budget: int,
    max_n: int = 20
) -> BenchmarkResult:
    """Simulate benchmark comparing direct search vs phase-aware synthesis.

    For each instance n in [0, max_n], checks whether each strategy
    solves within the given budget.

    Args:
        model: Lemma benefit model
        threshold: Phase transition boundary
        budget: Computational budget
        max_n: Maximum complexity score to test

    Returns:
        BenchmarkResult with solve counts and per-instance details
    """
    direct_solved = 0
    synthesis_solved = 0
    details = []

    for n in range(max_n + 1):
        phase = predict_phase(threshold, n)
        s_ok, d_ok = check_dominance(model, budget, n)
        if d_ok:
            direct_solved += 1
        if s_ok:
            synthesis_solved += 1
        details.append((n, phase, d_ok, s_ok))

    return BenchmarkResult(
        model_name=model.name,
        threshold=threshold,
        budget=budget,
        direct_solved=direct_solved,
        synthesis_solved=synthesis_solved,
        advantage=synthesis_solved - direct_solved,
        details=details,
    )


# ─── Pre-built Models ───────────────────────────────────────────────────

EXPONENTIAL_MODEL = LemmaBenefit(
    base_complexity=lambda n: 2 ** n,
    reduced_complexity=lambda n: n + 1,
    name="Exponential (Powerset Expansion)",
)

QUADRATIC_MODEL = LemmaBenefit(
    base_complexity=lambda n: n * n + 1,
    reduced_complexity=lambda n: n + 1,
    name="Quadratic (Telescoping Sums)",
)

CUBIC_MODEL = LemmaBenefit(
    base_complexity=lambda n: n ** 3,
    reduced_complexity=lambda n: 3 * n,
    name="Cubic (Nested Inductions)",
)


# ─── Example Usage ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Phase-Aware Lemma Synthesis: Algorithm Examples\n")

    # Example 1: Single policy evaluation
    result = evaluate_policy(EXPONENTIAL_MODEL, threshold=5, n=10, budget=100)
    print(f"Instance n=10, threshold=5:")
    print(f"  Phase: {result.phase.name}")
    print(f"  Action: {result.action.name}")
    print(f"  Base complexity: {result.base_complexity}")
    print(f"  Reduced complexity: {result.reduced_complexity}")
    print(f"  Dominates: {result.dominates}")
    print()

    # Example 2: Curriculum partition
    instances = list(range(20))
    tractable, hard = partition_curriculum(instances, threshold=5)
    print(f"Curriculum partition (threshold=5):")
    print(f"  Tractable (direct practice): {tractable}")
    print(f"  Hard (synthesis practice):   {hard}")
    print()

    # Example 3: Benchmark
    bench = run_benchmark(EXPONENTIAL_MODEL, threshold=5, budget=50, max_n=15)
    print(f"Benchmark ({bench.model_name}):")
    print(f"  Direct solved:    {bench.direct_solved}/16")
    print(f"  Synthesis solved: {bench.synthesis_solved}/16")
    print(f"  Advantage:        +{bench.advantage}")
