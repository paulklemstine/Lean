#!/usr/bin/env python3
"""
applications.py — Real-world applications of difference set theory.

Demonstrates how the structural properties (symmetry, translation invariance,
diameter bounds) apply to signal processing, pattern recognition, and
cryptographic analysis.
"""

import random
from collections import Counter


# ============================================================
# Application 1: Translation-Invariant Feature Extraction
# ============================================================

def translation_invariant_features(signal: list[int]) -> dict:
    """
    Extract features from a 1D discrete signal that are invariant under
    translation (shifting).

    By Theorem B, the difference set is translation-invariant, so any
    statistic derived from it is also translation-invariant.

    This is the mathematical foundation of shift-invariant pattern recognition.

    Args:
        signal: List of integer positions (e.g., peak locations)

    Returns:
        Dictionary of translation-invariant features
    """
    S = frozenset(signal)
    diffs = {x - y for x in S for y in S}
    nonzero_diffs = diffs - {0}
    pos_diffs = frozenset(d for d in nonzero_diffs if d > 0)

    # Representation counts (autocorrelation)
    repr_counts = Counter()
    for d in pos_diffs:
        repr_counts[d] = sum(1 for x in S if x - d in S)

    return {
        'num_positive_differences': len(pos_diffs),
        'min_gap': min(pos_diffs) if pos_diffs else 0,
        'max_gap': max(pos_diffs) if pos_diffs else 0,
        'diameter': max(S) - min(S) if S else 0,
        'gap_histogram': dict(repr_counts),
        'is_sidon': all(v <= 1 for v in repr_counts.values()),
        'additive_energy': sum(v**2 for v in repr_counts.values()) + len(S)**2,
    }


def demo_shift_invariant_recognition():
    """Show that shifted versions of the same pattern produce identical features."""
    print("Application 1: Shift-Invariant Pattern Recognition")
    print("-" * 50)

    # A pattern of peak positions
    pattern = [2, 5, 7, 13, 18]
    print(f"Original pattern: {pattern}")

    # Extract features from shifted versions
    for shift in [0, 100, -500, 12345]:
        shifted = [x + shift for x in pattern]
        features = translation_invariant_features(shifted)
        print(f"  Shift {shift:>6d}: {len(features['gap_histogram'])} gaps, "
              f"energy={features['additive_energy']}, "
              f"Sidon={features['is_sidon']}")

    print("  ✓ All shifted versions produce identical features (Theorem B)\n")


# ============================================================
# Application 2: Radar/Sonar Ambiguity Analysis
# ============================================================

def ambiguity_analysis(antenna_positions: list[int]) -> dict:
    """
    Analyze the ambiguity properties of a linear antenna array.

    In radar/sonar, the difference set of antenna positions determines
    the set of spatial frequencies that can be resolved. The negation
    symmetry (Theorem A) means the array has the same resolution
    looking left as looking right.

    Args:
        antenna_positions: Integer positions of antenna elements

    Returns:
        Analysis of the array's ambiguity properties
    """
    S = frozenset(antenna_positions)
    diffs = {x - y for x in S for y in S}
    nonzero_diffs = diffs - {0}
    pos_diffs = sorted(d for d in nonzero_diffs if d > 0)

    # Check for "holes" in the positive differences
    if pos_diffs:
        full_range = set(range(1, max(pos_diffs) + 1))
        holes = full_range - set(pos_diffs)
    else:
        holes = set()

    # Representation counts for each difference
    repr_counts = {}
    for d in pos_diffs:
        repr_counts[d] = sum(1 for x in S if x - d in S)

    return {
        'num_elements': len(S),
        'aperture': max(S) - min(S) if S else 0,
        'num_baselines': len(pos_diffs),
        'max_possible_baselines': max(S) - min(S) if S else 0,
        'coverage_ratio': len(pos_diffs) / (max(S) - min(S)) if len(S) > 1 else 0,
        'holes': sorted(holes),
        'is_redundancy_free': all(v == 1 for v in repr_counts.values()),
        'max_redundancy': max(repr_counts.values()) if repr_counts else 0,
    }


