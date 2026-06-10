#!/usr/bin/env python3
"""
Phase-Aware Lemma Synthesis: Real-World Applications

Demonstrates practical applications of the phase transition theory:
1. Adaptive tactic scheduling for theorem provers
2. Proof-search curriculum design
3. Energy landscape visualization
4. Complexity-aware resource allocation
"""

from dataclasses import dataclass
from typing import List, Tuple, Dict
import math


# ─── Application 1: Adaptive Tactic Scheduler ───────────────────────────

class Phase:
    TRACTABLE = 0
    TRANSITIONAL = 1
    INTRACTABLE = 2

    @staticmethod
    def name(p: int) -> str:
        return ["Tractable", "Transitional", "Intractable"][p]


def predict_phase(threshold: int, complexity: int) -> int:
    if complexity <= threshold:
        return Phase.TRACTABLE
    elif complexity <= 2 * threshold:
        return Phase.TRANSITIONAL
    else:
        return Phase.INTRACTABLE


@dataclass
class TacticConfig:
    """Configuration for a tactic in the scheduler."""
    name: str
    base_cost: int       # Expected cost without lemma support
    lemma_cost: int      # Expected cost with synthesized lemmas
    success_rate: float  # Base success probability


class AdaptiveTacticScheduler:
    """Phase-aware tactic scheduler that adapts strategy based on goal complexity.

    In the tractable phase, uses fast direct tactics.
    In the transitional phase, mixes direct and synthesis tactics.
    In the intractable phase, prioritizes lemma synthesis.

    This mirrors the formally verified `chooseSearchAction` function.
    """

    def __init__(self, threshold: int, tactics: List[TacticConfig]):
        self.threshold = threshold
        self.tactics = tactics

    def schedule(self, goal_complexity: int) -> List[Tuple[str, float]]:
        """Return ordered list of (tactic_name, time_allocation) pairs.

        The allocation sums to 1.0 and represents the fraction of
        computational budget assigned to each tactic.
        """
        phase = predict_phase(self.threshold, goal_complexity)

        if phase == Phase.TRACTABLE:
            # Direct tactics get most budget
            return [(t.name, 0.8 / len(self.tactics)) for t in self.tactics] + \
                   [("lemma_synthesis", 0.2)]
        elif phase == Phase.TRANSITIONAL:
            # Balanced allocation
            return [(t.name, 0.5 / len(self.tactics)) for t in self.tactics] + \
                   [("lemma_synthesis", 0.5)]
        else:
            # Synthesis dominates
            return [(t.name, 0.2 / len(self.tactics)) for t in self.tactics] + \
                   [("lemma_synthesis", 0.8)]

    def expected_cost(self, goal_complexity: int) -> Dict[str, int]:
        """Estimate expected cost under each strategy."""
        phase = predict_phase(self.threshold, goal_complexity)
        use_lemma = phase != Phase.TRACTABLE

        result = {}
        for t in self.tactics:
            cost = t.lemma_cost if use_lemma else t.base_cost
            result[t.name] = cost
        return result


# ─── Application 2: Proof-Search Curriculum Designer ────────────────────

@dataclass
class CurriculumLevel:
    """A level in the proof-search curriculum."""
    name: str
    phase: int
    complexity_range: Tuple[int, int]
    strategy: str
    example_problems: List[str]


