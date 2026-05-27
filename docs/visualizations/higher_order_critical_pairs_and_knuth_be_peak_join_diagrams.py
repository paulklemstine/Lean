#!/usr/bin/env python3
"""
Visualization: Peak/Join Diagrams for Higher-Order Critical Pairs

Visualizes the peak-and-join structure of critical pairs in rewrite systems.
Shows how local confluence works: every divergent peak must be joinable.

Uses matplotlib to create static diagrams.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_peak_join_diagram(ax, peak_label, left_label, right_label,
                           join_label=None, title="", joinable=True):
    """Draw a single peak/join diamond diagram."""
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Positions
    top = (0, 2.5)
    left = (-2, 0)
    right = (2, 0)
    bottom = (0, -2.5)

    # Draw arrows (peak)
    ax.annotate('', xy=left, xytext=top,
                arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))
    ax.annotate('', xy=right, xytext=top,
                arrowprops=dict(arrowstyle='->', color='#F44336', lw=2))

    # Draw join arrows if joinable
    if joinable and join_label:
        ax.annotate('', xy=bottom, xytext=left,
                    arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2,
                                   linestyle='dashed'))
        ax.annotate('', xy=bottom, xytext=right,
                    arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2,
                                   linestyle='dashed'))

    # Labels
    fontsize = 8
    bbox_props = dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                      edgecolor='gray', alpha=0.9)

    ax.text(top[0], top[1] + 0.3, peak_label, ha='center', va='bottom',
            fontsize=fontsize, fontweight='bold', bbox=bbox_props)
    ax.text(left[0] - 0.3, left[1], left_label, ha='right', va='center',
            fontsize=fontsize, bbox=bbox_props)
    ax.text(right[0] + 0.3, right[1], right_label, ha='left', va='center',
            fontsize=fontsize, bbox=bbox_props)

    if joinable and join_label:
        ax.text(bottom[0], bottom[1] - 0.3, join_label, ha='center',
                va='top', fontsize=fontsize, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#E8F5E9',
                         edgecolor='#4CAF50', alpha=0.9))

    # Status indicator
    if joinable:
        ax.text(0, -3.2, '✓ JOINABLE', ha='center', fontsize=10,
                color='#4CAF50', fontweight='bold')
    else:
        ax.text(0, -3.2, '✗ NOT JOINABLE', ha='center', fontsize=10,
                color='#F44336', fontweight='bold')

    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 6))
    fig.suptitle('Higher-Order Critical Pair Analysis: Peak/Join Diagrams',
                 fontsize=14, fontweight='bold', y=0.98)

    # Example 1: Identity elimination (joinable)
    draw_peak_join_diagram(
        axes[0],
        peak_label='id(id(x))',
        left_label='id(x)',
        right_label='id(x)',
        join_label='id(x)',
        title='Identity Elimination\n(Self-Overlap)',
        joinable=True
    )

    # Example 2: Composition laws (joinable)
    draw_peak_join_diagram(
        axes[1],
        peak_label='(∘ id)(f∘id)',
        left_label='f∘id',
        right_label='(∘ id)(f)',
        join_label='f',
        title='Composition with Identity\n(Cross-Rule Overlap)',
        joinable=True
    )

    # Example 3: Map fusion (non-joinable without compose axioms)
    draw_peak_join_diagram(
        axes[2],
        peak_label='map f (map g (map h xs))',
        left_label='map (f∘g) (map h xs)',
        right_label='map f (map (g∘h) xs)',
        join_label='map ((f∘g)∘h) xs',
        title='Map Fusion\n(Requires Associativity)',
        joinable=True
    )

    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig('peak_join_diagrams.png', dpi=150, bbox_inches='tight')
    print("Saved: peak_join_diagrams.png")


if __name__ == "__main__":
    main()
