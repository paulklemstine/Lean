"""
Visualization: Recursion Tree Pruning by Support Geometry

Illustrates how support geometry prunes the Lorentzian recognition
recursion tree. Shows a comparison between naive (all branches) and
support-compressed (surviving branches only) for a small example.

The key insight: branches die when the accumulated derivative index
cannot extend to any support element (basis). For matroids, this is
exactly the independence test.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import comb
from itertools import combinations


def draw_tree_comparison():
    """Draw a comparison of naive vs pruned recursion trees for a small example."""

    fig, axes = plt.subplots(1, 2, figsize=(14, 8))

    # Example: polynomial with support = {{0,1,2}, {0,1,3}, {1,2,3}} on 4 variables
    # This is like a rank-3 matroid on ground set {0,1,2,3}
    # degree = 3, so we need derivatives of order 1 (degree 3 - 2 = 1)
    # surviving 1-sets: {0}, {1}, {2}, {3} — all appear in some basis
    # ambient 1-sets: {0}, {1}, {2}, {3} — same (n=4, k=1)

    # For a more interesting example, consider rank-4 on 6 elements
    # with bases = {{0,1,2,3}, {0,1,2,4}, {0,1,3,4}, {0,2,3,4}, {1,2,3,4}}
    # derivative order = 2
    # ambient 2-subsets: C(6,2) = 15
    # surviving 2-subsets: those contained in some basis

    bases = [{0,1,2,3}, {0,1,2,4}, {0,1,3,4}, {0,2,3,4}, {1,2,3,4}]
    n, r = 6, 4
    k = r - 2  # = 2

    all_subsets = list(combinations(range(n), k))
    surviving = [s for s in all_subsets if any(set(s) <= b for b in bases)]
    dead = [s for s in all_subsets if not any(set(s) <= b for b in bases)]

    # Left panel: Naive tree (all branches)
    ax = axes[0]
    ax.set_title(f'Naive Recursion Tree\n({len(all_subsets)} branches, all explored)',
                 fontsize=13, fontweight='bold')
    ax.set_xlim(-0.5, len(all_subsets) - 0.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_axis_off()

    # Root
    ax.plot(len(all_subsets)/2 - 0.5, 2.2, 'ko', markersize=15)
    ax.text(len(all_subsets)/2 - 0.5, 2.4, f'$B_M(x)$, deg={r}',
            ha='center', fontsize=11, fontweight='bold')

    # Leaves
    for i, s in enumerate(all_subsets):
        is_surv = s in surviving
        color = '#2ecc71' if is_surv else '#e74c3c'
        ax.plot(i, 0, 'o', markersize=10, color=color, zorder=5)
        ax.plot([len(all_subsets)/2 - 0.5, i], [2.2, 0.2], '-',
                color='gray', alpha=0.3, linewidth=0.8)
        label = '{' + ','.join(map(str, s)) + '}'
        ax.text(i, -0.3, label, ha='center', fontsize=6, rotation=45)

    ax.text(len(all_subsets)/2 - 0.5, 1.2,
            f'All C({n},{k}) = {len(all_subsets)} derivative branches',
            ha='center', fontsize=10, style='italic', color='gray')

    # Right panel: Pruned tree (only surviving)
    ax = axes[1]
    ax.set_title(f'Support-Compressed Tree\n({len(surviving)} surviving, {len(dead)} pruned)',
                 fontsize=13, fontweight='bold')
    ax.set_xlim(-0.5, len(all_subsets) - 0.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_axis_off()

    # Root
    ax.plot(len(all_subsets)/2 - 0.5, 2.2, 'ko', markersize=15)
    ax.text(len(all_subsets)/2 - 0.5, 2.4, f'$B_M(x)$, deg={r}',
            ha='center', fontsize=11, fontweight='bold')

    # Only surviving leaves
    positions = np.linspace(1, len(all_subsets) - 2, len(surviving))
    for i, (pos, s) in enumerate(zip(positions, surviving)):
        ax.plot(pos, 0, 'o', markersize=12, color='#2ecc71', zorder=5)
        ax.plot([len(all_subsets)/2 - 0.5, pos], [2.2, 0.2], '-',
                color='#2ecc71', alpha=0.6, linewidth=1.5)
        label = '{' + ','.join(map(str, s)) + '}'
        ax.text(pos, -0.3, label, ha='center', fontsize=7, rotation=45)

    # Dead branches (faded X marks)
    dead_positions = np.linspace(0.5, len(all_subsets) - 1.5, len(dead))
    for i, (pos, s) in enumerate(zip(dead_positions, dead)):
        ax.plot(pos, 0.8, 'x', markersize=8, color='#e74c3c', alpha=0.4,
                markeredgewidth=2, zorder=5)

    ax.text(len(all_subsets)/2 - 0.5, 1.2,
            f'Only {len(surviving)} independent {k}-sets survive',
            ha='center', fontsize=10, style='italic', color='#27ae60')

    # Legend
    legend_elements = [
        mpatches.Patch(color='#2ecc71', label='Surviving (independent set)'),
        mpatches.Patch(color='#e74c3c', label='Pruned (dependent set)'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=2,
               fontsize=11, bbox_to_anchor=(0.5, -0.02))

    plt.suptitle('Lorentzian Recognition: Support Compression Prunes the Recursion Tree',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_recursion_tree.png', dpi=150, bbox_inches='tight')
    print("Saved viz_recursion_tree.png")


draw_tree_comparison()
