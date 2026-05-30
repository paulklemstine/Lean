"""
Visualization: Subgroup Lattice of S_3 with Möbius Values

Draws the Hasse diagram of the subgroup lattice of S_3, annotated with
the Möbius function values μ(H, S_3). This illustrates the alternating
sign pattern that drives the inclusion-exclusion in the Möbius formula.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_lattice():
    """Draw the subgroup lattice of S_3 with Möbius values."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # S_3 has 6 subgroups:
    # Level 0 (bottom): {e} (order 1)
    # Level 1: ⟨(12)⟩, ⟨(13)⟩, ⟨(23)⟩ (order 2 each), A_3 = ⟨(123)⟩ (order 3)
    # Level 2 (top): S_3 (order 6)

    # Positions
    positions = {
        '{e}': (5, 0),
        '⟨(12)⟩': (2, 2),
        '⟨(13)⟩': (5, 2),
        '⟨(23)⟩': (8, 2),
        'A₃': (5, 4),
        'S₃': (5, 6),
    }

    # Möbius values μ(H, S_3)
    moebius = {
        '{e}': 3,
        '⟨(12)⟩': -1,
        '⟨(13)⟩': -1,
        '⟨(23)⟩': -1,
        'A₃': -1,
        'S₃': 1,
    }

    orders = {
        '{e}': 1,
        '⟨(12)⟩': 2,
        '⟨(13)⟩': 2,
        '⟨(23)⟩': 2,
        'A₃': 3,
        'S₃': 6,
    }

    # Edges (Hasse diagram)
    edges = [
        ('{e}', '⟨(12)⟩'),
        ('{e}', '⟨(13)⟩'),
        ('{e}', '⟨(23)⟩'),
        ('{e}', 'A₃'),
        ('⟨(12)⟩', 'S₃'),
        ('⟨(13)⟩', 'S₃'),
        ('⟨(23)⟩', 'S₃'),
        ('A₃', 'S₃'),
    ]

    # Draw edges
    for h1, h2 in edges:
        x1, y1 = positions[h1]
        x2, y2 = positions[h2]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.4, zorder=1)

    # Draw nodes
    for name, (x, y) in positions.items():
        mu = moebius[name]
        order = orders[name]

        # Color by Möbius value
        if mu > 0:
            color = '#4CAF50'  # green for positive
            edge_color = '#2E7D32'
        elif mu < 0:
            color = '#F44336'  # red for negative
            edge_color = '#C62828'
        else:
            color = '#9E9E9E'
            edge_color = '#616161'

        circle = plt.Circle((x, y), 0.6, facecolor=color, edgecolor=edge_color,
                             linewidth=2, alpha=0.85, zorder=2)
        ax.add_patch(circle)

        # Subgroup name
        ax.text(x, y + 0.15, name, ha='center', va='center',
                fontsize=11, fontweight='bold', color='white', zorder=3)
        # Möbius value
        ax.text(x, y - 0.25, f'μ = {mu}', ha='center', va='center',
                fontsize=9, color='white', zorder=3)
        # Order
        ax.text(x + 0.7, y + 0.5, f'|H|={order}', ha='left', va='center',
                fontsize=8, color='#555', zorder=3)

    # Annotations
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-1, 7.5)
    ax.set_aspect('equal')
    ax.axis('off')

    ax.set_title('Subgroup Lattice of S₃ with Möbius Function Values\n'
                 'φ_k(S₃) = Σ μ(H, S₃) · |H|^k',
                 fontsize=14, fontweight='bold', pad=20)

    # Legend
    green_patch = mpatches.Patch(color='#4CAF50', label='μ > 0 (inclusion)')
    red_patch = mpatches.Patch(color='#F44336', label='μ < 0 (exclusion)')
    ax.legend(handles=[green_patch, red_patch], loc='lower right',
              fontsize=10, framealpha=0.9)

    # Add formula verification
    ax.text(0.5, -0.5,
            'k=2: φ₂(S₃) = 3·1² + (-1)·2² + (-1)·2² + (-1)·2² + (-1)·3² + 1·6² = 3-4-4-4-9+36 = 18  ✓',
            fontsize=9, color='#333', ha='left')

    plt.tight_layout()
    plt.savefig('moebius_lattice_s3.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: moebius_lattice_s3.png")


draw_lattice()
