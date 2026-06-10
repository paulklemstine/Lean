#!/usr/bin/env python3
"""
Proof Compression Phase Transitions — Applications

This module demonstrates real-world applications of the proof compression
phase transition theory:

1. Proof library design: Identifying compression lemmas
2. Automated prover design: Phase-aware search strategies
3. Mathematical pedagogy: Optimal abstraction introduction
4. Benchmark generation: Systematic difficulty scaling

Each application uses the formally verified theoretical framework
to derive practical recommendations.
"""

from dataclasses import dataclass
from typing import List, Dict, Tuple
import math


@dataclass
class TheoremFamily:
    """A parameterized family of theorems with cost characteristics."""
    name: str
    description: str
    human_cost: callable  # n → cost
    auto_cost: callable   # n → cost
    key_lemma: str        # The compression lemma
    branching_factor: int  # Branching factor of naive expansion


# === Application 1: Proof Library Design ===

def identify_compression_lemmas(families: List[TheoremFamily]) -> Dict[str, dict]:
    """Identify which lemmas provide the greatest proof compression.

    For each theorem family, compute the compression gain from adding
    the key lemma. Higher gain means the lemma is more valuable for
    the library.

    Returns:
        Dictionary mapping lemma names to compression statistics
    """
    results = {}
    for family in families:
        gains = []
        for n in range(1, 31):
            auto = family.auto_cost(n)
            human = family.human_cost(n)
            ratio = auto / max(1, human)
            gains.append(ratio)

        results[family.key_lemma] = {
            'family': family.name,
            'max_gain_at_30': gains[-1],
            'growth_rate': 'exponential' if gains[-1] > 1000 else 'polynomial',
            'recommendation': 'ESSENTIAL' if gains[-1] > 100 else 'USEFUL',
        }

    return results


# === Application 2: Prover Design ===

def phase_aware_strategy(n: int, threshold: int = 5) -> dict:
    """Recommend a proof strategy based on phase prediction.

    Below threshold: use direct automation (simp, omega, decide).
    Transitional: try automation first, then lemma-guided search.
    Above threshold: invest in lemma discovery before search.

    Returns:
        Strategy recommendation with time allocation
    """
    if n <= threshold:
        return {
            'phase': 'tractable',
            'strategy': 'Direct automation',
            'tactics': ['simp', 'omega', 'decide', 'norm_num'],
            'lemma_search_budget': 0.0,
            'direct_search_budget': 1.0,
            'expected_success': 'high',
        }
    elif n <= 2 * threshold:
        return {
            'phase': 'transitional',
            'strategy': 'Hybrid: try automation, then lemma-guided',
            'tactics': ['simp', 'induction', 'rw [key_lemma]'],
            'lemma_search_budget': 0.3,
            'direct_search_budget': 0.7,
            'expected_success': 'medium',
        }
    else:
        return {
            'phase': 'intractable',
            'strategy': 'Lemma discovery first',
            'tactics': ['have key_lemma := ...', 'induction', 'rw'],
            'lemma_search_budget': 0.7,
            'direct_search_budget': 0.3,
            'expected_success': 'low without lemmas, high with lemmas',
        }


# === Application 3: Pedagogy ===

def optimal_abstraction_point(family: TheoremFamily, ratio_threshold: float = 10.0) -> int:
    """Find the optimal point to introduce an abstraction in teaching.

    The optimal point is where the compression ratio first exceeds the
    threshold — this is where students benefit most from learning the
    intermediate concept.

    Returns:
        Optimal n to introduce the abstraction
    """
    for n in range(1, 100):
        ratio = family.auto_cost(n) / max(1, family.human_cost(n))
        if ratio > ratio_threshold:
            return n
    return 100


# === Application 4: Benchmark Generation ===

