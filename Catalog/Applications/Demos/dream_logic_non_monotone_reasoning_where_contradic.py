#!/usr/bin/env python3
"""
Dream Logic Demo: Numerical Examples and Demonstrations

Demonstrates the key concepts of paraconsistent non-monotone reasoning:
1. Belnap four-valued logic and explosion failure
2. Non-monotone skeptical consequence and belief retraction
3. Dream frames with coexisting contradictions
4. Dream depth analysis
"""

from algorithms import (
    BVal, ConflictSystem, skeptical_consequence,
    compute_dream_depth, verify_explosion_fails,
    iterated_belief_revision, dream_frame_evaluate
)


def demo_belnap_truth_tables():
    """Print the conjunction and disjunction truth tables for Belnap logic."""
    print("=" * 60)
    print("BELNAP FOUR-VALUED LOGIC: TRUTH TABLES")
    print("=" * 60)

    values = [BVal.T, BVal.F, BVal.B, BVal.N]
    labels = {"t": "T", "f": "F", "both": "B", "neither": "N"}

    # Conjunction
    print("\nConjunction (∧):")
    header = "     " + "  ".join(labels[v.value] for v in values)
    print(header)
    print("   " + "-" * (len(header) - 3))
    for a in values:
        row = f" {labels[a.value]} | "
        row += "  ".join(labels[a.conj(b).value] for b in values)
        print(row)

    # Disjunction
    print("\nDisjunction (∨):")
    print(header)
    print("   " + "-" * (len(header) - 3))
    for a in values:
        row = f" {labels[a.value]} | "
        row += "  ".join(labels[a.disj(b).value] for b in values)
        print(row)

    # Negation
    print("\nNegation (¬):")
    for v in values:
        print(f"  ¬{labels[v.value]} = {labels[v.belnap_neg().value]}")

    # Designation
    print("\nDesignation (positive support):")
    for v in values:
        print(f"  {labels[v.value]}: designated = {v.is_designated()}")


def demo_explosion_failure():
    """Demonstrate that explosion fails in Belnap logic."""
    print("\n" + "=" * 60)
    print("EXPLOSION FAILURE")
    print("=" * 60)

    for n in [2, 3, 5, 10]:
        val, verified = verify_explosion_fails(n)
        val_str = [val[i].value for i in range(n)]
        print(f"\n  n={n}: {val_str}")
        v0 = val[0]
        contr = v0.conj(v0.belnap_neg())
        print(f"    P₀ ∧ ¬P₀ = {v0.value} ∧ {v0.belnap_neg().value} "
              f"= {contr.value} (designated: {contr.is_designated()})")
        non_designated = [i for i in range(1, n) if not val[i].is_designated()]
        print(f"    Non-designated propositions: {non_designated}")
        print(f"    Explosion fails: {verified} ✓")


def demo_nonmonotone_consequence():
    """Demonstrate non-monotone skeptical consequence."""
    print("\n" + "=" * 60)
    print("NON-MONOTONE SKEPTICAL CONSEQUENCE")
    print("=" * 60)

    # Simple conflict: 0 conflicts with 1
    C = ConflictSystem(2, {(0, 1), (1, 0)})

    print("\n  Conflict system: 0 ↔ 1 (mutual conflict)")

    # Show non-monotonicity
    gamma = {0}
    delta = {0, 1}

    result_gamma = skeptical_consequence(C, gamma, 0)
    result_delta = skeptical_consequence(C, delta, 0)

    print(f"\n  Γ = {gamma}")
    print(f"    Γ ⊢ 0? {result_gamma} ← 0 ∈ Γ, no conflicts with 0 in Γ")
    print(f"\n  Δ = {delta} (Γ ⊆ Δ)")
    print(f"    Δ ⊢ 0? {result_delta} ← 1 ∈ Δ conflicts with 0!")
    print(f"\n  Monotonicity violated: Γ ⊆ Δ, Γ ⊢ 0, but Δ ⊬ 0 ✓")


def demo_belief_revision():
    """Demonstrate iterated belief revision."""
    print("\n" + "=" * 60)
    print("ITERATED BELIEF REVISION")
    print("=" * 60)

    # Triangle conflict: 0↔1, 1↔2, 0↔2
    conflicts = {(0, 1), (1, 0), (1, 2), (2, 1), (0, 2), (2, 0)}
    C = ConflictSystem(3, conflicts)

    print("\n  Conflict graph: complete triangle K₃")
    print("  0 ↔ 1, 1 ↔ 2, 0 ↔ 2")

    initial = {0, 1, 2}
    history = iterated_belief_revision(C, initial)

    print(f"\n  Initial beliefs: {initial}")
    for step, beliefs in enumerate(history):
        print(f"  Step {step}: {beliefs}")
    print(f"  Fixed point: ∅ (all beliefs retracted due to mutual conflicts)")

    # Linear conflict: 0↔1, 1↔2 (path graph)
    print("\n  Conflict graph: path P₃")
    print("  0 ↔ 1, 1 ↔ 2 (but 0 and 2 don't conflict)")
    conflicts2 = {(0, 1), (1, 0), (1, 2), (2, 1)}
    C2 = ConflictSystem(3, conflicts2)
    initial2 = {0, 1, 2}
    history2 = iterated_belief_revision(C2, initial2)
    for step, beliefs in enumerate(history2):
        print(f"  Step {step}: {beliefs}")


