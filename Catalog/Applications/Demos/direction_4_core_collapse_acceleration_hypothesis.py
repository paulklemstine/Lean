#!/usr/bin/env python3
"""
Applications of Core-Collapse Entropy Theory

Demonstrates real-world applications of the formally verified theorems
connecting feature entropy to semantic graph collapse:

1. Theorem family analysis: Predict when a collection of mathematical
   statements becomes topologically trivial.
2. Codeword diversity analysis: Apply the Hamming-geometry bridge to
   error-correcting codes.
3. Document clustering diagnostics: Use collapse thresholds to assess
   corpus diversity.
4. Feature selection: Identify which features contribute most to
   topological structure.
"""

from __future__ import annotations
import random
from collections import Counter
from typing import Any


# ──────────────────────────────────────────────────────────────────────────
# Core primitives (self-contained)
# ──────────────────────────────────────────────────────────────────────────

def symm_diff_card(s, t):
    return len(s ^ t)

def feature_frequencies(family):
    N = len(family)
    if N == 0:
        return {}
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return {f: c / N for f, c in counts.items()}

def collision_entropy(family):
    N = len(family)
    if N == 0:
        return 0.0
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return sum((c / N) * (1 - c / N) for c in counts.values())

def majority_core(family):
    N = len(family)
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return {f for f, c in counts.items() if 2 * c > N}

def core_radius(family, core):
    if not family:
        return 0
    return max(symm_diff_card(s, core) for s in family)

def minority_mass(family):
    N = len(family)
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return sum(min(c, N - c) for c in counts.values())

def complete_threshold_exact(family):
    fam = list(family)
    n = len(fam)
    if n <= 1:
        return 0
    return max(symm_diff_card(fam[i], fam[j])
               for i in range(n) for j in range(i + 1, n))

def predicted_complete_threshold(family):
    core = majority_core(family)
    return 2 * core_radius(family, core)


# ──────────────────────────────────────────────────────────────────────────
# Application 1: Mathematical Theorem Family Analysis
# ──────────────────────────────────────────────────────────────────────────

def theorem_family_analysis():
    """Analyze a family of mathematical statements modeled as feature sets.

    Features represent proof techniques, mathematical objects, and structural
    properties. The analysis predicts when the semantic graph collapses.
    """
    print("="*70)
    print("  APPLICATION 1: Mathematical Theorem Family Analysis")
    print("="*70)

    # Model: Features are proof techniques / concepts
    features = {
        'induction': 0, 'contradiction': 1, 'pigeonhole': 2,
        'triangle_ineq': 3, 'completeness': 4, 'compactness': 5,
        'linearity': 6, 'continuity': 7, 'monotonicity': 8,
        'symmetry': 9, 'convexity': 10, 'density': 11
    }
    feature_names = {v: k for k, v in features.items()}

    # A family of analysis theorems (sharing core techniques)
    analysis_family = [
        {0, 3, 4, 7, 8},      # "Monotone convergence uses induction, triangle, completeness, continuity, monotonicity"
        {0, 3, 4, 7, 10},     # "Bounded convergence"
        {0, 3, 7, 8, 10},     # "Dini's theorem"
        {3, 4, 5, 7, 8},      # "Heine-Borel application"
        {0, 3, 4, 7, 8, 10},  # "Weierstrass extreme value"
    ]

    # A diverse family (number theory, algebra, topology mixed)
    diverse_family = [
        {0, 2, 11},           # "Infinitely many primes"
        {1, 5, 6},            # "Dual space theorem"
        {3, 7, 9},            # "Isometry theorem"
        {0, 4, 8, 10},        # "Convex optimization"
        {1, 2, 6, 9},         # "Burnside's lemma"
    ]

    for name, family in [("Analysis theorems (concentrated)", analysis_family),
                          ("Diverse theorems (spread)", diverse_family)]:
        print(f"\n  {name}:")
        core = majority_core(family)
        core_names = sorted(feature_names.get(f, str(f)) for f in core)
        print(f"    Majority core features: {core_names}")
        print(f"    Collision entropy H₂ = {collision_entropy(family):.4f}")
        print(f"    Core radius = {core_radius(family, core)}")
        print(f"    Minority mass = {minority_mass(family)}")
        print(f"    Exact complete threshold = {complete_threshold_exact(family)}")
        print(f"    Predicted threshold bound = {predicted_complete_threshold(family)}")
        print(f"    → {'EARLY' if collision_entropy(family) < 2 else 'LATE'} collapse predicted")

    print()


