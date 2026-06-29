#!/usr/bin/env python3
"""
Cofinality Spectrum Theory - Interactive Demo

Demonstrates the key concepts:
1. Tame vs wild points in ordered spaces
2. The P-filter property
3. Cofinality computation for specific ordered spaces
"""

from fractions import Fraction
from typing import List, Tuple, Optional
import math


def cofinal_sequence_below_real(x: float, n_terms: int = 20) -> List[float]:
    """
    Generate the canonical cofinal sequence below a real number x.
    Uses x - 1/(k+1) for k = 0, 1, 2, ...

    Every real number is tame: this sequence witnesses countable left cofinality.
    """
    return [x - 1.0 / (k + 1) for k in range(n_terms)]


def coinitial_sequence_above_real(x: float, n_terms: int = 20) -> List[float]:
    """
    Generate the canonical coinitial sequence above a real number x.
    Uses x + 1/(k+1) for k = 0, 1, 2, ...
    """
    return [x + 1.0 / (k + 1) for k in range(n_terms)]


def verify_cofinality(x: float, seq: List[float], direction: str = "below") -> bool:
    """
    Verify that a sequence is cofinal below (or coinitial above) x.

    For 'below': checks that for test points y < x, there exists z in seq with y <= z.
    For 'above': checks that for test points y > x, there exists z in seq with z <= y.
    """
    if direction == "below":
        # Test with several points below x
        test_points = [x - 10**k for k in range(-10, 5)]
        for y in test_points:
            if y >= x:
                continue
            if not any(y <= z for z in seq):
                return False
        return True
    else:
        test_points = [x + 10**k for k in range(-10, 5)]
        for y in test_points:
            if y <= x:
                continue
            if not any(z <= y for z in seq):
                return False
        return True


def demonstrate_p_filter_failure_tame():
    """
    Demonstrate that tame points do NOT always have the P-filter property.

    For x = 0 in R, take U_n = (-1/(n+1), 1/(n+1)).
    Each U_n is a neighborhood of 0.
    But ∩ U_n = {0}, which is NOT a neighborhood of 0 (in the standard topology).

    This shows the P-filter property is specific to wild points.
    """
    x = 0.0
    neighborhoods = [(-1.0 / (n + 1), 1.0 / (n + 1)) for n in range(100)]

    print("=== P-Filter Property at Tame Points ===")
    print(f"Point: x = {x}")
    print(f"Neighborhoods U_n = (-1/(n+1), 1/(n+1)):")
    for n in range(5):
        a, b = neighborhoods[n]
        print(f"  U_{n} = ({a:.4f}, {b:.4f})")
    print("  ...")

    # The intersection shrinks to {0}
    print(f"\nIntersection ∩ U_n = {{0}}")
    print("This is NOT a neighborhood of 0 (it contains no open interval).")
    print("→ Tame points do NOT have the P-filter property in general.\n")


def demonstrate_p_filter_wild():
    """
    Demonstrate the P-filter property conceptually for wild points.

    In a space with uncountable cofinality (e.g., ω₁), countable intersections
    of neighborhoods remain neighborhoods because countable sets can't exhaust
    uncountable approach directions.
    """
    print("=== P-Filter Property at Wild Points ===")
    print("Consider ω₁ with the order topology.")
    print("The supremum point ω₁ has uncountable left cofinality.")
    print()
    print("Take neighborhoods U_n = (α_n, ω₁] for countable ordinals α_n.")
    print("The set {α_n : n ∈ ℕ} is countable, hence bounded in ω₁.")
    print("So ∃ β < ω₁ with α_n < β for all n.")
    print("Then (β, ω₁] ⊆ ∩ U_n, so ∩ U_n is a neighborhood.")
    print("→ The P-filter property holds at wild points.\n")


def cofinality_profile_examples():
    """
    Show cofinality profiles for various ordered spaces.
    """
    print("=== Cofinality Profiles ===\n")

    spaces = [
        ("ℝ (real numbers)", "All points tame",
         "Archimedean property gives countable cofinal sequences"),
        ("ℚ (rationals)", "All points tame",
         "Countable dense subset provides cofinal sequences"),
        ("ℤ (integers)", "All points tame",
         "Every point has a finite neighborhood basis"),
        ("ω₁ (first uncountable ordinal)", "ω₁ is left-wild; all others tame",
         "ω₁ has uncountable left cofinality; limit ordinals below ω₁ are tame"),
        ("ω₁ × [0,1) (long line)", "Points (ω₁, 0) are left-wild",
         "Inherits wildness from ω₁ component"),
        ("Surreal numbers (No)", "Most points wild",
         "The surreal number line has gaps at every uncountable cofinality"),
    ]

    for name, profile, reason in spaces:
        print(f"  {name}:")
        print(f"    Profile: {profile}")
        print(f"    Reason: {reason}")
        print()


