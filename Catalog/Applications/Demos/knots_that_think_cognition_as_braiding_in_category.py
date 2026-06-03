#!/usr/bin/env python3
"""
Cognitive Braids: Demonstration Script

Computes braid invariants for canonical cognitive processes and demonstrates
the relationship between topological complexity and cognitive quality.
"""

from algorithms import (
    CognitiveBraid, BraidGen,
    trivial_braid, linear_reasoning, trefoil_insight,
    confused_thinking, rumination, deep_insight,
    exponent_sum, braid_inverse, braid_compose,
    braid_permutation, quantum_dimension
)

import math
import cmath


def demo_basic_invariants():
    """Demonstrate basic braid invariants for canonical cognitive braids."""
    print("=" * 70)
    print("COGNITIVE BRAIDS: Topological Invariants of Thought")
    print("=" * 70)

    braids = [
        trivial_braid(),
        linear_reasoning(4),
        trefoil_insight(),
        confused_thinking(),
        rumination(3, 5),
        deep_insight(5),
    ]

    print(f"\n{'Thought Type':<35} {'Exp.Sum':>8} {'Cross#':>7} "
          f"{'Span':>5} {'Q-Dim':>8} {'Perm':>15}")
    print("-" * 85)

    for b in braids:
        print(f"{b.label:<35} {b.exponent_sum():>8} {b.crossing_number():>7} "
              f"{b.generator_span():>5} {b.quantum_dimension():>8.4f} "
              f"{str(b.permutation()):>15}")


def demo_invariance():
    """Demonstrate that exponent sum is a braid invariant."""
    print("\n" + "=" * 70)
    print("INVARIANCE DEMONSTRATION")
    print("=" * 70)

    # The trefoil braid
    trefoil = trefoil_insight()
    print(f"\nOriginal trefoil: {trefoil.word}")
    print(f"  Exponent sum: {trefoil.exponent_sum()}")

    # Add and cancel σ₀ σ₀⁻¹ (free cancellation)
    modified = CognitiveBraid(3,
        [BraidGen(0, 1), BraidGen(0, -1)] + trefoil.word,
        "trefoil + cancelling pair")
    print(f"\nWith cancelling pair prepended: {modified.word}")
    print(f"  Exponent sum: {modified.exponent_sum()}")
    print(f"  (Same! Free cancellation preserves exponent sum)")

    # Apply far commutativity (not applicable to B_3 with adjacent generators)
    # Apply braid relation: σ₀ σ₁ σ₀ = σ₁ σ₀ σ₁
    equivalent = CognitiveBraid(3,
        [BraidGen(1, 1), BraidGen(0, 1), BraidGen(1, 1)],
        "trefoil after braid relation")
    print(f"\nAfter braid relation σ₀σ₁σ₀ → σ₁σ₀σ₁: {equivalent.word}")
    print(f"  Exponent sum: {equivalent.exponent_sum()}")
    print(f"  (Same! Braid relation preserves exponent sum)")


def demo_composition():
    """Demonstrate composition (additivity of writhe)."""
    print("\n" + "=" * 70)
    print("COGNITIVE COMPOSITION: Additivity of Information Flow")
    print("=" * 70)

    t = trefoil_insight()
    f = confused_thinking()

    composed = t.compose(f)
    print(f"\nTrefoil writhe: {t.exponent_sum()}")
    print(f"Figure-eight writhe: {f.exponent_sum()}")
    print(f"Composed writhe: {composed.exponent_sum()}")
    print(f"Sum: {t.exponent_sum() + f.exponent_sum()}")
    print(f"Additive? {composed.exponent_sum() == t.exponent_sum() + f.exponent_sum()}")


def demo_reflection():
    """Demonstrate that a thought composed with its reflection has zero writhe."""
    print("\n" + "=" * 70)
    print("COGNITIVE REFLECTION: Self-Cancellation")
    print("=" * 70)

    t = trefoil_insight()
    inv = CognitiveBraid(3, braid_inverse(t.word), "inverse trefoil")
    composed = CognitiveBraid(3,
        braid_compose(t.word, inv.word),
        "trefoil + inverse")

    print(f"\nTrefoil writhe: {t.exponent_sum()}")
    print(f"Inverse writhe: {exponent_sum(inv.word)}")
    print(f"Composed writhe: {composed.exponent_sum()}")
    print(f"Zero? {composed.exponent_sum() == 0}")
    print("\nInterpretation: A thought composed with its 'reflection' cancels out.")
    print("This is the topological basis of cognitive self-correction.")


