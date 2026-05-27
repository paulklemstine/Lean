#!/usr/bin/env python3
"""
Visualization: Exchange Defect Heatmap for K₄ Graphical Matroid

Visualizes the exchange defect matrix for all pairs of spanning trees
of K₄ under a random valuation. The heatmap reveals the structure of
exchange interactions between bases, with the minimum exchange defect
highlighted. This visualization makes tangible the key concept that
spectral gaps are determined by the combinatorial exchange structure.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def graphical_matroid_bases(n_vertices, edges):
    rank = n_vertices - 1
    bases = []
    for subset in combinations(range(len(edges)), rank):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True
        ok = True
        for idx in subset:
            u, v = edges[idx]
            if not union(u, v):
                ok = False
                break
        if ok and len(set(find(i) for i in range(n_vertices))) == 1:
            bases.append(frozenset(subset))
    return bases


# Build K₄
edges = list(combinations(range(4), 2))
bases = graphical_matroid_bases(4, edges)
bases_set = set(bases)
n = len(bases)

# Random valuation
import random
rng = random.Random(42)
weights = {B: rng.randint(-5, 5) for B in bases}
w = lambda B: weights.get(B, 0)

# Compute minimum exchange defect for each pair of bases
defect_matrix = np.full((n, n), np.nan)
for idx1, B1 in enumerate(bases):
    for idx2, B2 in enumerate(bases):
        diff1 = B1 - B2
        diff2 = B2 - B1
        if not diff1 or not diff2:
            defect_matrix[idx1, idx2] = 0
            continue
        min_d = float('inf')
        for i in diff1:
            for j in diff2:
                B1n = (B1 - {i}) | {j}
                B2n = (B2 - {j}) | {i}
                if B1n in bases_set and B2n in bases_set:
                    d = w(B1) + w(B2) - w(B1n) - w(B2n)
                    min_d = min(min_d, d)
        defect_matrix[idx1, idx2] = min_d if min_d != float('inf') else np.nan

# Create labels
labels = [str(sorted(B)) for B in bases]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap of defect matrix
im1 = ax1.imshow(defect_matrix, cmap='RdYlBu_r', aspect='equal')
ax1.set_xticks(range(n))
ax1.set_yticks(range(n))
ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=7)
ax1.set_yticklabels(labels, fontsize=7)
ax1.set_title('Exchange Defect Matrix\n(K₄ Graphical Matroid, Random Valuation)', fontsize=13)
ax1.set_xlabel('Basis B₂')
ax1.set_ylabel('Basis B₁')
plt.colorbar(im1, ax=ax1, label='Min Exchange Defect δ(B₁, B₂)')

# Histogram of defect values
valid_defects = defect_matrix[~np.isnan(defect_matrix)].flatten()
ax2.hist(valid_defects, bins=20, color='steelblue', edgecolor='black', alpha=0.8)
ax2.axvline(x=np.nanmin(valid_defects[valid_defects != 0]) if np.any(valid_defects != 0) else 0,
            color='red', linestyle='--', linewidth=2, label='Min nonzero defect')
ax2.set_xlabel('Exchange Defect Value', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Distribution of Exchange Defects\n(Tropical Spectral Gap = Min Defect)', fontsize=13)
ax2.legend(fontsize=11)

plt.tight_layout()
plt.savefig('exchange_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved exchange_heatmap.png")
