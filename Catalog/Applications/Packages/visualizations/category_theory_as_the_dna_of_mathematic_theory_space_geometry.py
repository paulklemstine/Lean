#!/usr/bin/env python3
"""
Visualization: Theory Space Geometry
=====================================

Visualizes the metric space of mathematical theories,
showing mutation distances, Morita equivalence classes,
and evolutionary paths.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def create_theory_space_viz():
    """Create a visualization of theory space with mutation distances."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # --- Panel 1: Theory-Model Duality ---
    ax = axes[0]
    ax.set_title("Theory-Model Galois Connection", fontsize=13, fontweight='bold')

    # Draw theories on the left, models on the right
    theories = ["T₁: {pos}", "T₂: {even}", "T₃: {pos, even}", "T₄: {∅}"]
    models = ["{1..20}", "{0,2,4..}", "{2,4,6..}", "{0..20}"]
    model_sizes = [20, 11, 10, 21]

    for i, (theory, model, size) in enumerate(zip(theories, models, model_sizes)):
        y = 3 - i
        # Theory box
        ax.add_patch(plt.Rectangle((0.1, y - 0.15), 1.5, 0.3, fill=True,
                                    facecolor='lightblue', edgecolor='navy', linewidth=1.5))
        ax.text(0.85, y, theory, ha='center', va='center', fontsize=9, fontweight='bold')

        # Model box
        ax.add_patch(plt.Rectangle((3.4, y - 0.15), 1.5, 0.3, fill=True,
                                    facecolor='lightyellow', edgecolor='darkgoldenrod', linewidth=1.5))
        ax.text(4.15, y, f"|M|={size}", ha='center', va='center', fontsize=9)

        # Arrow
        ax.annotate('', xy=(3.35, y), xytext=(1.65, y),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    # Label the directions
    ax.text(2.5, 3.5, "models()", ha='center', fontsize=10, color='gray', style='italic')
    ax.text(2.5, -0.2, "More axioms → Fewer models", ha='center', fontsize=9, color='red')

    ax.set_xlim(-0.2, 5.2)
    ax.set_ylim(-0.6, 4.2)
    ax.axis('off')

    # --- Panel 2: Mutation Distance Graph ---
    ax = axes[1]
    ax.set_title("Mutation Distance Graph", fontsize=13, fontweight='bold')

    # Place theories at vertices of a graph
    positions = {
        "∅": (0.5, 2.5),
        "{pos}": (2.5, 3.5),
        "{even}": (2.5, 1.5),
        "{pos,even}": (4.5, 2.5),
        "{prime}": (0.5, 0.5),
    }

    # Draw edges with distances
    edges = [
        ("∅", "{pos}", 1),
        ("∅", "{even}", 1),
        ("∅", "{prime}", 1),
        ("{pos}", "{pos,even}", 1),
        ("{even}", "{pos,even}", 1),
        ("∅", "{pos,even}", 2),
        ("{pos}", "{even}", 2),
        ("{prime}", "{pos}", 2),
    ]

    for t1, t2, d in edges:
        x1, y1 = positions[t1]
        x2, y2 = positions[t2]
        alpha = 0.8 if d == 1 else 0.3
        lw = 2 if d == 1 else 1
        ax.plot([x1, x2], [y1, y2], 'k-', alpha=alpha, linewidth=lw)
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(mx + 0.1, my + 0.1, str(d), fontsize=10, color='red',
                fontweight='bold', ha='center')

    # Draw nodes
    for name, (x, y) in positions.items():
        ax.plot(x, y, 'o', markersize=20, color='steelblue', zorder=5)
        ax.text(x, y - 0.35, name, ha='center', fontsize=8, fontweight='bold')

    ax.text(2.5, 4.2, "d(A,C) ≤ d(A,B) + d(B,C)", ha='center', fontsize=10,
            color='darkred', style='italic')

    ax.set_xlim(-0.5, 5.5)
    ax.set_ylim(-0.2, 4.5)
    ax.axis('off')

    # --- Panel 3: Evolutionary Path ---
    ax = axes[2]
    ax.set_title("Evolutionary Path (Mutation Sequence)", fontsize=13, fontweight='bold')

    # Show a path through theory space
    path_steps = [
        ("∅", 21, "Start"),
        ("+pos", 20, "Add 'positive'"),
        ("+even", 10, "Add 'even'"),
        ("+small", 4, "Add 'x < 10'"),
        ("-even", 9, "Remove 'even'"),
    ]

    x_pos = np.linspace(0.5, 4.5, len(path_steps))
    y_vals = [s[1] for s in path_steps]

    # Plot model count evolution
    ax.fill_between(x_pos, 0, y_vals, alpha=0.2, color='steelblue')
    ax.plot(x_pos, y_vals, 'o-', color='steelblue', linewidth=2, markersize=10)

    for i, (label, count, desc) in enumerate(path_steps):
        ax.text(x_pos[i], count + 1, str(count), ha='center', fontsize=11,
                fontweight='bold', color='navy')
        ax.text(x_pos[i], -2.5, label, ha='center', fontsize=9, rotation=0)
        if i > 0:
            ax.text((x_pos[i] + x_pos[i-1])/2, max(y_vals[i], y_vals[i-1]) + 2.5,
                    desc, ha='center', fontsize=7, color='gray', rotation=15)

    ax.set_ylabel("|Models|", fontsize=11)
    ax.set_xlabel("Mutation Step", fontsize=11)
    ax.set_ylim(-4, 26)
    ax.set_xlim(0, 5)

    plt.tight_layout()
    plt.savefig("theory_space_geometry.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: theory_space_geometry.png")


def create_closure_viz():
    """Visualize the idempotent closure operator."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_title("Galois Closure Operator: Idempotence", fontsize=14, fontweight='bold')

    # Show sets and their closures
    universe = set(range(21))

    examples = [
        ({2, 4, 6}, "S₁ = {2,4,6}"),
        ({1, 2, 3}, "S₂ = {1,2,3}"),
        ({5, 10, 15}, "S₃ = {5,10,15}"),
    ]

    y_positions = [4, 2.5, 1]

    for (S, label), y in zip(examples, y_positions):
        # Compute closure
        excluded = universe - S
        closed = S.copy()  # In our simple framework, closure = S for exact theories

        # Draw original set
        ax.add_patch(plt.Rectangle((0.5, y - 0.3), 2.5, 0.6, fill=True,
                                    facecolor='lightcoral', edgecolor='darkred',
                                    alpha=0.7, linewidth=1.5))
        ax.text(1.75, y, label, ha='center', va='center', fontsize=10, fontweight='bold')

        # Arrow
        ax.annotate('', xy=(3.8, y), xytext=(3.1, y),
                    arrowprops=dict(arrowstyle='->', color='darkgreen', lw=2))
        ax.text(3.45, y + 0.3, "Mod∘Th", ha='center', fontsize=8, color='darkgreen')

        # Draw closure
        ax.add_patch(plt.Rectangle((4, y - 0.3), 2.5, 0.6, fill=True,
                                    facecolor='lightgreen', edgecolor='darkgreen',
                                    alpha=0.7, linewidth=1.5))
        ax.text(5.25, y, f"cl(S) = {sorted(S)}", ha='center', va='center', fontsize=9)

        # Arrow for double closure
        ax.annotate('', xy=(7.3, y), xytext=(6.6, y),
                    arrowprops=dict(arrowstyle='->', color='purple', lw=2))
        ax.text(6.95, y + 0.3, "Mod∘Th", ha='center', fontsize=8, color='purple')

        # Draw double closure (should be same)
        ax.add_patch(plt.Rectangle((7.5, y - 0.3), 2.5, 0.6, fill=True,
                                    facecolor='plum', edgecolor='purple',
                                    alpha=0.7, linewidth=1.5))
        ax.text(8.75, y, "cl²(S) = cl(S) ✓", ha='center', va='center',
                fontsize=9, color='purple')

    ax.text(5.25, 5, "Closure is IDEMPOTENT: cl(cl(S)) = cl(S)",
            ha='center', fontsize=13, fontweight='bold', color='darkblue',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='darkblue'))

    ax.set_xlim(0, 10.5)
    ax.set_ylim(0.2, 5.5)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("closure_idempotence.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: closure_idempotence.png")


if __name__ == "__main__":
    create_theory_space_viz()
    create_closure_viz()
    print("All visualizations generated!")