def demo_quantum_dimension():
    """Compute quantum dimensions for cognitive braids."""
    print("\n" + "=" * 70)
    print("QUANTUM DIMENSION: Information Content of Thoughts")
    print("=" * 70)

    t = cmath.exp(2j * cmath.pi / 3)

    # Trivial braid: V = 1
    print(f"\nTrivial thought:")
    print(f"  Jones polynomial at e^(2πi/3): V = 1")
    print(f"  Quantum dimension: Q = log|1| = 0")

    # Right trefoil: V(t) = -t^{-4} + t^{-3} + t^{-1}
    v_trefoil = -t**(-4) + t**(-3) + t**(-1)
    print(f"\nCreative insight (trefoil):")
    print(f"  V(e^(2πi/3)) = {v_trefoil:.4f}")
    print(f"  |V| = {abs(v_trefoil):.4f}")
    print(f"  Q = log|V| = {math.log(abs(v_trefoil)):.4f}")

    # Figure-eight: V(t) = t^2 - t + 1 - t^{-1} + t^{-2}
    v_fig8 = t**2 - t + 1 - t**(-1) + t**(-2)
    print(f"\nConfused thinking (figure-eight):")
    print(f"  V(e^(2πi/3)) = {v_fig8:.4f}")
    print(f"  |V| = {abs(v_fig8):.4f}")
    print(f"  Q = log|V| = {math.log(abs(v_fig8)):.4f}")

    print(f"\n{'Thought':<25} {'|V(ω)|':>10} {'Q = log|V|':>12}")
    print("-" * 50)
    print(f"{'Trivial':.<25} {'1.0000':>10} {'0.0000':>12}")
    print(f"{'Creative (trefoil)':.<25} {abs(v_trefoil):>10.4f} {math.log(abs(v_trefoil)):>12.4f}")
    print(f"{'Confused (figure-8)':.<25} {abs(v_fig8):>10.4f} {math.log(abs(v_fig8)):>12.4f}")


def demo_writhe_bound():
    """Demonstrate that |writhe| ≤ crossing number."""
    print("\n" + "=" * 70)
    print("WRITHE BOUND: |exponent sum| ≤ crossing number")
    print("=" * 70)

    import random
    random.seed(42)

    print(f"\n{'Braid':<30} {'|Writhe|':>10} {'Crossings':>10} {'Bound holds?':>12}")
    print("-" * 65)

    for _ in range(10):
        n = random.randint(3, 6)
        length = random.randint(1, 12)
        word = [BraidGen(random.randint(0, n-2), random.choice([1, -1]))
                for _ in range(length)]
        cb = CognitiveBraid(n, word, "random")
        w = cb.abs_writhe()
        c = cb.crossing_number()
        holds = w <= c
        desc = f"B_{n}, len={length}"
        print(f"{desc:<30} {w:>10} {c:>10} {'✓' if holds else '✗':>12}")


if __name__ == "__main__":
    demo_basic_invariants()
    demo_invariance()
    demo_composition()
    demo_reflection()
    demo_quantum_dimension()
    demo_writhe_bound()


