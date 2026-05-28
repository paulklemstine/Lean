"""
Visualization: Leaf Count Comparison

Compares the actual nonzero quadratic leaf count to the ambient worst-case
count C(n, r-2) for different matroid families. Shows how support geometry
compresses the recognition tree.

Produces a grouped bar chart comparing actual vs ambient counts for
path, cycle, and complete graph matroids.
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
    r = n_verts - 1
    bases = []
    for combo in combinations(range(len(edges)), r):
        edge_set = [edges[i] for i in combo]
        if is_spanning_tree(n_verts, edge_set):
            bases.append(set(combo))
    return bases


# Compute data for different graph families
vertex_range = [4, 5, 6, 7, 8]
families = {
    'Path': lambda nv: [(i, i+1) for i in range(nv - 1)],
    'Cycle': lambda nv: [(i, (i+1) % nv) for i in range(nv)],
    'Complete': lambda nv: [(i,j) for i in range(nv) for j in range(i+1, nv)],
}

results = {name: {'actual': [], 'ambient': []} for name in families}

for nv in vertex_range:
    for name, edge_fn in families.items():
        edges = edge_fn(nv)
        ne = len(edges)
        r = nv - 1
        k = r - 2
        if k < 0:
            results[name]['actual'].append(0)
            results[name]['ambient'].append(0)
            continue
        try:
            bases = graphic_bases(nv, edges)
            actual = count_indep_sets(ne, r, bases, k)
            ambient = comb(ne, k)
            results[name]['actual'].append(actual)
            results[name]['ambient'].append(ambient)
        except Exception:
            results[name]['actual'].append(0)
            results[name]['ambient'].append(0)

fig, axes = plt.subplots(1, 3, figsize=(15, 5), sharey=False)

colors_actual = '#2196F3'
colors_ambient = '#FF9800'

for idx, (name, data) in enumerate(results.items()):
    ax = axes[idx]
    x = np.arange(len(vertex_range))
    width = 0.35

    bars1 = ax.bar(x - width/2, data['actual'], width, label='Actual Leaves',
                   color=colors_actual, alpha=0.85)
    bars2 = ax.bar(x + width/2, data['ambient'], width, label='Ambient C(n,r−2)',
                   color=colors_ambient, alpha=0.85)

    ax.set_xlabel('Number of Vertices')
    ax.set_title(f'{name} Graph', fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(vertex_range)
    ax.legend(fontsize=8)

    # Add value labels
    for bar in bars1:
        h = bar.get_height()
        if h > 0:
            ax.text(bar.get_x() + bar.get_width()/2., h,
                   f'{int(h)}', ha='center', va='bottom', fontsize=7)
    for bar in bars2:
        h = bar.get_height()
        if h > 0:
            ax.text(bar.get_x() + bar.get_width()/2., h,
                   f'{int(h)}', ha='center', va='bottom', fontsize=7)

axes[0].set_ylabel('Leaf Count')
fig.suptitle('Nonzero Quadratic Leaves: Actual vs Ambient Count',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('leaf_count_comparison.png', dpi=150, bbox_inches='tight')
print("Saved leaf_count_comparison.png")
