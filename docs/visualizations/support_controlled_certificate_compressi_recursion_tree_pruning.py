#!/usr/bin/env python3
"""
Visualization: Recursion Tree Pruning
=======================================

Visualizes how the Lorentzian recognition recursion tree collapses when
the polynomial has matroid basis support. Dead branches (non-independent
subsets) are pruned, leaving only the independent-set skeleton.

Shows the tree for a small example: graphic matroid of K4 with rank 3
on 6 edges.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from math import comb


def graphic_matroid_bases(edges, n_v):
    """Compute spanning trees."""
    n_e = len(edges)
    rank = n_v - 1
    bases = []
    for subset in combinations(range(n_e), rank):
        parent = list(range(n_v))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py: return False
            parent[px] = py
            return True
        ok = all(union(*edges[i]) for i in subset)
        if ok and len(set(find(v) for v in range(n_v))) == 1:
            bases.append(frozenset(subset))
    return bases


# Setup: K4 graphic matroid
edges_k4 = [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]
n_v, n_e = 4, 6
bases = graphic_matroid_bases(edges_k4, n_v)
rank = 3  # n_v - 1

# All 1-subsets (r-2 = 1)
all_singletons = [frozenset({i}) for i in range(n_e)]
indep_singletons = [S for S in all_singletons
                    if any(S <= B for B in bases)]

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# Panel 1: Full recursion tree (all branches)
ax1 = axes[0]
ax1.set_xlim(-1, n_e)
ax1.set_ylim(-0.5, 2.5)
ax1.set_title(f'Naive Recursion Tree\n(all {comb(n_e, rank-2)} branches explored)',
              fontsize=13, fontweight='bold')

# Root
root_x, root_y = n_e/2 - 0.5, 2
ax1.plot(root_x, root_y, 'ko', markersize=12)
ax1.text(root_x, root_y + 0.15, 'B_M(x)', ha='center', fontsize=10, fontweight='bold')

# Leaf level
for i in range(n_e):
    leaf_x = i
    leaf_y = 0.5
    color = 'green' if frozenset({i}) in indep_singletons else 'red'
    alpha = 0.9 if color == 'green' else 0.4
    ax1.plot([root_x, leaf_x], [root_y - 0.1, leaf_y + 0.1],
             color=color, alpha=alpha, linewidth=2)
    ax1.plot(leaf_x, leaf_y, 'o', color=color, markersize=10, alpha=alpha)
    edge_label = f'e{i}={edges_k4[i]}'
    ax1.text(leaf_x, leaf_y - 0.2, edge_label, ha='center', fontsize=7,
             color=color, alpha=alpha)

    status = '✓' if color == 'green' else '✗'
    ax1.text(leaf_x, leaf_y + 0.15, status, ha='center', fontsize=12,
             color=color, fontweight='bold')

ax1.set_axis_off()

# Legend
alive_patch = mpatches.Patch(color='green', label=f'Alive ({len(indep_singletons)} leaves)')
dead_patch = mpatches.Patch(color='red', alpha=0.4,
                           label=f'Dead ({n_e - len(indep_singletons)} leaves)')
ax1.legend(handles=[alive_patch, dead_patch], loc='lower left', fontsize=10)

# Panel 2: Pruned tree (only surviving branches)
ax2 = axes[1]
ax2.set_xlim(-1, len(indep_singletons))
ax2.set_ylim(-0.5, 2.5)
ax2.set_title(f'Compressed Tree\n(only {len(indep_singletons)} independent branches)',
              fontsize=13, fontweight='bold')

# Root
root_x2 = len(indep_singletons)/2 - 0.5
ax2.plot(root_x2, root_y, 'ko', markersize=12)
ax2.text(root_x2, root_y + 0.15, 'B_M(x)', ha='center', fontsize=10, fontweight='bold')

# Surviving leaves
for idx, S in enumerate(indep_singletons):
    i = min(S)
    leaf_x = idx
    leaf_y = 0.5
    ax2.plot([root_x2, leaf_x], [root_y - 0.1, leaf_y + 0.1],
             color='green', linewidth=2.5)
    ax2.plot(leaf_x, leaf_y, 'o', color='green', markersize=12)
    edge_label = f'e{i}={edges_k4[i]}'
    ax2.text(leaf_x, leaf_y - 0.2, edge_label, ha='center', fontsize=8)

    # Show extending bases
    ext = [sorted(B) for B in bases if S <= B]
    ext_str = f'{len(ext)} bases'
    ax2.text(leaf_x, leaf_y - 0.4, ext_str, ha='center', fontsize=7,
             color='darkgreen', style='italic')

ax2.set_axis_off()

# Add compression statistics
stats_text = (
    f"K4 Graphic Matroid (6 edges, rank 3)\n"
    f"Ambient leaves: {comb(n_e, rank-2)}\n"
    f"Actual leaves: {len(indep_singletons)}\n"
    f"Compression: {len(indep_singletons)/comb(n_e, rank-2):.0%}"
)
fig.text(0.5, 0.02, stats_text, ha='center', fontsize=10,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout(rect=[0, 0.12, 1, 1])
plt.savefig('recursion_tree.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved recursion_tree.png")
