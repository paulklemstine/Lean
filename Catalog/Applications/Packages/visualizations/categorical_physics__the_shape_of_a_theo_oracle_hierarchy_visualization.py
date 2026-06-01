"""
Visualization: Oracle Hierarchy for TQFTs by Dimension

Standalone matplotlib visualization showing how the computability
of topological quantum field theories depends on spacetime dimension.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def tqft_oracle_level(d: int) -> int:
    """Oracle level sigma for dimension d."""
    return 0 if d <= 3 else d - 3


def main():
    dims = list(range(0, 16))
    levels = [tqft_oracle_level(d) for d in dims]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Oracle level vs dimension
    colors = ['#2ecc71' if l == 0 else '#e74c3c' if l == 1 else '#3498db'
              for l in levels]

    bars = ax1.bar(dims, levels, color=colors, edgecolor='black', linewidth=0.5)
    ax1.set_xlabel('Spacetime Dimension d', fontsize=12)
    ax1.set_ylabel('Oracle Level σ(d)', fontsize=12)
    ax1.set_title('Computability of TQFTs by Dimension', fontsize=14, fontweight='bold')

    # Add annotations
    ax1.axhline(y=0, color='green', linestyle='--', alpha=0.3, label='Computable')
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.3, label='Undecidable')

    ax1.annotate('Computable\n(d ≤ 3)', xy=(1.5, 0.2), fontsize=10,
                ha='center', color='#27ae60', fontweight='bold')
    ax1.annotate('Exotic R⁴\n(d = 4)', xy=(4, 1.3), fontsize=9,
                ha='center', color='#c0392b')
    ax1.annotate('Higher\noracles', xy=(10, 7.5), fontsize=10,
                ha='center', color='#2980b9')

    green_patch = mpatches.Patch(color='#2ecc71', label='Computable (Σ₀)')
    red_patch = mpatches.Patch(color='#e74c3c', label='Undecidable (Σ₁)')
    blue_patch = mpatches.Patch(color='#3498db', label='Higher oracle (Σₙ)')
    ax1.legend(handles=[green_patch, red_patch, blue_patch], loc='upper left')

    # Plot 2: Theory inclusion hierarchy
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.set_title('Theory Inclusion & Shadow Structure', fontsize=14, fontweight='bold')

    # Draw theory nodes
    positions = {
        'TQFT': (2, 7),
        'CFT': (5, 7),
        'String': (2, 3),
        'Gravity': (8, 5),
    }
    node_colors = {
        'TQFT': '#2ecc71',
        'CFT': '#f39c12',
        'String': '#9b59b6',
        'Gravity': '#e74c3c',
    }

    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.8, color=node_colors[name],
                           ec='black', linewidth=2, alpha=0.8)
        ax2.add_patch(circle)
        ax2.text(x, y, name, ha='center', va='center', fontsize=10,
                fontweight='bold', color='white')

    # Draw inclusion arrows
    arrows = [
        ('TQFT', 'CFT'),
        ('CFT', 'Gravity'),
        ('String', 'Gravity'),
    ]
    for src, dst in arrows:
        sx, sy = positions[src]
        dx, dy = positions[dst]
        ax2.annotate('', xy=(dx - 0.8 * (dx - sx) / np.sqrt((dx-sx)**2 + (dy-sy)**2),
                            dy - 0.8 * (dy - sy) / np.sqrt((dx-sx)**2 + (dy-sy)**2)),
                    xytext=(sx + 0.8 * (dx - sx) / np.sqrt((dx-sx)**2 + (dy-sy)**2),
                           sy + 0.8 * (dy - sy) / np.sqrt((dx-sx)**2 + (dy-sy)**2)),
                    arrowprops=dict(arrowstyle='->', lw=2, color='black'))

    # Add the (2,∞) annotation
    ax2.text(5, 1.2, '(2,∞)-Category Necessity:', fontsize=11,
            ha='center', fontweight='bold')
    ax2.text(5, 0.5, 'TQFT ∧ String ⟹ stable level ≥ 2',
            fontsize=10, ha='center', style='italic')

    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: oracle_hierarchy.png")


if __name__ == "__main__":
    main()
