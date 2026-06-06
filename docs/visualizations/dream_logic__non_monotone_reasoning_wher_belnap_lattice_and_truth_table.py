#!/usr/bin/env python3
"""
Visualization: Belnap's Four-Valued Logic Lattice and Truth Tables

Generates a visualization of the FOUR lattice structure and operation tables.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_belnap_lattice(ax):
    """Draw the Belnap FOUR lattice (diamond/bilattice)."""
    # Information order positions
    positions = {
        'Neither': (0, 0),
        'False': (-1, 1),
        'True': (1, 1),
        'Both': (0, 2),
    }
    
    colors = {
        'Neither': '#808080',  # Gray
        'False': '#FF4444',    # Red
        'True': '#44AA44',     # Green
        'Both': '#FFD700',     # Gold
    }
    
    # Draw edges (information order)
    edges = [('Neither', 'False'), ('Neither', 'True'), ('False', 'Both'), ('True', 'Both')]
    for a, b in edges:
        ax.plot([positions[a][0], positions[b][0]], 
                [positions[a][1], positions[b][1]], 
                'k-', linewidth=2, zorder=1)
    
    # Draw nodes
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.25, color=colors[name], ec='black', 
                           linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, name[0], ha='center', va='center', fontsize=14, 
                fontweight='bold', zorder=3)
        ax.text(x, y - 0.45, name, ha='center', va='center', fontsize=9)
    
    # Labels
    ax.set_xlim(-2, 2)
    ax.set_ylim(-0.8, 3)
    ax.set_aspect('equal')
    ax.set_title('Belnap FOUR\n(Information Lattice)', fontsize=13, fontweight='bold')
    ax.axis('off')
    
    # Add designation indicator
    ax.text(1.5, 1.5, 'Designated\n{T, B}', fontsize=9, 
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5),
            ha='center')


def draw_truth_table(ax, operation, title, func):
    """Draw a 4x4 truth table."""
    values = ['N', 'F', 'T', 'B']
    colors_map = {'N': '#C0C0C0', 'F': '#FFAAAA', 'T': '#AAFFAA', 'B': '#FFFFAA'}
    
    # Compute table
    table = np.zeros((4, 4), dtype=object)
    for i, a in enumerate(values):
        for j, b in enumerate(values):
            table[i, j] = func(a, b)
    
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 4.5)
    
    # Draw cells
    for i in range(4):
        for j in range(4):
            val = table[i, j]
            color = colors_map[val]
            rect = mpatches.FancyBboxPatch((j + 0.55, 3.55 - i), 0.9, 0.9,
                                            boxstyle="round,pad=0.05",
                                            facecolor=color, edgecolor='gray')
            ax.add_patch(rect)
            ax.text(j + 1, 4 - i, val, ha='center', va='center', fontsize=12)
    
    # Headers
    for j, v in enumerate(values):
        ax.text(j + 1, 4.7, v, ha='center', va='center', fontsize=12, fontweight='bold')
        ax.text(-0.2, 4 - j, v, ha='center', va='center', fontsize=12, fontweight='bold')
    
    ax.set_title(title, fontsize=13, fontweight='bold', pad=15)
    ax.axis('off')


def conj_func(a, b):
    table = {
        ('F','F'):'F',('F','T'):'F',('F','B'):'F',('F','N'):'F',
        ('T','F'):'F',('T','T'):'T',('T','B'):'B',('T','N'):'N',
        ('B','F'):'F',('B','T'):'B',('B','B'):'B',('B','N'):'F',
        ('N','F'):'F',('N','T'):'N',('N','B'):'F',('N','N'):'N',
    }
    return table[(a, b)]


def disj_func(a, b):
    table = {
        ('F','F'):'F',('F','T'):'T',('F','B'):'B',('F','N'):'N',
        ('T','F'):'T',('T','T'):'T',('T','B'):'T',('T','N'):'T',
        ('B','F'):'B',('B','T'):'T',('B','B'):'B',('B','N'):'T',
        ('N','F'):'N',('N','T'):'T',('N','B'):'T',('N','N'):'N',
    }
    return table[(a, b)]


def neg_func(v):
    return {'N': 'N', 'F': 'T', 'T': 'F', 'B': 'B'}[v]


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    draw_belnap_lattice(axes[0])
    draw_truth_table(axes[1], 'AND', 'Conjunction (∧)', conj_func)
    draw_truth_table(axes[2], 'OR', 'Disjunction (∨)', disj_func)
    
    fig.suptitle("Belnap's Four-Valued Logic: Structure and Operations", 
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('belnap_four.png', dpi=150, bbox_inches='tight')
    print("Saved belnap_four.png")


if __name__ == "__main__":
    main()
