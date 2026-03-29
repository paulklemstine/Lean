#!/usr/bin/env python3
"""
Demo 3: Arrow Reversal — The Contravariance of Spec
=====================================================
Visualizes how ring homomorphisms reverse direction when translated
to maps of spectra. The heart of the Space ↔ Algebra duality.

Run: python demo3_contravariance.py
Output: contravariance.png
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def create_contravariance_diagram():
    fig, axes = plt.subplots(1, 3, figsize=(18, 7))

    # ─── Example 1: ℤ → ℤ/6ℤ ───
    ax = axes[0]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    ax.set_title('Example 1: Quotient Map', fontsize=14, fontweight='bold',
                 fontfamily='serif', pad=15)

    # Algebra side (top)
    ax.add_patch(mpatches.FancyBboxPatch((1, 7), 3, 1.5,
                 boxstyle="round,pad=0.2", facecolor='#f0e6f6', edgecolor='#533483', lw=2))
    ax.text(2.5, 7.75, 'ℤ', fontsize=18, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    ax.add_patch(mpatches.FancyBboxPatch((6, 7), 3, 1.5,
                 boxstyle="round,pad=0.2", facecolor='#f0e6f6', edgecolor='#533483', lw=2))
    ax.text(7.5, 7.75, 'ℤ/6ℤ', fontsize=18, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    # Algebra arrow (right)
    ax.annotate('', xy=(5.8, 7.75), xytext=(4.2, 7.75),
                arrowprops=dict(arrowstyle='->', color='#533483', lw=2.5))
    ax.text(5, 8.5, 'φ: ℤ → ℤ/6ℤ', fontsize=11, ha='center', va='center',
            color='#533483', fontfamily='serif', style='italic')
    ax.text(5, 9.3, 'ALGEBRA', fontsize=13, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    # Space side (bottom)
    ax.add_patch(mpatches.FancyBboxPatch((1, 2), 3, 2.5,
                 boxstyle="round,pad=0.2", facecolor='#e8f4f8', edgecolor='#0f3460', lw=2))
    ax.text(2.5, 3.8, 'Spec(ℤ)', fontsize=14, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')
    ax.text(2.5, 3.0, '{(0),(2),(3),(5),...}', fontsize=9, ha='center', va='center',
            color='#0f3460', fontfamily='serif')

    ax.add_patch(mpatches.FancyBboxPatch((6, 2), 3, 2.5,
                 boxstyle="round,pad=0.2", facecolor='#e8f4f8', edgecolor='#0f3460', lw=2))
    ax.text(7.5, 3.8, 'Spec(ℤ/6ℤ)', fontsize=14, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')
    ax.text(7.5, 3.0, '{(2̄),(3̄)}', fontsize=11, ha='center', va='center',
            color='#0f3460', fontfamily='serif')

    # Space arrow (LEFT — reversed!)
    ax.annotate('', xy=(4.2, 3.25), xytext=(5.8, 3.25),
                arrowprops=dict(arrowstyle='->', color='#e94560', lw=2.5))
    ax.text(5, 1.5, 'Spec(φ): ←', fontsize=11, ha='center', va='center',
            color='#e94560', fontfamily='serif', style='italic')
    ax.text(5, 0.7, 'SPACE', fontsize=13, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')

    # Reversal indicator
    ax.annotate('', xy=(0.5, 5), xytext=(0.5, 6.5),
                arrowprops=dict(arrowstyle='->', color='#e94560', lw=2, linestyle='dashed'))
    ax.text(0.3, 5.75, '↕', fontsize=24, ha='center', va='center', color='#e94560')

    # ─── Example 2: k[x] → k (evaluation) ───
    ax = axes[1]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    ax.set_title('Example 2: Evaluation Map', fontsize=14, fontweight='bold',
                 fontfamily='serif', pad=15)

    # Algebra side
    ax.add_patch(mpatches.FancyBboxPatch((1, 7), 3, 1.5,
                 boxstyle="round,pad=0.2", facecolor='#f0e6f6', edgecolor='#533483', lw=2))
    ax.text(2.5, 7.75, 'k[x]', fontsize=18, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    ax.add_patch(mpatches.FancyBboxPatch((6, 7), 3, 1.5,
                 boxstyle="round,pad=0.2", facecolor='#f0e6f6', edgecolor='#533483', lw=2))
    ax.text(7.5, 7.75, 'k', fontsize=18, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    ax.annotate('', xy=(5.8, 7.75), xytext=(4.2, 7.75),
                arrowprops=dict(arrowstyle='->', color='#533483', lw=2.5))
    ax.text(5, 8.5, 'ev_a: f ↦ f(a)', fontsize=11, ha='center', va='center',
            color='#533483', fontfamily='serif', style='italic')
    ax.text(5, 9.3, 'ALGEBRA', fontsize=13, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    # Space side
    ax.add_patch(mpatches.FancyBboxPatch((1, 2), 3, 2.5,
                 boxstyle="round,pad=0.2", facecolor='#e8f4f8', edgecolor='#0f3460', lw=2))
    ax.text(2.5, 3.8, 'Line 𝔸¹', fontsize=14, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')
    ax.text(2.5, 3.0, 'all points', fontsize=10, ha='center', va='center',
            color='#0f3460', fontfamily='serif')

    ax.add_patch(mpatches.FancyBboxPatch((6, 2), 3, 2.5,
                 boxstyle="round,pad=0.2", facecolor='#e8f4f8', edgecolor='#0f3460', lw=2))
    ax.text(7.5, 3.8, 'Point {a}', fontsize=14, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')
    ax.text(7.5, 3.0, 'one point', fontsize=10, ha='center', va='center',
            color='#0f3460', fontfamily='serif')

    ax.annotate('', xy=(4.2, 3.25), xytext=(5.8, 3.25),
                arrowprops=dict(arrowstyle='->', color='#e94560', lw=2.5))
    ax.text(5, 1.5, '{a} ↪ 𝔸¹', fontsize=11, ha='center', va='center',
            color='#e94560', fontfamily='serif', style='italic')
    ax.text(5, 0.7, 'SPACE', fontsize=13, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')

    # ─── Example 3: The General Principle ───
    ax = axes[2]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    ax.set_title('The General Principle', fontsize=14, fontweight='bold',
                 fontfamily='serif', pad=15)

    # Big arrows showing the reversal
    # Algebra: A → B
    ax.text(5, 9, 'ALGEBRA', fontsize=16, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    ax.add_patch(mpatches.FancyBboxPatch((1.5, 7), 2.5, 1.5,
                 boxstyle="round,pad=0.2", facecolor='#f0e6f6', edgecolor='#533483', lw=2))
    ax.text(2.75, 7.75, 'A', fontsize=24, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    ax.add_patch(mpatches.FancyBboxPatch((6, 7), 2.5, 1.5,
                 boxstyle="round,pad=0.2", facecolor='#f0e6f6', edgecolor='#533483', lw=2))
    ax.text(7.25, 7.75, 'B', fontsize=24, ha='center', va='center',
            color='#533483', fontweight='bold', fontfamily='serif')

    ax.annotate('', xy=(5.8, 7.75), xytext=(4.2, 7.75),
                arrowprops=dict(arrowstyle='->', color='#533483', lw=3))
    ax.text(5, 8.3, 'φ', fontsize=16, ha='center', va='center',
            color='#533483', fontfamily='serif', style='italic')

    # Big reversal symbol
    ax.text(5, 5.5, '⇕  REVERSAL  ⇕', fontsize=18, ha='center', va='center',
            color='#e94560', fontweight='bold', fontfamily='serif')
    ax.add_patch(mpatches.FancyBboxPatch((2, 5), 6, 1,
                 boxstyle="round,pad=0.2", facecolor='#fce4ec', edgecolor='#e94560',
                 lw=2, linestyle='--'))

    # Space: Spec(B) → Spec(A)
    ax.text(5, 1, 'SPACE', fontsize=16, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')

    ax.add_patch(mpatches.FancyBboxPatch((1, 2), 3, 1.5,
                 boxstyle="round,pad=0.2", facecolor='#e8f4f8', edgecolor='#0f3460', lw=2))
    ax.text(2.5, 2.75, 'Spec(A)', fontsize=16, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')

    ax.add_patch(mpatches.FancyBboxPatch((6, 2), 3, 1.5,
                 boxstyle="round,pad=0.2", facecolor='#e8f4f8', edgecolor='#0f3460', lw=2))
    ax.text(7.5, 2.75, 'Spec(B)', fontsize=16, ha='center', va='center',
            color='#0f3460', fontweight='bold', fontfamily='serif')

    # Arrow goes LEFT
    ax.annotate('', xy=(4.2, 2.75), xytext=(5.8, 2.75),
                arrowprops=dict(arrowstyle='->', color='#e94560', lw=3))
    ax.text(5, 3.5, 'Spec(φ)', fontsize=14, ha='center', va='center',
            color='#e94560', fontfamily='serif', style='italic')

    plt.tight_layout()
    plt.savefig('contravariance.png', dpi=200, bbox_inches='tight',
                facecolor='white')
    print("✓ Saved contravariance.png")
    plt.close()

if __name__ == '__main__':
    create_contravariance_diagram()
