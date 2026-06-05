#!/usr/bin/env python3
"""
Aleph-1 Surface: Numerical Demonstrations

Demonstrates the cardinal obstructions and Hilbert cube universality
established in Novelty/AlephOneSurface.lean.
"""

import math
from fractions import Fraction


def demo_cardinal_bound():
    """Demonstrate the cardinal triangulation bound.

    For finite cases, |V| bounds |X| under surjection.
    Shows that as dimension grows, the required vertex count grows exponentially.
    """
    print("=" * 60)
    print("Demo 1: Cardinal Triangulation Bound")
    print("=" * 60)
    print()
    print("For a simplicial complex triangulating [0,1]^d,")
    print("the minimum vertex count grows with dimension d:")
    print()
    print(f"{'Dim d':>8} | {'Min vertices':>14} | {'Min simplices':>14}")
    print("-" * 45)
    for d in range(1, 13):
        # Minimum vertices for a triangulation of [0,1]^d
        # Kuhn triangulation: d! simplices, (d+1) choose-like vertices
        min_vertices = 2 ** d  # hypercube vertices
        min_simplices = math.factorial(d)  # Kuhn triangulation
        print(f"{d:>8} | {min_vertices:>14,} | {min_simplices:>14,}")

    print()
    print("As d → ∞, both grow without bound.")
    print("At d = ℵ₁ (under CH), no finite count suffices.")
    print()


def demo_linear_embedding_obstruction():
    """Demonstrate the linear embedding obstruction.

    In ℝ^n, at most n vectors can be linearly independent.
    A module of rank ℵ₁ has uncountably many independent vectors.
    """
    print("=" * 60)
    print("Demo 2: Linear Embedding Obstruction")
    print("=" * 60)
    print()
    print("Maximum linearly independent vectors in ℝ^n:")
    print()
    print(f"{'Target dim n':>14} | {'Max indep. vectors':>20} | {'Can embed rank-k?':>20}")
    print("-" * 60)
    for n in [1, 2, 3, 10, 100, 1000]:
        for k_label, k in [("n", n), ("n+1", n + 1), ("2n", 2 * n), ("ℵ₀", float('inf'))]:
            can_embed = "Yes" if k <= n else "No"
            k_str = k_label if k == float('inf') else str(k)
            print(f"{n:>14} | {k_str:>20} | {can_embed:>20}")
        print("-" * 60)

    print()
    print("For rank ≥ ℵ₁ (> ℵ₀), no finite n works.")
    print("Every linear map to ℝ^n has non-trivial kernel.")
    print()


def demo_hilbert_cube_cardinality():
    """Demonstrate the Hilbert cube cardinality computation.

    |[0,1]^ℕ| = 𝔠 = |ℝ| = 2^ℵ₀

    We show this by the squeeze: |[0,1]| ≤ |[0,1]^ℕ| ≤ |ℝ^ℕ| = 𝔠.
    """
    print("=" * 60)
    print("Demo 3: Hilbert Cube Cardinality")
    print("=" * 60)
    print()
    print("Cardinality chain:")
    print()
    print("  |[0,1]| = 𝔠     (by Cantor-Bernstein with ℝ)")
    print("       ≤")
    print("  |[0,1]^ℕ|        (via constant-sequence embedding)")
    print("       ≤")
    print("  |ℝ^ℕ|            (via Subtype.val on each coordinate)")
    print("       =")
    print("  𝔠^ℵ₀             (cardinal exponentiation)")
    print("       =")
    print("  𝔠                (since 𝔠^ℵ₀ = (2^ℵ₀)^ℵ₀ = 2^(ℵ₀·ℵ₀) = 2^ℵ₀ = 𝔠)")
    print()
    print("Therefore |[0,1]^ℕ| = 𝔠.")
    print()
    print("Under CH (ℵ₁ = 𝔠): |[0,1]^ℕ| = ℵ₁.")
    print()

    # Finite approximation
    print("Finite approximation: |{0,1,...,k-1}^n| for increasing k, n:")
    print()
    print(f"{'k':>5} | {'n':>5} | {'|{0,...,k-1}^n|':>20}")
    print("-" * 40)
    for k in [2, 3, 10]:
        for n in [1, 2, 5, 10]:
            card = k ** n
            print(f"{k:>5} | {n:>5} | {card:>20,}")
    print()


