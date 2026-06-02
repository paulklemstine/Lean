"""
Visualization: The Wadge Hierarchy Structure
=============================================

Visualizes the Wadge hierarchy for simple sets in Baire space,
showing reducibility relationships as a Hasse diagram.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_wadge_hierarchy():
    """Draw the Wadge hierarchy for low Borel complexity classes."""

    fig, ax = plt.subplots(1, 1, figsize=(12, 10))
    fig.suptitle("The Wadge Hierarchy: Complexity of Infinite Game Payoff Sets",
                 fontsize=15, fontweight='bold')

    # Nodes in the hierarchy (name, x, y, color, description)
    nodes = [
        ("∅", 0, 0, '#95a5a6', "Empty set\n(rank 0)"),
        ("univ", 0, 1, '#95a5a6', "Universal set\n(rank 0)"),
        ("Clopen₁", -2, 2, '#3498db', "Simple clopen\n(rank 1)"),
        ("Clopen₁ᶜ", 2, 2, '#3498db', "Complement clopen\n(rank 1)"),
        ("Open", -3, 3.5, '#2ecc71', "Open sets\n(Σ⁰₁)"),
        ("Closed", 3, 3.5, '#e74c3c', "Closed sets\n(Π⁰₁)"),
        ("Fσ", -2, 5, '#f39c12', "Countable union\nof closed (Σ⁰₂)"),
        ("Gδ", 2, 5, '#9b59b6', "Countable intersection\nof open (Π⁰₂)"),
        ("Borel", 0, 7, '#1abc9c', "All Borel sets\n(determined!)"),
    ]

    # Edges (from, to) representing ≤_W
    edges = [
        ("∅", "univ"),
        ("univ", "Clopen₁"),
        ("univ", "Clopen₁ᶜ"),
        ("Clopen₁", "Open"),
        ("Clopen₁ᶜ", "Open"),
        ("Clopen₁", "Closed"),
        ("Clopen₁ᶜ", "Closed"),
        ("Open", "Fσ"),
        ("Closed", "Fσ"),
        ("Open", "Gδ"),
        ("Closed", "Gδ"),
        ("Fσ", "Borel"),
        ("Gδ", "Borel"),
    ]

    # Position lookup
    pos = {n[0]: (n[1], n[2]) for n in nodes}
    colors = {n[0]: n[3] for n in nodes}
    labels = {n[0]: n[4] for n in nodes}

    # Draw edges
    for (a, b) in edges:
        x1, y1 = pos[a]
        x2, y2 = pos[b]
        ax.annotate("", xy=(x2, y2 - 0.3), xytext=(x1, y1 + 0.3),
                     arrowprops=dict(arrowstyle='->', color='gray',
                                     lw=1.5, alpha=0.6))

    # Draw nodes
    for name, x, y, color, desc in nodes:
        circle = plt.Circle((x, y), 0.4, facecolor=color, edgecolor='black',
                            linewidth=2, zorder=5, alpha=0.9)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white', zorder=6)
        ax.text(x + 0.7, y, desc, ha='left', va='center', fontsize=7,
                color='#2c3e50')

    # Annotations
    ax.annotate("Gale-Stewart\nDeterminacy", xy=(-3, 3.0), fontsize=9,
                color='#27ae60', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#eafaf1'))

    ax.annotate("Martin's Theorem:\nAll Borel games\nare determined", xy=(-1.5, 7),
                fontsize=9, color='#16a085', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#e8f8f5'))

    ax.annotate("Complement\nDuality", xy=(3.5, 2), fontsize=8,
                color='#2980b9', fontstyle='italic')

    # Key theorems box
    theorems = [
        "Key Theorems Proved:",
        "• Wadge reflexivity: A ≤_W A",
        "• Wadge transitivity: A ≤_W B ≤_W C ⟹ A ≤_W C",
        "• Rank complement: rank(G) = rank(Gᶜ)",
        "• Strategy exclusivity: ¬(∃σ winning-I ∧ ∃τ winning-II)",
    ]
    textbox = '\n'.join(theorems)
    ax.text(-4.5, 0.5, textbox, fontsize=8, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.set_xlim(-5.5, 5.5)
    ax.set_ylim(-1, 8.5)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('viz_wadge_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_wadge_hierarchy.png")


if __name__ == "__main__":
    draw_wadge_hierarchy()