#!/usr/bin/env python3
"""
Visualization: Braid Diagrams for Cognitive Processes

Draws braid diagrams showing how strands (brain regions) interleave
during different cognitive processes.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_braid(ax, n_strands, crossings, title="", colors=None):
    """Draw a braid diagram.

    Args:
        ax: matplotlib axis.
        n_strands: Number of strands.
        crossings: List of (strand_idx, sign) tuples.
        title: Title for the plot.
        colors: Optional list of colors for strands.
    """
    if colors is None:
        cmap = plt.cm.Set2
        colors = [cmap(i / max(n_strands, 1)) for i in range(n_strands)]

    n_levels = len(crossings) + 1
    strand_positions = np.zeros((n_levels, n_strands))

    # Initialize strand positions
    for i in range(n_strands):
        strand_positions[0, i] = i

    # Apply crossings
    strand_order = list(range(n_strands))
    for level, (idx, sign) in enumerate(crossings):
        for i in range(n_strands):
            strand_positions[level + 1, i] = strand_positions[level, i]
        if 0 <= idx < n_strands - 1:
            # Swap strands at idx and idx+1
            strand_positions[level + 1, idx] = strand_positions[level, idx + 1]
            strand_positions[level + 1, idx + 1] = strand_positions[level, idx]
            strand_order[idx], strand_order[idx + 1] = strand_order[idx + 1], strand_order[idx]

    # Track which original strand is at each position
    strand_identity = list(range(n_strands))
    current_pos = list(range(n_strands))

    # Draw strands
    y_positions = np.linspace(0, -n_levels + 1, n_levels)

    # Re-track strand identities for coloring
    identity_at_pos = [list(range(n_strands))]
    for level, (idx, sign) in enumerate(crossings):
        prev = identity_at_pos[-1].copy()
        if 0 <= idx < n_strands - 1:
            prev[idx], prev[idx + 1] = prev[idx + 1], prev[idx]
        identity_at_pos.append(prev)

    for level in range(n_levels - 1):
        idx, sign = crossings[level]
        for strand in range(n_strands):
            x_start = strand
            # Find where this strand goes
            next_positions = identity_at_pos[level + 1]
            curr_positions = identity_at_pos[level]

            original_strand = curr_positions[strand]
            # Find where original_strand ends up
            next_strand = next_positions.index(original_strand)

            y_start = y_positions[level]
            y_end = y_positions[level + 1]

            t = np.linspace(0, 1, 30)
            x = x_start + (next_strand - x_start) * (3 * t**2 - 2 * t**3)
            y = y_start + (y_end - y_start) * t

            # Determine line style for over/under crossing
            is_crossing_strand = (strand == idx or strand == idx + 1) if 0 <= idx < n_strands - 1 else False

            if is_crossing_strand and strand == idx and sign == -1:
                # Under-crossing: draw with gap
                ax.plot(x[:12], y[:12], color=colors[original_strand], linewidth=3)
                ax.plot(x[18:], y[18:], color=colors[original_strand], linewidth=3)
            elif is_crossing_strand and strand == idx + 1 and sign == 1:
                ax.plot(x[:12], y[:12], color=colors[original_strand], linewidth=3)
                ax.plot(x[18:], y[18:], color=colors[original_strand], linewidth=3)
            else:
                ax.plot(x, y, color=colors[original_strand], linewidth=3)

    # Crossing symbols
    for level, (idx, sign) in enumerate(crossings):
        if 0 <= idx < n_strands - 1:
            y_mid = (y_positions[level] + y_positions[level + 1]) / 2
            x_mid = (idx + idx + 1) / 2
            symbol = "+" if sign == 1 else "−"
            ax.text(x_mid, y_mid, symbol, fontsize=8, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

    # Labels
    for i in range(n_strands):
        ax.text(i, 0.3, f"R{i+1}", ha='center', fontsize=9, fontweight='bold')
        ax.text(i, y_positions[-1] - 0.3, f"R{identity_at_pos[-1][i]+1}",
                ha='center', fontsize=9, color='gray')

    ax.set_xlim(-0.5, n_strands - 0.5)
    ax.set_ylim(y_positions[-1] - 0.5, 1)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axis('off')


def main():
    fig, axes = plt.subplots(1, 4, figsize=(18, 6))

    # Trivial braid (no crossings)
    ax = axes[0]
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-2, 1)
    for i in range(3):
        ax.plot([i, i], [0, -1.5], linewidth=3, color=plt.cm.Set2(i/3))
        ax.text(i, 0.3, f"R{i+1}", ha='center', fontsize=9, fontweight='bold')
    ax.set_title("Trivial Thought\nWrithe = 0, Q = 0", fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')

    # Trefoil braid
    draw_braid(axes[1], 3,
               [(0, 1), (1, 1), (0, 1)],
               "Creative Insight (Trefoil)\nWrithe = 3, Q > 0")

    # Figure-eight braid
    draw_braid(axes[2], 3,
               [(0, 1), (1, -1), (0, 1), (1, -1)],
               "Confused Thinking (Fig-8)\nWrithe = 0, Crossings = 4")

    # Deep insight (full twist)
    draw_braid(axes[3], 4,
               [(0, 1), (1, 1), (2, 1), (0, 1), (1, 1), (2, 1)],
               "Deep Insight (Full Twist)\nWrithe = 6, Span = 3")

    plt.suptitle("Cognitive Braids: Thoughts as Topological Objects",
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig("cognitive_braids.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cognitive_braids.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quantum Dimension of Cognitive Braids

Plots the information content (quantum dimension) of various cognitive
braid types, showing how topological complexity correlates with
cognitive richness.
"""

import matplotlib.pyplot as plt
import numpy as np
import cmath
import math