class CurriculumDesigner:
    """Designs training curricula based on phase transition theory.

    The key insight (formally verified as `curriculumBucket_agrees_with_policy`):
    the curriculum partition agrees with the phase-aware policy. Training on
    tractable instances first builds the foundation for synthesis-heavy phases.
    """

    def __init__(self, threshold: int):
        self.threshold = threshold

    def design(self, max_complexity: int) -> List[CurriculumLevel]:
        """Generate a phase-aware curriculum."""
        levels = []

        # Phase 1: Tractable
        levels.append(CurriculumLevel(
            name="Foundation",
            phase=Phase.TRACTABLE,
            complexity_range=(0, self.threshold),
            strategy="Direct search with simple tactics (simp, ring, omega)",
            example_problems=[
                "Linear arithmetic goals",
                "Simple algebraic identities",
                "Direct application of known lemmas",
            ]
        ))

        # Phase 2: Transitional
        levels.append(CurriculumLevel(
            name="Bridge",
            phase=Phase.TRANSITIONAL,
            complexity_range=(self.threshold + 1, 2 * self.threshold),
            strategy="Mixed: direct tactics + lightweight lemma introduction",
            example_problems=[
                "Multi-step rewriting chains",
                "Goals requiring one intermediate lemma",
                "Bounded inductions",
            ]
        ))

        # Phase 3: Intractable without synthesis
        levels.append(CurriculumLevel(
            name="Mastery",
            phase=Phase.INTRACTABLE,
            complexity_range=(2 * self.threshold + 1, max_complexity),
            strategy="Lemma synthesis dominates: decompose, abstract, reuse",
            example_problems=[
                "Exponential-size proof terms without compression",
                "Goals requiring novel intermediate abstractions",
                "Problems where direct search timeout is guaranteed",
            ]
        ))

        return levels

    def classify_problem(self, complexity: int) -> str:
        """Classify a single problem into the appropriate curriculum level."""
        phase = predict_phase(self.threshold, complexity)
        return ["Foundation", "Bridge", "Mastery"][phase]


# ─── Application 3: Energy Landscape Analysis ──────────────────────────

def compute_energy_landscape(
    base_fn, reduced_fn, max_n: int = 20
) -> List[Dict]:
    """Compute the reasoning energy landscape.

    Returns data points showing energy before and after synthesis,
    illustrating the formal theorem `synthesis_lowers_reasoningEnergy`.
    """
    landscape = []
    for n in range(max_n + 1):
        base_e = float(base_fn(n))
        reduced_e = float(reduced_fn(n))
        gap = base_e - reduced_e

        landscape.append({
            "n": n,
            "energy_direct": base_e,
            "energy_synthesis": reduced_e,
            "energy_gap": gap,
            "gap_ratio": gap / base_e if base_e > 0 else 0,
        })
    return landscape


def print_energy_landscape(landscape: List[Dict]):
    """Display energy landscape as ASCII chart."""
    print(f"\n{'n':>4} | {'E(direct)':>12} | {'E(synth)':>12} | {'Gap':>12} | {'Ratio':>8}")
    print(f"{'-'*4}-+-{'-'*12}-+-{'-'*12}-+-{'-'*12}-+-{'-'*8}")

    for pt in landscape:
        ratio_str = f"{pt['gap_ratio']:.1%}" if pt['gap_ratio'] > 0 else "  0.0%"
        # Truncate large numbers
        de = pt['energy_direct']
        se = pt['energy_synthesis']
        gap = pt['energy_gap']
        de_s = f"{de:.0f}" if de < 1e8 else f"{de:.2e}"
        se_s = f"{se:.0f}" if se < 1e8 else f"{se:.2e}"
        gap_s = f"{gap:.0f}" if abs(gap) < 1e8 else f"{gap:.2e}"
        print(f"{pt['n']:>4} | {de_s:>12} | {se_s:>12} | {gap_s:>12} | {ratio_str:>8}")


# ─── Application 4: Resource Allocation Optimizer ───────────────────────

@dataclass
class AllocationResult:
    """Result of resource allocation optimization."""
    budget: int
    direct_solves: int
    synthesis_solves: int
    phase_aware_solves: int
    optimal_threshold: int


