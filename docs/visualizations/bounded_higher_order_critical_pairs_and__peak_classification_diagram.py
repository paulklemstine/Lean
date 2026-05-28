#!/usr/bin/env python3
"""
Visualize Peak/Join Diagrams for Higher-Order Critical Pairs.

This script creates a visual representation of the peak classification
theorem: every local peak in a rewrite system is either disjoint, nested,
or a genuine overlap, and each type has a characteristic join pattern.

The visualization shows the diamond property for each peak type, which is
the geometric heart of the Knuth-Bendix critical pair theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_peak_join(ax, title, source, left, right, join,
                   peak_type, color, joinable=True):
    """Draw a single peak/join diagram."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(title, fontsize=13, fontweight='bold', pad=15)

    # Source node (top)
    ax.plot(0, 3, 'o', markersize=18, color=color, zorder=5)
    ax.text(0, 3, source, ha='center', va='center', fontsize=9,
            fontweight='bold', color='white', zorder=6)

    # Left node
    ax.plot(-1, 2, 'o', markersize=18, color=color, alpha=0.7, zorder=5)
    ax.text(-1, 2, left, ha='center', va='center', fontsize=8, zorder=6)

    # Right node
    ax.plot(1, 2, 'o', markersize=18, color=color, alpha=0.7, zorder=5)
    ax.text(1, 2, right, ha='center', va='center', fontsize=8, zorder=6)

    # Downward arrows from source
    ax.annotate('', xy=(-0.85, 2.15), xytext=(-0.15, 2.85),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))
    ax.annotate('', xy=(0.85, 2.15), xytext=(0.15, 2.85),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))

    if joinable:
        # Join node (bottom)
        ax.plot(0, 1, 'o', markersize=18, color='#2ecc71', zorder=5)
        ax.text(0, 1, join, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white', zorder=6)

        # Arrows to join
        ax.annotate('', xy=(-0.15, 1.15), xytext=(-0.85, 1.85),
                    arrowprops=dict(arrowstyle='->', color='#2ecc71',
                                    lw=2, linestyle='dashed'))
        ax.annotate('', xy=(0.15, 1.15), xytext=(0.85, 1.85),
                    arrowprops=dict(arrowstyle='->', color='#2ecc71',
                                    lw=2, linestyle='dashed'))

        ax.text(0, 0.3, '✓ Joinable', ha='center', fontsize=11,
                color='#2ecc71', fontweight='bold')
    else:
        ax.text(-0.5, 1.2, '?', ha='center', fontsize=20, color='#e74c3c')
        ax.text(0.5, 1.2, '?', ha='center', fontsize=20, color='#e74c3c')
        ax.text(0, 0.3, '✗ Not joinable', ha='center', fontsize=11,
                color='#e74c3c', fontweight='bold')

    # Peak type label
    ax.text(0, -0.2, f'Peak type: {peak_type}', ha='center', fontsize=9,
            style='italic', color='#7f8c8d')


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Peak Classification in Higher-Order Rewriting Modulo β',
             fontsize=16, fontweight='bold', y=0.98)

# 1. Disjoint peak
draw_peak_join(axes[0], 'Disjoint Peak',
               's₁ s₂', "s₁' s₂", "s₁ s₂'", "s₁' s₂'",
               'Disjoint', '#3498db', joinable=True)

# 2. Nested peak (one redex inside another)
draw_peak_join(axes[1], 'Nested Peak',
               'C[l]', 'C[r]', "C'[l]", "C'[r]",
               'Nested', '#9b59b6', joinable=True)

# 3. Overlap peak (critical pair)
draw_peak_join(axes[2], 'Overlap Peak (Critical Pair)',
               'σ(l₁)', 'σ(r₁)', 'σ(r₂)', 'w',
               'Overlap', '#e67e22', joinable=True)

plt.tight_layout()
plt.savefig('peak_classification.png', dpi=150, bbox_inches='tight',
            facecolor='white')
print("Saved: peak_classification.png")
