"""
Visualization: Matroid Compression Landscape.

A scatter plot showing the relationship between structural parameters
(number of bases, ground set size, rank) and the compression ratio
across different matroid families. Each point represents a specific
matroid, colored by family type.

This visualization reveals the structural pattern: sparser matroids
achieve more compression.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def graphic_matroid_bases(n_vertices, edges):
    m = len(edges)
    def is_acyclic(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx == ry: return False
            parent[rx] = ry
            return True
        for idx in edge_indices:
            u, v = edges[idx]
            if not union(u, v): return False
        return True

    def count_components(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx != ry: parent[rx] = ry
        for idx in edge_indices:
            u, v = edges[idx]
            union(u, v)
        return len({find(i) for i in range(n_vertices)})

    full_comp = count_components(list(range(m)))
    rank = n_vertices - full_comp
    bases = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases, rank


def support_compressed_leaf_count(bases, n, k):
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        for B in bases:
            if fs <= B:
                count += 1
                break
    return count


fig, ax = plt.subplots(1, 1, figsize=(10, 7))

# Collect data points
data_points = []  # (num_bases, compression_ratio, family, label)

# Uniform matroids
for n in range(4, 9):
    for r in range(3, n):
        k = r - 2
        bases = {frozenset(B) for B in combinations(range(n), r)}
        nb = len(bases)
        amb = comb(n, k)
        comp = support_compressed_leaf_count(bases, n, k)
        ratio = comp / amb if amb > 0 else 1.0
        data_points.append((nb, ratio, 'Uniform', f'U_{{{r},{n}}}'))

# Graphic matroids (cycles)
for nv in range(4, 10):
    edges = [(i, (i + 1) % nv) for i in range(nv)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0: continue
    nb = len(bases)
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    ratio = comp / amb if amb > 0 else 1.0
    data_points.append((nb, ratio, 'Cycle', f'C_{nv}'))

# Graphic matroids (complete)
for nv in range(3, 8):
    edges = [(i, j) for i in range(nv) for j in range(i + 1, nv)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0: continue
    nb = len(bases)
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    ratio = comp / amb if amb > 0 else 1.0
    data_points.append((nb, ratio, 'Complete', f'K_{nv}'))

# Graphic matroids (paths)
for nv in range(4, 10):
    edges = [(i, i + 1) for i in range(nv - 1)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0: continue
    nb = len(bases)
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    ratio = comp / amb if amb > 0 else 1.0
    data_points.append((nb, ratio, 'Path', f'P_{nv}'))

# Plot by family
colors = {'Uniform': '#e74c3c', 'Cycle': '#3498db', 'Complete': '#2ecc71', 'Path': '#9b59b6'}
markers = {'Uniform': 'o', 'Cycle': 's', 'Complete': 'D', 'Path': '^'}

for family in ['Uniform', 'Cycle', 'Complete', 'Path']:
    pts = [(nb, r, label) for nb, r, f, label in data_points if f == family]
    if pts:
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        labels = [p[2] for p in pts]
        ax.scatter(xs, ys, c=colors[family], marker=markers[family],
                  s=80, label=family, alpha=0.8, edgecolors='black', linewidth=0.5)
        # Label a few key points
        for x, y, label in pts:
            if y < 0.98 or family == 'Uniform':
                ax.annotate(label, (x, y), fontsize=7, alpha=0.7,
                           textcoords='offset points', xytext=(5, 5))

ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='No compression')
ax.set_xlabel('Number of Bases', fontsize=12)
ax.set_ylabel('Compression Ratio (actual / ambient)', fontsize=12)
ax.set_title('Matroid Compression Landscape\nEach point = one matroid, showing support compression efficiency',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=10, loc='lower left')
ax.grid(True, alpha=0.2)
ax.set_xscale('log')
ax.set_ylim(0.4, 1.05)

plt.tight_layout()
plt.savefig('viz_matroid_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_matroid_landscape.png")