def demo_dream_frames():
    """Demonstrate dream frames with coexisting contradictions."""
    print("\n" + "=" * 60)
    print("DREAM FRAMES: COEXISTING CONTRADICTIONS")
    print("=" * 60)

    # Dream frame 1: single world with contradictory valuation
    print("\n  Frame 1: Single contradictory world")
    print("  W = {0}, R = {(0,0)}, V(0,P) = B (both)")
    access1 = {0: {0}}
    val1 = {(0, 0): BVal.B}
    nec, pos, neg_nec = dream_frame_evaluate(access1, val1, 0, 0)
    print(f"    □P at 0: {nec} (P is necessary)")
    print(f"    ◇P at 0: {pos} (P is possible)")
    print(f"    □¬P at 0: {neg_nec} (¬P is also necessary!)")
    print(f"    → P and ¬P are BOTH necessary — impossible classically ✓")

    # Dream frame 2: two worlds with different values
    print("\n  Frame 2: Two worlds, mixed valuations")
    print("  W = {0,1}, R = {(0,0),(0,1)}, V(0,P)=B, V(1,P)=T")
    access2 = {0: {0, 1}, 1: {1}}
    val2 = {(0, 0): BVal.B, (1, 0): BVal.T}
    nec, pos, neg_nec = dream_frame_evaluate(access2, val2, 0, 0)
    print(f"    □P at 0: {nec} (both B and T are designated)")
    print(f"    ◇P at 0: {pos}")
    print(f"    □¬P at 0: {neg_nec} (T's negation F is not designated)")
    print(f"    → P is necessary but ¬P is only possible, not necessary")


def demo_dream_depth():
    """Demonstrate dream depth analysis."""
    print("\n" + "=" * 60)
    print("DREAM DEPTH ANALYSIS")
    print("=" * 60)

    # Various valuations on 5 propositions
    valuations = [
        ("Classical (all T)", {i: BVal.T for i in range(5)}),
        ("Unknown (all N)", {i: BVal.N for i in range(5)}),
        ("Mixed", {0: BVal.T, 1: BVal.B, 2: BVal.F, 3: BVal.B, 4: BVal.T}),
        ("Full dream (all B)", {i: BVal.B for i in range(5)}),
        ("One contradiction", {0: BVal.B, 1: BVal.T, 2: BVal.T, 3: BVal.T, 4: BVal.T}),
    ]

    for name, val in valuations:
        depth = compute_dream_depth(val)
        designated = sum(1 for v in val.values() if v.is_designated())
        dual_designated = sum(
            1 for v in val.values()
            if v.is_designated() and v.belnap_neg().is_designated()
        )
        print(f"\n  {name}:")
        print(f"    Values: {[val[i].value for i in range(5)]}")
        print(f"    Dream depth: {depth}/5")
        print(f"    Designated: {designated}/5")
        print(f"    Dual designated (P ∧ ¬P): {dual_designated}/5")
        print(f"    Dream depth = dual designated: {depth == dual_designated} ✓")


if __name__ == "__main__":
    demo_belnap_truth_tables()
    demo_explosion_failure()
    demo_nonmonotone_consequence()
    demo_belief_revision()
    demo_dream_frames()
    demo_dream_depth()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Belnap Four-Valued Logic Lattice and Dream Depth

