#!/usr/bin/env python3
"""
Visualization: Provability Depth Hierarchy

Shows the strict stratification of types by provability depth,
the axiom hierarchy, and the relationship between MLTT and ReflTT.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_depth_hierarchy():
    """Plot the provability depth hierarchy with example types."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 8))

    # --- Panel 1: Depth Strata ---
    ax = axes[0]
    ax.set_title("Provability Depth Strata", fontsize=14, fontweight='bold')

    strata = {
        0: ["P", "⊤", "⊥", "P→Q", "P×Q", "P+Q"],
        1: ["□P", "□P→⊥", "□(P→Q)→□P→□Q"],
        2: ["□□P", "□P→□□P", "□(□P→P)→□P"],
        3: ["□□□P", "□(□□P→□P)"],
        4: ["□⁴P"],
    }

    colors = ['#4CAF50', '#2196F3', '#FF9800', '#F44336', '#9C27B0']

    for depth, types in strata.items():
        y = 4 - depth
        ax.axhspan(y - 0.4, y + 0.4, alpha=0.15, color=colors[depth])
        ax.text(-0.5, y, f"Depth {depth}", fontsize=12, fontweight='bold',
                ha='right', va='center', color=colors[depth])
        for i, t in enumerate(types):
            x = 0.5 + i * 2.2
            ax.text(x, y, t, fontsize=9, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor=colors[depth],
                              alpha=0.3, edgecolor=colors[depth]))

    ax.set_xlim(-2, 14)
    ax.set_ylim(-1, 5)
    ax.set_axis_off()

    # Separation line
    ax.axhline(y=3.6, color='red', linewidth=2, linestyle='--')
    ax.text(6, 3.8, "← MLTT Fragment (depth 0) →", fontsize=10,
            ha='center', color='red', fontstyle='italic')
    ax.text(6, 3.2, "↓ Reflective Extension ↓", fontsize=10,
            ha='center', color='blue', fontstyle='italic')

    # --- Panel 2: Axiom Hierarchy ---
    ax = axes[1]
    ax.set_title("Modal Axiom Depth Hierarchy", fontsize=14, fontweight='bold')

    axiom_data = [
        ("K: □(A→B)→□A→□B", 1, '#2196F3'),
        ("T: □A→A", 1, '#2196F3'),
        ("Gödel: □P→⊥", 1, '#2196F3'),
        ("4: □A→□□A", 2, '#FF9800'),
        ("Löb: □(□P→P)→□P", 2, '#FF9800'),
        ("Grz: □(□(A→□A)→A)→A", 2, '#FF9800'),
        ("PnPP: □P×(□□P→⊥)", 2, '#FF9800'),
    ]

    y_positions = list(range(len(axiom_data)))
    for i, (name, depth, color) in enumerate(axiom_data):
        ax.barh(i, depth, color=color, alpha=0.7, edgecolor='black', height=0.6)
        ax.text(depth + 0.1, i, name, fontsize=9, va='center')

    ax.set_xlabel("Provability Depth", fontsize=12)
    ax.set_yticks([])
    ax.set_xlim(0, 5)

    # Arrow showing "4 > K"
    ax.annotate("4 > K\n(strict)", xy=(2, 3), xytext=(3.5, 1.5),
                fontsize=10, fontweight='bold', color='red',
                arrowprops=dict(arrowstyle='->', color='red', lw=2))

    # --- Panel 3: Translation Correspondence ---
    ax = axes[2]
    ax.set_title("ReflTy ↔ Modal μ-Calculus", fontsize=14, fontweight='bold')

    left_items = ["base(n)", "⊤", "⊥", "A → B", "A × B", "A + B", "□A", "μA"]
    right_items = ["var(n)", "⊤", "⊥", "φ → ψ", "φ ∧ ψ", "φ ∨ ψ", "□φ", "μφ"]

    for i, (l, r) in enumerate(zip(left_items, right_items)):
        y = 7 - i
        ax.text(1, y, l, fontsize=11, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue',
                          edgecolor='steelblue'))
        ax.text(5, y, r, fontsize=11, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                          edgecolor='goldenrod'))
        ax.annotate("", xy=(3.8, y), xytext=(2.2, y),
                    arrowprops=dict(arrowstyle='<->', color='green', lw=1.5))

    ax.text(1, 8.3, "ReflTy", fontsize=13, fontweight='bold', ha='center', color='steelblue')
    ax.text(5, 8.3, "Modal μ-Calculus", fontsize=13, fontweight='bold', ha='center', color='goldenrod')
    ax.text(3, 8.3, "≅", fontsize=16, fontweight='bold', ha='center', color='green')

    ax.set_xlim(-0.5, 6.5)
    ax.set_ylim(-0.5, 9)
    ax.set_axis_off()

    plt.tight_layout()
    plt.savefig("depth_hierarchy.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: depth_hierarchy.png")


def plot_kripke_example():
    """Plot an example Kripke model with evaluation."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_title("Kripke Model: Box Monotonicity", fontsize=14, fontweight='bold')

    # Draw worlds
    world_positions = {0: (1, 3), 1: (4, 3), 2: (7, 3)}
    world_labels = {
        0: "w₀\nP₀=T, P₁=F\n□P₁=T",
        1: "w₁\nP₀=T, P₁=T\n□P₁=T",
        2: "w₂\nP₀=F, P₁=T\n□P₁=T (vacuous)",
    }

    for w, (x, y) in world_positions.items():
        circle = plt.Circle((x, y), 0.8, fill=True, facecolor='lightcyan',
                             edgecolor='navy', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, world_labels[w], fontsize=8, ha='center', va='center')

    # Draw accessibility arrows
    arrows = [(0, 1), (1, 2), (0, 2)]
    for w, v in arrows:
        x1, y1 = world_positions[w]
        x2, y2 = world_positions[v]
        dx, dy = x2 - x1, y2 - y1
        norm = np.sqrt(dx**2 + dy**2)
        dx, dy = dx/norm, dy/norm
        ax.annotate("", xy=(x2 - dx*0.85, y2 - dy*0.85),
                    xytext=(x1 + dx*0.85, y1 + dy*0.85),
                    arrowprops=dict(arrowstyle='->', color='red', lw=2))

    # Labels
    ax.text(2.5, 4.2, "R", fontsize=12, color='red', fontweight='bold')
    ax.text(5.5, 4.2, "R", fontsize=12, color='red', fontweight='bold')
    ax.text(4, 1.5, "R (transitivity)", fontsize=10, color='red', fontstyle='italic')

    # Theorem statement
    ax.text(4, 0.5,
            "Theorem: If R is transitive and □A holds at w,\nthen □A holds at every R-accessible world from w.",
            fontsize=11, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                      edgecolor='orange'))

    ax.set_xlim(-0.5, 8.5)
    ax.set_ylim(-0.5, 5.5)
    ax.set_aspect('equal')
    ax.set_axis_off()

    plt.tight_layout()
    plt.savefig("kripke_model.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: kripke_model.png")


if __name__ == "__main__":
    plot_depth_hierarchy()
    plot_kripke_example()
    print("All visualizations generated.")
