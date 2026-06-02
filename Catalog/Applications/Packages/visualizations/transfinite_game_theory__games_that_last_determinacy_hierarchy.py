#!/usr/bin/env python3
"""
Visualization 2: The Determinacy Hierarchy
Shows the relationship between Borel complexity and axiom strength.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def main():
    fig, ax = plt.subplots(figsize=(14, 9))

    # Hierarchy levels
    levels = [
        {"name": "Clopen (Δ⁰₁)", "y": 0, "strength": 0, "color": "#81C784",
         "axiom": "ZF", "det_year": "1913 (Zermelo)"},
        {"name": "Open (Σ⁰₁)", "y": 1, "strength": 0, "color": "#66BB6A",
         "axiom": "ZF", "det_year": "1953 (Gale-Stewart)"},
        {"name": "Σ⁰₂", "y": 2, "strength": 1, "color": "#FFF176",
         "axiom": "ZFC", "det_year": "1975 (Martin)"},
        {"name": "Σ⁰₃", "y": 3, "strength": 2, "color": "#FFD54F",
         "axiom": "ZFC", "det_year": "1975 (Martin)"},
        {"name": "Borel", "y": 4, "strength": 5, "color": "#FFB74D",
         "axiom": "ZFC", "det_year": "1975 (Martin)"},
        {"name": "Analytic (Σ¹₁)", "y": 5.5, "strength": 10, "color": "#FF8A65",
         "axiom": "ZFC + sharps", "det_year": "1985 (Harrington-Martin)"},
        {"name": "Projective", "y": 7, "strength": 20, "color": "#EF5350",
         "axiom": "ZFC + Woodin", "det_year": "1989 (Martin-Steel)"},
        {"name": "AD (all sets)", "y": 9, "strength": 50, "color": "#AB47BC",
         "axiom": "ZF + DC + LC", "det_year": "1962 (Mycielski-Steinhaus)"},
    ]

    # Draw boxes
    box_width = 6
    for level in levels:
        rect = mpatches.FancyBboxPatch(
            (0.5, level["y"] - 0.35), box_width, 0.7,
            boxstyle="round,pad=0.1",
            facecolor=level["color"], edgecolor='#424242',
            linewidth=1.5, alpha=0.9
        )
        ax.add_patch(rect)

        # Level name
        ax.text(0.5 + box_width / 2, level["y"],
                level["name"], ha='center', va='center',
                fontsize=12, fontweight='bold', color='#212121')

    # Draw strength bars
    max_strength = 50
    bar_x = 8
    bar_width = 4

    for level in levels:
        w = bar_width * level["strength"] / max_strength
        rect = mpatches.FancyBboxPatch(
            (bar_x, level["y"] - 0.25), max(w, 0.05), 0.5,
            boxstyle="round,pad=0.05",
            facecolor=level["color"], edgecolor='#616161',
            linewidth=1, alpha=0.7
        )
        ax.add_patch(rect)

        # Axiom label
        ax.text(bar_x + bar_width + 0.3, level["y"],
                f'{level["axiom"]}  ({level["det_year"]})',
                ha='left', va='center', fontsize=9, color='#424242')

    # Arrows between levels
    for i in range(len(levels) - 1):
        y1 = levels[i]["y"] + 0.35
        y2 = levels[i + 1]["y"] - 0.35
        ax.annotate('', xy=(3.5, y2), xytext=(3.5, y1),
                    arrowprops=dict(arrowstyle='->', color='#757575',
                                   lw=1.5, connectionstyle='arc3,rad=0'))

    # Labels
    ax.text(3.5, -1.3, 'Topological Complexity →',
            ha='center', va='center', fontsize=11, fontweight='bold',
            color='#424242')
    ax.text(bar_x + bar_width / 2, -1.3, 'Axiom Strength →',
            ha='center', va='center', fontsize=11, fontweight='bold',
            color='#424242')

    # Title
    ax.set_title('The Determinacy Hierarchy\n'
                 'Topological Complexity vs. Axiomatic Strength',
                 fontsize=16, fontweight='bold', pad=20)

    # Annotation
    ax.text(bar_x + bar_width / 2, 10.5,
            'Each step up the hierarchy requires\n'
            'strictly stronger set-theoretic axioms.\n'
            'This is the deep bridge between\n'
            'game theory and large cardinals.',
            ha='center', va='center', fontsize=10,
            style='italic', color='#616161',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#F5F5F5',
                     edgecolor='#BDBDBD'))

    ax.set_xlim(-0.5, 20)
    ax.set_ylim(-2, 11.5)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('determinacy_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: determinacy_hierarchy.png")


if __name__ == "__main__":
    main()