def optimize_allocation(
    base_fn, reduced_fn,
    budget: int,
    max_n: int = 30,
    threshold_range: range = range(1, 15),
) -> AllocationResult:
    """Find optimal threshold for phase-aware resource allocation.

    Tests different thresholds and finds the one that maximizes
    the number of problems solved within budget.

    This operationalizes the dominance theorem:
    `phaseAware_dominates_direct_above_threshold`.
    """
    # Direct search baseline
    direct_solves = sum(1 for n in range(max_n + 1) if base_fn(n) <= budget)

    # Pure synthesis
    synthesis_solves = sum(1 for n in range(max_n + 1) if reduced_fn(n) <= budget)

    # Phase-aware: test each threshold
    best_threshold = 1
    best_count = 0

    for t in threshold_range:
        count = 0
        for n in range(max_n + 1):
            phase = predict_phase(t, n)
            if phase == Phase.TRACTABLE:
                # Use direct (assume small overhead for switching)
                if base_fn(n) <= budget:
                    count += 1
            else:
                # Use synthesis
                if reduced_fn(n) <= budget:
                    count += 1
        if count > best_count:
            best_count = count
            best_threshold = t

    return AllocationResult(
        budget=budget,
        direct_solves=direct_solves,
        synthesis_solves=synthesis_solves,
        phase_aware_solves=best_count,
        optimal_threshold=best_threshold,
    )


# ─── Main Demo ──────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  Phase-Aware Lemma Synthesis: Applications")
    print("=" * 70)

    # App 1: Tactic Scheduler
    print("\n▶ Application 1: Adaptive Tactic Scheduler")
    print("-" * 50)
    tactics = [
        TacticConfig("simp", 5, 3, 0.7),
        TacticConfig("ring", 8, 4, 0.5),
        TacticConfig("omega", 10, 6, 0.4),
    ]
    scheduler = AdaptiveTacticScheduler(threshold=5, tactics=tactics)

    for complexity in [3, 7, 15]:
        phase = predict_phase(5, complexity)
        schedule = scheduler.schedule(complexity)
        costs = scheduler.expected_cost(complexity)
        print(f"\n  Goal complexity={complexity} ({Phase.name(phase)}):")
        print(f"    Schedule: {schedule}")
        print(f"    Expected costs: {costs}")

    # App 2: Curriculum Design
    print("\n\n▶ Application 2: Proof-Search Curriculum")
    print("-" * 50)
    designer = CurriculumDesigner(threshold=5)
    curriculum = designer.design(max_complexity=25)

    for level in curriculum:
        print(f"\n  Level: {level.name} (Phase: {Phase.name(level.phase)})")
        print(f"    Complexity range: {level.complexity_range}")
        print(f"    Strategy: {level.strategy}")
        print(f"    Examples: {level.example_problems[0]}")

    # App 3: Energy Landscape
    print("\n\n▶ Application 3: Energy Landscape (Exponential Model)")
    print("-" * 50)
    landscape = compute_energy_landscape(
        lambda n: 2 ** n,
        lambda n: n + 1,
        max_n=15,
    )
    print_energy_landscape(landscape)

    # App 4: Resource Allocation
    print("\n\n▶ Application 4: Resource Allocation Optimization")
    print("-" * 50)
    result = optimize_allocation(
        lambda n: 2 ** n,
        lambda n: n + 1,
        budget=100,
        max_n=20,
    )
    print(f"  Budget: {result.budget}")
    print(f"  Direct search solves:    {result.direct_solves}/21")
    print(f"  Pure synthesis solves:   {result.synthesis_solves}/21")
    print(f"  Phase-aware solves:      {result.phase_aware_solves}/21")
    print(f"  Optimal threshold:       {result.optimal_threshold}")
    print(f"  ★ Phase-aware advantage: +{result.phase_aware_solves - result.direct_solves} over direct")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Phase-Aware Lemma Synthesis: Interactive Demonstration

This demo illustrates the mathematical theory of reasoning phase transitions.
Given a complexity score and threshold, it predicts the phase, chooses the
optimal search action, and compares direct vs. synthesis effective complexity.

Usage:
    python demo.py                    # Interactive mode
    python demo.py --benchmark        # Run benchmark simulation
    python demo.py --complexity 15 --threshold 5  # Single query
