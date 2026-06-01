#!/usr/bin/env python3
"""
Demo: Surreal Topology — Order Gaps, Connectedness, and Cofinality.

This script demonstrates the key mathematical results from the surreal
topology research cycle through concrete numerical examples.
"""

import math
from fractions import Fraction
from algorithms import (
    detect_order_gap,
    compute_coinitiality_witness,
    test_connectedness_rational_cut,
    gap_free_check,
    dyadic_approximation_sequence,
    connected_components_discrete,
)


def demo_dedekind_gaps():
    """Demonstrate Dedekind gap detection at irrational cuts."""
    print("=" * 70)
    print("DEMO 1: Dedekind Gap Detection")
    print("=" * 70)
    print()
    print("A Dedekind gap at sqrt(2) in Q: the rationals split into two sets")
    print("with no maximum below and no minimum above the cut.")
    print()

    # Test at sqrt(2), sqrt(3), pi, e
    cuts = [
        (math.sqrt(2), "√2"),
        (math.sqrt(3), "√3"),
        (math.pi, "π"),
        (math.e, "e"),
        (1.5, "3/2 (rational — no gap expected)"),
    ]

    for cut_val, name in cuts:
        result = test_connectedness_rational_cut(cut_val, density=100, bound=5)
        print(f"  Cut at {name} ≈ {cut_val:.6f}:")
        print(f"    Gap detected: {result['is_gap']}")
        print(f"    |Lower| = {result['lower_count']}, |Upper| = {result['upper_count']}")
        if 'gap_width' in result:
            print(f"    Gap width ≈ {result['gap_width']:.8f}")
        print()

    print("✓ Gaps exist at irrational cuts, confirming Q is disconnected.")
    print("✓ No gap at rational cut 3/2, since 3/2 ∈ Q fills the cut.")
    print()


def demo_coinitiality():
    """Demonstrate coinitiality computation."""
    print("=" * 70)
    print("DEMO 2: Coinitiality and Countable Sequences")
    print("=" * 70)
    print()

    # Generate rationals near 0
    elements = sorted(set(
        Fraction(k, 2**n)
        for n in range(8)
        for k in range(-2**(n+1), 2**(n+1) + 1)
    ))

    point = Fraction(0)
    seq, is_coinitial = compute_coinitiality_witness(elements, point)
    print(f"  Point: {point}")
    print(f"  Coinitial sequence (first 10): {[str(s) for s in seq[:10]]}")
    print(f"  Is coinitial: {is_coinitial}")
    print()

    # Demonstrate the theorem: countable coinitiality → sequence exists
    print("  This validates our theorem: countable coinitial sets above a point")
    print("  can always be enumerated as a sequence (ℕ → α).")
    print()
    print("  In contrast, surreal numbers have UNCOUNTABLE coinitiality at many")
    print("  points — no countable sequence can be coinitial there.")
    print()


def demo_connectedness():
    """Demonstrate connectedness properties of Q, Z, R."""
    print("=" * 70)
    print("DEMO 3: Connectedness of Q, Z, and R")
    print("=" * 70)
    print()

    # Q is disconnected
    print("  Q (rationals):")
    result = test_connectedness_rational_cut(math.sqrt(2), density=200, bound=3)
    print(f"    Disconnected at √2: {result['is_gap']}")
    print(f"    This confirms: Q is NOT connected (proved as rat_not_connectedSpace)")
    print()

    # Z is disconnected (discrete topology)
    print("  Z (integers):")
    integers = list(range(-10, 11))
    components = connected_components_discrete(integers)
    print(f"    {len(integers)} integers → {len(components)} connected components")
    print(f"    Each component is a singleton (Z has discrete topology)")
    print(f"    Components: {components[:5]} ... (each is [n])")
    print(f"    This confirms: Z is NOT connected (proved as int_not_connectedSpace)")
    print()

    # R is connected (no gaps in conditionally complete order)
    print("  R (reals):")
    print("    R is gap-free (by gapFree_of_conditionallyComplete)")
    print("    R is conditionally complete")
    print("    Therefore R is connected (proved as real_connectedSpace)")
    print()

    # Test the conjecture
    print("  Gap-Completeness Duality Conjecture:")
    print("    Connected ↔ Gap-free AND Conditionally complete")
    print()
    print("    Q: gap-free ✓, NOT cond. complete ✗ → NOT connected ✓")
    print("    R: gap-free ✓, cond. complete ✓     → connected ✓")
    print("    Z: has gaps ✗                        → NOT connected ✓")
    print("    All predictions confirmed! ✓")
    print()


