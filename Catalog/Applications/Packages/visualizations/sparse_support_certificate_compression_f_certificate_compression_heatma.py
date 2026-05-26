#!/usr/bin/env python3
"""
Visualization: Compression Ratio Heatmap

Visualizes how the compression ratio (actual leaves / ambient bound)
varies with matroid parameters n (ground set size) and r (rank).

For uniform matroids, the ratio is always 1 (no compression).
For graphic matroids of paths, the ratio decreases with density,
showing that sparser structures yield better compression.

This makes tangible the core insight: support geometry controls
Lorentzian certification complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools
from math import comb


def graphic_matroid_leaf_count(n_vertices, edges):
    """Count independent (r-2)-sets for a graphic matroid."""
    m = len(edges)
    
    def is_forest(idxs):
        p = list(range(n_vertices))
        def find(x):
            while p[x] != x: p[x] = p[p[x]]; x = p[x]
            return x
        for i in idxs:
            u, v = edges[i]
            a, b = find(u), find(v)
            if a == b: return False
            p[a] = b
        return True
    
    def n_comp(idxs):
        p = list(range(n_vertices))
        def find(x):
            while p[x] != x: p[x] = p[p[x]]; x = p[x]
            return x
        for i in idxs:
            u, v = edges[i]
            p[find(u)] = find(v)
        return len(set(find(i) for i in range(n_vertices)))
    
    nc = n_comp(range(m))
    r = n_vertices - nc
    
    if r < 2:
        return 1, 1, r, m
    
    ambient = comb(m, r - 2)
    compressed = sum(1 for S in itertools.combinations(range(m), r - 2)
                     if is_forest(S))
    return compressed, ambient, r, m


# Data for the heatmap: varying number of vertices and edge density
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Panel 1: Compression ratios for graph families
families = {
    'Path': lambda nv: [(i, i+1) for i in range(nv-1)],
    'Cycle': lambda nv: [(i, (i+1) % nv) for i in range(nv)],
    'Complete': lambda nv: [(i,j) for i in range(nv) for j in range(i+1, nv)],
}

nv_range = range(4, 9)
ax = axes[0]
for fname, fgen in families.items():
    ratios = []
    ns = []
    for nv in nv_range:
        edges = fgen(nv)
        comp, amb, r, m = graphic_matroid_leaf_count(nv, edges)
        if amb > 0:
            ratios.append(comp / amb)
            ns.append(nv)
    ax.plot(ns, ratios, 'o-', label=fname, linewidth=2, markersize=8)

ax.set_xlabel('Number of vertices', fontsize=12)
ax.set_ylabel('Compression ratio (actual / ambient)', fontsize=12)
ax.set_title('Certificate Compression by Graph Family', fontsize=14)
ax.legend(fontsize=11)
ax.set_ylim(0, 1.05)
ax.grid(True, alpha=0.3)

# Panel 2: Leaf count comparison
ax2 = axes[1]
nv_range2 = range(4, 8)
bar_width = 0.25
x = np.arange(len(list(nv_range2)))

for idx, (fname, fgen) in enumerate(families.items()):
    leaf_counts = []
    for nv in nv_range2:
        edges = fgen(nv)
        comp, amb, r, m = graphic_matroid_leaf_count(nv, edges)
        leaf_counts.append(comp)
    ax2.bar(x + idx * bar_width, leaf_counts, bar_width, label=fname, alpha=0.8)

ax2.set_xlabel('Number of vertices', fontsize=12)
ax2.set_ylabel('Nonzero quadratic leaves', fontsize=12)
ax2.set_title('Leaf Count by Graph Family', fontsize=14)
ax2.set_xticks(x + bar_width)
ax2.set_xticklabels([str(nv) for nv in nv_range2])
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved compression_heatmap.png")
