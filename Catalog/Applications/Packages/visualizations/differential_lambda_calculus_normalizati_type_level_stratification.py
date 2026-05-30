#!/usr/bin/env python3
"""
Visualization: Type-Level Stratification for Differential Lambda-Calculus

This script visualizes how the type-level measure decreases during
normalization of typed differential lambda-calculus terms. Each
beta-reduction step decreases the type level, while differential
steps operate at level 0 — forming a well-founded lexicographic order.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def type_level_tree():
    """Create a visualization of the type hierarchy and level measure."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Type hierarchy with levels
    ax = axes[0]
    ax.set_xlim(-1, 11)
    ax.set_ylim(-0.5, 4.5)
    ax.set_title("Type Hierarchy and Level Measure", fontsize=14, fontweight='bold')

    types = [
        (5, 0, "ι", 0, "#4CAF50"),
        (2, 1, "ι → ι", 1, "#2196F3"),
        (8, 1, "ι ⊸ ι", 1, "#03A9F4"),
        (1, 2, "(ι→ι) → ι", 2, "#FF9800"),
        (5, 2, "ι → (ι→ι)", 2, "#FF9800"),
        (9, 2, "ι ⊸ (ι→ι)", 2, "#FFC107"),
        (3, 3, "((ι→ι)→ι) → ι", 3, "#F44336"),
        (7, 3, "ι → ((ι→ι)→ι)", 3, "#F44336"),
    ]

    for x, y, label, level, color in types:
        circle = plt.Circle((x, y), 0.4, color=color, alpha=0.8)
        ax.add_patch(circle)
        ax.text(x, y, f"L{level}", ha='center', va='center', fontsize=10,
                fontweight='bold', color='white')
        ax.text(x, y - 0.6, label, ha='center', va='top', fontsize=8)

    # Draw arrows showing level relationships
    arrows = [(5, 0, 2, 1), (5, 0, 8, 1), (2, 1, 1, 2), (2, 1, 5, 2),
              (8, 1, 9, 2), (1, 2, 3, 3), (5, 2, 7, 3)]
    for x1, y1, x2, y2 in arrows:
        ax.annotate("", xy=(x2, y2 - 0.4), xytext=(x1, y1 + 0.4),
                     arrowprops=dict(arrowstyle="->", color="gray", lw=1.5))

    ax.set_ylabel("Type Level", fontsize=12)
    for i in range(4):
        ax.axhline(y=i, color='gray', linestyle='--', alpha=0.3)
        ax.text(-0.5, i, f"Level {i}", fontsize=9, va='center', color='gray')
    ax.set_xticks([])
    ax.set_yticks([])

    # Right panel: Measure decrease during reduction
    ax2 = axes[1]
    ax2.set_title("Stratified Measure Decrease During Reduction", fontsize=14,
                  fontweight='bold')

    # Simulated reduction trace
    steps = list(range(12))
    type_levels = [3, 3, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0]
    term_sizes =  [15, 12, 18, 14, 10, 16, 12, 8, 5, 8, 4, 3]

    colors_map = {0: '#4CAF50', 1: '#2196F3', 2: '#FF9800', 3: '#F44336'}
    colors_list = [colors_map[l] for l in type_levels]

    # Plot type level (bars)
    bars = ax2.bar(steps, type_levels, alpha=0.3, color=colors_list,
                   label='Type level', width=0.8)

    # Plot term size as line
    ax2_twin = ax2.twinx()
    ax2_twin.plot(steps, term_sizes, 'ko-', markersize=6, linewidth=2,
                  label='Term size')
    ax2_twin.set_ylabel("Term Size", fontsize=11)

    # Add annotations for key events
    ax2.annotate("β-step\n(level drops)", xy=(2, 2), xytext=(3.5, 3.3),
                arrowprops=dict(arrowstyle="->", color="red", lw=2),
                fontsize=9, ha='center', color='red', fontweight='bold')
    ax2.annotate("D-step\n(size drops)", xy=(6, 1), xytext=(7.5, 2.2),
                arrowprops=dict(arrowstyle="->", color="blue", lw=2),
                fontsize=9, ha='center', color='blue', fontweight='bold')

    ax2.set_xlabel("Reduction Step", fontsize=12)
    ax2.set_ylabel("Type Level", fontsize=11)
    ax2.legend(loc='upper right')
    ax2_twin.legend(loc='center right')
    ax2.set_xticks(steps)

    plt.tight_layout()
    plt.savefig("viz_type_stratification.png", dpi=150, bbox_inches='tight')
    print("Saved: viz_type_stratification.png")
    plt.close()


