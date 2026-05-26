#!/usr/bin/env python3
"""
Visualization: Graph Pair Comparison

Shows the two graph types (single cycle vs two cycles) side by side,
with their filtration events and the resulting TMS.

SELF-CONTAINED: does not import any local modules.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def draw_cycle(ax, n, center, radius, color, label, start_angle=0):
    """Draw a cycle graph on the given axes."""
    angles = np.linspace(start_angle, start_angle + 2*np.pi, n, endpoint=False)
    xs = center[0] + radius * np.cos(angles)
    ys = center[1] + radius * np.sin(angles)

    # Draw edges
    for i in range(n):
        j = (i + 1) % n
        ax.plot([xs[i], xs[j]], [ys[i], ys[j]], color=color, linewidth=2, alpha=0.7)

    # Draw vertices
    ax.scatter(xs, ys, c=color, s=80, zorder=5, edgecolors='black', linewidth=1)

    # Label
    ax.text(center[0], center[1], label, ha='center', va='center',
            fontsize=9, fontweight='bold', color=color)


fig, axes = plt.subplots(2, 3, figsize=(15, 10))

for col, n in enumerate([3, 4, 5]):
    # Top row: graph diagrams
    ax = axes[0, col]
    ax.set_aspect('equal')
    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-2.5, 2.5)

    # Single cycle C_{2n}
    draw_cycle(ax, 2*n, (-1.8, 0), 1.5, '#2196F3', f'C$_{{{2*n}}}$')

    # Two cycles 2×C_n
    draw_cycle(ax, n, (2.2, 0.8), 0.7, '#F44336', f'C$_{{{n}}}$')
    draw_cycle(ax, n, (2.2, -0.8), 0.7, '#F44336', f'C$_{{{n}}}$')

    ax.set_title(f'n = {n}: C$_{{{2*n}}}$ vs 2×C$_{{{n}}}$', fontsize=13, fontweight='bold')
    ax.axis('off')

    # Bottom row: TMS comparison
    ax = axes[1, col]
    single_merges = 2*n - 1
    single_cycles = 1
    double_merges = 2*(n-1)
    double_cycles = 2

    categories = ['Merge\nevents', 'Cycle-death\nevents', 'β₁']
    single_vals = [single_merges, single_cycles, single_cycles]
    double_vals = [double_merges, double_cycles, double_cycles]

    x = np.arange(len(categories))
    width = 0.35

    bars1 = ax.bar(x - width/2, single_vals, width, label=f'C$_{{{2*n}}}$',
                   color='#2196F3', alpha=0.8)
    bars2 = ax.bar(x + width/2, double_vals, width, label=f'2×C$_{{{n}}}$',
                   color='#F44336', alpha=0.8)

    # Add value labels on bars
    for bar in bars1:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.1,
                f'{int(height)}', ha='center', va='bottom', fontsize=10, fontweight='bold')
    for bar in bars2:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.1,
                f'{int(height)}', ha='center', va='bottom', fontsize=10, fontweight='bold')

    ax.set_xticks(x)
    ax.set_xticklabels(categories, fontsize=10)
    ax.set_ylabel('Count', fontsize=11)
    ax.set_title(f'TMS Event Comparison (n={n})', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3, axis='y')
    ax.set_ylim(0, max(single_merges, double_merges) + 1.5)

plt.suptitle('WL1-Equivalent Graphs Separated by Tropical Morse Spectrum',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('graph_comparison.png', dpi=150, bbox_inches='tight')
print("Saved graph_comparison.png")
