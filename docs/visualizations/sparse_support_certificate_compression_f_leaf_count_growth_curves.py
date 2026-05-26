"""
Visualization: Leaf Count Growth Curves.

Compares the growth of nonzero quadratic leaf counts across matroid families
as the ground set size increases, showing how support geometry constrains
growth relative to the ambient worst case.

This plot demonstrates the fundamental compression principle: for sparse
matroids, the leaf count grows much slower than the ambient C(n, r-2).
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def graphic_matroid_bases(n_vertices, edges):
    """Spanning forests (bases of graphic matroid)."""
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


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# --- Left plot: Cycle graphs ---
nvs_cycle = list(range(4, 12))
ambient_cycle = []
compressed_cycle = []

for nv in nvs_cycle:
    edges = [(i, (i + 1) % nv) for i in range(nv)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0:
        ambient_cycle.append(0)
        compressed_cycle.append(0)
        continue
    ambient_cycle.append(comb(m, k))
    compressed_cycle.append(support_compressed_leaf_count(bases, m, k))

ax1.plot(nvs_cycle, ambient_cycle, 'o-', color='red', label='Ambient C(n, r-2)', linewidth=2)
ax1.plot(nvs_cycle, compressed_cycle, 's-', color='blue', label='Compressed (actual)', linewidth=2)
ax1.fill_between(nvs_cycle, compressed_cycle, ambient_cycle, alpha=0.15, color='green',
                  label='Savings')
ax1.set_xlabel('Number of vertices', fontsize=12)
ax1.set_ylabel('Leaf count', fontsize=12)
ax1.set_title('Cycle Graphs $C_n$\n(n edges, rank n-1)', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_yscale('log')

# --- Right plot: Complete graphs ---
nvs_complete = list(range(3, 8))
ambient_complete = []
compressed_complete = []
uniform_count = []

for nv in nvs_complete:
    edges = [(i, j) for i in range(nv) for j in range(i + 1, nv)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0:
        ambient_complete.append(0)
        compressed_complete.append(0)
        uniform_count.append(0)
        continue
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    unif = comb(m, k)  # Uniform would be the same as ambient
    ambient_complete.append(amb)
    compressed_complete.append(comp)
    uniform_count.append(unif)

ax2.bar(np.array(range(len(nvs_complete))) - 0.15, ambient_complete, 0.3,
        color='red', alpha=0.7, label='Ambient C(m, r-2)')
ax2.bar(np.array(range(len(nvs_complete))) + 0.15, compressed_complete, 0.3,
        color='blue', alpha=0.7, label='Compressed (actual)')
ax2.set_xlabel('Complete graph $K_n$', fontsize=12)
ax2.set_ylabel('Leaf count', fontsize=12)
ax2.set_title('Complete Graphs $K_n$\n(m=C(n,2) edges, rank n-1)', fontsize=13)
ax2.set_xticks(range(len(nvs_complete)))
ax2.set_xticklabels([f'$K_{nv}$' for nv in nvs_complete])
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# Add ratio annotations
for i, nv in enumerate(nvs_complete):
    if ambient_complete[i] > 0:
        ratio = compressed_complete[i] / ambient_complete[i]
        ax2.annotate(f'{ratio:.2f}', (i + 0.15, compressed_complete[i]),
                     ha='center', va='bottom', fontsize=8, fontweight='bold')

plt.suptitle('Leaf Count Growth: Ambient vs. Support-Compressed',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_leaf_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_leaf_growth.png")