def demo_dual_obstruction():
    """Demonstrate the dual obstruction theorem.

    Under CH, spaces with |X| = 𝔠 = ℵ₁ simultaneously:
    1. Admit no countable cover
    2. Have no finite-dim linear embedding (for high-rank modules)
    3. Fit cardinality-wise in the Hilbert cube
    """
    print("=" * 60)
    print("Demo 4: Dual Obstruction (Synthesis)")
    print("=" * 60)
    print()
    print("Under CH, for X with |X| = ℵ₁:")
    print()
    print("  Obstruction 1 (Combinatorial):")
    print("    No κ-bounded cover for κ < ℵ₁")
    print("    In particular, no finite or countable triangulation")
    print()
    print("  Obstruction 2 (Algebraic):")
    print("    For any ℝ-module M with rank(M) ≥ ℵ₁,")
    print("    no injective linear map M → ℝ^n exists")
    print()
    print("  Resolution (Hilbert Cube):")
    print("    |X| = ℵ₁ = |[0,1]^ℕ|")
    print("    X fits cardinality-wise in the Hilbert cube")
    print()
    print("The dimensional gap ℵ₀ < ℵ₁ is the single root cause")
    print("of both obstructions. The Hilbert cube bridges the gap")
    print("by providing a continuum-sized universal container.")
    print()


if __name__ == "__main__":
    demo_cardinal_bound()
    demo_linear_embedding_obstruction()
    demo_hilbert_cube_cardinality()
    demo_dual_obstruction()