def leibniz_rule_visualization():
    """Visualize the Leibniz rule as a rewriting diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 5))
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-1, 4)
    ax.set_title("The Leibniz Rule: Syntax ↔ Semantics Bridge", fontsize=16,
                 fontweight='bold')

    # Syntactic side
    ax.text(2.5, 3.5, "SYNTACTIC (λ-calculus)", ha='center', fontsize=12,
            fontweight='bold', color='#1565C0')

    # D(λx.M)(N) box
    box1 = mpatches.FancyBboxPatch((0.5, 1.8), 4, 1.2, boxstyle="round,pad=0.1",
                                    facecolor='#BBDEFB', edgecolor='#1565C0', lw=2)
    ax.add_patch(box1)
    ax.text(2.5, 2.4, "D(λx.M)(N)", ha='center', va='center', fontsize=14,
            fontfamily='monospace', fontweight='bold')

    # Arrow down
    ax.annotate("", xy=(2.5, 0.7), xytext=(2.5, 1.8),
                arrowprops=dict(arrowstyle="-|>", color='#1565C0', lw=2.5))
    ax.text(3.3, 1.25, "Leibniz\nrule", fontsize=10, color='#1565C0',
            fontweight='bold', ha='left')

    # λx.D(M)(↑N) box
    box2 = mpatches.FancyBboxPatch((0.3, -0.5), 4.4, 1.2, boxstyle="round,pad=0.1",
                                    facecolor='#C8E6C9', edgecolor='#2E7D32', lw=2)
    ax.add_patch(box2)
    ax.text(2.5, 0.1, "λx.D(M)(↑N)", ha='center', va='center', fontsize=14,
            fontfamily='monospace', fontweight='bold')

    # Semantic side
    ax.text(8, 3.5, "SEMANTIC (ring derivation)", ha='center', fontsize=12,
            fontweight='bold', color='#C62828')

    # D(f·g) box
    box3 = mpatches.FancyBboxPatch((6, 1.8), 4, 1.2, boxstyle="round,pad=0.1",
                                    facecolor='#FFCDD2', edgecolor='#C62828', lw=2)
    ax.add_patch(box3)
    ax.text(8, 2.4, "D(f · g)", ha='center', va='center', fontsize=14,
            fontfamily='monospace', fontweight='bold')

    # Arrow down
    ax.annotate("", xy=(8, 0.7), xytext=(8, 1.8),
                arrowprops=dict(arrowstyle="-|>", color='#C62828', lw=2.5))
    ax.text(8.8, 1.25, "Product\nrule", fontsize=10, color='#C62828',
            fontweight='bold', ha='left')

    # D(f)·g + f·D(g) box
    box4 = mpatches.FancyBboxPatch((5.5, -0.5), 5, 1.2, boxstyle="round,pad=0.1",
                                    facecolor='#FFF9C4', edgecolor='#F57F17', lw=2)
    ax.add_patch(box4)
    ax.text(8, 0.1, "D(f)·g + f·D(g)", ha='center', va='center', fontsize=14,
            fontfamily='monospace', fontweight='bold')

    # Bridge arrow
    ax.annotate("", xy=(6, 2.4), xytext=(4.5, 2.4),
                arrowprops=dict(arrowstyle="<->", color='purple', lw=3,
                               connectionstyle="arc3,rad=0.2"))
    ax.text(5.25, 3.0, "≅", fontsize=20, ha='center', va='center', color='purple',
            fontweight='bold')

    ax.set_xticks([])
    ax.set_yticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    ax.spines['left'].set_visible(False)

    plt.tight_layout()
    plt.savefig("viz_leibniz_bridge.png", dpi=150, bbox_inches='tight')
    print("Saved: viz_leibniz_bridge.png")
    plt.close()


if __name__ == "__main__":
    type_level_tree()
    leibniz_rule_visualization()
    print("All visualizations generated.")