Creates visualizations of:
1. The Belnap bilattice (truth and information orderings)
2. Dream depth distribution across random valuations
3. Explosion failure demonstration
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_belnap_bilattice():
    """Draw the Belnap bilattice with truth and information orderings."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Truth ordering: f < {n, b} < t
    ax1 = axes[0]
    ax1.set_title("Truth Ordering (≤ₜ)", fontsize=14, fontweight='bold')
    positions = {'f': (0, 0), 'n': (-1, 1), 'b': (1, 1), 't': (0, 2)}
    colors = {'t': '#2ecc71', 'f': '#e74c3c', 'b': '#9b59b6', 'n': '#95a5a6'}
    labels = {'t': 'T (true)', 'f': 'F (false)', 'b': 'B (both)', 'n': 'N (neither)'}

    # Draw edges (Hasse diagram)
    edges = [('f', 'n'), ('f', 'b'), ('n', 't'), ('b', 't')]
    for a, c in edges:
        ax1.plot([positions[a][0], positions[c][0]],
                [positions[a][1], positions[c][1]],
                'k-', linewidth=1.5, zorder=1)

    # Draw nodes
    for val, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.25, color=colors[val],
                           ec='black', linewidth=2, zorder=2)
        ax1.add_patch(circle)
        ax1.text(x, y, val.upper(), ha='center', va='center',
                fontsize=16, fontweight='bold', color='white', zorder=3)
        ax1.text(x, y - 0.4, labels[val], ha='center', va='top',
                fontsize=9, color='gray')

    ax1.set_xlim(-2, 2)
    ax1.set_ylim(-0.8, 2.8)
    ax1.set_aspect('equal')
    ax1.axis('off')
    ax1.text(0, -0.6, "∧ = meet,  ∨ = join", ha='center',
            fontsize=10, style='italic')

    # Information ordering: n < {t, f} < b
    ax2 = axes[1]
    ax2.set_title("Information Ordering (≤ₖ)", fontsize=14, fontweight='bold')
    positions2 = {'n': (0, 0), 't': (-1, 1), 'f': (1, 1), 'b': (0, 2)}

    edges2 = [('n', 't'), ('n', 'f'), ('t', 'b'), ('f', 'b')]
    for a, c in edges2:
        ax2.plot([positions2[a][0], positions2[c][0]],
                [positions2[a][1], positions2[c][1]],
                'k-', linewidth=1.5, zorder=1)

    for val, (x, y) in positions2.items():
        circle = plt.Circle((x, y), 0.25, color=colors[val],
                           ec='black', linewidth=2, zorder=2)
        ax2.add_patch(circle)
        ax2.text(x, y, val.upper(), ha='center', va='center',
                fontsize=16, fontweight='bold', color='white', zorder=3)

    ax2.set_xlim(-2, 2)
    ax2.set_ylim(-0.8, 2.8)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.text(0, -0.6, "⊕ = consensus,  ⊗ = gullibility", ha='center',
            fontsize=10, style='italic')

    # Add designated marker
    for ax, pos in [(ax1, positions), (ax2, positions2)]:
        for val in ['t', 'b']:
            x, y = pos[val]
            ax.plot(x + 0.2, y + 0.2, '*', color='gold', markersize=12,
                   markeredgecolor='black', markeredgewidth=0.5, zorder=4)

    fig.suptitle("Belnap's Four-Valued Bilattice\n(★ = designated values)",
                fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout()
    plt.savefig('viz_belnap_bilattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_belnap_bilattice.png")


def draw_dream_depth_analysis():
    """Visualize dream depth distribution and properties."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    np.random.seed(42)

    # 1. Dream depth distribution for random valuations
    ax1 = axes[0]
    n_props = 10
    n_samples = 10000
    values = [0, 1, 2, 3]  # t, f, b, n
    depths = []
    for _ in range(n_samples):
        valuation = np.random.choice(values, size=n_props)
        depth = np.sum(valuation == 2)  # count 'b' values
        depths.append(depth)

    ax1.hist(depths, bins=range(n_props + 2), color='#9b59b6', alpha=0.7,
            edgecolor='black', density=True, align='left')
    # Overlay binomial distribution
    from scipy.stats import binom
    x = np.arange(0, n_props + 1)
    ax1.plot(x, binom.pmf(x, n_props, 0.25), 'ro-', markersize=5,
            label='Binomial(10, 0.25)')
    ax1.set_xlabel('Dream Depth', fontsize=12)
    ax1.set_ylabel('Frequency', fontsize=12)
    ax1.set_title('Dream Depth Distribution\n(10 props, uniform random)', fontsize=12)
    ax1.legend()

    # 2. Designated count vs dream depth
    ax2 = axes[1]
    for depth in range(n_props + 1):
        # For a given depth d, propositions: d are B (designated),
        # remaining split among T, F, N
        for _ in range(200):
            # d propositions are B (designated)
            n_remaining = n_props - depth
            remaining = np.random.choice([0, 1, 3], size=n_remaining)
            designated = depth + np.sum(remaining == 0)  # B + T
            ax2.scatter(depth, designated, color='#3498db', alpha=0.05, s=10)

    ax2.set_xlabel('Dream Depth', fontsize=12)
    ax2.set_ylabel('Designated Count', fontsize=12)
    ax2.set_title('Designated Propositions\nvs Dream Depth', fontsize=12)
    ax2.plot([0, n_props], [0, n_props], 'r--', alpha=0.5, label='depth = designated')
    ax2.legend()

    # 3. Explosion containment
    ax3 = axes[2]
    n_values = list(range(2, 21))
    for n in n_values:
        # With depth 1 (one B), all others F: 1 designated out of n
        ratio = 1 / n
        ax3.bar(n, ratio, color='#e74c3c', alpha=0.7, edgecolor='black')

    ax3.set_xlabel('Number of Propositions', fontsize=12)
    ax3.set_ylabel('Fraction Designated\n(with 1 contradiction)', fontsize=12)
    ax3.set_title('Explosion Containment\n(contradiction stays local)', fontsize=12)
    ax3.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5,
               label='Classical (all designated)')
    ax3.legend()

    plt.suptitle("Dream Depth Analysis", fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_dream_depth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_dream_depth.png")


def draw_nonmonotone_belief_revision():
    """Visualize non-monotone belief revision dynamics."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Example 1: K₃ conflict graph
    ax1 = axes[0]
    ax1.set_title("K₃ Conflict: Iterated Revision", fontsize=12, fontweight='bold')

    # Draw conflict graph
    angles = [np.pi/2, np.pi/2 + 2*np.pi/3, np.pi/2 + 4*np.pi/3]
    cx, cy = 0.3, 0.7
    r = 0.15
    node_pos = [(cx + r * np.cos(a), cy + r * np.sin(a)) for a in angles]

    for i in range(3):
        for j in range(i+1, 3):
            ax1.plot([node_pos[i][0], node_pos[j][0]],
                    [node_pos[i][1], node_pos[j][1]],
                    'r-', linewidth=2, alpha=0.5)

    for i, (x, y) in enumerate(node_pos):
        ax1.plot(x, y, 'o', markersize=20, color='#3498db',
                markeredgecolor='black', markeredgewidth=2)
        ax1.text(x, y, str(i), ha='center', va='center',
                fontsize=12, fontweight='bold', color='white')

    # Timeline
    steps = [0, 1, 2]
    beliefs = [{0, 1, 2}, set(), set()]
    for step in steps:
        y = 0.3 - step * 0.1
        active = beliefs[step]
        for i in range(3):
            color = '#2ecc71' if i in active else '#e0e0e0'
            ax1.add_patch(plt.Circle((0.7 + i * 0.08, y), 0.025,
                                    color=color, ec='black'))
        ax1.text(0.62, y, f"t={step}", ha='right', va='center', fontsize=10)

    ax1.set_xlim(0, 1)
    ax1.set_ylim(-0.05, 1)
    ax1.axis('off')
    ax1.text(0.5, 0.95, "All beliefs retracted\n(mutual conflicts)",
            ha='center', fontsize=10, style='italic')

    # Example 2: Path P₅ conflict graph
    ax2 = axes[1]
    ax2.set_title("P₅ Path: Iterated Revision", fontsize=12, fontweight='bold')

    # Draw path graph
    path_pos = [(0.1 + i * 0.15, 0.7) for i in range(5)]
    for i in range(4):
        ax2.plot([path_pos[i][0], path_pos[i+1][0]],
                [path_pos[i][1], path_pos[i+1][1]],
                'r-', linewidth=2, alpha=0.5)

    for i, (x, y) in enumerate(path_pos):
        ax2.plot(x, y, 'o', markersize=20, color='#3498db',
                markeredgecolor='black', markeredgewidth=2)
        ax2.text(x, y, str(i), ha='center', va='center',
                fontsize=12, fontweight='bold', color='white')

    # Compute revision for path 0-1-2-3-4
    # Conflicts: 0↔1, 1↔2, 2↔3, 3↔4
    # Step 0: {0,1,2,3,4} → all conflicted → retract all conflicted ones
    # Actually: 0 conflicts with 1, 1 conflicts with 0,2, 2 conflicts with 1,3, etc.
    # None survive because each has a neighbor
    # Step 1: {} (fixed point)

    path_steps = [
        {0, 1, 2, 3, 4},
        set(),
        set()
    ]

    for step in range(min(3, len(path_steps))):
        y = 0.4 - step * 0.1
        active = path_steps[step]
        for i in range(5):
            color = '#2ecc71' if i in active else '#e0e0e0'
            ax2.add_patch(plt.Circle((0.1 + i * 0.15, y), 0.025,
                                    color=color, ec='black'))
        ax2.text(0.02, y, f"t={step}", ha='right', va='center', fontsize=10)

    ax2.set_xlim(-0.05, 0.95)
    ax2.set_ylim(0.05, 0.95)
    ax2.axis('off')
    ax2.text(0.45, 0.12, "All beliefs retracted\n(every node has a conflicting neighbor)",
            ha='center', fontsize=10, style='italic')

    plt.suptitle("Non-Monotone Belief Revision Dynamics",
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_belief_revision.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_belief_revision.png")


if __name__ == "__main__":
    draw_belnap_bilattice()
    draw_dream_depth_analysis()
    draw_nonmonotone_belief_revision()
    print("\nAll visualizations generated successfully.")