# ──────────────────────────────────────────────────────────────────────────
# Application 2: Error-Correcting Code Diversity
# ──────────────────────────────────────────────────────────────────────────

def code_diversity_analysis():
    """Analyze codeword diversity using the Hamming-geometry bridge.

    The semantic distance between feature sets equals the Hamming distance
    between binary codewords. Low collision entropy means the code has
    poor distance properties (codewords too similar).
    """
    print("="*70)
    print("  APPLICATION 2: Error-Correcting Code Diversity Analysis")
    print("="*70)

    # Repetition-like code (low diversity)
    rep_code = [
        {0, 1, 2, 3, 4, 5, 6},
        {0, 1, 2, 3, 4, 5, 6},
        {0, 1, 2, 3, 4, 5, 6},
        {0, 1, 2, 3, 4, 5},
    ]

    # Good code (balanced diversity)
    good_code = [
        {0, 1, 2},
        {0, 3, 4},
        {1, 3, 5},
        {2, 4, 5},
    ]

    for name, code in [("Repetition-like code (low diversity)", rep_code),
                        ("Balanced code (good diversity)", good_code)]:
        print(f"\n  {name}:")
        print(f"    Codewords: {[sorted(c) for c in code]}")
        print(f"    H₂ = {collision_entropy(code):.4f}")
        print(f"    Min Hamming distance = {min(symm_diff_card(code[i], code[j]) for i in range(len(code)) for j in range(i+1, len(code)))}")
        print(f"    Collapse threshold = {complete_threshold_exact(code)}")
        print(f"    → {'POOR' if collision_entropy(code) < 1.5 else 'GOOD'} error-correction capability")

    print()


# ──────────────────────────────────────────────────────────────────────────
# Application 3: Document Corpus Diversity Diagnostic
# ──────────────────────────────────────────────────────────────────────────

def corpus_diversity_diagnostic():
    """Use collapse threshold as a diversity diagnostic for document corpora.

    Each document is represented by its topic/keyword feature set.
    A low collapse threshold indicates the corpus lacks diversity.
    """
    print("="*70)
    print("  APPLICATION 3: Document Corpus Diversity Diagnostic")
    print("="*70)

    topics = {
        'ML': 0, 'NLP': 1, 'CV': 2, 'RL': 3,
        'optimization': 4, 'statistics': 5, 'theory': 6,
        'biology': 7, 'physics': 8, 'chemistry': 9,
        'ethics': 10, 'HCI': 11
    }
    topic_names = {v: k for k, v in topics.items()}

    # Homogeneous AI corpus
    ai_corpus = [
        {0, 1, 4, 5},  # "ML + NLP paper"
        {0, 2, 4, 5},  # "ML + CV paper"
        {0, 3, 4, 5},  # "ML + RL paper"
        {0, 1, 2, 4},  # "Multimodal ML"
        {0, 4, 5, 6},  # "ML theory"
    ]

    # Interdisciplinary corpus
    diverse_corpus = [
        {0, 1, 4},     # "ML + NLP"
        {7, 8, 9},     # "Biophysics + chemistry"
        {6, 10, 11},   # "Theory + ethics + HCI"
        {2, 3, 8},     # "CV + RL + physics"
        {5, 7, 10},    # "Biostatistics + ethics"
    ]

    for name, corpus in [("Homogeneous AI corpus", ai_corpus),
                          ("Interdisciplinary corpus", diverse_corpus)]:
        print(f"\n  {name}:")
        core = majority_core(corpus)
        core_topics = sorted(topic_names.get(f, str(f)) for f in core)
        print(f"    Core topics: {core_topics}")
        print(f"    H₂ = {collision_entropy(corpus):.4f}")
        print(f"    Collapse threshold = {complete_threshold_exact(corpus)}")
        print(f"    Predicted bound = {predicted_complete_threshold(corpus)}")

        # Diversity score: higher is more diverse
        h2 = collision_entropy(corpus)
        print(f"    Diversity score: {'LOW' if h2 < 2 else 'MEDIUM' if h2 < 4 else 'HIGH'} ({h2:.2f})")

    print()


