#!/usr/bin/env python3
"""
Visualization: Cross-Overlap Matrix Heatmap

Visualizes the pairwise intersection cardinalities between supports
as a heatmap. The block-diagonal structure reveals overlap classes:
supports in different classes have zero intersection, creating
a visible block structure.

This illustrates the componentwise factorization theorem:
the interaction matrix decomposes into independent blocks
corresponding to overlap classes.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def overlap_classes_sorted(family):
    """Find overlap classes and return indices sorted by class."""
    n = len(family)
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:
                union(i, j)

    groups = defaultdict(list)
    for i in range(n):
        groups[find(i)].append(i)

    # Sort so classes appear as contiguous blocks
    sorted_indices = []
    class_boundaries = []
    for cls in groups.values():
        class_boundaries.append(len(sorted_indices))
        sorted_indices.extend(cls)
    class_boundaries.append(len(sorted_indices))

    return sorted_indices, class_boundaries


def cross_overlap_matrix(family, order):
    """Compute cross-overlap matrix in given index order."""
    n = len(order)
    M = np.zeros((n, n), dtype=int)
    for a in range(n):
        for b in range(n):
            i, j = order[a], order[b]
            M[a][b] = len(family[i] & family[j])
    return M


# ─────────────────────────────────────────────────────────────────────
# Main visualization
# ─────────────────────────────────────────────────────────────────────

# A family with clear block structure
family = [
    frozenset({1, 2, 3, 4}),      # Block A
    frozenset({3, 4, 5, 6}),      # Block A
    frozenset({5, 6, 7}),         # Block A
    frozenset({10, 11, 12}),      # Block B
    frozenset({11, 12, 13, 14}),  # Block B
    frozenset({20, 21}),          # Block C (singleton class)
    frozenset({30, 31, 32}),      # Block D
    frozenset({31, 32, 33}),      # Block D
    frozenset({32, 33, 34, 35}),  # Block D
]

order, boundaries = overlap_classes_sorted(family)
M = cross_overlap_matrix(family, order)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: raw matrix (unsorted)
M_raw = cross_overlap_matrix(family, list(range(len(family))))
im1 = ax1.imshow(M_raw, cmap='YlOrRd', aspect='equal', interpolation='nearest')
ax1.set_title('Cross-Overlap Matrix (unsorted)', fontsize=13, fontweight='bold')
ax1.set_xlabel('Support index')
ax1.set_ylabel('Support index')
for i in range(len(family)):
    for j in range(len(family)):
        val = M_raw[i][j]
        color = 'white' if val > 2 else 'black'
        ax1.text(j, i, str(val), ha='center', va='center',
                fontsize=9, color=color, fontweight='bold')
plt.colorbar(im1, ax=ax1, label='|Fᵢ ∩ Fⱼ|', shrink=0.8)

# Right: sorted by overlap class (block-diagonal visible)
im2 = ax2.imshow(M, cmap='YlOrRd', aspect='equal', interpolation='nearest')
ax2.set_title('Cross-Overlap Matrix (sorted by overlap class)', fontsize=13,
              fontweight='bold')
ax2.set_xlabel('Support index (reordered)')
ax2.set_ylabel('Support index (reordered)')
for i in range(len(family)):
    for j in range(len(family)):
        val = M[i][j]
        color = 'white' if val > 2 else 'black'
        ax2.text(j, i, str(val), ha='center', va='center',
                fontsize=9, color=color, fontweight='bold')

# Draw class boundaries
for b in boundaries[1:-1]:
    ax2.axhline(y=b - 0.5, color='blue', linewidth=2, linestyle='--')
    ax2.axvline(x=b - 0.5, color='blue', linewidth=2, linestyle='--')

plt.colorbar(im2, ax=ax2, label='|Fᵢ ∩ Fⱼ|', shrink=0.8)

# Add class labels
class_names = ['A', 'B', 'C', 'D']
for ci in range(len(boundaries) - 1):
    mid = (boundaries[ci] + boundaries[ci + 1]) / 2 - 0.5
    ax2.text(-1.2, mid, f'Class {class_names[ci]}', ha='right', va='center',
             fontsize=10, fontweight='bold', color='blue')

fig.suptitle('Overlap Class Block Structure\n'
             'Sorting by overlap classes reveals independent interaction sectors',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig("viz_overlap_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_overlap_heatmap.png")
