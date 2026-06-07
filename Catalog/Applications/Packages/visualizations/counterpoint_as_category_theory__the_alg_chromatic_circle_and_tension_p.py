#!/usr/bin/env python3
"""
Visualization: Consonant Intervals on the Chromatic Circle

Shows the 12 pitch classes arranged in a circle, with consonant intervals
highlighted and inversion pairs connected by arcs.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_chromatic_circle():
    """Draw the chromatic circle with consonance analysis."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    CONSONANT = {0, 3, 4, 7, 8, 9}
    PERFECT = {0, 7}
    IMPERFECT = {3, 4, 8, 9}

    NAMES = ['C/P1', 'm2', 'M2', 'm3', 'M3', 'P4',
             'TT', 'P5', 'm6', 'M6', 'm7', 'M7']

    # Plot 1: Consonance on the chromatic circle
    ax = axes[0]
    ax.set_aspect('equal')
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.set_title('Consonant Intervals in ℤ/12ℤ', fontsize=14, fontweight='bold')
    ax.axis('off')

    # Draw circle
    theta = np.linspace(0, 2 * np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2, linewidth=1)

    # Place intervals
    for i in range(12):
        angle = np.pi / 2 - 2 * np.pi * i / 12
        x, y = 1.0 * np.cos(angle), 1.0 * np.sin(angle)
        lx, ly = 1.35 * np.cos(angle), 1.35 * np.sin(angle)

        if i in PERFECT:
            color = '#2196F3'
            size = 300
        elif i in IMPERFECT:
            color = '#4CAF50'
            size = 250
        else:
            color = '#E0E0E0'
            size = 150

        ax.scatter(x, y, s=size, c=color, zorder=5, edgecolors='black', linewidth=1.5)
        ax.text(lx, ly, NAMES[i], ha='center', va='center', fontsize=9, fontweight='bold')

    # Draw inversion pairs
    inv_pairs = [(3, 9), (4, 8)]
    for a, b in inv_pairs:
        angle_a = np.pi / 2 - 2 * np.pi * a / 12
        angle_b = np.pi / 2 - 2 * np.pi * b / 12
        xa, ya = 0.85 * np.cos(angle_a), 0.85 * np.sin(angle_a)
        xb, yb = 0.85 * np.cos(angle_b), 0.85 * np.sin(angle_b)
        ax.annotate('', xy=(xb, yb), xytext=(xa, ya),
                     arrowprops=dict(arrowstyle='<->', color='#FF9800', lw=2))

    # Draw the broken pair (5, 7)
    for val, c in [(5, '#F44336'), (7, '#2196F3')]:
        angle = np.pi / 2 - 2 * np.pi * val / 12
        xa, ya = 0.85 * np.cos(angle), 0.85 * np.sin(angle)
    angle_5 = np.pi / 2 - 2 * np.pi * 5 / 12
    angle_7 = np.pi / 2 - 2 * np.pi * 7 / 12
    x5, y5 = 0.85 * np.cos(angle_5), 0.85 * np.sin(angle_5)
    x7, y7 = 0.85 * np.cos(angle_7), 0.85 * np.sin(angle_7)
    ax.annotate('', xy=(x5, y5), xytext=(x7, y7),
                 arrowprops=dict(arrowstyle='<->', color='#F44336', lw=2, linestyle='dashed'))

    # Legend
    ax.scatter([], [], c='#2196F3', s=100, label='Perfect consonance', edgecolors='black')
    ax.scatter([], [], c='#4CAF50', s=100, label='Imperfect consonance', edgecolors='black')
    ax.scatter([], [], c='#E0E0E0', s=100, label='Dissonant', edgecolors='black')
    ax.plot([], [], '-', color='#FF9800', lw=2, label='Inversion pair (both consonant)')
    ax.plot([], [], '--', color='#F44336', lw=2, label='Broken pair (P5↔P4)')
    ax.legend(loc='lower center', fontsize=8, ncol=2)

    # Plot 2: Tension Poset
    ax2 = axes[1]
    ax2.set_xlim(-2, 6)
    ax2.set_ylim(-0.5, 3.5)
    ax2.set_title('Tension Poset: 1 + 1 + 4', fontsize=14, fontweight='bold')
    ax2.axis('off')

    # Level 0: Unison
    ax2.scatter([2], [0], s=400, c='#2196F3', zorder=5, edgecolors='black', linewidth=2)
    ax2.text(2, -0.35, 'Unison (0)\nτ = 0', ha='center', fontsize=9)

    # Level 1: Fifth
    ax2.scatter([2], [1.2], s=400, c='#2196F3', zorder=5, edgecolors='black', linewidth=2)
    ax2.text(2, 0.85, 'Fifth (7)\nτ = 1', ha='center', fontsize=9)

    # Level 2: Imperfect consonances
    imp_x = [0.5, 1.5, 2.5, 3.5]
    imp_labels = ['m3 (3)', 'M3 (4)', 'm6 (8)', 'M6 (9)']
    for x, label in zip(imp_x, imp_labels):
        ax2.scatter([x], [2.5], s=350, c='#4CAF50', zorder=5, edgecolors='black', linewidth=2)
        ax2.text(x, 2.9, label, ha='center', fontsize=8)
    ax2.text(2, 2.15, 'τ = 2 (mobile)', ha='center', fontsize=9, fontstyle='italic')

    # Hasse edges
    ax2.plot([2, 2], [0.15, 1.05], 'k-', linewidth=2)
    for x in imp_x:
        ax2.plot([2, x], [1.35, 2.35], 'k-', linewidth=1.5, alpha=0.6)

    # Annotations
    ax2.text(2.2, 0.6, '≤', fontsize=14, fontweight='bold')
    ax2.text(0.3, 1.8, '≤', fontsize=12, rotation=55)

    plt.tight_layout()
    plt.savefig('counterpoint_analysis.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: counterpoint_analysis.png")


if __name__ == "__main__":
    draw_chromatic_circle()
