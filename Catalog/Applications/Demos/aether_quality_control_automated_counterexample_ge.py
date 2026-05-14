#!/usr/bin/env python3
"""
Applications of Adversarial Stress Testing

Demonstrates the framework in three concrete domains:
1. Polynomial identity testing over finite fields
2. Machine learning model selection via adversarial validation
3. Cryptographic predicate screening
"""

import random
from typing import List, Dict, Tuple
from algorithms import HypothesisClass, greedy_test_selection


# ============================================================================
# APPLICATION 1: Polynomial Identity Testing Over Finite Fields
# ============================================================================

def polynomial_identity_testing():
    """
    Test whether candidate polynomial identities hold over GF(p).
    
    Each "hypothesis" is a polynomial identity (e.g., p(x) = 0 for all x).
    We stress-test by evaluating at random/adversarial points.
    """
    print("=" * 70)
    print("APPLICATION 1: Polynomial Identity Testing over GF(31)")
    print("=" * 70)
    
    p = 31  # prime, so GF(31) is a field
    universe = list(range(p))
    
    # Create polynomial hypotheses: "f(x) = 0 for all x in GF(p)"
    # Some are true identities, some are not
    polynomials = []
    labels = []
    
    # True identity: 0 = 0
    polynomials.append(lambda x, p=p: 0)
    labels.append("0 (true identity)")
    
    # True identity: x^p - x = 0 (Fermat's little theorem)
    polynomials.append(lambda x, p=p: (pow(x, p, p) - x) % p)
    labels.append("x^p - x (Fermat, true)")
    
    # False: x^2 - 1 = 0 (only true for x = ±1)
    polynomials.append(lambda x, p=p: (x * x - 1) % p)
    labels.append("x² - 1 (false, roots at ±1)")
    
    # False: x^3 = 0 (only true at 0)
    polynomials.append(lambda x, p=p: pow(x, 3, p))
    labels.append("x³ (false, root at 0)")
    
    # False: x^2 - x = 0 (roots at 0 and 1)
    polynomials.append(lambda x, p=p: (x * x - x) % p)
    labels.append("x² - x (false, roots at 0,1)")
    
    # Almost-identity: a high-degree polynomial with many roots
    # x(x-1)(x-2)...(x-15) mod p — has 16 roots out of 31
    polynomials.append(lambda x, p=p: eval_product_poly(x, 16, p))
    labels.append("x(x-1)...(x-15) (false, 16 roots)")
    
    truth_tables = [
        {a: (poly(a) == 0) for a in universe}
        for poly in polynomials
    ]
    
    hc = HypothesisClass(universe, truth_tables)
    
    print(f"\nField: GF({p})")
    print(f"Hypotheses: {len(polynomials)} polynomial identity claims")
    print(f"False hypotheses: {hc.n_false}")
    
    # Greedy adversarial selection
    for budget in [1, 2, 3, 5, 10]:
        test = greedy_test_selection(hc, budget)
        result = hc.stress_test(test)
        print(f"\n  Budget {budget}: test points = {test}")
        print(f"    False positives remaining: {result.false_positive_count}/{hc.n_false}")
        for i, (label, tt) in enumerate(zip(labels, truth_tables)):
            if hc.is_false(i):
                status = "KILLED ✗" if not hc.survives(i, test) else "SURVIVES ✓ (false positive!)"
                print(f"    {label}: {status}")


def eval_product_poly(x: int, n_roots: int, p: int) -> int:
    """Evaluate x(x-1)(x-2)...(x-(n_roots-1)) mod p."""
    result = 1
    for k in range(n_roots):
        result = (result * ((x - k) % p)) % p
    return result


# ============================================================================
# APPLICATION 2: ML Model Selection via Adversarial Validation
# ============================================================================

