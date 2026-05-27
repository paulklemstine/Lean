#!/usr/bin/env python3
"""
Visualization: Compression Ratio Heatmap
==========================================

Shows how the compression ratio (actual leaves / ambient leaves) varies
across different matroid parameters. For uniform matroids the ratio is always 1.
For graphic matroids of sparse graphs, the ratio drops dramatically.

This visualizes the core insight: support geometry compresses the
Lorentzian recognition recursion tree.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def graphic_matroid_bases(edges, n_v):
    """Compute bases (spanning trees) of a graphic matroid."""
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
    """Count independent k-sets in a basis family."""
    return sum(1 for S in combinations(range(n), k)
               if any(frozenset(S) <= B for B in bases))


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Uniform matroid - leaf count vs C(n, r-2)
ax1 = axes[0]
ns = list(range(4, 16))
for r in [3, 4, 5, 6]:
    leaf_counts = [comb(n, r-2) for n in ns if n >= r]
    valid_ns = [n for n in ns if n >= r]
    ax1.plot(valid_ns, leaf_counts, 'o-', label=f'r={r}', markersize=4)
ax1.set_xlabel('n (ground set size)')
ax1.set_ylabel('Leaf count = C(n, r-2)')
ax1.set_title('Uniform Matroid U_{r,n}\n(ratio always 1.0)')
ax1.legend()
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Path graphs - compression ratio
ax2 = axes[1]
path_ns = list(range(4, 12))
ratios = []
for n_v in path_ns:
    edges = [(i, i+1) for i in range(n_v - 1)]
    n_e = len(edges)
    rank = n_v - 1
    bases = graphic_matroid_bases(edges, n_v)
    if bases and rank >= 2:
        actual = count_independent_k_sets(bases, n_e, rank - 2)
        ambient = comb(n_e, rank - 2)
        ratios.append(actual / ambient if ambient > 0 else 1)
    else:
        ratios.append(1)

ax2.bar(path_ns, ratios, color='steelblue', alpha=0.7, edgecolor='navy')
ax2.set_xlabel('Number of vertices')
ax2.set_ylabel('Compression ratio')
ax2.set_title('Path Graph P_n\n(ratio = actual/ambient)')
ax2.set_ylim(0, 1.1)
ax2.grid(True, alpha=0.3, axis='y')
ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='No compression')
ax2.legend()

# Panel 3: Complete graph vs path - comparison
ax3 = axes[2]
vertex_counts = list(range(4, 9))
complete_ratios = []
path_ratios2 = []

for n_v in vertex_counts:
    # Complete graph
    edges_k = [(i,j) for i in range(n_v) for j in range(i+1, n_v)]
    n_e_k = len(edges_k)
    rank = n_v - 1
    bases_k = graphic_matroid_bases(edges_k, n_v)

    if bases_k and rank >= 2:
        actual_k = count_independent_k_sets(bases_k, n_e_k, rank - 2)
        ambient_k = comb(n_e_k, rank - 2)
        complete_ratios.append(actual_k / ambient_k if ambient_k > 0 else 1)
    else:
        complete_ratios.append(1)

    # Path graph
    edges_p = [(i, i+1) for i in range(n_v - 1)]
    n_e_p = len(edges_p)
    bases_p = graphic_matroid_bases(edges_p, n_v)

    if bases_p and rank >= 2:
        actual_p = count_independent_k_sets(bases_p, n_e_p, rank - 2)
        ambient_p = comb(n_e_p, rank - 2)
        path_ratios2.append(actual_p / ambient_p if ambient_p > 0 else 1)
    else:
        path_ratios2.append(1)

x = np.arange(len(vertex_counts))
width = 0.35
ax3.bar(x - width/2, complete_ratios, width, label='Complete graph K_n',
        color='coral', alpha=0.7, edgecolor='darkred')
ax3.bar(x + width/2, path_ratios2, width, label='Path graph P_n',
        color='steelblue', alpha=0.7, edgecolor='navy')
ax3.set_xlabel('Number of vertices')
ax3.set_ylabel('Compression ratio')
ax3.set_title('Dense vs Sparse Graphs\n(graphic matroid comparison)')
ax3.set_xticks(x)
ax3.set_xticklabels(vertex_counts)
ax3.legend()
ax3.set_ylim(0, 1.1)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('compression_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved compression_heatmap.png")