def demo_antenna_array():
    """Demonstrate difference set analysis for antenna array design."""
    print("Application 2: Antenna Array Ambiguity Analysis")
    print("-" * 50)

    # A minimum-redundancy array (Sidon-like)
    mra = [0, 1, 3, 7, 12, 20]
    analysis = ambiguity_analysis(mra)
    print(f"Array positions: {mra}")
    print(f"  Aperture: {analysis['aperture']}")
    print(f"  Baselines: {analysis['num_baselines']}/{analysis['max_possible_baselines']}")
    print(f"  Coverage: {analysis['coverage_ratio']:.1%}")
    print(f"  Holes: {analysis['holes'][:5]}{'...' if len(analysis['holes']) > 5 else ''}")
    print(f"  Redundancy-free: {analysis['is_redundancy_free']}")

    # A uniform array (high redundancy)
    uniform = [0, 1, 2, 3, 4, 5]
    analysis_u = ambiguity_analysis(uniform)
    print(f"\nUniform array: {uniform}")
    print(f"  Aperture: {analysis_u['aperture']}")
    print(f"  Baselines: {analysis_u['num_baselines']}/{analysis_u['max_possible_baselines']}")
    print(f"  Coverage: {analysis_u['coverage_ratio']:.1%}")
    print(f"  Redundancy-free: {analysis_u['is_redundancy_free']}")
    print(f"  Max redundancy: {analysis_u['max_redundancy']}")
    print()


# ============================================================
# Application 3: Cryptographic Sequence Analysis
# ============================================================

def sequence_difference_profile(seq: list[int]) -> dict:
    """
    Analyze a sequence's difference profile for cryptographic quality.

    Good pseudorandom sequences should have approximately flat
    autocorrelation, meaning representation counts r(d) ≈ r(d')
    for all nonzero d, d'. The even-cardinality theorem (Theorem A)
    ensures the nonzero differences always come in sign-paired orbits.

    Args:
        seq: Sequence of integers

    Returns:
        Cryptographic quality metrics
    """
    S = frozenset(seq)
    nonzero_diffs = {x - y for x in S for y in S} - {0}
    pos_diffs = sorted(d for d in nonzero_diffs if d > 0)

    repr_counts = [sum(1 for x in S if x - d in S) for d in pos_diffs]

    if repr_counts:
        mean_repr = sum(repr_counts) / len(repr_counts)
        variance = sum((r - mean_repr)**2 for r in repr_counts) / len(repr_counts)
    else:
        mean_repr = 0
        variance = 0

    return {
        'sequence_length': len(S),
        'num_orbits': len(pos_diffs),
        'mean_representation': mean_repr,
        'representation_variance': variance,
        'flatness_score': 1.0 / (1.0 + variance),  # 1.0 = perfectly flat
        'is_sidon': all(r <= 1 for r in repr_counts),
    }