def generate_benchmark_suite(
    families: List[TheoremFamily],
    sizes: List[int],
) -> List[dict]:
    """Generate a systematic benchmark suite with known difficulty.

    Each benchmark instance has a predicted difficulty class based
    on the phase transition theory.

    Returns:
        List of benchmark instances with metadata
    """
    benchmarks = []
    for family in families:
        for n in sizes:
            human = family.human_cost(n)
            auto = family.auto_cost(n)
            ratio = auto / max(1, human)

            benchmarks.append({
                'family': family.name,
                'parameter': n,
                'human_cost': human,
                'auto_cost': auto,
                'compression_ratio': round(ratio, 2),
                'predicted_difficulty': (
                    'easy' if ratio < 5
                    else 'medium' if ratio < 50
                    else 'hard'
                ),
                'requires_lemma': ratio > 10,
            })

    return benchmarks


# === Concrete theorem families ===

SUBSET_EXPANSION = TheoremFamily(
    name="Powerset Expansion",
    description="∏(1 + f_i) = ∑_{S ⊆ [n]} ∏_{i∈S} f_i",
    human_cost=lambda n: n + 1,
    auto_cost=lambda n: 2 ** n,
    key_lemma="Finset.prod_one_add",
    branching_factor=2,
)

TELESCOPING = TheoremFamily(
    name="Telescoping Identity",
    description="(x-1) · ∑ x^i = x^n - 1",
    human_cost=lambda n: n + 1,
    auto_cost=lambda n: n * n + 1,
    key_lemma="geom_sum_mul",
    branching_factor=1,  # polynomial, not exponential
)

BINOMIAL = TheoremFamily(
    name="Binomial Theorem",
    description="(a+b)^n = ∑ C(n,k) a^k b^(n-k)",
    human_cost=lambda n: n + 1,
    auto_cost=lambda n: 2 ** n,
    key_lemma="Commute.add_pow",
    branching_factor=2,
)

ALL_FAMILIES = [SUBSET_EXPANSION, TELESCOPING, BINOMIAL]