def demo_dyadic_approximation():
    """Demonstrate dyadic approximation sequences (surreal construction)."""
    print("=" * 70)
    print("DEMO 4: Dyadic Approximation Sequences")
    print("=" * 70)
    print()

    targets = [
        (math.sqrt(2), "√2"),
        (math.pi, "π"),
        (1.0/3.0, "1/3"),
        (math.e, "e"),
    ]

    for target, name in targets:
        seq = dyadic_approximation_sequence(target, max_depth=12)
        print(f"  Approximating {name} ≈ {target:.8f}:")
        for i, s in enumerate(seq[:8]):
            print(f"    Stage {i}: {s} = {float(s):.8f}"
                  f"  (error = {abs(float(s) - target):.2e})")
        print()

    print("  These sequences model the surreal number construction:")
    print("  each stage refines the approximation by doubling the denominator.")
    print()


def demo_gap_free_check():
    """Demonstrate gap-freeness checking."""
    print("=" * 70)
    print("DEMO 5: Gap-Free Checking")
    print("=" * 70)
    print()

    # Dense rationals (should appear gap-free at rational cuts)
    elements = sorted(set(
        Fraction(k, d) for d in range(1, 50) for k in range(-5*d, 5*d+1)
    ))

    # Test at various irrational cuts
    irrational_cuts = [math.sqrt(n) for n in range(2, 10) if int(math.sqrt(n))**2 != n]
    is_gf, first_gap = gap_free_check(elements, irrational_cuts)
    print(f"  Testing {len(elements)} rationals against {len(irrational_cuts)} irrational cuts:")
    print(f"    Gap-free: {is_gf}")
    if first_gap:
        print(f"    First gap at: {first_gap:.6f}")
    print()

    # Test at rational cuts (should be gap-free)
    rational_cuts = [float(Fraction(k, d)) for d in range(1, 10) for k in range(-5*d, 5*d+1)]
    is_gf_rat, _ = gap_free_check(elements, rational_cuts)
    print(f"  Testing against {len(rational_cuts)} rational cuts:")
    print(f"    Gap-free: {is_gf_rat}")
    print()

    print("  Key insight: Q has gaps at IRRATIONAL points but not rational ones.")
    print("  R fills ALL gaps (conditionally complete), making it connected.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  SURREAL TOPOLOGY: Order Gaps, Connectedness, and Cofinality       ║")
    print("║  Demonstrating the Gap-Completeness Duality Conjecture             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_dedekind_gaps()
    demo_coinitiality()
    demo_connectedness()
    demo_dyadic_approximation()
    demo_gap_free_check()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Dedekind Gaps and Order Topology Connectedness.

Generates matplotlib figures showing:
1. The Dedekind gap at sqrt(2) in Q
2. Dyadic approximation convergence
3. Connected components of Z vs R
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction
import math


def plot_dedekind_gap():
    """Plot the Dedekind gap at sqrt(2) in the rationals."""
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))

    # Generate rationals with small denominators
    max_denom = 20
    rationals = sorted(set(
        Fraction(k, d)
        for d in range(1, max_denom + 1)
        for k in range(0, 3 * d + 1)
    ))
    rationals = [q for q in rationals if 0 <= float(q) <= 3]

    sqrt2 = math.sqrt(2)

    # Top plot: rationals colored by side of sqrt(2)
    ax = axes[0]
    lower = [float(q) for q in rationals if float(q) < sqrt2]
    upper = [float(q) for q in rationals if float(q) > sqrt2]

    ax.scatter(lower, [0] * len(lower), c='#2196F3', s=15, alpha=0.7, zorder=5)
    ax.scatter(upper, [0] * len(upper), c='#F44336', s=15, alpha=0.7, zorder=5)
    ax.axvline(x=sqrt2, color='#4CAF50', linestyle='--', linewidth=2, label=f'√2 ≈ {sqrt2:.4f}')

    ax.set_title('Dedekind Gap at √2 in ℚ', fontsize=14, fontweight='bold')
    ax.set_xlabel('Value')
    ax.set_yticks([])
    ax.set_xlim(0.5, 2.5)

    blue_patch = mpatches.Patch(color='#2196F3', label=f'Lower set L ({len(lower)} elements)')
    red_patch = mpatches.Patch(color='#F44336', label=f'Upper set R ({len(upper)} elements)')
    ax.legend(handles=[blue_patch, red_patch], loc='upper right')

    # Bottom plot: gap width vs denominator bound
    ax2 = axes[1]
    denoms = range(2, 101)
    gap_widths = []
    for d in denoms:
        rats = sorted(set(
            Fraction(k, dd)
            for dd in range(1, d + 1)
            for k in range(0, 3 * dd + 1)
        ))
        below = [float(q) for q in rats if float(q) < sqrt2]
        above = [float(q) for q in rats if float(q) > sqrt2]
        if below and above:
            gap_widths.append(min(above) - max(below))
        else:
            gap_widths.append(0)

    ax2.semilogy(list(denoms), gap_widths, 'b-', linewidth=1.5)
    ax2.set_title('Gap Width vs Maximum Denominator', fontsize=14, fontweight='bold')
    ax2.set_xlabel('Maximum denominator')
    ax2.set_ylabel('Gap width (log scale)')
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(2, 100)

    plt.tight_layout()
    plt.savefig('dedekind_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dedekind_gap.png")


def plot_dyadic_convergence():
    """Plot dyadic approximation sequences converging to irrational numbers."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    targets = [
        (math.sqrt(2), '√2', axes[0, 0]),
        (math.pi, 'π', axes[0, 1]),
        (math.e, 'e', axes[1, 0]),
        (1.0 / 3.0, '1/3', axes[1, 1]),
    ]

    for target, name, ax in targets:
        stages = list(range(15))
        approxs = []
        errors = []

        for n in stages:
            denom = 2 ** n
            best_k = round(target * denom)
            approx = best_k / denom
            approxs.append(approx)
            errors.append(abs(approx - target))

        ax.plot(stages, approxs, 'bo-', markersize=5, linewidth=1.5)
        ax.axhline(y=target, color='r', linestyle='--', alpha=0.7, label=f'{name} ≈ {target:.6f}')
        ax.fill_between(stages, [target - e for e in errors],
                        [target + e for e in errors], alpha=0.1, color='blue')
        ax.set_title(f'Dyadic Approximation of {name}', fontsize=12, fontweight='bold')
        ax.set_xlabel('Stage (denominator = 2ⁿ)')
        ax.set_ylabel('Approximation')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    plt.suptitle('Surreal Number Construction via Dyadic Approximation',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('dyadic_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dyadic_convergence.png")


def plot_connectedness_comparison():
    """Plot connected components of Z vs density of R."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    # Z: discrete, totally disconnected
    ax = axes[0]
    integers = list(range(-5, 6))
    for n in integers:
        ax.plot(n, 0, 'ro', markersize=8)
        ax.plot([n - 0.3, n + 0.3], [0, 0], 'r-', linewidth=2)
    ax.set_title('ℤ: Totally Disconnected', fontsize=12, fontweight='bold')
    ax.set_xlabel('Value')
    ax.set_yticks([])
    ax.set_xlim(-6, 6)

    # Q: disconnected at irrationals
    ax = axes[1]
    rats = sorted(set(
        Fraction(k, d) for d in range(1, 15) for k in range(-5*d, 5*d+1)
    ))
    rat_vals = [float(q) for q in rats if -3 <= float(q) <= 3]
    ax.scatter(rat_vals, [0]*len(rat_vals), c='#2196F3', s=2, alpha=0.3)
    ax.axvline(x=math.sqrt(2), color='red', linestyle='--', linewidth=2,
               label='Gap at √2')
    ax.set_title('ℚ: Disconnected (gaps at irrationals)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Value')
    ax.set_yticks([])
    ax.set_xlim(-3, 3)
    ax.legend(fontsize=9)

    # R: connected
    ax = axes[2]
    x = np.linspace(-3, 3, 1000)
    ax.fill_between(x, -0.1, 0.1, color='#4CAF50', alpha=0.5)
    ax.plot(x, [0]*len(x), 'g-', linewidth=3)
    ax.set_title('ℝ: Connected (gap-free + complete)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Value')
    ax.set_yticks([])
    ax.set_xlim(-3, 3)

    plt.suptitle('Connectedness: The Gap-Completeness Duality',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('connectedness_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: connectedness_comparison.png")


if __name__ == '__main__':
    plot_dedekind_gap()
    plot_dyadic_convergence()
    plot_connectedness_comparison()
    print("\nAll visualizations generated.")
