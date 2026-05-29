"""
Visualization: Compression Ratio Heatmap

Visualizes the compression ratio (actual leaves / ambient bound) for
uniform matroids U_{r,n} across different values of n and r.

For uniform matroids, the ratio is always 1 (every subset is independent),
so we compare against graphic matroids of complete graphs K_n where
support geometry creates significant compression.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def graphic_bases(nv, edges):
    """Enumerate spanning trees."""
    rank = nv - 1
    m = len(edges)
    bases = []
    for combo in combinations(range(m), rank):
        parent = list(range(nv))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        ok = True
        for idx in combo:
            u, v = edges[idx]
            pu, pv = find(u), find(v)
            if pu == pv:
                ok = False
                break
            parent[pu] = pv
        if ok and len(set(find(i) for i in range(nv))) == 1:
            bases.append(frozenset(combo))
    return bases


def count_leaves(bases, r):
    if r < 2 or not bases:
        return 0
    ground = frozenset().union(*bases)
    count = 0
    for combo in combinations(sorted(ground), r - 2):
        subset = frozenset(combo)
        if any(subset <= b for b in bases):
            count += 1
    return count


# Compute compression data for graphic matroids of K_n
ns = range(3, 8)
data_rows = []
labels_r = []
labels_n = []

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Panel 1: Leaf counts across graph families
ax1 = axes[0]
graph_ns = list(range(3, 8))
uniform_leaves = []
graphic_leaves = []
ambient_bounds = []

for n in graph_ns:
    r = n - 1
    m = n * (n - 1) // 2  # edges of K_n

    # Uniform matroid on m elements with rank r
    uniform_count = comb(m, r - 2) if r >= 2 else 1
    uniform_leaves.append(uniform_count)

    # Graphic matroid of K_n
    edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
    bases = graphic_bases(n, edges)
    graphic_count = count_leaves(bases, r)
    graphic_leaves.append(graphic_count)

    ambient = comb(m, r - 2) if r >= 2 else 1
    ambient_bounds.append(ambient)

x = np.arange(len(graph_ns))
width = 0.35
ax1.bar(x - width/2, ambient_bounds, width, label='Ambient C(m, r-2)',
        color='#ff6b6b', alpha=0.8)
ax1.bar(x + width/2, graphic_leaves, width, label='Actual (graphic)',
        color='#4ecdc4', alpha=0.8)
ax1.set_xlabel('Complete Graph K_n', fontsize=12)
ax1.set_ylabel('Leaf Count', fontsize=12)
ax1.set_title('Ambient vs Actual Leaf Count\n(Graphic Matroids of K_n)', fontsize=13)
ax1.set_xticks(x)
ax1.set_xticklabels([f'K_{n}' for n in graph_ns])
ax1.legend(fontsize=10)
ax1.set_yscale('log')

# Panel 2: Compression ratio heatmap
ax2 = axes[1]

# Build ratio matrix for different graph types
graph_types = ['Path', 'Cycle', 'K_n']
ns_heatmap = list(range(4, 8))
ratio_matrix = np.zeros((len(graph_types), len(ns_heatmap)))

for j, n in enumerate(ns_heatmap):
    # Path graph
    edges_path = [(i, i+1) for i in range(n-1)]
    r_path = n - 1
    bases_path = graphic_bases(n, edges_path)
    if bases_path and r_path >= 2:
        actual = count_leaves(bases_path, r_path)
        ambient = comb(len(edges_path), r_path - 2)
        ratio_matrix[0, j] = actual / ambient if ambient > 0 else 0
    else:
        ratio_matrix[0, j] = 1.0

    # Cycle graph
    edges_cycle = [(i, (i+1) % n) for i in range(n)]
    r_cycle = n - 1
    bases_cycle = graphic_bases(n, edges_cycle)
    if bases_cycle and r_cycle >= 2:
        actual = count_leaves(bases_cycle, r_cycle)
        ambient = comb(len(edges_cycle), r_cycle - 2)
        ratio_matrix[1, j] = actual / ambient if ambient > 0 else 0
    else:
        ratio_matrix[1, j] = 1.0

    # Complete graph
    edges_kn = [(i, k) for i in range(n) for k in range(i+1, n)]
    r_kn = n - 1
    bases_kn = graphic_bases(n, edges_kn)
    if bases_kn and r_kn >= 2:
        actual = count_leaves(bases_kn, r_kn)
        ambient = comb(len(edges_kn), r_kn - 2)
        ratio_matrix[2, j] = actual / ambient if ambient > 0 else 0
    else:
        ratio_matrix[2, j] = 1.0

im = ax2.imshow(ratio_matrix, cmap='RdYlGn_r', aspect='auto',
                vmin=0, vmax=1)
ax2.set_xticks(range(len(ns_heatmap)))
ax2.set_xticklabels([str(n) for n in ns_heatmap])
ax2.set_yticks(range(len(graph_types)))
ax2.set_yticklabels(graph_types)
ax2.set_xlabel('Number of Vertices', fontsize=12)
ax2.set_title('Compression Ratio\n(lower = more compression)', fontsize=13)

# Annotate cells
for i in range(len(graph_types)):
    for j in range(len(ns_heatmap)):
        text = f'{ratio_matrix[i, j]:.2f}'
        color = 'white' if ratio_matrix[i, j] > 0.6 else 'black'
        ax2.text(j, i, text, ha='center', va='center', fontsize=11,
                color=color, fontweight='bold')

plt.colorbar(im, ax=ax2, label='Ratio (actual/ambient)')
plt.tight_layout()
plt.savefig('compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved compression_heatmap.png")