def main():
    """Run all application demonstrations."""
    print("=" * 70)
    print("  PROOF COMPRESSION PHASE TRANSITIONS — APPLICATIONS")
    print("=" * 70)

    # Application 1: Library design
    print("\n--- Application 1: Proof Library Design ---\n")
    lemma_analysis = identify_compression_lemmas(ALL_FAMILIES)
    for lemma, stats in lemma_analysis.items():
        print(f"  Lemma: {lemma}")
        print(f"    Family: {stats['family']}")
        print(f"    Max compression gain at n=30: {stats['max_gain_at_30']:,.1f}x")
        print(f"    Growth rate: {stats['growth_rate']}")
        print(f"    Recommendation: {stats['recommendation']}")
        print()

    # Application 2: Prover design
    print("--- Application 2: Phase-Aware Prover Strategy ---\n")
    for n in [2, 5, 8, 15, 25]:
        strategy = phase_aware_strategy(n)
        print(f"  n={n}: [{strategy['phase']}] {strategy['strategy']}")
        print(f"    Lemma budget: {strategy['lemma_search_budget']:.0%}, "
              f"Search budget: {strategy['direct_search_budget']:.0%}")
        print(f"    Expected success: {strategy['expected_success']}")
        print()

    # Application 3: Pedagogy
    print("--- Application 3: Optimal Abstraction Introduction ---\n")
    for family in ALL_FAMILIES:
        point = optimal_abstraction_point(family)
        print(f"  {family.name}: introduce '{family.key_lemma}' at n = {point}")
        print(f"    Description: {family.description}")
        print()

    # Application 4: Benchmark suite
    print("--- Application 4: Benchmark Suite Generation ---\n")
    benchmarks = generate_benchmark_suite(ALL_FAMILIES, [1, 3, 5, 10, 15, 20])
    print(f"  Generated {len(benchmarks)} benchmark instances:\n")
    print(f"  {'Family':<22} {'n':>3} {'Human':>6} {'Auto':>10} "
          f"{'Ratio':>10} {'Difficulty':>10} {'Needs Lemma':>12}")
    print(f"  {'-'*75}")
    for b in benchmarks:
        print(f"  {b['family']:<22} {b['parameter']:>3} {b['human_cost']:>6} "
              f"{b['auto_cost']:>10,} {b['compression_ratio']:>10.1f} "
              f"{b['predicted_difficulty']:>10} {'YES' if b['requires_lemma'] else 'no':>12}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Proof Compression Phase Transitions — Interactive Demonstration

This script visualizes the proof compression phase transition phenomenon:
how automation cost explodes relative to structured proof cost beyond a
critical complexity threshold, and how adding reusable lemmas collapses
the gap.

Usage:
    python demo.py

Generates plots saved as PNG files and prints numerical tables to stdout.
"""

import math
from typing import List, Tuple


def human_cost_subset(n: int) -> int:
    """Human (structured) proof cost for the powerset expansion family.
    One induction step per element, so cost is n + 1."""
    return n + 1


def auto_cost_subset(n: int) -> int:
    """Automation (flat) proof cost for the powerset expansion family.
    One term per subset, so cost is 2^n."""
    return 2 ** n


def augmented_cost_subset(n: int) -> int:
    """Automation cost after adding the inductive lemma as a basis.
    With the lemma, each step is one application, so cost is n + 1."""
    return n + 1


def human_cost_telescoping(n: int) -> int:
    """Human proof cost for the telescoping identity family."""
    return n + 1


def auto_cost_telescoping(n: int) -> int:
    """Automation cost for telescoping: quadratic expansion."""
    return n * n + 1


def compression_ratio(human: int, auto: int) -> float:
    """Compression ratio: auto_cost / max(1, human_cost)."""
    return auto / max(1, human)


def predicted_phase(threshold: int, n: int) -> str:
    """Predict the proof regime phase given a threshold."""
    if n <= threshold:
        return "tractable"
    elif n <= 2 * threshold:
        return "transitional"
    else:
        return "intractable"


def phase_index(phase: str) -> int:
    """Numerical index for phase ordering."""
    return {"tractable": 0, "transitional": 1, "intractable": 2}[phase]


def verify_monotonicity(threshold: int, max_n: int = 100) -> bool:
    """Verify that phase prediction is monotone (Theorem 5)."""
    prev = 0
    for n in range(max_n + 1):
        curr = phase_index(predicted_phase(threshold, n))
        if curr < prev:
            return False
        prev = curr
    return True


def find_threshold(max_n: int = 50, ratio_bound: float = 10.0) -> int:
    """Find the empirical threshold where compression ratio exceeds ratio_bound."""
    for n in range(max_n):
        r = compression_ratio(human_cost_subset(n), auto_cost_subset(n))
        if r > ratio_bound:
            return n
    return max_n


def print_table(title: str, headers: List[str], rows: List[List], widths: List[int]):
    """Print a formatted table."""
    print(f"\n{'=' * 70}")
    print(f"  {title}")
    print(f"{'=' * 70}")
    header_line = " | ".join(h.rjust(w) for h, w in zip(headers, widths))
    print(f"  {header_line}")
    print(f"  {'-' * len(header_line)}")
    for row in rows:
        row_line = " | ".join(str(v).rjust(w) for v, w in zip(row, widths))
        print(f"  {row_line}")


def demo_compression_ratio():
    """Demonstrate the compression ratio growth for subset expansion."""
    headers = ["n", "Human", "Auto", "Augmented", "Ratio", "Aug.Ratio", "Phase"]
    widths = [4, 8, 14, 10, 14, 10, 14]
    rows = []
    threshold = 5

    for n in range(0, 31):
        h = human_cost_subset(n)
        a = auto_cost_subset(n)
        aug = augmented_cost_subset(n)
        r = compression_ratio(h, a)
        ar = compression_ratio(h, aug)
        p = predicted_phase(threshold, n)
        if n <= 15 or n % 5 == 0:
            rows.append([n, h, f"{a:,}", aug, f"{r:,.1f}", f"{ar:.1f}", p])

    print_table(
        "Subset Expansion: Compression Ratio Growth",
        headers, rows, widths
    )


def demo_cross_domain():
    """Compare compression ratios across domains."""
    headers = ["n", "Subset Ratio", "Telescoping Ratio"]
    widths = [4, 16, 18]
    rows = []

    for n in [1, 2, 3, 5, 10, 15, 20, 25, 30]:
        sr = compression_ratio(human_cost_subset(n), auto_cost_subset(n))
        tr = compression_ratio(human_cost_telescoping(n), auto_cost_telescoping(n))
        rows.append([n, f"{sr:,.1f}", f"{tr:.1f}"])

    print_table(
        "Cross-Domain Comparison: Subset vs Telescoping",
        headers, rows, widths
    )


def demo_lemma_basis_collapse():
    """Demonstrate the lemma basis collapse effect."""
    print(f"\n{'=' * 70}")
    print(f"  Lemma Basis Collapse: Before and After Adding Inductive Lemma")
    print(f"{'=' * 70}")
    print()
    print("  Before augmentation:")
    print("    autoCost(n) = 2^n  (exponential)")
    print("    Asymptotic gap: YES (unbounded compression ratio)")
    print()
    print("  After augmentation (adding one reusable lemma):")
    print("    autoCost(n) = n+1  (linear)")
    print("    Asymptotic gap: NO  (constant-factor relationship)")
    print()

    headers = ["n", "Before (2^n)", "After (n+1)", "Reduction Factor"]
    widths = [4, 14, 10, 18]
    rows = []

    for n in [1, 5, 10, 15, 20, 25, 30]:
        before = auto_cost_subset(n)
        after = augmented_cost_subset(n)
        factor = before / max(1, after)
        rows.append([n, f"{before:,}", after, f"{factor:,.1f}x"])

    print_table(
        "Cost Reduction from Lemma Augmentation",
        headers, rows, widths
    )


def demo_threshold():
    """Demonstrate threshold existence."""
    print(f"\n{'=' * 70}")
    print(f"  Phase Transition Threshold Detection")
    print(f"{'=' * 70}")

    for bound in [2, 5, 10, 100, 1000]:
        t = find_threshold(ratio_bound=bound)
        print(f"  Ratio exceeds {bound:>5}: threshold at n = {t}")

    print()
    print("  Verified monotonicity of phase predictor:", verify_monotonicity(5))


def demo_phase_diagram():
    """Print an ASCII phase diagram."""
    print(f"\n{'=' * 70}")
    print(f"  Phase Diagram (threshold = 5)")
    print(f"{'=' * 70}")
    print()

    threshold = 5
    for n in range(25):
        phase = predicted_phase(threshold, n)
        ratio = compression_ratio(human_cost_subset(n), auto_cost_subset(n))
        bar_len = min(60, int(math.log2(max(1, ratio)) * 3))
        symbol = {"tractable": ".", "transitional": "~", "intractable": "#"}[phase]
        bar = symbol * bar_len
        phase_label = f"[{phase[:5]:>5}]"
        print(f"  n={n:>2} {phase_label} |{bar}")

    print()
    print("  Legend: . = tractable, ~ = transitional, # = intractable")
    print("  Bar length ∝ log₂(compression ratio)")


def generate_plot_data() -> Tuple[List[int], List[float], List[float], List[float]]:
    """Generate data for plotting."""
    ns = list(range(1, 26))
    ratios_subset = []
    ratios_telescoping = []
    ratios_augmented = []

    for n in ns:
        ratios_subset.append(
            compression_ratio(human_cost_subset(n), auto_cost_subset(n))
        )
        ratios_telescoping.append(
            compression_ratio(human_cost_telescoping(n), auto_cost_telescoping(n))
        )
        ratios_augmented.append(
            compression_ratio(human_cost_subset(n), augmented_cost_subset(n))
        )

    return ns, ratios_subset, ratios_telescoping, ratios_augmented


def try_matplotlib_plot():
    """Attempt to generate matplotlib plots if available."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        ns, ratios_subset, ratios_telescoping, ratios_augmented = generate_plot_data()

        # Plot 1: Compression ratio comparison
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

        ax1.semilogy(ns, ratios_subset, 'r-o', label='Subset expansion (2^n/(n+1))',
                     markersize=4, linewidth=2)
        ax1.semilogy(ns, ratios_telescoping, 'b-s', label='Telescoping ((n²+1)/(n+1))',
                     markersize=4, linewidth=2)
        ax1.semilogy(ns, ratios_augmented, 'g--^', label='Augmented (constant)',
                     markersize=4, linewidth=2)
        ax1.axvline(x=5, color='gray', linestyle=':', alpha=0.7, label='Threshold (c=5)')
        ax1.set_xlabel('Semantic Complexity n', fontsize=12)
        ax1.set_ylabel('Compression Ratio (log scale)', fontsize=12)
        ax1.set_title('Proof Compression Phase Transition', fontsize=14)
        ax1.legend(fontsize=10)
        ax1.grid(True, alpha=0.3)

        # Plot 2: Cost comparison
        ns2 = list(range(0, 16))
        human = [human_cost_subset(n) for n in ns2]
        auto = [auto_cost_subset(n) for n in ns2]
        augmented = [augmented_cost_subset(n) for n in ns2]

        ax2.semilogy(ns2, auto, 'r-o', label='Auto cost (2^n)', markersize=4, linewidth=2)
        ax2.semilogy(ns2, human, 'b-s', label='Human cost (n+1)', markersize=4, linewidth=2)
        ax2.semilogy(ns2, augmented, 'g--^', label='Augmented cost (n+1)',
                     markersize=4, linewidth=2)
        ax2.set_xlabel('Theorem Family Parameter n', fontsize=12)
        ax2.set_ylabel('Proof Cost (log scale)', fontsize=12)
        ax2.set_title('Lemma Basis Collapse Effect', fontsize=14)
        ax2.legend(fontsize=10)
        ax2.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig('proof_compression_phase_transition.png', dpi=150)
        print("\n  [Plot saved to proof_compression_phase_transition.png]")
        return True

    except ImportError:
        print("\n  [matplotlib not available — using text-based visualization]")
        return False


def main():
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║       PROOF COMPRESSION PHASE TRANSITIONS — DEMONSTRATION          ║")
    print("║                                                                    ║")
    print("║  Showing that lemma invention is a mathematically necessary        ║")
    print("║  phase transition phenomenon, not an implementation detail.        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_compression_ratio()
    demo_cross_domain()
    demo_lemma_basis_collapse()
    demo_threshold()
    demo_phase_diagram()
    try_matplotlib_plot()

    print(f"\n{'=' * 70}")
    print("  Summary of Verified Results")
    print(f"{'=' * 70}")
    print()
    print("  1. gap_of_linear_vs_exponential: Linear human + exponential auto")
    print("     ⟹ unbounded compression ratio (PROVED)")
    print()
    print("  2. subsetExpansion_unbounded_gap: Powerset expansion exhibits")
    print("     unbounded gap with branching factor 2 (PROVED)")
    print()
    print("  3. augmented_no_gap: Adding one inductive lemma collapses the")
    print("     exponential blowup to constant factor (PROVED)")
    print()
    print("  4. subsetExpansion_has_threshold: Formal phase transition at")
    print("     threshold c = 0 (PROVED)")
    print()
    print("  5. telescoping_unbounded_gap: Cross-domain validation with")
    print("     telescoping identities (PROVED)")
    print()
    print("  6. predictedPhase_monotone: Phase predictor is well-ordered (PROVED)")
    print()


if __name__ == "__main__":
    main()