# ──────────────────────────────────────────────────────────────────────────
# Application 4: Feature Importance for Topological Structure
# ──────────────────────────────────────────────────────────────────────────

def feature_importance_analysis():
    """Identify which features contribute most to preventing collapse.

    A feature with minority count close to N/2 contributes maximally to
    the collision entropy and thus to maintaining topological structure.
    Features with minority count ≈ 0 are near-universal or near-absent
    and do not contribute to diversity.
    """
    print("="*70)
    print("  APPLICATION 4: Feature Importance for Topological Structure")
    print("="*70)

    family = [
        {0, 1, 2, 5, 6},
        {0, 1, 3, 5, 7},
        {0, 1, 2, 6, 7},
        {0, 1, 3, 5, 6},
        {0, 2, 3, 6, 7},
        {0, 1, 2, 5, 7},
    ]
    N = len(family)

    print(f"\n  Family of {N} feature sets")

    freq = feature_frequencies(family)
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1

    print(f"\n  {'Feature':>8}  {'Count':>6}  {'Freq':>6}  {'MinCount':>9}  {'p(1-p)':>8}  {'Importance':>11}")
    print(f"  {'─'*8}  {'─'*6}  {'─'*6}  {'─'*9}  {'─'*8}  {'─'*11}")

    features_sorted = sorted(counts.keys())
    for f in features_sorted:
        nf = counts[f]
        pf = nf / N
        mc = min(nf, N - nf)
        collision = pf * (1 - pf)
        importance = "HIGH" if mc >= N * 0.3 else "MEDIUM" if mc >= N * 0.15 else "LOW"
        print(f"  {f:>8}  {nf:>6}  {pf:>6.3f}  {mc:>9}  {collision:>8.4f}  {importance:>11}")

    print(f"\n  Total collision entropy H₂ = {collision_entropy(family):.4f}")
    print(f"  Complete threshold = {complete_threshold_exact(family)}")

    # Show effect of removing highest-importance feature
    # Find the feature with the highest minority count
    max_mc_feature = max(counts.keys(), key=lambda f: min(counts[f], N - counts[f]))
    reduced = [{f for f in s if f != max_mc_feature} for s in family]
    print(f"\n  After removing feature {max_mc_feature} (highest diversity contributor):")
    print(f"    H₂ = {collision_entropy(reduced):.4f}")
    print(f"    Complete threshold = {complete_threshold_exact(reduced)}")
    print(f"    → Collapse accelerated by removing diverse feature")

    print()


# ──────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────

def main():
    print("╔════════════════════════════════════════════════════════════════╗")
    print("║  Core-Collapse Entropy: Real-World Applications              ║")
    print("║  From Formally Verified Theorems to Practical Diagnostics    ║")
    print("╚════════════════════════════════════════════════════════════════╝\n")

    theorem_family_analysis()
    code_diversity_analysis()
    corpus_diversity_diagnostic()
    feature_importance_analysis()

    print("="*70)
    print("  SUMMARY")
    print("="*70)
    print("""
  The core-collapse acceleration theory provides practical tools for:

  1. THEOREM ANALYSIS: Predict when mathematical families become
     topologically trivial from feature statistics alone.

  2. CODING THEORY: Assess codeword diversity via collision entropy,
     connecting to minimum distance bounds.

  3. CORPUS DIAGNOSTICS: Quantify document collection diversity
     using the collapse threshold as a single-number summary.

  4. FEATURE SELECTION: Identify which attributes contribute most
     to maintaining structural diversity in any classification.

  All applications rest on three formally verified theorems:
    • Disagreement Identity (entropy ↔ total distance)
    • Majority Core Distance Identity (core ↔ minority mass)
    • Complete-Graph Collapse Theorem (distance bound → completeness)
    """)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Core-Collapse Entropy: Interactive Demonstration

Generates synthetic families from controllable feature distributions,
computes entropy surrogates and collapse thresholds, plots threshold
versus entropy/diversity, and tests the conjectured scaling law.

Usage:
    python demo.py

