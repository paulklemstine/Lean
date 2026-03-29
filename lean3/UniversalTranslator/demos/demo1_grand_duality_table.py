#!/usr/bin/env python3
"""
Demo 1: The Grand Duality Table — Space ↔ Algebra
===================================================
A publication-quality infographic showing the eight-row dictionary
that translates between geometry and algebra.

Run: python demo1_grand_duality_table.py
Output: grand_duality_table.png
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def create_grand_duality_table():
    fig, ax = plt.subplots(figsize=(16, 14))
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 14)
    ax.axis('off')

    # Title
    ax.text(8, 13.3, 'THE UNIVERSAL TRANSLATOR', fontsize=28, fontweight='bold',
            ha='center', va='center', color='#1a1a2e',
            fontfamily='serif')
    ax.text(8, 12.7, 'Space ↔ Algebra', fontsize=20, ha='center', va='center',
            color='#16213e', fontfamily='serif', style='italic')

    # Column headers
    header_y = 12.0
    ax.add_patch(mpatches.FancyBboxPatch((0.5, header_y - 0.3), 6.5, 0.6,
                 boxstyle="round,pad=0.1", facecolor='#0f3460', edgecolor='none'))
    ax.add_patch(mpatches.FancyBboxPatch((9, header_y - 0.3), 6.5, 0.6,
                 boxstyle="round,pad=0.1", facecolor='#533483', edgecolor='none'))

    ax.text(3.75, header_y, 'SPACE  (Geometry)', fontsize=16, fontweight='bold',
            ha='center', va='center', color='white', fontfamily='serif')
    ax.text(12.25, header_y, 'ALGEBRA  (Rings)', fontsize=16, fontweight='bold',
            ha='center', va='center', color='white', fontfamily='serif')

    # Arrow in the middle
    ax.annotate('', xy=(8.7, header_y), xytext=(7.3, header_y),
                arrowprops=dict(arrowstyle='<->', color='#e94560', lw=3))

    # Table rows
    rows = [
        ('1', 'Point  x ∈ X', 'Prime ideal  𝔭 ⊂ R', '#e8f4f8', '#f0e6f6'),
        ('2', 'Open set  U ⊆ X', 'Element  a ∈ R  (via D(a))', '#d4edda', '#e8d5e8'),
        ('3', 'Continuous map  f: X→Y', 'Ring hom  φ: B→A  (reversed!)', '#fff3cd', '#fce4ec'),
        ('4', 'Closed subspace  Z ⊆ X', 'Ideal  I ⊂ R  (via V(I))', '#e8f4f8', '#f0e6f6'),
        ('5', 'Dimension  dim(X)', 'Krull dim = sup chain primes', '#d4edda', '#e8d5e8'),
        ('6', 'Tangent vector  v', 'Derivation  δ: R → M', '#fff3cd', '#fce4ec'),
        ('7', 'Connected components', 'Idempotents  e² = e', '#e8f4f8', '#f0e6f6'),
        ('8', 'Vector bundle  E → X', 'Projective module  P', '#d4edda', '#e8d5e8'),
    ]

    for i, (num, space, algebra, col_s, col_a) in enumerate(rows):
        y = 11.0 - i * 1.2
        # Row number
        ax.add_patch(plt.Circle((0.8, y), 0.3, color='#e94560', zorder=5))
        ax.text(0.8, y, num, fontsize=14, fontweight='bold',
                ha='center', va='center', color='white', zorder=6)
        # Space side
        ax.add_patch(mpatches.FancyBboxPatch((1.3, y - 0.35), 6.0, 0.7,
                     boxstyle="round,pad=0.1", facecolor=col_s, edgecolor='#0f3460',
                     linewidth=1.5))
        ax.text(4.3, y, space, fontsize=12, ha='center', va='center',
                color='#0f3460', fontfamily='serif')
        # Arrow
        ax.annotate('', xy=(8.7, y), xytext=(7.5, y),
                    arrowprops=dict(arrowstyle='<->', color='#e94560', lw=2))
        # Algebra side
        ax.add_patch(mpatches.FancyBboxPatch((9.0, y - 0.35), 6.0, 0.7,
                     boxstyle="round,pad=0.1", facecolor=col_a, edgecolor='#533483',
                     linewidth=1.5))
        ax.text(12.0, y, algebra, fontsize=12, ha='center', va='center',
                color='#533483', fontfamily='serif')

    # Footer: The Spec Functor
    footer_y = 1.0
    ax.add_patch(mpatches.FancyBboxPatch((2, footer_y - 0.4), 12, 0.9,
                 boxstyle="round,pad=0.2", facecolor='#1a1a2e', edgecolor='#e94560',
                 linewidth=2))
    ax.text(8, footer_y + 0.05, 'The Spec Functor:  CommRing$^{op}$ → Top',
            fontsize=16, ha='center', va='center', color='#e94560',
            fontfamily='serif', fontweight='bold')

    # Subtitle
    ax.text(8, 0.3, 'Each row is a theorem — machine-verified in Lean 4 with Mathlib',
            fontsize=11, ha='center', va='center', color='#666666',
            fontfamily='serif', style='italic')

    plt.tight_layout()
    plt.savefig('grand_duality_table.png', dpi=200, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    plt.savefig('grand_duality_table.pdf', bbox_inches='tight',
                facecolor='white', edgecolor='none')
    print("✓ Saved grand_duality_table.png and .pdf")
    plt.close()

if __name__ == '__main__':
    create_grand_duality_table()
