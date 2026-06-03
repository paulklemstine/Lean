#!/usr/bin/env python3
"""
Visualization: The factorization hierarchy diagram.

Shows the strict inclusion chain:
  UF ⊂ Collision-Free ⊂ Product-Free
with example sets at each level.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def main():
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Draw nested regions (Venn-like, but nested)
    # Product-Free (outermost)
    pf_ellipse = mpatches.FancyBboxPatch(
        (0.5, 0.8), 10, 6.5, boxstyle="round,pad=0.5",
        facecolor='#FFE0B2', edgecolor='#E65100', linewidth=3, alpha=0.7)
    ax.add_patch(pf_ellipse)

    # Collision-Free (middle)
    cf_ellipse = mpatches.FancyBboxPatch(
        (1.2, 1.3), 8.5, 5, boxstyle="round,pad=0.5",
        facecolor='#C8E6C9', edgecolor='#2E7D32', linewidth=3, alpha=0.7)
    ax.add_patch(cf_ellipse)

    # UF (innermost)
    uf_ellipse = mpatches.FancyBboxPatch(
        (2, 2), 7, 3.2, boxstyle="round,pad=0.5",
        facecolor='#BBDEFB', edgecolor='#1565C0', linewidth=3, alpha=0.7)
    ax.add_patch(uf_ellipse)

    # Labels for regions
    ax.text(5.5, 7.8, 'Product-Free', fontsize=18, fontweight='bold',
            ha='center', color='#E65100')
    ax.text(5.5, 6.6, 'Collision-Free', fontsize=18, fontweight='bold',
            ha='center', color='#2E7D32')
    ax.text(5.5, 5.4, 'Unique Factorization', fontsize=18, fontweight='bold',
            ha='center', color='#1565C0')

    # Example sets
    # UF region: Primes
    ax.text(5.5, 4.2, '● Primes {2, 3, 5, 7, 11, ...}', fontsize=13,
            ha='center', color='#0D47A1', style='italic')
    ax.text(5.5, 3.5, '● {2, 3, 5, 7} (coprime)', fontsize=13,
            ha='center', color='#0D47A1', style='italic')

    # Collision-Free but not UF
    # (Hard to find natural examples — most collision-free sets do have UF)
    ax.text(5.5, 2.0, '● {4, 9, 25} (prime powers)', fontsize=13,
            ha='center', color='#1B5E20', style='italic')

    # Product-Free but not Collision-Free
    ax.text(5.5, 1.1, '● {6, 10, 21, 35}', fontsize=14,
            ha='center', color='#BF360C', fontweight='bold')
    ax.text(5.5, 0.5, '  6×35 = 10×21 = 210 (COLLISION!)', fontsize=12,
            ha='center', color='#BF360C')

    # Arrows showing strict implications
    ax.annotate('', xy=(10.5, 3.5), xytext=(10.5, 5.5),
                arrowprops=dict(arrowstyle='->', color='#616161', lw=2))
    ax.text(11.2, 4.5, '⟹', fontsize=20, ha='center', va='center', color='#616161')

    ax.annotate('', xy=(10.5, 5.8), xytext=(10.5, 7.2),
                arrowprops=dict(arrowstyle='->', color='#616161', lw=2))
    ax.text(11.2, 6.5, '⟹', fontsize=20, ha='center', va='center', color='#616161')

    # "NOT reverse" markers
    ax.text(12.0, 4.5, '⇍', fontsize=20, ha='center', va='center', color='red')
    ax.text(12.0, 6.5, '⇍', fontsize=20, ha='center', va='center', color='red')

    ax.set_xlim(-0.5, 13)
    ax.set_ylim(-0.5, 9)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Factorization Hierarchy\nUF ⟹ Collision-Free ⟹ Product-Free (strict)',
                 fontsize=20, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('hierarchy_diagram.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved hierarchy_diagram.png")


if __name__ == "__main__":
    main()
