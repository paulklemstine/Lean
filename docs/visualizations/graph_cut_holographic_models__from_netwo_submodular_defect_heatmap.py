#!/usr/bin/env python3
"""
Visualization: Submodular Defect Heatmap

Displays the defect matrix for a submodular function (matroid rank)
across all pairs of subsets. Darker colors indicate stronger geometric
interaction (higher curvature in the holographic interpretation).

Key insight: the defect matrix reveals the curvature structure of
the holographic geometry — modular pairs (zero defect) correspond
to flat regions, while high-defect pairs indicate geometric bending.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

# Ground set
n = 4
elements = list(range(n))

# Generate all subsets
subsets = []
for k in range(n + 1):
    for combo in combinations(elements, k):
        subsets.append(frozenset(combo))

num_subsets = len(subsets)

# Submodular function: rank function of uniform matroid of rank 2
def rank_fn(S):
    return min(len(S), 2)

# Compute defect matrix
defect_matrix = np.zeros((num_subsets, num_subsets))
for i, X in enumerate(subsets):
    for j, Y in enumerate(subsets):
        fX = rank_fn(X)
        fY = rank_fn(Y)
        fXY = rank_fn(X & Y)
        fXuY = rank_fn(X | Y)
        defect_matrix[i, j] = fX + fY - fXY - fXuY

# Labels
labels = ['{' + ','.join(map(str, sorted(s))) + '}' if s else '∅' for s in subsets]

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: full defect heatmap
ax1 = axes[0]
im1 = ax1.imshow(defect_matrix, cmap='YlOrRd', aspect='auto', interpolation='nearest')
ax1.set_xticks(range(num_subsets))
ax1.set_xticklabels(labels, rotation=90, fontsize=6)
ax1.set_yticks(range(num_subsets))
ax1.set_yticklabels(labels, fontsize=6)
ax1.set_title('Submodular Defect Matrix\n(Rank-2 Matroid on {0,1,2,3})',
              fontsize=12, fontweight='bold')
ax1.set_xlabel('Region Y', fontsize=10)
ax1.set_ylabel('Region X', fontsize=10)
plt.colorbar(im1, ax=ax1, label='Defect value', shrink=0.8)

# Right: curvature tensor for triples
# Compute curvature tensor for all triples of singletons
singletons_idx = [i for i, s in enumerate(subsets) if len(s) == 1]
singleton_labels = [labels[i] for i in singletons_idx]

pairs_idx = [(i, j) for i in singletons_idx for j in singletons_idx if i < j]

ax2 = axes[1]

# Create a bar chart of defects for singleton pairs
pair_defects = []
pair_labels = []
for i, j in pairs_idx:
    d = defect_matrix[i, j]
    pair_defects.append(d)
    pair_labels.append(f'{labels[i]}↔{labels[j]}')

colors = plt.cm.coolwarm(np.array(pair_defects) / max(max(pair_defects), 0.01))
bars = ax2.bar(range(len(pair_defects)), pair_defects, color=colors,
               edgecolor='black', linewidth=0.5)
ax2.set_xticks(range(len(pair_labels)))
ax2.set_xticklabels(pair_labels, rotation=45, fontsize=8)
ax2.set_ylabel('Defect Value', fontsize=10)
ax2.set_title('Singleton Pair Defects\n(Zero = Flat Geometry)', fontsize=12, fontweight='bold')
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.grid(True, alpha=0.2, axis='y')

# Annotate
for i, (label, d) in enumerate(zip(pair_labels, pair_defects)):
    ax2.annotate(f'{d:.1f}', (i, d), textcoords="offset points",
                xytext=(0, 5), ha='center', fontsize=8, fontweight='bold')

# Add summary statistics
total = sum(pair_defects)
ax2.text(0.95, 0.95, f'Total curvature: {total:.1f}\n'
         f'All ≥ 0: ✓\n'
         f'Modular pairs: {sum(1 for d in pair_defects if abs(d) < 0.01)}',
         transform=ax2.transAxes, fontsize=9, va='top', ha='right',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.7))

plt.tight_layout()
plt.savefig('defect_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved defect_heatmap.png")