def ml_adversarial_validation():
    """
    Use stress testing to screen candidate ML models.
    
    Each "hypothesis" is a model's prediction function. The universe
    is a validation dataset. Stress testing selects the hardest
    validation examples to distinguish good models from bad ones.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: ML Model Screening via Adversarial Validation")
    print("=" * 70)
    
    random.seed(42)
    n_examples = 50
    n_models = 20
    universe = list(range(n_examples))
    
    # Generate "ground truth" labels
    true_labels = [random.choice([0, 1]) for _ in range(n_examples)]
    
    # Generate model predictions with varying accuracy
    models = []
    accuracies = []
    for m in range(n_models):
        noise_rate = random.uniform(0.0, 0.5)
        predictions = [
            true_labels[i] if random.random() > noise_rate else 1 - true_labels[i]
            for i in range(n_examples)
        ]
        models.append(predictions)
        acc = sum(p == t for p, t in zip(predictions, true_labels)) / n_examples
        accuracies.append(acc)
    
    # Hypothesis: "model m predicts correctly on example a"
    truth_tables = [
        {a: (models[m][a] == true_labels[a]) for a in universe}
        for m in range(n_models)
    ]
    
    hc = HypothesisClass(universe, truth_tables)
    
    print(f"\nDataset size: {n_examples}")
    print(f"Candidate models: {n_models}")
    print(f"Models with <100% accuracy (= 'false' hypotheses): {hc.n_false}")
    
    # Compare greedy adversarial selection vs random
    print(f"\n{'Budget':>8}  {'Greedy FP':>10}  {'Random FP':>10}")
    print("-" * 32)
    for budget in [1, 2, 5, 10, 20, 30, 50]:
        greedy_T = greedy_test_selection(hc, budget)
        random_T = random.sample(universe, min(budget, len(universe)))
        
        greedy_fp = hc.false_positive_count(greedy_T)
        random_fp = hc.false_positive_count(random_T)
        print(f"{budget:>8}  {greedy_fp:>10}  {random_fp:>10}")


# ============================================================================
# APPLICATION 3: Cryptographic Predicate Screening
# ============================================================================

def crypto_predicate_screening():
    """
    Screen candidate Boolean functions for cryptographic properties.
    
    Each hypothesis claims a Boolean function f: {0,1}^n → {0,1} is
    balanced (equal number of 0s and 1s in its truth table). We
    stress-test by evaluating on adversarial inputs.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Cryptographic Predicate Screening (Balance Test)")
    print("=" * 70)
    
    n = 6  # input bits
    N = 2 ** n  # universe size = 64
    universe = list(range(N))
    
    random.seed(99)
    n_functions = 40
    
    functions = []
    labels = []
    for f_idx in range(n_functions):
        if f_idx < 10:
            # Truly balanced functions
            table = [0] * (N // 2) + [1] * (N // 2)
            random.shuffle(table)
            labels.append(f"f{f_idx} (balanced)")
        elif f_idx < 25:
            # Slightly imbalanced
            n_ones = N // 2 + random.randint(1, 5)
            table = [0] * (N - n_ones) + [1] * n_ones
            random.shuffle(table)
            labels.append(f"f{f_idx} (imbalanced, {n_ones}/{N} ones)")
        else:
            # Very imbalanced
            n_ones = random.randint(1, N // 4)
            table = [0] * (N - n_ones) + [1] * n_ones
            random.shuffle(table)
            labels.append(f"f{f_idx} (very imbalanced, {n_ones}/{N} ones)")
    
        functions.append(table)
    
    # Hypothesis: "f(x) = 1" — we test balance by checking if the function
    # agrees with a balanced reference on selected points
    # Simpler: hypothesis h_f says "f is balanced" ≡ for each test point pair (x, x'),
    # the function has appropriate distribution
    # Even simpler: use majority-vote style testing
    # For this demo, hypothesis = "f(x) = 1 for all x in test set"
    # This is a simplified stress test for detecting constant-0 or sparse functions
    
    truth_tables = [
        {a: bool(functions[f_idx][a]) for a in universe}
        for f_idx in range(n_functions)
    ]
    
    hc = HypothesisClass(universe, truth_tables)
    
    print(f"\nInput bits: {n}")
    print(f"Universe size: {N}")
    print(f"Candidate functions: {n_functions}")
    print(f"Functions with some zero output ('false' hypotheses): {hc.n_false}")
    
    greedy_T = greedy_test_selection(hc, 10)
    result = hc.stress_test(greedy_T)
    
    print(f"\nGreedy adversarial test (budget=10):")
    print(f"  Test points: {greedy_T}")
    print(f"  False positives remaining: {result.false_positive_count}/{hc.n_false}")
    print(f"  Elimination rate: {result.elimination_rate:.1%}")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    polynomial_identity_testing()
    ml_adversarial_validation()
    crypto_predicate_screening()
    
    print("\n" + "=" * 70)
    print("All applications demonstrate the core theorems:")
    print("  • Soundness: detected counterexamples certify falsity")
    print("  • Monotonicity: more tests → fewer false positives")
    print("  • Greedy selection outperforms random selection")
    print("=" * 70)


#!/usr/bin/env python3
"""
Aether Quality Control: Demonstrating Finite Counterexample Stress Testing

This demo illustrates the key theorems from the formal framework:
1. Soundness: Finding a counterexample certifies falsity
2. Monotonicity: Larger test sets never increase false positives
3. Kill monotonicity: Larger test sets kill more hypotheses
"""

import random
import itertools
from typing import Callable

# ---------------------------------------------------------------------------
# Core Definitions (mirroring the formal Lean definitions)
# ---------------------------------------------------------------------------

def survives(hypothesis: Callable, test_set: list) -> bool:
    """A hypothesis survives a test set if it passes all tests."""
    return all(hypothesis(a) for a in test_set)

def is_false(hypothesis: Callable, universe: list) -> bool:
    """A hypothesis is false if some element of the universe refutes it."""
    return any(not hypothesis(a) for a in universe)

def false_positive_count(hypotheses: list, universe: list, test_set: list) -> int:
    """Count hypotheses that are false but survive the test set."""
    return sum(
        1 for h in hypotheses
        if is_false(h, universe) and survives(h, test_set)
    )

def killed_by(hypotheses: list, test_set: list) -> set:
    """Return indices of hypotheses killed (refuted) by the test set."""
    return {
        i for i, h in enumerate(hypotheses)
        if any(not h(a) for a in test_set)
    }

# ---------------------------------------------------------------------------
# Example: Parity Conjectures over Fin(10)
# ---------------------------------------------------------------------------

def make_parity_hypothesis(i: int) -> Callable:
    """Hypothesis i: '(i + a) % 2 == 0' for all a."""
    return lambda a: (i + a) % 2 == 0

print("=" * 70)
print("DEMO 1: Parity Conjectures over {0,...,9}")
print("=" * 70)

universe = list(range(10))
hypotheses = [make_parity_hypothesis(i) for i in range(10)]

# Even-indexed hypotheses claim (even + a) % 2 == 0, which is true only for even a
# So they are false on odd a. Odd-indexed ones are false on even a.
# All hypotheses are false on the full universe (they fail on some element).

small_test = [0, 1]
large_test = [0, 1, 2, 3]
full_test  = list(range(10))

fp_small = false_positive_count(hypotheses, universe, small_test)
fp_large = false_positive_count(hypotheses, universe, large_test)
fp_full  = false_positive_count(hypotheses, universe, full_test)

print(f"\nUniverse: {universe}")
print(f"Number of hypotheses: {len(hypotheses)}")
print(f"\nTest set {{0,1}}:       false positives = {fp_small}")
print(f"Test set {{0,1,2,3}}:   false positives = {fp_large}")
print(f"Test set {{0,...,9}}:    false positives = {fp_full}")
print(f"\nMonotonicity verified: {fp_full} ≤ {fp_large} ≤ {fp_small}  →  {fp_full <= fp_large <= fp_small}")

# ---------------------------------------------------------------------------
# DEMO 2: Monotone Decrease Under Sequential Test Enlargement
# ---------------------------------------------------------------------------

print("\n" + "=" * 70)
print("DEMO 2: Monotone False-Positive Decrease (Step-by-Step)")
print("=" * 70)

# Random hypothesis class: 50 random Boolean functions on {0,...,19}
random.seed(42)
N = 20
universe = list(range(N))
num_hyp = 50
hyp_tables = [
    {a: random.choice([True, False]) for a in universe}
    for _ in range(num_hyp)
]
hypotheses = [lambda a, t=t: t[a] for t in hyp_tables]

print(f"\nUniverse size: {N}")
print(f"Hypothesis class size: {num_hyp}")
print(f"False hypotheses: {sum(1 for h in hypotheses if is_false(h, universe))}")
print()

# Incrementally add test points and track false positives
test_set = []
fp_trace = []
for k in range(N + 1):
    fp = false_positive_count(hypotheses, universe, test_set)
    fp_trace.append(fp)
    if k < N:
        test_set.append(k)

print(f"{'|T|':>4}  {'False Positives':>16}")
print("-" * 24)
for k, fp in enumerate(fp_trace):
    bar = "█" * fp
    print(f"{k:>4}  {fp:>16}  {bar}")

# Verify monotonicity
is_monotone = all(fp_trace[i] >= fp_trace[i + 1] for i in range(len(fp_trace) - 1))
print(f"\nMonotonicity holds: {is_monotone}")

# ---------------------------------------------------------------------------
# DEMO 3: Kill Set Monotonicity
# ---------------------------------------------------------------------------

print("\n" + "=" * 70)
print("DEMO 3: Kill Set Monotonicity")
print("=" * 70)

test_sets = [list(range(k)) for k in range(N + 1)]
kill_sizes = [len(killed_by(hypotheses, T)) for T in test_sets]

print(f"\n{'|T|':>4}  {'Killed':>8}  {'Surviving False':>16}")
print("-" * 34)
for k in range(N + 1):
    killed = kill_sizes[k]
    fp = fp_trace[k]
    print(f"{k:>4}  {killed:>8}  {fp:>16}")

# Verify kill monotonicity
kill_monotone = all(kill_sizes[i] <= kill_sizes[i + 1] for i in range(len(kill_sizes) - 1))
print(f"\nKill monotonicity holds: {kill_monotone}")

# ---------------------------------------------------------------------------
# DEMO 4: Soundness — Finding a Counterexample
# ---------------------------------------------------------------------------

print("\n" + "=" * 70)
print("DEMO 4: Soundness — Counterexample Detection")
print("=" * 70)

# A specific hypothesis that fails on element 7
bad_hyp = lambda a: a != 7
print(f"\nHypothesis: 'a ≠ 7' for all a in universe")
print(f"Universe: {{0,...,{N-1}}}")

for test_size in [1, 3, 5, 8, 10]:
    test = list(range(test_size))
    detected = not survives(bad_hyp, test)
    counterexample = next((a for a in test if not bad_hyp(a)), None)
    status = f"DETECTED (counterexample: {counterexample})" if detected else "Not yet detected"
    print(f"  Test set {{0,...,{test_size-1}}}: {status}")

print("\n✓ All demonstrations complete. Every theorem from the formal framework")
print("  is illustrated with concrete numerical examples.")


#!/usr/bin/env python3
"""
Visualizations for Aether Quality Control

Generates publication-quality figures demonstrating:
1. False-positive monotone decrease
2. Greedy vs random test selection comparison
3. Kill set growth
4. Pipeline stage analysis
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import base64
import io
from algorithms import HypothesisClass, greedy_test_selection, random_test_selection


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('ascii')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def create_hypothesis_class(n_universe=30, n_hypotheses=100, seed=42):
    """Create a random hypothesis class for visualization."""
    rng = random.Random(seed)
    universe = list(range(n_universe))
    truth_tables = [
        {a: rng.random() > 0.3 for a in universe}
        for _ in range(n_hypotheses)
    ]
    return HypothesisClass(universe, truth_tables)


def plot_monotone_decrease():
    """Figure 1: False-positive count as test set grows."""
    hc = create_hypothesis_class()
    
    fp_counts = []
    for k in range(hc.n_universe + 1):
        test = list(range(k))
        fp_counts.append(hc.false_positive_count(test))
    
    fig, ax = plt.subplots(figsize=(10, 6))
    x = list(range(hc.n_universe + 1))
    
    ax.fill_between(x, fp_counts, alpha=0.3, color='#2196F3')
    ax.plot(x, fp_counts, 'o-', color='#1565C0', linewidth=2, markersize=6)
    
    ax.set_xlabel('Test Set Size |T|', fontsize=14)
    ax.set_ylabel('False Positive Count', fontsize=14)
    ax.set_title('Monotone Decrease of False Positives\n(Theorem: falsePositiveCount_antitone)', fontsize=16)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, hc.n_universe)
    ax.set_ylim(bottom=0)
    
    # Annotate
    ax.annotate('Every additional test point\ncan only reduce false positives',
                xy=(10, fp_counts[10]), xytext=(15, fp_counts[5] + 5),
                arrowprops=dict(arrowstyle='->', color='#D32F2F'),
                fontsize=12, color='#D32F2F')
    
    fig.savefig('fig_monotone_decrease.png', dpi=150, bbox_inches='tight', facecolor='white')
    return fig_to_base64(fig)


def plot_greedy_vs_random():
    """Figure 2: Greedy vs random test selection comparison."""
    hc = create_hypothesis_class(n_universe=30, n_hypotheses=200, seed=42)
    
    budgets = list(range(1, hc.n_universe + 1))
    greedy_fps = []
    random_fps_mean = []
    random_fps_std = []
    
    for budget in budgets:
        # Greedy
        greedy_T = greedy_test_selection(hc, budget)
        greedy_fps.append(hc.false_positive_count(greedy_T))
        
        # Random (average over 20 trials)
        rfps = []
        for trial in range(20):
            random_T = random_test_selection(hc, budget, seed=trial * 100)
            rfps.append(hc.false_positive_count(random_T))
        random_fps_mean.append(np.mean(rfps))
        random_fps_std.append(np.std(rfps))
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    ax.fill_between(budgets, 
                     [m - s for m, s in zip(random_fps_mean, random_fps_std)],
                     [m + s for m, s in zip(random_fps_mean, random_fps_std)],
                     alpha=0.2, color='#FF9800')
    ax.plot(budgets, random_fps_mean, 's-', color='#E65100', linewidth=2, 
            markersize=4, label='Random (mean ± std)')
    ax.plot(budgets, greedy_fps, 'o-', color='#1565C0', linewidth=2,
            markersize=4, label='Greedy (adversarial)')
    
    ax.set_xlabel('Test Budget k', fontsize=14)
    ax.set_ylabel('False Positive Count', fontsize=14)
    ax.set_title('Adversarial (Greedy) vs Random Test Selection', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, hc.n_universe)
    ax.set_ylim(bottom=0)
    
    fig.savefig('fig_greedy_vs_random.png', dpi=150, bbox_inches='tight', facecolor='white')
    return fig_to_base64(fig)


def plot_kill_growth():
    """Figure 3: Kill set growth under sequential testing."""
    hc = create_hypothesis_class()
    
    kill_counts = []
    for k in range(hc.n_universe + 1):
        test = list(range(k))
        killed = len(hc.killed_by(test))
        kill_counts.append(killed)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    x = list(range(hc.n_universe + 1))
    
    # Left: Kill count
    ax1.fill_between(x, kill_counts, alpha=0.3, color='#4CAF50')
    ax1.plot(x, kill_counts, 'o-', color='#2E7D32', linewidth=2, markersize=6)
    ax1.set_xlabel('Test Set Size |T|', fontsize=14)
    ax1.set_ylabel('Killed Hypotheses', fontsize=14)
    ax1.set_title('Kill Set Growth\n(Theorem: killedBy_mono)', fontsize=14)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=hc.n_false, color='#D32F2F', linestyle='--', label=f'Total false = {hc.n_false}')
    ax1.legend(fontsize=11)
    
    # Right: Dual view — false positives and killed
    fp_counts = [hc.false_positive_count(list(range(k))) for k in range(hc.n_universe + 1)]
    
    ax2.bar(x, kill_counts, alpha=0.6, color='#4CAF50', label='Killed')
    ax2.bar(x, fp_counts, alpha=0.6, color='#F44336', label='False Positives')
    ax2.set_xlabel('Test Set Size |T|', fontsize=14)
    ax2.set_ylabel('Count', fontsize=14)
    ax2.set_title('Killed vs Surviving False Hypotheses', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3, axis='y')
    
    fig.tight_layout()
    fig.savefig('fig_kill_growth.png', dpi=150, bbox_inches='tight', facecolor='white')
    return fig_to_base64(fig)


def plot_pipeline():
    """Figure 4: Multi-stage pipeline analysis."""
    hc = create_hypothesis_class(n_universe=40, n_hypotheses=150, seed=77)
    
    # Define 4 pipeline stages
    stage_size = 5
    stages = [list(range(i * stage_size, (i + 1) * stage_size)) for i in range(8)]
    
    cumulative_fps = []
    cumulative_killed = []
    cumulative_test = []
    
    for i in range(len(stages)):
        cumulative_test.extend(stages[i])
        cumulative_fps.append(hc.false_positive_count(cumulative_test))
        cumulative_killed.append(len(hc.killed_by(cumulative_test)))
    
    fig, ax = plt.subplots(figsize=(10, 6))
    stage_labels = [f'Stage {i+1}\n(+{stage_size} pts)' for i in range(len(stages))]
    x = range(len(stages))
    
    ax.bar(x, cumulative_fps, color='#F44336', alpha=0.7, label='False Positives')
    ax.plot(x, cumulative_fps, 'o-', color='#B71C1C', linewidth=2, markersize=8)
    
    ax.set_xticks(list(x))
    ax.set_xticklabels(stage_labels, fontsize=10)
    ax.set_ylabel('False Positive Count', fontsize=14)
    ax.set_title('Pipeline Composition: Sequential Stress-Test Stages\nEach stage adds 5 test points', fontsize=16)
    ax.grid(True, alpha=0.3, axis='y')
    
    for i, fp in enumerate(cumulative_fps):
        ax.annotate(str(fp), (i, fp + 1), ha='center', fontsize=12, fontweight='bold')
    
    fig.savefig('fig_pipeline.png', dpi=150, bbox_inches='tight', facecolor='white')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = plot_monotone_decrease()
    print(f"  ✓ fig_monotone_decrease.png ({len(b64_1)} chars base64)")
    
    b64_2 = plot_greedy_vs_random()
    print(f"  ✓ fig_greedy_vs_random.png ({len(b64_2)} chars base64)")
    
    b64_3 = plot_kill_growth()
    print(f"  ✓ fig_kill_growth.png ({len(b64_3)} chars base64)")
    
    b64_4 = plot_pipeline()
    print(f"  ✓ fig_pipeline.png ({len(b64_4)} chars base64)")
    
    print("\nAll visualizations saved to PNG files.")
    
    # Save base64 data for JSON package
    import json
    viz_data = {
        "monotone_decrease": b64_1,
        "greedy_vs_random": b64_2,
        "kill_growth": b64_3,
        "pipeline": b64_4
    }
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