#!/usr/bin/env python3
"""
Visualization: Cardinal Hierarchy of Dimensional Obstructions

Shows how the triangulation bound κ vs |X| creates a staircase of
obstructions at each cardinal level.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Left panel: Triangulation complexity vs dimension ---
    ax1 = axes[0]
    dims = np.arange(1, 16)
    vertices = 2 ** dims  # hypercube vertices
    simplices = np.array([np.math.factorial(d) for d in dims])

    ax1.semilogy(dims, vertices, 'o-', color='#2196F3', linewidth=2,
                 markersize=6, label='Min vertices (2^d)')
    ax1.semilogy(dims, simplices, 's-', color='#FF5722', linewidth=2,
                 markersize=6, label='Min simplices (d!)')

    ax1.fill_between(dims, 1, vertices, alpha=0.1, color='#2196F3')
    ax1.set_xlabel('Dimension d', fontsize=12)
    ax1.set_ylabel('Count (log scale)', fontsize=12)
    ax1.set_title('Triangulation Complexity vs Dimension', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Add annotation for the transfinite regime
    ax1.annotate('d → ℵ₁: no finite\ntriangulation exists',
                xy=(12, 1e10), fontsize=10, color='#9C27B0',
                fontweight='bold', ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#E1BEE7', alpha=0.8))

    # --- Right panel: Cardinal obstruction diagram ---
    ax2 = axes[1]
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.set_title('Cardinal Obstruction Map', fontsize=13, fontweight='bold')

    # Draw cardinal levels as horizontal bands
    levels = [
        (1.5, 'Finite', '#E8F5E9', '#4CAF50'),
        (4.0, 'ℵ₀ (Countable)', '#E3F2FD', '#2196F3'),
        (6.5, 'ℵ₁ = 𝔠 (under CH)', '#FFF3E0', '#FF9800'),
        (8.5, 'ℵ₂, ℵ₃, ...', '#FCE4EC', '#E91E63'),
    ]

    for y, label, bg_color, text_color in levels:
        rect = mpatches.FancyBboxPatch(
            (0.5, y - 0.6), 9, 1.0,
            boxstyle="round,pad=0.1",
            facecolor=bg_color, edgecolor=text_color, linewidth=1.5)
        ax2.add_patch(rect)
        ax2.text(5, y, label, ha='center', va='center',
                fontsize=11, fontweight='bold', color=text_color)

    # Draw obstruction arrows
    arrow_props = dict(arrowstyle='->', color='red', lw=2)

    # Finite → ℵ₀ obstruction
    ax2.annotate('', xy=(2, 2.4), xytext=(2, 3.0),
                arrowprops=dict(arrowstyle='-|>', color='red', lw=2))
    ax2.text(2.3, 2.7, '✗ no finite\ntriangulation', fontsize=8,
            color='red', va='center')

    # ℵ₀ → ℵ₁ obstruction
    ax2.annotate('', xy=(2, 4.9), xytext=(2, 5.5),
                arrowprops=dict(arrowstyle='-|>', color='red', lw=2))
    ax2.text(2.3, 5.2, '✗ no countable\ntriangulation', fontsize=8,
            color='red', va='center')

    # Hilbert cube arrow
    ax2.annotate('', xy=(7.5, 5.5), xytext=(7.5, 6.0),
                arrowprops=dict(arrowstyle='-|>', color='green', lw=2))
    ax2.text(7.8, 5.7, '✓ Hilbert cube\nembedding', fontsize=8,
            color='green', va='center')

    # Linear algebra arrow
    ax2.annotate('', xy=(5, 4.9), xytext=(5, 5.5),
                arrowprops=dict(arrowstyle='-|>', color='darkred', lw=2))
    ax2.text(5.3, 5.2, '✗ no linear\nembedding in ℝⁿ', fontsize=8,
            color='darkred', va='center')

    plt.tight_layout()
    plt.savefig('cardinal_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: cardinal_hierarchy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Hilbert Cube and the Embedding Landscape

Shows the cardinality squeeze argument and the position of
transfinite manifolds relative to finite and infinite containers.
"""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Left: Cardinality squeeze ---
    ax1 = axes[0]
    ax1.set_xlim(-0.5, 7.5)
    ax1.set_ylim(-0.5, 6)
    ax1.axis('off')
    ax1.set_title('Cardinality Squeeze: |[0,1]^ℕ| = 𝔠', fontsize=13, fontweight='bold')

    # Draw the chain
    items = [
        (1, 4.5, '|[0,1]|', '= 𝔠'),
        (1, 3.5, '', '≤'),
        (1, 2.5, '|[0,1]^ℕ|', '?'),
        (1, 1.5, '', '≤'),
        (1, 0.5, '|ℝ^ℕ| = 𝔠^{ℵ₀}', '= 𝔠'),
    ]

    for x, y, label, val in items:
        if label:
            ax1.text(x, y, label, fontsize=13, fontweight='bold',
                    ha='left', va='center', color='#1565C0')
            ax1.text(x + 3.5, y, val, fontsize=13, ha='left', va='center',
                    color='#4CAF50' if '=' in val else '#FF9800',
                    fontweight='bold')
        else:
            ax1.text(x + 1.5, y, val, fontsize=16, ha='center', va='center',
                    color='#757575')

    # Conclusion box
    from matplotlib.patches import FancyBboxPatch
    rect = FancyBboxPatch((0.3, -0.3), 6.5, 0.9,
                          boxstyle="round,pad=0.15",
                          facecolor='#E8F5E9', edgecolor='#4CAF50', linewidth=2)
    ax1.add_patch(rect)
    ax1.text(3.5, 0.1, '∴  |[0,1]^ℕ| = 𝔠  (by squeeze)',
            fontsize=13, fontweight='bold', ha='center', va='center',
            color='#2E7D32')

    # --- Right: Embedding landscape ---
    ax2 = axes[1]
    ax2.set_title('Embedding Landscape for ℵ₁-Surfaces', fontsize=13, fontweight='bold')

    # Create a visual showing which spaces can/cannot host the surface
    categories = ['ℝ¹', 'ℝ²', 'ℝ³', 'ℝ¹⁰', 'ℝ¹⁰⁰⁰', 'ℝ^ℕ\n(seq. space)', '[0,1]^ℕ\n(Hilbert cube)']
    can_host = [False, False, False, False, False, True, True]
    colors = ['#FFCDD2' if not h else '#C8E6C9' for h in can_host]
    edge_colors = ['#E53935' if not h else '#43A047' for h in can_host]
    symbols = ['✗' if not h else '✓' for h in can_host]

    bars = ax2.bar(range(len(categories)), [1]*len(categories),
                   color=colors, edgecolor=edge_colors, linewidth=2)

    ax2.set_xticks(range(len(categories)))
    ax2.set_xticklabels(categories, fontsize=9, rotation=0)
    ax2.set_yticks([])
    ax2.set_ylim(0, 1.5)

    for i, (sym, color) in enumerate(zip(symbols, edge_colors)):
        ax2.text(i, 0.5, sym, ha='center', va='center',
                fontsize=24, fontweight='bold', color=color)

    ax2.text(3, 1.3, 'Can an ℵ₁-surface embed here?',
            ha='center', fontsize=11, fontstyle='italic', color='#424242')

    # Dividing line
    ax2.axvline(x=4.5, color='#9E9E9E', linestyle='--', linewidth=1.5)
    ax2.text(2, 1.1, 'Finite-dimensional\n(OBSTRUCTED)', ha='center',
            fontsize=9, color='#E53935', fontweight='bold')
    ax2.text(5.5, 1.1, 'Infinite-dimensional\n(COMPATIBLE)', ha='center',
            fontsize=9, color='#43A047', fontweight='bold')

    plt.tight_layout()
    plt.savefig('embedding_landscape.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: embedding_landscape.png")


if __name__ == "__main__":
    main()