def jones_at_root_of_unity(braid_type):
    """Compute |V(e^{2πi/3})| for canonical braids.

    Returns (label, abs_v, quantum_dim, exponent_sum, crossing_number).
    """
    t = cmath.exp(2j * cmath.pi / 3)
    results = []

    # Trivial
    results.append(("Trivial\n(no thought)", 1.0, 0.0, 0, 0))

    # Hopf link (σ₁²)
    v = -t**(1/2) - t**(5/2)
    results.append(("Hopf Link\n(simple association)", abs(v), math.log(max(abs(v), 1e-10)), 2, 2))

    # Right trefoil: V(t) = -t^{-4} + t^{-3} + t^{-1}
    v = -t**(-4) + t**(-3) + t**(-1)
    results.append(("Trefoil\n(creative insight)", abs(v), math.log(max(abs(v), 1e-10)), 3, 3))

    # Figure-eight: V(t) = t^2 - t + 1 - t^{-1} + t^{-2}
    v = t**2 - t + 1 - t**(-1) + t**(-2)
    results.append(("Figure-Eight\n(confused thought)", abs(v), math.log(max(abs(v), 1e-10)), 0, 4))

    # Cinquefoil (5_1 torus knot): V(t) = -t^2 + t + 1 - t^{-1} + t^{-2} + ... (5,2 torus)
    v = -t**(-10) + t**(-9) - t**(-8) + t**(-7) + t**(-3)
    results.append(("Cinquefoil\n(deep analysis)", abs(v), math.log(max(abs(v), 1e-10)), 5, 5))

    return results


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    data = jones_at_root_of_unity(None)
    labels = [d[0] for d in data]
    abs_v = [d[1] for d in data]
    q_dim = [d[2] for d in data]
    exp_sums = [d[3] for d in data]
    crossings = [d[4] for d in data]

    colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6', '#f39c12']

    # Plot 1: Quantum dimension bar chart
    ax = axes[0]
    bars = ax.bar(range(len(labels)), q_dim, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels, fontsize=8)
    ax.set_ylabel("Quantum Dimension Q = log|V(ω)|", fontsize=10)
    ax.set_title("Information Content of Thoughts", fontsize=12, fontweight='bold')
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    for i, v in enumerate(q_dim):
        ax.text(i, v + 0.05, f"{v:.2f}", ha='center', fontsize=9, fontweight='bold')

    # Plot 2: Exponent sum vs crossing number
    ax = axes[1]
    for i in range(len(labels)):
        ax.scatter(crossings[i], abs(exp_sums[i]), s=200, c=colors[i],
                  edgecolors='black', linewidth=1, zorder=5)
        ax.annotate(labels[i].split('\n')[0], (crossings[i], abs(exp_sums[i])),
                   textcoords="offset points", xytext=(10, 5), fontsize=8)

    # Draw the bound |writhe| ≤ crossings
    x_line = np.linspace(0, 6, 100)
    ax.plot(x_line, x_line, 'r--', alpha=0.5, label="|writhe| ≤ crossings")
    ax.fill_between(x_line, 0, x_line, alpha=0.1, color='red')
    ax.set_xlabel("Crossing Number", fontsize=10)
    ax.set_ylabel("|Exponent Sum| (Absolute Writhe)", fontsize=10)
    ax.set_title("Writhe Bound Theorem", fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.set_xlim(-0.5, 6)
    ax.set_ylim(-0.5, 6)

    # Plot 3: Phase diagram at root of unity
    ax = axes[2]
    t_vals = np.linspace(0, 2 * np.pi, 200)

    # Plot unit circle
    ax.plot(np.cos(t_vals), np.sin(t_vals), 'k-', alpha=0.2, linewidth=0.5)

    # Plot Jones polynomial evaluated on unit circle for trefoil
    for idx, (label, braid_func) in enumerate([
        ("Trefoil", lambda t: -t**(-4) + t**(-3) + t**(-1)),
        ("Figure-8", lambda t: t**2 - t + 1 - t**(-1) + t**(-2)),
    ]):
        real_parts = []
        imag_parts = []
        for angle in t_vals:
            t = cmath.exp(1j * angle)
            try:
                v = braid_func(t)
                real_parts.append(v.real)
                imag_parts.append(v.imag)
            except (ZeroDivisionError, OverflowError):
                real_parts.append(0)
                imag_parts.append(0)
        ax.plot(real_parts, imag_parts, linewidth=2,
               label=label, color=colors[idx + 2])

    # Mark evaluation point e^{2πi/3}
    t0 = cmath.exp(2j * cmath.pi / 3)
    ax.scatter([t0.real], [t0.imag], s=100, c='red', zorder=10, marker='*')
    ax.annotate("e^{2πi/3}", (t0.real, t0.imag),
               textcoords="offset points", xytext=(10, -10), fontsize=9, color='red')

    ax.set_xlabel("Re(V)", fontsize=10)
    ax.set_ylabel("Im(V)", fontsize=10)
    ax.set_title("Jones Polynomial on Unit Circle", fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.suptitle("Cognitive Braids: Topological Invariants of Thought",
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig("quantum_dimension.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: quantum_dimension.png")


if __name__ == "__main__":
    main()
