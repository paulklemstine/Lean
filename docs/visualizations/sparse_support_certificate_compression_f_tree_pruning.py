"""
Visualization: Derivative Recursion Tree Pruning

This script visualizes how the derivative recursion tree for Lorentzian
recognition gets pruned when the polynomial has matroid basis support.
Surviving branches (independent sets) are highlighted; pruned branches
(non-independent sets) are shown as dead ends.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from itertools import combinations
from math import comb


def graphic_bases(edges, nv):
    ne = len(edges)
    rank = nv - 1
    bases = []
    for subset in combinations(range(ne), rank):
        adj = {v: set() for v in range(nv)}
        for idx in subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)
        if len(visited) == nv:
            bases.append(frozenset(subset))
    return bases


fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# Left panel: Schematic of derivative tree for K_4 graphic matroid
ax1 = axes[0]
ax1.set_xlim(-1, 7)
ax1.set_ylim(-0.5, 4.5)
ax1.set_aspect('equal')
ax1.axis('off')
ax1.set_title('Derivative Tree: K₄ Graphic Matroid\n(6 edges, rank 3)', fontsize=13)

# K_4 has edges e0,...,e5, rank 3, so we look at (3-2)=1-subsets
# All 1-subsets {e_i} are independent (contained in some spanning tree)
# So all 6 leaves survive

# Draw root
ax1.add_patch(plt.Circle((3, 4), 0.3, color='#1565C0', zorder=5))
ax1.text(3, 4, 'B(x)', ha='center', va='center', color='white', fontsize=9, fontweight='bold')

# Draw level 1: differentiate by each variable
positions = [(0.5, 2), (1.5, 2), (2.5, 2), (3.5, 2), (4.5, 2), (5.5, 2)]
edge_labels = ['e₀', 'e₁', 'e₂', 'e₃', 'e₄', 'e₅']

for i, (x, y) in enumerate(positions):
    # All survive for K_4
    color = '#4CAF50'  # green = surviving
    ax1.plot([3, x], [3.7, y + 0.3], '-', color=color, linewidth=2, alpha=0.7)
    ax1.add_patch(plt.Circle((x, y), 0.3, color=color, zorder=5))
    ax1.text(x, y, f'∂{edge_labels[i]}', ha='center', va='center',
             color='white', fontsize=8, fontweight='bold')
    ax1.text(x, y - 0.6, '✓ indep', ha='center', va='center',
             color=color, fontsize=8)

ax1.text(3, -0.2, 'All 6 leaves survive (ratio = 1.0)',
         ha='center', fontsize=11, style='italic')

# Right panel: A sparse graph where pruning occurs
ax2 = axes[1]
ax2.set_xlim(-1, 9)
ax2.set_ylim(-1, 5)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title('Derivative Tree: Path + Extra Edge\n(5 edges, rank 3)', fontsize=13)

# Graph: path 0-1-2-3 plus edge 1-3
# Edges: e0=(0,1), e1=(1,2), e2=(2,3), e3=(1,3)
# Total: 5 edges (add e4=(0,3))
# Actually let's use: 0-1, 1-2, 2-3, 0-2 (4 edges, rank 3)
# Spanning trees: {0,1,2}, {0,1,3}, {0,2,3}, {1,2,3} -> need to check
# Wait, with 4 vertices and edges (0,1),(1,2),(2,3),(0,2):
# rank = 3, need 3-edge spanning trees from 4 edges
# So leaves = 1-subsets of {0,1,2,3} that are independent
# All 1-subsets are independent (each edge is in some spanning tree)

# Let me use a better example: 5 vertices, specific edges
# K_4 minus an edge: 5 edges on 4 vertices
# edges: (0,1),(0,2),(0,3),(1,2),(1,3)  -- missing (2,3)
# rank = 3, spanning trees from 5 edges choosing 3
edges = [(0,1),(0,2),(0,3),(1,2),(1,3)]
nv = 4
bases = graphic_bases(edges, nv)

# r-2 = 1, so look at 1-subsets
# All {e_i} are independent
# Actually for r-2=1, it's trivial. Let me try rank 4

# Better: use 5 vertices, 7 edges, rank 4
# So r-2 = 2, look at 2-subsets
edges2 = [(0,1),(1,2),(2,3),(3,4),(0,4),(0,2),(2,4)]
nv2 = 5
bases2 = graphic_bases(edges2, nv2)
ne2 = len(edges2)
rank2 = nv2 - 1  # 4

# Count 2-subsets that are independent
all_pairs = list(combinations(range(ne2), 2))
independent_pairs = [frozenset(p) for p in all_pairs if any(frozenset(p) <= B for B in bases2)]
non_independent_pairs = [frozenset(p) for p in all_pairs if not any(frozenset(p) <= B for B in bases2)]

# Draw root
ax2.add_patch(plt.Circle((4, 4.2), 0.3, color='#1565C0', zorder=5))
ax2.text(4, 4.2, 'B(x)', ha='center', va='center', color='white', fontsize=9, fontweight='bold')

# Show some surviving and pruned leaves
n_show = min(10, len(all_pairs))
y_pos = 1.5
survived = 0
pruned = 0

for i, pair in enumerate(all_pairs[:15]):
    fs = frozenset(pair)
    is_indep = any(fs <= B for B in bases2)
    x = 0.5 + i * 0.55

    if x > 8.5:
        break

    if is_indep:
        color = '#4CAF50'
        survived += 1
        label = '✓'
    else:
        color = '#E53935'
        pruned += 1
        label = '✗'

    ax2.plot([4, x], [3.9, y_pos + 0.25], '-', color=color, linewidth=1, alpha=0.4)
    ax2.add_patch(plt.Circle((x, y_pos), 0.2, color=color, zorder=5, alpha=0.8))
    e1, e2 = sorted(pair)
    ax2.text(x, y_pos, label, ha='center', va='center', color='white',
             fontsize=7, fontweight='bold')
    ax2.text(x, y_pos - 0.45, f'{e1},{e2}', ha='center', fontsize=6, color='gray')

total_pairs = len(all_pairs)
total_indep = len(independent_pairs)
total_pruned = len(non_independent_pairs)

ax2.text(4, -0.5,
         f'{total_indep} survive / {total_pairs} total '
         f'(ratio = {total_indep/total_pairs:.3f})',
         ha='center', fontsize=11, style='italic')

# Legend
legend_elements = [
    patches.Patch(facecolor='#4CAF50', label=f'Surviving ({total_indep})'),
    patches.Patch(facecolor='#E53935', label=f'Pruned ({total_pruned})'),
]
ax2.legend(handles=legend_elements, loc='upper right', fontsize=10)

plt.tight_layout()
plt.savefig('derivative_tree_pruning.png', dpi=150, bbox_inches='tight')
print("Saved visualization to derivative_tree_pruning.png")
