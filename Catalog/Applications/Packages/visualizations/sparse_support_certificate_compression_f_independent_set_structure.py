#!/usr/bin/env python3
"""
Visualization: Independent Set Structure

Illustrates the core insight: nonzero quadratic leaves correspond to
independent sets of the matroid. For a graphic matroid, independent
sets are forests (acyclic edge subsets).

Shows a comparison of independent (r-2)-set counts across graph 
families, making visible how graph structure controls certification
complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools
from math import comb


def count_forests(n_vertices, edges, k):
    """Count k-element forests (independent sets of size k in graphic matroid)."""
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
    
    return sum(1 for S in itertools.combinations(range(m), k) if is_forest(S))


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Independent set count by size for K5
ax = axes[0]
nv = 5
edges_k5 = [(i,j) for i in range(nv) for j in range(i+1, nv)]
m = len(edges_k5)
r = nv - 1  # rank of K5

sizes = range(0, r + 1)
counts = [count_forests(nv, edges_k5, k) for k in sizes]
ambient_counts = [comb(m, k) for k in sizes]

ax.bar(np.array(list(sizes)) - 0.15, ambient_counts, 0.3, label='All subsets C(m,k)', 
       alpha=0.5, color='gray')
ax.bar(np.array(list(sizes)) + 0.15, counts, 0.3, label='Forests (independent)', 
       alpha=0.8, color='steelblue')
ax.axvline(x=r-2, color='red', linestyle='--', linewidth=2, label=f'k = r-2 = {r-2}')
ax.set_xlabel('Set size k', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'K₅: Forests vs. All Subsets\n(m={m}, r={r})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

# Panel 2: Same for cycle C6
ax = axes[1]
nv = 6
edges_c6 = [(i, (i+1) % nv) for i in range(nv)]
m = len(edges_c6)
r = nv - 1

sizes = range(0, r + 1)
counts = [count_forests(nv, edges_c6, k) for k in sizes]
ambient_counts = [comb(m, k) for k in sizes]

ax.bar(np.array(list(sizes)) - 0.15, ambient_counts, 0.3, label='All subsets C(m,k)', 
       alpha=0.5, color='gray')
ax.bar(np.array(list(sizes)) + 0.15, counts, 0.3, label='Forests (independent)', 
       alpha=0.8, color='darkorange')
ax.axvline(x=r-2, color='red', linestyle='--', linewidth=2, label=f'k = r-2 = {r-2}')
ax.set_xlabel('Set size k', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'C₆: Forests vs. All Subsets\n(m={m}, r={r})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

# Panel 3: Compression at k=r-2 across graph sizes
ax = axes[2]
nv_range = range(4, 9)

for graph_type, gen_edges, color, label in [
    ('Path', lambda nv: [(i, i+1) for i in range(nv-1)], 'blue', 'Path'),
    ('Cycle', lambda nv: [(i, (i+1) % nv) for i in range(nv)], 'orange', 'Cycle'),
    ('Complete', lambda nv: [(i,j) for i in range(nv) for j in range(i+1, nv)], 'green', 'Complete'),
]:
    compressions = []
    ns = []
    for nv in nv_range:
        edges = gen_edges(nv)
        m = len(edges)
        # compute rank
        p = list(range(nv))
        def find(x):
            while p[x] != x: p[x] = p[p[x]]; x = p[x]
            return x
        for i in range(m):
            u, v = edges[i]
            a, b = find(u), find(v)
            if a != b: p[a] = b
        nc = len(set(find(i) for i in range(nv)))
        r = nv - nc
        if r >= 2:
            amb = comb(m, r - 2)
            comp = count_forests(nv, edges, r - 2)
            if amb > 0:
                compressions.append(comp / amb)
                ns.append(nv)
    ax.plot(ns, compressions, 'o-', color=color, label=label, linewidth=2, markersize=8)

ax.set_xlabel('Number of vertices', fontsize=12)
ax.set_ylabel('Compression ratio at k = r-2', fontsize=12)
ax.set_title('Certificate Compression\nAcross Graph Families', fontsize=13)
ax.legend(fontsize=11)
ax.set_ylim(0, 1.05)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('independent_sets.png', dpi=150, bbox_inches='tight')
print("Saved independent_sets.png")