"""

import argparse
import sys
from enum import Enum
from dataclasses import dataclass
from typing import Callable


# ─── Phase Classification ────────────────────────────────────────────────

class Phase(Enum):
    TRACTABLE = 0
    TRANSITIONAL = 1
    INTRACTABLE = 2

    def __str__(self):
        labels = {0: "Tractable ✓", 1: "Transitional ⚠", 2: "Intractable ✗"}
        return labels[self.value]


class SearchAction(Enum):
    DIRECT = "direct"
    SYNTHESIZE_LEMMAS = "synthesize_lemmas"

    def __str__(self):
        if self == SearchAction.DIRECT:
            return "Direct Search"
        return "Lemma Synthesis"


# ─── Core Definitions (mirroring Lean formalization) ─────────────────────

def predicted_phase(threshold: int, n: int) -> Phase:
    """Phase prediction given a threshold parameter.
    Below threshold: tractable. Up to 2× threshold: transitional. Above: intractable."""
    if n <= threshold:
        return Phase.TRACTABLE
    elif n <= 2 * threshold:
        return Phase.TRANSITIONAL
    else:
        return Phase.INTRACTABLE


def phase_aware_policy(phase: Phase) -> SearchAction:
    """Phase-aware policy: direct search in tractable phase, synthesis otherwise."""
    if phase == Phase.TRACTABLE:
        return SearchAction.DIRECT
    return SearchAction.SYNTHESIZE_LEMMAS


@dataclass
class LemmaBenefit:
    """A lemma benefit model capturing complexity reduction through synthesis."""
    name: str
    base_complexity: Callable[[int], int]
    reduced_complexity: Callable[[int], int]

    def effective_complexity(self, use_lemma: bool, n: int) -> int:
        return self.reduced_complexity(n) if use_lemma else self.base_complexity(n)


def reasoning_energy(complexity_fn: Callable[[int], int], n: int) -> float:
    """Reasoning energy proportional to complexity."""
    return float(complexity_fn(n))


# ─── Concrete Models ─────────────────────────────────────────────────────

EXPONENTIAL_MODEL = LemmaBenefit(
    name="Exponential (Powerset Expansion)",
    base_complexity=lambda n: 2 ** n,
    reduced_complexity=lambda n: n + 1,
)

QUADRATIC_MODEL = LemmaBenefit(
    name="Quadratic (Telescoping Sums)",
    base_complexity=lambda n: n * n + 1,
    reduced_complexity=lambda n: n + 1,
)

CUBIC_MODEL = LemmaBenefit(
    name="Cubic (Nested Inductions)",
    base_complexity=lambda n: n ** 3,
    reduced_complexity=lambda n: 3 * n,
)


# ─── Display Functions ───────────────────────────────────────────────────

def display_analysis(n: int, threshold: int, model: LemmaBenefit):
    """Display full phase-aware analysis for a single instance."""
    phase = predicted_phase(threshold, n)
    action = phase_aware_policy(phase)
    base = model.base_complexity(n)
    reduced = model.reduced_complexity(n)
    direct_energy = reasoning_energy(model.base_complexity, n)
    synth_energy = reasoning_energy(model.reduced_complexity, n)

    print(f"\n{'='*60}")
    print(f"  Phase-Aware Analysis: {model.name}")
    print(f"{'='*60}")
    print(f"  Complexity Score:     {n}")
    print(f"  Threshold:            {threshold}")
    print(f"  Predicted Phase:      {phase}")
    print(f"  Chosen Action:        {action}")
    print(f"  Base Complexity:      {base}")
    print(f"  Reduced Complexity:   {reduced}")
    if base > 0:
        ratio = base / reduced if reduced > 0 else float('inf')
        print(f"  Compression Ratio:    {ratio:.2f}×")
    print(f"  Reasoning Energy (direct):    {direct_energy:.1f}")
    print(f"  Reasoning Energy (synthesis): {synth_energy:.1f}")
    if direct_energy > synth_energy:
        print(f"  Energy Reduction:     {direct_energy - synth_energy:.1f} "
              f"({100*(direct_energy - synth_energy)/direct_energy:.1f}%)")
    print(f"{'='*60}")


def run_benchmark(model: LemmaBenefit, threshold: int, budget: int, max_n: int = 20):
    """Simulate benchmark: count problems solved by each strategy within budget."""
    print(f"\n{'='*70}")
    print(f"  Benchmark: {model.name}")
    print(f"  Threshold: {threshold}  |  Budget: {budget}  |  Range: 0..{max_n}")
    print(f"{'='*70}")
    print(f"{'n':>4} | {'Phase':>14} | {'Base':>8} | {'Reduced':>8} | {'Direct':>8} | {'Synth':>8}")
    print(f"{'-'*4}-+-{'-'*14}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}")

    direct_solved = 0
    synth_solved = 0

    for n in range(max_n + 1):
        phase = predicted_phase(threshold, n)
        base = model.base_complexity(n)
        reduced = model.reduced_complexity(n)
        d_ok = base <= budget
        s_ok = reduced <= budget
        if d_ok:
            direct_solved += 1
        if s_ok:
            synth_solved += 1

        d_sym = "  ✓" if d_ok else "  ✗"
        s_sym = "  ✓" if s_ok else "  ✗"
        print(f"{n:>4} | {str(phase):>14} | {base:>8} | {reduced:>8} | {d_sym:>8} | {s_sym:>8}")

    print(f"\n  Direct search solved:  {direct_solved}/{max_n+1}")
    print(f"  Lemma synthesis solved: {synth_solved}/{max_n+1}")
    advantage = synth_solved - direct_solved
    if advantage > 0:
        print(f"  ★ Synthesis advantage: +{advantage} problems solved")
    print()


def interactive_mode():
    """Run interactive exploration."""
    print("\n" + "="*60)
    print("  Phase-Aware Lemma Synthesis — Interactive Demo")
    print("="*60)
    print("\nModels available:")
    print("  1. Exponential (powerset expansion: 2^n vs n+1)")
    print("  2. Quadratic (telescoping sums: n²+1 vs n+1)")
    print("  3. Cubic (nested inductions: n³ vs 3n)")

    models = {1: EXPONENTIAL_MODEL, 2: QUADRATIC_MODEL, 3: CUBIC_MODEL}

    while True:
        try:
            print("\n--- Enter parameters (Ctrl+C to quit) ---")
            model_idx = int(input("Model [1-3]: "))
            model = models.get(model_idx, EXPONENTIAL_MODEL)
            n = int(input("Complexity score n: "))
            threshold = int(input("Threshold: "))
            display_analysis(n, threshold, model)
        except (ValueError, EOFError):
            print("Invalid input, try again.")
        except KeyboardInterrupt:
            print("\nGoodbye!")
            break


def main():
    parser = argparse.ArgumentParser(description="Phase-Aware Lemma Synthesis Demo")
    parser.add_argument("--benchmark", action="store_true", help="Run benchmark simulation")
    parser.add_argument("--complexity", type=int, help="Complexity score for single query")
    parser.add_argument("--threshold", type=int, default=5, help="Phase threshold (default 5)")
    parser.add_argument("--budget", type=int, default=100, help="Budget for benchmark (default 100)")
    parser.add_argument("--max-n", type=int, default=15, help="Max n for benchmark (default 15)")
    args = parser.parse_args()

    if args.benchmark:
        for model in [EXPONENTIAL_MODEL, QUADRATIC_MODEL, CUBIC_MODEL]:
            run_benchmark(model, args.threshold, args.budget, args.max_n)
    elif args.complexity is not None:
        for model in [EXPONENTIAL_MODEL, QUADRATIC_MODEL, CUBIC_MODEL]:
            display_analysis(args.complexity, args.threshold, model)
    else:
        # Default: show a comprehensive example
        print("\n" + "★"*60)
        print("  Phase-Aware Lemma Synthesis: Demonstration")
        print("★"*60)

        print("\n▶ Example analyses with threshold = 5:")
        for n in [3, 5, 8, 12]:
            display_analysis(n, 5, EXPONENTIAL_MODEL)

        print("\n▶ Benchmark comparison:")
        run_benchmark(EXPONENTIAL_MODEL, 5, 100, 15)
        run_benchmark(QUADRATIC_MODEL, 5, 100, 15)


if __name__ == "__main__":
    main()
