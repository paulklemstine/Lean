"""
Visualization: Scaling of Leaf Counts

Shows how the number of nonzero quadratic derivative leaves scales
with matroid parameters, comparing different matroid families.
The key insight: support geometry creates dramatic compression
for sparse matroids while uniform matroids achieve the ambient bound.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def graphic_bases(nv, edges):
    """Enumerate spanning trees of a graph."""
    rank = nv - 1
    bases = []
    for combo in combinations(range(len(edges)), rank):
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


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Uniform matroid leaf counts
ax1 = axes[0]
ns = list(range(4, 16))
for r in [3, 4, 5]:
    leaves = [comb(n, r - 2) for n in ns if n >= r]
    valid_ns = [n for n in ns if n >= r]
    ax1.plot(valid_ns, leaves, 'o-', label=f'r={r}', markersize=5)

ax1.set_xlabel('n (ground set size)', fontsize=12)
ax1.set_ylabel('Leaf Count', fontsize=12)
ax1.set_title('Uniform Matroid U_{r,n}\nLeaves = C(n, r-2)', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Graphic matroid compression
ax2 = axes[1]
graph_ns = list(range(3, 8))

for graph_type, graph_fn, label, color in [
    ('path', lambda n: [(i, i+1) for i in range(n-1)], 'Path P_n', '#2196F3'),
    ('cycle', lambda n: [(i, (i+1)%n) for i in range(n)], 'Cycle C_n', '#FF9800'),
    ('complete', lambda n: [(i,j) for i in range(n) for j in range(i+1,n)],
     'Complete K_n', '#4CAF50'),
]:
    ratios = []
    valid_ns = []
    for n in graph_ns:
        edges = graph_fn(n)
        r = n - 1
        bases = graphic_bases(n, edges)
        if bases and r >= 2:
            actual = count_leaves(bases, r)
            ambient = comb(len(edges), r - 2)
            if ambient > 0:
                ratios.append(actual / ambient)
                valid_ns.append(n)

    if valid_ns:
        ax2.plot(valid_ns, ratios, 'o-', label=label, color=color,
                markersize=7, linewidth=2)

ax2.set_xlabel('n (vertices)', fontsize=12)
ax2.set_ylabel('Compression Ratio', fontsize=12)
ax2.set_title('Graphic Matroid Compression\nRatio = actual / ambient', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 1.1)
ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='No compression')
ax2.grid(True, alpha=0.3)

# Panel 3: Active variable bound vs ambient bound
ax3 = axes[2]

ns_compare = list(range(4, 8))
for n in ns_compare:
    edges = [(i,j) for i in range(n) for j in range(i+1,n)]
    r = n - 1
    m = len(edges)

    # For K_n: all edges active, so active bound = ambient bound
    # For paths: only n-1 edges, so active bound much smaller

    ambient = comb(m, r-2) if r >= 2 else 1

    # Path
    path_edges = [(i, i+1) for i in range(n-1)]
    path_bases = graphic_bases(n, path_edges)
    if path_bases and r >= 2:
        path_actual = count_leaves(path_bases, r)
        path_active = len(frozenset().union(*path_bases))
        path_active_bound = comb(path_active, r-2)
    else:
        path_actual = 0
        path_active_bound = 0

    ax3.scatter(n, ambient, color='red', s=100, marker='s',
               zorder=5, label='Ambient' if n == ns_compare[0] else '')
    ax3.scatter(n, path_active_bound, color='blue', s=80, marker='^',
               zorder=5, label='Active bound (path)' if n == ns_compare[0] else '')
    ax3.scatter(n, path_actual, color='green', s=60, marker='o',
               zorder=5, label='Actual (path)' if n == ns_compare[0] else '')

ax3.set_xlabel('n (vertices)', fontsize=12)
ax3.set_ylabel('Bound Value', fontsize=12)
ax3.set_title('Three-Level Bounds\nAmbient ≥ Active ≥ Actual', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_yscale('log')
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('scaling_analysis.png', dpi=150, bbox_inches='tight')
print("Saved scaling_analysis.png")