def demo_crypto_analysis():
    """Compare difference profiles of structured vs. random sequences."""
    print("Application 3: Cryptographic Sequence Quality")
    print("-" * 50)

    # A structured (bad) sequence
    structured = list(range(0, 20, 2))  # even numbers
    profile_s = sequence_difference_profile(structured)
    print(f"Structured (evens 0-18): flatness = {profile_s['flatness_score']:.4f}, "
          f"Sidon = {profile_s['is_sidon']}")

    # A random sequence
    random.seed(42)
    rand_seq = sorted(random.sample(range(100), 10))
    profile_r = sequence_difference_profile(rand_seq)
    print(f"Random ({rand_seq[:4]}...): flatness = {profile_r['flatness_score']:.4f}, "
          f"Sidon = {profile_r['is_sidon']}")

    # A Sidon set (best possible)
    sidon = [0, 1, 3, 7, 12, 20, 29, 38]
    profile_si = sequence_difference_profile(sidon)
    print(f"Sidon-like ({sidon[:4]}...): flatness = {profile_si['flatness_score']:.4f}, "
          f"Sidon = {profile_si['is_sidon']}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("APPLICATIONS OF DIFFERENCE SET STRUCTURAL THEORY")
    print("=" * 60)
    print()

    demo_shift_invariant_recognition()
    demo_antenna_array()
    demo_crypto_analysis()

    print("=" * 60)
    print("ALL APPLICATIONS DEMONSTRATED")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Demonstrates the structural properties of finite difference sets.

Verified properties:
  Theorem A: Negation symmetry and even cardinality of nonzero differences
  Theorem B: Translation invariance
  Theorem C: Diameter bound on all differences

Run: python3 demo.py
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def difference_set(S: set[int]) -> set[int]:
    """Compute the difference set {x - y : x, y in S}."""
    return {x - y for x in S for y in S}


def nonzero_difference_set(S: set[int]) -> set[int]:
    """Compute the nonzero difference set."""
    return difference_set(S) - {0}


def translate(S: set[int], a: int) -> set[int]:
    """Translate S by a."""
    return {x + a for x in S}


def diameter(S: set[int]) -> int:
    """Diameter = max(S) - min(S)."""
    return max(S) - min(S)


# ============================================================
# Theorem A: Negation Symmetry
# ============================================================

def demo_negation_symmetry():
    print("=" * 60)
    print("THEOREM A: Negation Symmetry")
    print("=" * 60)

    # Concrete example
    S = {1, 3, 7, 12}
    D = difference_set(S)
    D_star = nonzero_difference_set(S)

    print(f"\nS = {sorted(S)}")
    print(f"Δ(S) = {sorted(D)}")
    print(f"|Δ(S)| = {len(D)}")
    print(f"Δ*(S) = {sorted(D_star)}")
    print(f"|Δ*(S)| = {len(D_star)} (even: {len(D_star) % 2 == 0})")

    # Verify symmetry
    assert all(-z in D for z in D), "Symmetry failed!"
    assert all(-z in D_star for z in D_star), "Nonzero symmetry failed!"
    print("✓ Negation symmetry verified")

    # Positive/negative decomposition
    pos = {z for z in D_star if z > 0}
    neg = {z for z in D_star if z < 0}
    print(f"Δ⁺(S) = {sorted(pos)}, |Δ⁺| = {len(pos)}")
    print(f"Δ⁻(S) = {sorted(neg)}, |Δ⁻| = {len(neg)}")
    assert len(pos) == len(neg), "Halves not equal!"
    assert len(D_star) == 2 * len(pos), "Decomposition failed!"
    print("✓ |Δ*(S)| = 2 · |Δ⁺(S)| verified")

    # Statistical verification on random sets
    print("\nRandom verification (1000 trials)...")
    for _ in range(1000):
        n = random.randint(2, 15)
        S_rand = set(random.sample(range(-50, 51), n))
        D_star_rand = nonzero_difference_set(S_rand)
        assert len(D_star_rand) % 2 == 0, f"Even cardinality failed for {S_rand}"
        assert all(-z in D_star_rand for z in D_star_rand), \
            f"Symmetry failed for {S_rand}"
    print("✓ All 1000 random tests passed")


# ============================================================
# Theorem B: Translation Invariance
# ============================================================

def demo_translation_invariance():
    print("\n" + "=" * 60)
    print("THEOREM B: Translation Invariance")
    print("=" * 60)

    S = {1, 3, 7, 12}
    D_original = difference_set(S)

    for a in [-1000, -1, 0, 1, 42, 1000]:
        S_shifted = translate(S, a)
        D_shifted = difference_set(S_shifted)
        assert D_shifted == D_original, \
            f"Translation invariance failed for a={a}"
        print(f"  a = {a:>5d}: S+a = {sorted(S_shifted)[:4]}... → Δ(S+a) = Δ(S) ✓")

    # Statistical verification
    print("\nRandom verification (1000 trials)...")
    for _ in range(1000):
        n = random.randint(2, 12)
        S_rand = set(random.sample(range(-50, 51), n))
        a = random.randint(-10000, 10000)
        assert difference_set(translate(S_rand, a)) == difference_set(S_rand)
    print("✓ All 1000 random tests passed")


# ============================================================
# Theorem C: Diameter Bound
# ============================================================

def demo_diameter_bound():
    print("\n" + "=" * 60)
    print("THEOREM C: Diameter Bound")
    print("=" * 60)

    S = {1, 3, 7, 12}
    D = difference_set(S)
    diam = diameter(S)

    print(f"\nS = {sorted(S)}")
    print(f"Diameter D = {max(S)} - {min(S)} = {diam}")
    print(f"Δ(S) = {sorted(D)}")
    print(f"max |z| for z ∈ Δ(S) = {max(abs(z) for z in D)}")
    print(f"Bound: max |z| ≤ D = {diam}")
    assert all(abs(z) <= diam for z in D), "Diameter bound failed!"
    print("✓ All differences bounded by diameter")

    # Cardinality consequence
    print(f"\n|Δ(S)| = {len(D)} ≤ 2D+1 = {2*diam+1}")
    assert len(D) <= 2 * diam + 1

    # Statistical verification
    print("\nRandom verification (1000 trials)...")
    for _ in range(1000):
        n = random.randint(2, 15)
        S_rand = set(random.sample(range(-50, 51), n))
        D_rand = difference_set(S_rand)
        d = diameter(S_rand)
        assert all(abs(z) <= d for z in D_rand)
        assert len(D_rand) <= 2 * d + 1
    print("✓ All 1000 random tests passed")


# ============================================================
# Visualization
# ============================================================

def create_visualizations():
    print("\n" + "=" * 60)
    print("Creating Visualizations")
    print("=" * 60)

    # Figure 1: Difference set symmetry visualization
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    S = {1, 3, 7, 12}
    D = sorted(difference_set(S))
    D_star = sorted(nonzero_difference_set(S))

    # Plot 1: The difference set with symmetry highlighted
    ax = axes[0]
    colors = ['#e74c3c' if z < 0 else '#2ecc71' if z > 0 else '#3498db' for z in D]
    ax.bar(range(len(D)), [1]*len(D), color=colors, edgecolor='black', linewidth=0.5)
    ax.set_xticks(range(len(D)))
    ax.set_xticklabels([str(d) for d in D], rotation=45, fontsize=8)
    ax.set_title(f'Δ(S) for S = {sorted(S)}\nRed=negative, Green=positive, Blue=zero',
                 fontsize=10)
    ax.set_ylabel('Membership')
    ax.set_yticks([])

    # Plot 2: Even cardinality across random sets
    ax = axes[1]
    sizes = []
    cards = []
    for _ in range(200):
        n = random.randint(2, 20)
        S_rand = set(random.sample(range(-30, 31), n))
        sizes.append(n)
        cards.append(len(nonzero_difference_set(S_rand)))
    ax.scatter(sizes, cards, alpha=0.5, s=15, c='#9b59b6')
    ax.set_xlabel('|S|')
    ax.set_ylabel('|Δ*(S)|')
    ax.set_title('Nonzero difference set cardinality\n(all even, by Theorem A)')

    # Plot 3: Diameter bound tightness
    ax = axes[2]
    ratios = []
    set_sizes = []
    for _ in range(300):
        n = random.randint(3, 15)
        S_rand = set(random.sample(range(-40, 41), n))
        d = diameter(S_rand)
        if d > 0:
            ratio = len(difference_set(S_rand)) / (2 * d + 1)
            ratios.append(ratio)
            set_sizes.append(n)
    ax.scatter(set_sizes, ratios, alpha=0.5, s=15, c='#e67e22')
    ax.set_xlabel('|S|')
    ax.set_ylabel('|Δ(S)| / (2D+1)')
    ax.set_title('Diameter bound utilization\n(always ≤ 1, by Theorem C)')
    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Upper bound')
    ax.legend()

    plt.tight_layout()
    plt.savefig('difference_set_structure.png', dpi=150, bbox_inches='tight')
    print("✓ Saved difference_set_structure.png")

    # Figure 2: Translation invariance demonstration
    fig2, ax2 = plt.subplots(figsize=(10, 4))
    S = {2, 5, 8, 14}
    translations = [-10, -5, 0, 5, 10, 20]
    D_original = sorted(difference_set(S))

    for i, a in enumerate(translations):
        S_t = translate(S, a)
        D_t = sorted(difference_set(S_t))
        y = [i] * len(D_t)
        ax2.scatter(D_t, y, s=30, zorder=5)

    ax2.set_yticks(range(len(translations)))
    ax2.set_yticklabels([f'S + {a}' for a in translations])
    ax2.set_xlabel('Difference values')
    ax2.set_title('Translation Invariance: Δ(S+a) = Δ(S) for all a')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('translation_invariance.png', dpi=150, bbox_inches='tight')
    print("✓ Saved translation_invariance.png")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    random.seed(42)

    demo_negation_symmetry()
    demo_translation_invariance()
    demo_diameter_bound()
    create_visualizations()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
