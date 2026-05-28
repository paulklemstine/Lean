"""
Visualization: Recursion Tree Pruning

Visualizes the derivative recursion tree for a small matroid, highlighting
which branches survive (are nonzero) and which are pruned. Surviving
branches correspond to independent sets of the matroid.

Shows a tree diagram for the cycle graph C_4 matroid, with rank 3
and 4 edges, illustrating the bijection between surviving leaves
and independent 1-sets (edges contained in some spanning tree).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from itertools import combinations


def is_spanning_tree(n_vertices, edges):
    if len(edges) != n_vertices - 1:
        return False
    parent = list(range(n_vertices))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    for u, v in edges:
        ru, rv = find(u), find(v)
        if ru == rv:
            return False
        parent[ru] = rv
    return all(find(i) == find(0) for i in range(n_vertices))


# Set up the cycle graph C_5
nv = 5
edge_labels = [f'e{i}' for i in range(nv)]
edges = [(i, (i + 1) % nv) for i in range(nv)]
ne = len(edges)
r = nv - 1  # rank = 4
k = r - 2   # k = 2

# Find bases (spanning trees)
bases = []
for combo in combinations(range(ne), r):
    edge_set = [edges[i] for i in combo]
    if is_spanning_tree(nv, edge_set):
        bases.append(set(combo))

# Find which k-element subsets are independent
all_k_sets = list(combinations(range(ne), k))
indep_sets = []
non_indep_sets = []
for combo in all_k_sets:
    s = set(combo)
    if any(s <= b for b in bases):
        indep_sets.append(combo)
    else:
        non_indep_sets.append(combo)

# Create visualization
fig, ax = plt.subplots(figsize=(14, 8))
ax.set_xlim(-1, 15)
ax.set_ylim(-1, 9)
ax.axis('off')

# Title
ax.text(7, 8.5, f'Derivative Recursion Tree for Cycle Graph C₅',
        ha='center', va='center', fontsize=16, fontweight='bold')
ax.text(7, 7.8, f'Rank r = {r}, ground set n = {ne}, derivative order k = {k}',
        ha='center', va='center', fontsize=11, color='gray')
ax.text(7, 7.2, f'Edges: ' + ', '.join(f'e{i}=({edges[i][0]},{edges[i][1]})'
        for i in range(ne)),
        ha='center', va='center', fontsize=9, color='gray')

# Root node
root_x, root_y = 7, 6.2
circle = plt.Circle((root_x, root_y), 0.4, fill=True,
                     facecolor='#E3F2FD', edgecolor='#1565C0', linewidth=2)
ax.add_patch(circle)
ax.text(root_x, root_y, 'B_M', ha='center', va='center',
        fontsize=11, fontweight='bold', color='#1565C0')

# Layout leaves
n_total = len(all_k_sets)
leaf_width = 13.0
leaf_start = 0.5
leaf_spacing = leaf_width / (n_total - 1) if n_total > 1 else 0

leaf_y = 2.5
label_y = 1.5

for idx, combo in enumerate(all_k_sets):
    x = leaf_start + idx * leaf_spacing
    s = set(combo)
    is_indep = any(s <= b for b in bases)

    # Draw connection
    mid_y = 4.3
    color = '#4CAF50' if is_indep else '#F44336'
    alpha = 0.8 if is_indep else 0.3
    ax.plot([root_x, x], [root_y - 0.4, leaf_y + 0.35],
            color=color, alpha=alpha, linewidth=1.5 if is_indep else 0.8)

    # Draw leaf node
    if is_indep:
        rect = patches.FancyBboxPatch((x - 0.45, leaf_y - 0.3), 0.9, 0.6,
                                       boxstyle="round,pad=0.1",
                                       facecolor='#C8E6C9', edgecolor='#2E7D32',
                                       linewidth=2)
        ax.add_patch(rect)
        ax.text(x, leaf_y, '✓', ha='center', va='center',
                fontsize=14, color='#2E7D32', fontweight='bold')
    else:
        rect = patches.FancyBboxPatch((x - 0.45, leaf_y - 0.3), 0.9, 0.6,
                                       boxstyle="round,pad=0.1",
                                       facecolor='#FFCDD2', edgecolor='#C62828',
                                       linewidth=1, alpha=0.5)
        ax.add_patch(rect)
        ax.text(x, leaf_y, '0', ha='center', va='center',
                fontsize=12, color='#C62828', alpha=0.6)

    # Label
    label = '{' + ','.join(f'e{i}' for i in combo) + '}'
    ax.text(x, label_y, label, ha='center', va='center',
            fontsize=7, rotation=45 if n_total > 8 else 0)

# Legend and summary
ax.text(0.5, 0.5, f'Surviving leaves (independent sets): {len(indep_sets)}',
        fontsize=11, color='#2E7D32', fontweight='bold')
ax.text(0.5, 0.0, f'Pruned branches (non-independent): {len(non_indep_sets)}',
        fontsize=11, color='#C62828')
ax.text(0.5, -0.5, f'Compression ratio: {len(indep_sets)}/{len(all_k_sets)} '
        f'= {len(indep_sets)/len(all_k_sets):.3f}',
        fontsize=11, color='#1565C0', fontweight='bold')

# Spanning trees
ax.text(9, 0.5, f'Spanning trees (bases): {len(bases)}',
        fontsize=10, color='gray')
for bidx, b in enumerate(bases[:5]):
    tree_str = '{' + ','.join(f'e{i}' for i in sorted(b)) + '}'
    ax.text(9, 0.0 - bidx * 0.4, f'  {tree_str}', fontsize=8, color='gray')

plt.tight_layout()
plt.savefig('recursion_tree.png', dpi=150, bbox_inches='tight')
print("Saved recursion_tree.png")