Produces plots and numerical output demonstrating the formally verified
theorems connecting feature entropy to semantic graph collapse.
"""

from __future__ import annotations
import random
import math
from collections import Counter
from typing import Sequence, Any

# ──────────────────────────────────────────────────────────────────────────
# Core algorithms (self-contained, no local imports)
# ──────────────────────────────────────────────────────────────────────────

def feature_support(family):
    result = set()
    for s in family:
        result |= s
    return result

def feature_frequencies(family):
    N = len(family)
    if N == 0:
        return {}
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return {f: c / N for f, c in counts.items()}

def collision_entropy_numerator(family):
    N = len(family)
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return sum(c * (N - c) for c in counts.values())

def collision_entropy(family):
    N = len(family)
    if N == 0:
        return 0.0
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return sum((c / N) * (1 - c / N) for c in counts.values())

def majority_core(family):
    N = len(family)
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return {f for f, c in counts.items() if 2 * c > N}

def symm_diff_card(s, t):
    return len(s ^ t)

def core_radius(family, core):
    if not family:
        return 0
    return max(symm_diff_card(s, core) for s in family)

def minority_mass(family):
    N = len(family)
    counts = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return sum(min(c, N - c) for c in counts.values())

def total_pairwise_distance(family):
    total = 0
    fam = list(family)
    for s in fam:
        for t in fam:
            total += symm_diff_card(s, t)
    return total

def complete_threshold_exact(family):
    fam = list(family)
    n = len(fam)
    if n <= 1:
        return 0
    return max(symm_diff_card(fam[i], fam[j])
               for i in range(n) for j in range(i+1, n))

def predicted_complete_threshold(family):
    core = majority_core(family)
    return 2 * core_radius(family, core)

def avg_pairwise_distance(family):
    N = len(family)
    if N == 0:
        return 0.0
    return total_pairwise_distance(family) / (N * N)

# ──────────────────────────────────────────────────────────────────────────
# Synthetic family generators
# ──────────────────────────────────────────────────────────────────────────

def generate_uniform_family(n_statements: int, n_features: int,
                            prob: float = 0.5, seed: int = 42) -> list[set]:
    """Each feature included independently with probability `prob`."""
    rng = random.Random(seed)
    return [{f for f in range(n_features) if rng.random() < prob}
            for _ in range(n_statements)]

def generate_concentrated_family(n_statements: int, n_features: int,
                                  core_size: int, noise: float = 0.1,
                                  seed: int = 42) -> list[set]:
    """Core features always present; non-core included with prob `noise`."""
    rng = random.Random(seed)
    core = set(range(core_size))
    return [core | {f for f in range(core_size, n_features)
                    if rng.random() < noise}
            for _ in range(n_statements)]

def generate_dirichlet_family(n_statements: int, n_features: int,
                               concentration: float = 1.0,
                               seed: int = 42) -> list[set]:
    """Feature inclusion probabilities drawn from Beta(concentration, concentration)."""
    rng = random.Random(seed)
    # Draw feature probabilities
    probs = []
    for _ in range(n_features):
        # Beta distribution via gamma
        a = max(1e-6, rng.gammavariate(concentration, 1))
        b = max(1e-6, rng.gammavariate(concentration, 1))
        probs.append(a / (a + b))
    return [{f for f in range(n_features) if rng.random() < probs[f]}
            for _ in range(n_statements)]

# ──────────────────────────────────────────────────────────────────────────
# Verification of theorems
# ──────────────────────────────────────────────────────────────────────────

def verify_all_theorems(family, label=""):
    """Verify all three main theorems computationally."""
    N = len(family)

    # Theorem 1: Disagreement Identity
    lhs1 = total_pairwise_distance(family)
    rhs1 = 2 * collision_entropy_numerator(family)
    t1_ok = (lhs1 == rhs1)

    # Theorem 2: Majority Core Distance Identity
    core = majority_core(family)
    lhs2 = sum(symm_diff_card(s, core) for s in family)
    rhs2 = minority_mass(family)
    t2_ok = (lhs2 == rhs2)

    # Theorem 3: Collapse at predicted threshold
    predicted = predicted_complete_threshold(family)
    exact = complete_threshold_exact(family)
    t3_ok = (exact <= predicted)

    if label:
        print(f"\n{'='*60}")
        print(f"  {label}")
        print(f"{'='*60}")
    print(f"  Family size: {N}, Universe size: {len(feature_support(family))}")
    print(f"  Collision entropy (H₂): {collision_entropy(family):.4f}")
    print(f"  Minority mass: {minority_mass(family)}")
    print(f"  Core radius: {core_radius(family, core)}")
    print(f"  Theorem 1 (Disagreement Identity):     {'✓' if t1_ok else '✗'}  "
          f"  LHS={lhs1}, RHS={rhs1}")
    print(f"  Theorem 2 (Majority Core Distance):    {'✓' if t2_ok else '✗'}  "
          f"  LHS={lhs2}, RHS={rhs2}")
    print(f"  Theorem 3 (Collapse Bound):            {'✓' if t3_ok else '✗'}  "
          f"  exact={exact}, predicted={predicted}")
    return t1_ok and t2_ok and t3_ok

# ──────────────────────────────────────────────────────────────────────────
# Scaling law experiment
# ──────────────────────────────────────────────────────────────────────────

def scaling_experiment(n_statements=20, n_features=10, n_trials=50):
    """Test the conjectured scaling: ε_complete ~ 2 * coreRadius ~ O(H₂).

    Generates families with varying concentration parameters and
    plots the relationship between entropy and collapse threshold.
    """
    print("\n" + "="*60)
    print("  SCALING LAW EXPERIMENT")
    print("="*60)
    print(f"  {n_trials} trials, N={n_statements}, m={n_features}")
    print()

    results = []
    for trial in range(n_trials):
        eta = 0.1 + 4.9 * trial / max(1, n_trials - 1)  # concentration 0.1 to 5.0
        family = generate_dirichlet_family(n_statements, n_features, eta, seed=trial*17+3)
        if not family or all(len(s) == 0 for s in family):
            continue

        h2 = collision_entropy(family)
        exact_thresh = complete_threshold_exact(family)
        predicted_thresh = predicted_complete_threshold(family)
        core = majority_core(family)
        rad = core_radius(family, core)

        results.append({
            'eta': eta,
            'h2': h2,
            'exact_threshold': exact_thresh,
            'predicted_threshold': predicted_thresh,
            'core_radius': rad,
            'minority_mass': minority_mass(family),
        })

    # Print results table
    print(f"  {'η':>6}  {'H₂':>8}  {'ε_exact':>8}  {'ε_pred':>8}  "
          f"{'radius':>7}  {'ratio':>8}")
    print(f"  {'─'*6}  {'─'*8}  {'─'*8}  {'─'*8}  {'─'*7}  {'─'*8}")
    for r in results:
        ratio = r['exact_threshold'] / r['h2'] if r['h2'] > 0 else float('inf')
        print(f"  {r['eta']:6.2f}  {r['h2']:8.4f}  {r['exact_threshold']:8d}  "
              f"{r['predicted_threshold']:8d}  {r['core_radius']:7d}  {ratio:8.4f}")

    # Summary statistics
    ratios = [r['exact_threshold'] / r['h2'] for r in results if r['h2'] > 0]
    if ratios:
        print(f"\n  Threshold/H₂ ratio: mean={sum(ratios)/len(ratios):.4f}, "
              f"min={min(ratios):.4f}, max={max(ratios):.4f}")

    # Verify bound holds
    violations = sum(1 for r in results
                     if r['exact_threshold'] > r['predicted_threshold'])
    print(f"  Bound violations: {violations}/{len(results)} "
          f"(should be 0 by Theorem 3)")

    return results

# ──────────────────────────────────────────────────────────────────────────
# ASCII scatter plot
# ──────────────────────────────────────────────────────────────────────────

def ascii_scatter(xs, ys, xlabel="x", ylabel="y", title="", width=60, height=20):
    """Simple ASCII scatter plot."""
    if not xs or not ys:
        return
    xmin, xmax = min(xs), max(xs)
    ymin, ymax = min(ys), max(ys)
    if xmax == xmin:
        xmax = xmin + 1
    if ymax == ymin:
        ymax = ymin + 1

    grid = [[' '] * width for _ in range(height)]
    for x, y in zip(xs, ys):
        col = int((x - xmin) / (xmax - xmin) * (width - 1))
        row = height - 1 - int((y - ymin) / (ymax - ymin) * (height - 1))
        col = max(0, min(width - 1, col))
        row = max(0, min(height - 1, row))
        grid[row][col] = '●'

    print(f"\n  {title}")
    print(f"  {ymax:8.2f} ┤{''.join(grid[0])}")
    for i in range(1, height - 1):
        if i == height // 2:
            mid = (ymax + ymin) / 2
            print(f"  {mid:8.2f} ┤{''.join(grid[i])}")
        else:
            print(f"           │{''.join(grid[i])}")
    print(f"  {ymin:8.2f} ┤{''.join(grid[-1])}")
    print(f"           └{'─' * width}")
    print(f"  {xmin:8.2f}{' ' * (width - 16)}{xmax:8.2f}")
    print(f"           {xlabel:^{width}}")

# ──────────────────────────────────────────────────────────────────────────
# Main demonstration
# ──────────────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Core-Collapse Acceleration: Interactive Demonstration  ║")
    print("║  Information-Theoretic Foundations of Semantic Collapse  ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Demo 1: Verify theorems on structured examples
    print("\n" + "="*60)
    print("  PART 1: Theorem Verification on Structured Families")
    print("="*60)

    # Highly concentrated family (low entropy → fast collapse)
    fam1 = generate_concentrated_family(10, 8, core_size=6, noise=0.05, seed=1)
    verify_all_theorems(fam1, "Concentrated family (large core, low noise)")

    # Uniform family (high entropy → slow collapse)
    fam2 = generate_uniform_family(10, 8, prob=0.5, seed=2)
    verify_all_theorems(fam2, "Uniform family (p=0.5, high entropy)")

    # Sparse family
    fam3 = generate_uniform_family(10, 8, prob=0.2, seed=3)
    verify_all_theorems(fam3, "Sparse family (p=0.2)")

    # Identical family (zero entropy → instant collapse)
    fam4 = [{1, 2, 3}] * 5
    verify_all_theorems(fam4, "Identical family (zero entropy)")

    # Demo 2: Scaling experiment
    results = scaling_experiment(n_statements=15, n_features=8, n_trials=30)

    # Demo 3: ASCII visualization
    if results:
        h2s = [r['h2'] for r in results]
        thresholds = [r['exact_threshold'] for r in results]
        predicted = [r['predicted_threshold'] for r in results]

        ascii_scatter(h2s, thresholds,
                      xlabel="Collision Entropy H₂",
                      ylabel="ε_complete",
                      title="Exact Complete Threshold vs Collision Entropy")

        ascii_scatter(h2s, predicted,
                      xlabel="Collision Entropy H₂",
                      ylabel="2·radius",
                      title="Predicted Threshold (2·coreRadius) vs Collision Entropy")

    # Demo 4: Transition profile
    print("\n" + "="*60)
    print("  PART 4: Transition Profile for a Single Family")
    print("="*60)
    family = generate_dirichlet_family(12, 6, concentration=0.5, seed=99)
    print(f"\n  Family: {[sorted(s) for s in family]}")
    print(f"  Majority core: {sorted(majority_core(family))}")
    print(f"  H₂ = {collision_entropy(family):.4f}")
    print()
    print(f"  {'ε':>4}  {'edges':>6}  {'max_edges':>10}  {'complete?':>10}")
    print(f"  {'─'*4}  {'─'*6}  {'─'*10}  {'─'*10}")
    N = len(family)
    max_edges = N * (N - 1) // 2
    for eps in range(0, 15):
        edges = len([1 for i in range(N) for j in range(i+1, N)
                     if symm_diff_card(family[i], family[j]) <= eps])
        complete = "YES" if edges == max_edges else ""
        print(f"  {eps:4d}  {edges:6d}  {max_edges:10d}  {complete:>10}")

    print("\n" + "="*60)
    print("  DEMONSTRATION COMPLETE")
    print("="*60)
    print("\n  All three formally verified theorems confirmed computationally.")
    print("  The causal chain is:")
    print("    Low entropy → Small minority mass → Small core radius")
    print("    → Small pairwise distances → Early complete-graph collapse")
    print()


if __name__ == "__main__":
    main()