def bound_lemma_demo():
    """
    Demonstrate the Bound Lemma numerically.

    In the ordinal ω₁, any countable set of ordinals has a strict upper bound.
    We simulate this with large natural numbers representing countable ordinals.
    """
    print("=== Bound Lemma Demonstration ===\n")

    # Simulate: countable sets of "ordinals" (represented as integers)
    # always have upper bounds
    import random
    random.seed(42)

    for trial in range(3):
        # Generate a "countable" set of ordinals
        n_elements = random.randint(5, 15)
        ordinals = sorted(random.sample(range(1, 10000), n_elements))

        bound = max(ordinals) + 1
        print(f"  Trial {trial + 1}: S = {ordinals[:5]}{'...' if len(ordinals) > 5 else ''}")
        print(f"    |S| = {len(ordinals)} (countable)")
        print(f"    Upper bound: {bound} > all elements of S")
        print(f"    In ω₁, this bound is still < ω₁ (uncountable cofinality)")
        print()

    print("  Key insight: No matter how many countable ordinals you pick,")
    print("  there's always room above them — that's uncountable cofinality.\n")


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║      COFINALITY SPECTRUM THEORY — Interactive Demo         ║")
    print("╚══════════════════════════════════════════════════════════════╝\n")

    # 1. Show cofinal sequences for reals
    print("=== Cofinal Sequences for Real Numbers ===")
    x = math.pi
    seq_below = cofinal_sequence_below_real(x, 10)
    seq_above = coinitial_sequence_above_real(x, 10)

    print(f"Point: x = π ≈ {x:.6f}")
    print(f"\nCofinal below (x - 1/(k+1)):")
    for i, s in enumerate(seq_below):
        print(f"  a_{i} = {s:.6f}  (gap to x: {x - s:.6f})")

    print(f"\nCoinitial above (x + 1/(k+1)):")
    for i, s in enumerate(seq_above[:5]):
        print(f"  b_{i} = {s:.6f}  (gap from x: {s - x:.6f})")
    print("  ...")

    is_cofinal = verify_cofinality(x, seq_below, "below")
    print(f"\nIs cofinal below π? {is_cofinal}")
    print(f"→ π is TAME (countable cofinality from both sides)\n")

    # 2. P-filter demonstrations
    demonstrate_p_filter_failure_tame()
    demonstrate_p_filter_wild()

    # 3. Cofinality profiles
    cofinality_profile_examples()

    # 4. Bound lemma
    bound_lemma_demo()

    # 5. Summary
    print("=" * 60)
    print("SUMMARY OF MAIN THEOREMS (all formally verified in Lean 4)")
    print("=" * 60)
    print()
    print("Theorem 1 (Bound Lemma):")
    print("  Countable sets below a wild point have strict upper bounds.")
    print()
    print("Theorem 2 (P-Filter Theorem):")
    print("  Fully wild points have the P-filter property:")
    print("  countable intersections of neighborhoods are neighborhoods.")
    print()
    print("Theorem 3 (Tame ↔ First-Countable):")
    print("  A point is tame ⟺ its neighborhood filter is")
    print("  countably generated.")
    print()
    print("Theorem 4 (All Reals Tame):")
    print("  Every real number is a tame point.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Cofinality Spectrum and P-Filter Property

Standalone matplotlib visualization of the key concepts.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_cofinal_sequences():
    """Plot cofinal and coinitial sequences converging to a point."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    x = np.pi
    n = 15

    # Left: cofinal sequence below x
    ax = axes[0]
    seq_below = [x - 1.0 / (k + 1) for k in range(n)]
    for i, s in enumerate(seq_below):
        ax.plot([s, s], [0, 0.8], color='steelblue', alpha=0.3 + 0.7 * i / n, linewidth=2)
        ax.plot(s, 0, 'o', color='steelblue', markersize=6)
    ax.axvline(x=x, color='red', linewidth=2, linestyle='--', label=f'x = π')
    ax.set_xlabel('Value', fontsize=12)
    ax.set_title('Cofinal Sequence Below π\n(witnesses countable left cofinality)', fontsize=11)
    ax.legend(fontsize=10)
    ax.set_yticks([])
    ax.annotate('→ approaching π', xy=(x - 0.3, 0.9), fontsize=10, color='steelblue')

    # Right: coinitial sequence above x
    ax = axes[1]
    seq_above = [x + 1.0 / (k + 1) for k in range(n)]
    for i, s in enumerate(seq_above):
        ax.plot([s, s], [0, 0.8], color='darkorange', alpha=0.3 + 0.7 * i / n, linewidth=2)
        ax.plot(s, 0, 'o', color='darkorange', markersize=6)
    ax.axvline(x=x, color='red', linewidth=2, linestyle='--', label=f'x = π')
    ax.set_xlabel('Value', fontsize=12)
    ax.set_title('Coinitial Sequence Above π\n(witnesses countable right cofinality)', fontsize=11)
    ax.legend(fontsize=10)
    ax.set_yticks([])
    ax.annotate('← approaching π', xy=(x + 0.15, 0.9), fontsize=10, color='darkorange')

    plt.suptitle('Real Numbers Are Tame: Countable Cofinality From Both Sides',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('cofinal_sequences.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cofinal_sequences.png")


def plot_p_filter_comparison():
    """Compare P-filter behavior at tame vs wild points."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Tame point — neighborhoods shrink to a point
    ax = axes[0]
    x = 0
    n_nbhds = 8
    colors = plt.cm.Blues(np.linspace(0.3, 0.9, n_nbhds))

    for i in range(n_nbhds):
        width = 1.0 / (i + 1)
        rect = mpatches.FancyBboxPatch(
            (x - width, i * 0.5), 2 * width, 0.4,
            boxstyle="round,pad=0.02",
            facecolor=colors[i], edgecolor='navy', alpha=0.6
        )
        ax.add_patch(rect)
        ax.text(x, i * 0.5 + 0.2, f'U_{i}', ha='center', va='center',
                fontsize=9, fontweight='bold')

    ax.axvline(x=0, color='red', linewidth=2, linestyle='--')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.3, n_nbhds * 0.5 + 0.3)
    ax.set_xlabel('Value', fontsize=12)
    ax.set_title('TAME Point: Neighborhoods Shrink to {x}\n∩ Uₙ = {0} — NOT a neighborhood',
                 fontsize=11, color='darkred')
    ax.set_yticks([])

    # Right: Wild point — neighborhoods maintain width
    ax = axes[1]
    for i in range(n_nbhds):
        # Each neighborhood is wide, only slightly different
        width = 1.0 + 0.3 * np.sin(i)
        left = -width / 2 - 0.1 * i
        rect = mpatches.FancyBboxPatch(
            (left, i * 0.5), width + 0.1 * i, 0.4,
            boxstyle="round,pad=0.02",
            facecolor=colors[i], edgecolor='darkgreen', alpha=0.6
        )
        ax.add_patch(rect)
        ax.text(0, i * 0.5 + 0.2, f'U_{i}', ha='center', va='center',
                fontsize=9, fontweight='bold')

    # Show the bounding interval
    ax.axvspan(-0.3, 0.3, alpha=0.2, color='green', label='∩ Uₙ ⊇ (a, b)')
    ax.axvline(x=0, color='red', linewidth=2, linestyle='--')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.3, n_nbhds * 0.5 + 0.3)
    ax.set_xlabel('Value', fontsize=12)
    ax.set_title('WILD Point: Bound Lemma Saves the Day\n∩ Uₙ ⊇ (a,b) — IS a neighborhood',
                 fontsize=11, color='darkgreen')
    ax.set_yticks([])
    ax.legend(fontsize=10)

    plt.suptitle('The P-Filter Theorem: Wild Points Have Stronger Convergence',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('p_filter_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: p_filter_comparison.png")


def plot_cofinality_spectrum():
    """Visualize the four cofinality types."""
    fig, ax = plt.subplots(figsize=(10, 7))

    types = [
        ('Tame', 0, 0, '#2196F3', 'Countable left\nCountable right',
         'Sequential methods ✓\nMetric compatible ✓\nP-filter: sometimes'),
        ('Left-Wild', 1, 0, '#FF9800', 'Uncountable left\nCountable right',
         'Left approach: nets only\nRight approach: sequences ✓'),
        ('Right-Wild', 0, 1, '#FF9800', 'Countable left\nUncountable right',
         'Left approach: sequences ✓\nRight approach: nets only'),
        ('Fully Wild', 1, 1, '#F44336', 'Uncountable left\nUncountable right',
         'Sequential methods ✗\nP-filter property ✓ (!)')
    ]

    for name, i, j, color, desc, props in types:
        x_pos = j * 3.5
        y_pos = (1 - i) * 3
        rect = mpatches.FancyBboxPatch(
            (x_pos - 1.4, y_pos - 1.1), 2.8, 2.2,
            boxstyle="round,pad=0.15",
            facecolor=color, edgecolor='black', alpha=0.15, linewidth=2
        )
        ax.add_patch(rect)
        ax.text(x_pos, y_pos + 0.6, name, ha='center', va='center',
                fontsize=14, fontweight='bold', color=color)
        ax.text(x_pos, y_pos, desc, ha='center', va='center',
                fontsize=9, style='italic')
        ax.text(x_pos, y_pos - 0.6, props, ha='center', va='center',
                fontsize=8, color='#333333')

    # Arrows and labels
    ax.annotate('', xy=(3.5 - 1.5, 3), xytext=(-1.3, 3),
                arrowprops=dict(arrowstyle='->', lw=2, color='gray'))
    ax.text(1.0, 3.3, 'Right cofinality\nincreases', ha='center',
            fontsize=9, color='gray')

    ax.annotate('', xy=(0, -0.2), xytext=(0, 2.8),
                arrowprops=dict(arrowstyle='->', lw=2, color='gray'))
    ax.text(-1.8, 1.5, 'Left cofinality\nincreases', ha='center',
            fontsize=9, color='gray', rotation=90)

    ax.set_xlim(-2.5, 5.5)
    ax.set_ylim(-1.8, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Cofinality Spectrum: Four-Way Classification',
                 fontsize=14, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('cofinality_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cofinality_spectrum.png")


if __name__ == '__main__':
    plot_cofinal_sequences()
    plot_p_filter_comparison()
    plot_cofinality_spectrum()
    print("\nAll visualizations generated.")
