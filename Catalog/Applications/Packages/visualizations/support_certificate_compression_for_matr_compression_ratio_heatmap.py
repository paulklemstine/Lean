"""
Visualization: Compression Ratio Heatmap

Visualizes how the compression ratio (actual leaves / ambient count) varies
across different matroid parameters. Darker cells indicate better compression.
For uniform matroids the ratio is always 1 (no compression); for sparse
graphic matroids the ratio is much less than 1.

Uses matplotlib to produce a heatmap of compression ratios for cycle graph
matroids C_n with varying number of vertices.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from math import comb


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


def count_indep_sets(n, r, bases, k):
    count = 0
    for combo in combinations(range(n), k):
        s = set(combo)
        if any(s <= b for b in bases):
            count += 1
    return count


def graphic_bases(n_verts, edges):
    n_edges = len(edges)
    r = n_verts - 1
    bases = []
    for combo in combinations(range(n_edges), r):
        edge_set = [edges[i] for i in combo]
        if is_spanning_tree(n_verts, edge_set):
            bases.append(set(combo))
    return bases


# Compute compression ratios for various graph types
graph_types = ['Path', 'Cycle', 'Complete']
vertex_counts = list(range(4, 10))
data = np.ones((len(graph_types), len(vertex_counts)))

for j, nv in enumerate(vertex_counts):
    for i, gtype in enumerate(graph_types):
        if gtype == 'Path':
            edges = [(v, v + 1) for v in range(nv - 1)]
        elif gtype == 'Cycle':
            edges = [(v, (v + 1) % nv) for v in range(nv)]
        else:  # Complete
            edges = [(a, b) for a in range(nv) for b in range(a + 1, nv)]

        ne = len(edges)
        r = nv - 1
        k = r - 2
        if k < 0 or k > ne:
            data[i, j] = 1.0
            continue

        try:
            bases = graphic_bases(nv, edges)
            if not bases:
                data[i, j] = 1.0
                continue
            actual = count_indep_sets(ne, r, bases, k)
            ambient = comb(ne, k)
            data[i, j] = actual / ambient if ambient > 0 else 1.0
        except Exception:
            data[i, j] = 1.0

fig, ax = plt.subplots(figsize=(10, 4))
im = ax.imshow(data, cmap='RdYlGn_r', aspect='auto', vmin=0, vmax=1)

ax.set_xticks(range(len(vertex_counts)))
ax.set_xticklabels(vertex_counts)
ax.set_yticks(range(len(graph_types)))
ax.set_yticklabels(graph_types)
ax.set_xlabel('Number of Vertices', fontsize=12)
ax.set_title('Support Compression Ratio (lower = better compression)',
             fontsize=14, fontweight='bold')

# Add text annotations
for i in range(len(graph_types)):
    for j in range(len(vertex_counts)):
        text = f'{data[i, j]:.2f}'
        color = 'white' if data[i, j] > 0.6 else 'black'
        ax.text(j, i, text, ha='center', va='center', color=color, fontsize=10)

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Compression Ratio', fontsize=11)

plt.tight_layout()
plt.savefig('compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved compression_heatmap.png")
