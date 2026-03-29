#!/usr/bin/env python3
"""
Demo 6: Idempotent Decomposition — Connected Components ↔ Idempotents
======================================================================
Visualizes how idempotent elements e² = e in a ring correspond to
clopen (simultaneously closed and open) decompositions of the spectrum.

Example: ℤ/6ℤ ≅ ℤ/2ℤ × ℤ/3ℤ via idempotents e=3, f=4.

Run: python demo6_idempotent_decomposition.py
Output: idempotent_decomposition.png
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def create_idempotent_demo():
    fig, axes = plt.subplots(1, 3, figsize=(18, 7))
    fig.suptitle('Row 7: Connected Components ↔ Idempotents',
                 fontsize=20, fontweight='bold', fontfamily='serif', y=1.02)

    # ─── Panel 1: ℤ/6ℤ and its idempotents ───
    ax = axes[0]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    ax.set_title('The Ring ℤ/6ℤ', fontsize=16, fontweight='bold',
                 fontfamily='serif')

    # Elements of ℤ/6ℤ
    elements = list(range(6))
    for i, e in enumerate(elements):
        angle = 2 * np.pi * i / 6 - np.pi / 2
        x = 5 + 2.5 * np.cos(angle)
        y = 5 + 2.5 * np.sin(angle)
        is_idemp = (e * e) % 6 == e
        color = '#e94560' if is_idemp else '#cccccc'
        edge = '#1a1a2e' if is_idemp else '#999999'
        size = 20 if is_idemp else 14
        ax.plot(x, y, 'o', markersize=size, color=color,
                markeredgecolor=edge, markeredgewidth=2, zorder=10)
        ax.text(x, y, str(e), fontsize=12, ha='center', va='center',
                color='white' if is_idemp else '#333333',
                fontweight='bold', zorder=11)

    ax.text(5, 1.2, 'Idempotents: e² = e (mod 6)', fontsize=11,
            ha='center', va='center', color='#e94560', fontweight='bold',
            fontfamily='serif')
    ax.text(5, 0.5, '0² = 0 ✓   1² = 1 ✓   3² = 9 ≡ 3 ✓   4² = 16 ≡ 4 ✓',
            fontsize=9, ha='center', va='center', color='#666666',
            fontfamily='serif')

    # ─── Panel 2: The decomposition ───
    ax = axes[1]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    ax.set_title('Idempotent Decomposition', fontsize=16, fontweight='bold',
                 fontfamily='serif')

    # ℤ/6ℤ box
    ax.add_patch(mpatches.FancyBboxPatch((1, 7), 8, 1.5,
                 boxstyle="round,pad=0.2", facecolor='#f0e6f6',
                 edgecolor='#533483', lw=2))
    ax.text(5, 7.75, 'ℤ/6ℤ', fontsize=20, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    # Arrow down
    ax.annotate('', xy=(5, 5.8), xytext=(5, 6.8),
                arrowprops=dict(arrowstyle='->', color='#e94560', lw=2.5))
    ax.text(6.5, 6.3, 'e=3, f=4\ne+f=1 (mod 6)\nef=0 (mod 6)',
            fontsize=9, ha='left', va='center', color='#e94560',
            fontfamily='serif')

    # Two components
    ax.add_patch(mpatches.FancyBboxPatch((0.5, 3.5), 3.5, 2,
                 boxstyle="round,pad=0.2", facecolor='#e8f4f8',
                 edgecolor='#0f3460', lw=2))
    ax.text(2.25, 4.5, 'eA ≅ ℤ/2ℤ', fontsize=14, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')
    ax.text(2.25, 3.9, '{0̄, 3̄}', fontsize=11, ha='center', va='center',
            color='#0f3460', fontfamily='serif')

    ax.text(5, 4.5, '×', fontsize=24, ha='center', va='center',
            color='#e94560', fontweight='bold')

    ax.add_patch(mpatches.FancyBboxPatch((6, 3.5), 3.5, 2,
                 boxstyle="round,pad=0.2", facecolor='#d5f5e3',
                 edgecolor='#27ae60', lw=2))
    ax.text(7.75, 4.5, 'fA ≅ ℤ/3ℤ', fontsize=14, ha='center', va='center',
            color='#27ae60', fontweight='bold', fontfamily='serif')
    ax.text(7.75, 3.9, '{0̄, 2̄, 4̄}', fontsize=11, ha='center', va='center',
            color='#27ae60', fontfamily='serif')

    # CRT
    ax.text(5, 2.5, 'Chinese Remainder Theorem:', fontsize=11,
            ha='center', va='center', color='#333333', fontweight='bold',
            fontfamily='serif')
    ax.text(5, 1.8, 'ℤ/6ℤ ≅ ℤ/2ℤ × ℤ/3ℤ', fontsize=14,
            ha='center', va='center', color='#533483', fontweight='bold',
            fontfamily='serif')
    ax.text(5, 1.0, 'Nontrivial idempotents ⟹ disconnected spectrum',
            fontsize=10, ha='center', va='center', color='#e94560',
            fontfamily='serif', style='italic')

    # ─── Panel 3: Spec visualization ───
    ax = axes[2]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    ax.set_title('Spec(ℤ/6ℤ) — Two Connected Components',
                 fontsize=16, fontweight='bold', fontfamily='serif')

    # Component 1
    circle1 = plt.Circle((3, 6), 1.8, facecolor='#e8f4f8',
                          edgecolor='#0f3460', lw=3, zorder=5)
    ax.add_patch(circle1)
    ax.plot(3, 6, 's', markersize=20, color='#0f3460',
            markeredgecolor='#1a1a2e', markeredgewidth=2, zorder=10)
    ax.text(3, 6, '(2̄)', fontsize=14, ha='center', va='center',
            color='white', fontweight='bold', zorder=11)
    ax.text(3, 4.0, 'D(3) — clopen', fontsize=10, ha='center', va='center',
            color='#0f3460', fontfamily='serif', fontweight='bold')

    # Component 2
    circle2 = plt.Circle((7, 6), 1.8, facecolor='#d5f5e3',
                          edgecolor='#27ae60', lw=3, zorder=5)
    ax.add_patch(circle2)
    ax.plot(7, 6, 's', markersize=20, color='#27ae60',
            markeredgecolor='#1a1a2e', markeredgewidth=2, zorder=10)
    ax.text(7, 6, '(3̄)', fontsize=14, ha='center', va='center',
            color='white', fontweight='bold', zorder=11)
    ax.text(7, 4.0, 'D(4) — clopen', fontsize=10, ha='center', va='center',
            color='#27ae60', fontfamily='serif', fontweight='bold')

    # Disconnected indicator
    ax.text(5, 6, '✗', fontsize=30, ha='center', va='center',
            color='#e94560', fontweight='bold', zorder=15)

    ax.text(5, 2.5, 'Spec(ℤ/6ℤ) = {(2̄), (3̄)}', fontsize=12,
            ha='center', va='center', color='#333333', fontweight='bold',
            fontfamily='serif')
    ax.text(5, 1.5, 'Two points = two connected components\n'
            '= two nontrivial idempotents (3 and 4)',
            fontsize=10, ha='center', va='center', color='#666666',
            fontfamily='serif')

    plt.tight_layout()
    plt.savefig('idempotent_decomposition.png', dpi=200, bbox_inches='tight',
                facecolor='white')
    print("✓ Saved idempotent_decomposition.png")
    plt.close()

if __name__ == '__main__':
    create_idempotent_demo()
