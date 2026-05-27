#!/usr/bin/env python3
"""
Visualization: Leaf Count Growth Curves
=========================================

Compares the growth of quadratic leaf counts for different matroid families
as n increases. Shows that sparse matroids have dramatically fewer leaves
than the ambient worst-case bound C(n, r-2).
"""

import matplotlib.pyplot as plt
import numpy as np
from math import comb
from itertools import combinations


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


def count_independent_k_sets(bases, n, k):
    """Count independent k-sets."""
    if k == 0:
        return 1
    return sum(1 for S in combinations(range(n), k)
               if any(frozenset(S) <= B for B in bases))


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Absolute leaf counts
ax1 = axes[0]

vertex_range = list(range(4, 10))

# Uniform matroid
uniform_leaves = []
for n_v in vertex_range:
    r = n_v - 1
    # Uniform matroid on edges of complete graph
    n_e = n_v * (n_v - 1) // 2
    uniform_leaves.append(comb(n_e, r - 2))

# Path graph
path_leaves = []
for n_v in vertex_range:
    edges = [(i, i+1) for i in range(n_v - 1)]
    n_e = len(edges)
    rank = n_v - 1
    bases = graphic_matroid_bases(edges, n_v)
    if bases and rank >= 2:
        path_leaves.append(count_independent_k_sets(bases, n_e, rank - 2))
    else:
        path_leaves.append(1)

# Cycle graph
cycle_leaves = []
for n_v in vertex_range:
    edges = [(i, (i+1) % n_v) for i in range(n_v)]
    n_e = len(edges)
    rank = n_v - 1
    bases = graphic_matroid_bases(edges, n_v)
    if bases and rank >= 2:
        cycle_leaves.append(count_independent_k_sets(bases, n_e, rank - 2))
    else:
        cycle_leaves.append(1)

# Complete graph (graphic matroid)
complete_leaves = []
for n_v in vertex_range:
    edges = [(i,j) for i in range(n_v) for j in range(i+1, n_v)]
    n_e = len(edges)
    rank = n_v - 1
    bases = graphic_matroid_bases(edges, n_v)
    if bases and rank >= 2:
        complete_leaves.append(count_independent_k_sets(bases, n_e, rank - 2))
    else:
        complete_leaves.append(1)

ax1.plot(vertex_range, uniform_leaves, 'rs-', label='Ambient bound C(m, r-2)', linewidth=2, markersize=6)
ax1.plot(vertex_range, complete_leaves, 'b^-', label='Complete graph K_n', linewidth=2, markersize=6)
ax1.plot(vertex_range, cycle_leaves, 'go-', label='Cycle graph C_n', linewidth=2, markersize=6)
ax1.plot(vertex_range, path_leaves, 'mD-', label='Path graph P_n', linewidth=2, markersize=6)

ax1.set_xlabel('Number of vertices', fontsize=12)
ax1.set_ylabel('Quadratic leaf count', fontsize=12)
ax1.set_title('Leaf Count Growth\n(graphic matroids, rank = n-1)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Compression ratio vs graph density
ax2 = axes[1]

densities = []
ratios = []
labels = []

for n_v in range(4, 9):
    rank = n_v - 1

    # Various edge densities
    full_edges = [(i,j) for i in range(n_v) for j in range(i+1, n_v)]
    max_edges = len(full_edges)

    for n_extra in range(0, max_edges - rank + 1):
        n_e = rank + n_extra  # start from tree (rank edges) up to complete
        if n_e > max_edges:
            break

        # Take first n_e edges
        edges = full_edges[:n_e]
        bases = graphic_matroid_bases(edges, n_v)

        if bases and rank >= 2:
            actual = count_independent_k_sets(bases, n_e, rank - 2)
            ambient = comb(n_e, rank - 2)
            if ambient > 0:
                density = n_e / max_edges
                ratio = actual / ambient
                densities.append(density)
                ratios.append(ratio)

ax2.scatter(densities, ratios, c='steelblue', alpha=0.6, edgecolors='navy', s=30)

# Add trend
if densities:
    z = np.polyfit(densities, ratios, 2)
    p = np.poly1d(z)
    xs = np.linspace(min(densities), max(densities), 100)
    ax2.plot(xs, np.clip(p(xs), 0, 1), 'r-', linewidth=2, label='Trend')

ax2.set_xlabel('Edge density (edges / max possible)', fontsize=12)
ax2.set_ylabel('Compression ratio', fontsize=12)
ax2.set_title('Compression vs Graph Density\n(various graphs with 4-8 vertices)', fontsize=13, fontweight='bold')
ax2.set_ylim(-0.05, 1.1)
ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
ax2.grid(True, alpha=0.3)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('leaf_growth.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved leaf_growth.png")
