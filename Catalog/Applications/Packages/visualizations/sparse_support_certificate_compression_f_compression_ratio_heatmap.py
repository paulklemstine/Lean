"""
Visualization: Compression Ratio Heatmap for Uniform Matroids.

Shows how the ratio compressed_count / ambient_count varies as a function
of n (ground set size) and r (rank) for uniform matroids U_{r,n}.
For uniform matroids the ratio is always 1 (every subset extends to a basis),
but we compare with graphic matroids (cycle graphs) to show compression.

This heatmap visualizes the core insight: support geometry compresses
the Lorentzian certification tree for sparse matroids.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def graphic_matroid_bases_cycle(nv):
    """Bases of the graphic matroid of the cycle graph C_nv."""
    edges = [(i, (i + 1) % nv) for i in range(nv)]
    m = len(edges)

    def is_acyclic(edge_indices):
        parent = list(range(nv))
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

    rank = nv - 1
    bases = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases, rank, m


def support_compressed_leaf_count(bases, n, k):
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        for B in bases:
            if fs <= B:
                count += 1
                break
    return count


# --- Complete graph graphic matroids ---
def graphic_matroid_bases_complete(nv):
    edges = [(i, j) for i in range(nv) for j in range(i + 1, nv)]
    m = len(edges)

    def is_acyclic(edge_indices):
        parent = list(range(nv))
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

    rank = nv - 1
    bases = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases, rank, m


# Build data for heatmap: complete graphs K_3 through K_8
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Uniform matroid ratios (always 1.0)
ns = list(range(3, 10))
data_uniform = []
for n in ns:
    row = []
    for r in range(2, n + 1):
        k = r - 2
        ratio = 1.0  # For uniform matroids, all subsets extend
        row.append(ratio)
    # Pad with NaN for alignment
    while len(row) < max(ns) - 1:
        row.append(np.nan)
    data_uniform.append(row)

ax = axes[0]
data_arr = np.array(data_uniform)
im = ax.imshow(data_arr, cmap='RdYlGn', vmin=0, vmax=1, aspect='auto')
ax.set_xlabel('Rank r (starting from 2)')
ax.set_ylabel('Ground set size n')
ax.set_yticks(range(len(ns)))
ax.set_yticklabels(ns)
ax.set_xticks(range(data_arr.shape[1]))
ax.set_xticklabels(range(2, 2 + data_arr.shape[1]))
ax.set_title('Uniform Matroid: Compression Ratio\n(always 1.0 — no compression)')
for i in range(data_arr.shape[0]):
    for j in range(data_arr.shape[1]):
        if not np.isnan(data_arr[i, j]):
            ax.text(j, i, f'{data_arr[i,j]:.2f}', ha='center', va='center', fontsize=7)

# Right: Complete graph graphic matroid ratios
data_graphic = []
graph_ns = list(range(3, 8))
for nv in graph_ns:
    bases, rank, m = graphic_matroid_bases_complete(nv)
    row = []
    for k in range(0, rank - 1):
        amb = comb(m, k)
        if amb == 0:
            row.append(np.nan)
        else:
            comp = support_compressed_leaf_count(bases, m, k)
            row.append(comp / amb)
    while len(row) < 6:
        row.append(np.nan)
    data_graphic.append(row)

ax = axes[1]
data_arr2 = np.array(data_graphic)
im2 = ax.imshow(data_arr2, cmap='RdYlGn', vmin=0, vmax=1, aspect='auto')
ax.set_xlabel('Derivative depth k')
ax.set_ylabel('Complete graph K_n')
ax.set_yticks(range(len(graph_ns)))
ax.set_yticklabels([f'K_{nv}' for nv in graph_ns])
ax.set_xticks(range(data_arr2.shape[1]))
ax.set_xticklabels(range(data_arr2.shape[1]))
ax.set_title('Graphic Matroid (K_n): Compression Ratio\n(< 1 shows support compression)')
for i in range(data_arr2.shape[0]):
    for j in range(data_arr2.shape[1]):
        if not np.isnan(data_arr2[i, j]):
            ax.text(j, i, f'{data_arr2[i,j]:.2f}', ha='center', va='center', fontsize=7)

fig.colorbar(im2, ax=axes, shrink=0.8, label='Compression Ratio (actual / ambient)')
plt.suptitle('Support Compression in Lorentzian Recognition Trees', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_compression_heatmap.png")
