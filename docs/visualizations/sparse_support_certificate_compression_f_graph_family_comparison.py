"""
Visualization: Compression Comparison Across Graph Families

Compares the actual quadratic leaf count (= independent (r-2)-set count)
against the ambient worst case C(n, r-2) for different graph families.
Shows how graph structure determines certification complexity.

Key insight: sparse graphs (paths, cycles) often match the ambient bound,
while dense graphs with many dependencies can show genuine compression.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def graphic_matroid_leaves(n_verts, edges):
    """Compute leaf count for a graphic matroid."""
    E = list(range(len(edges)))

    def find(p, x):
        while p[x] != x: p[x] = p[p[x]]; x = p[x]
        return x

    def union(p, rk, x, y):
        rx, ry = find(p, x), find(p, y)
        if rx == ry: return False
        if rk[rx] < rk[ry]: rx, ry = ry, rx
        p[ry] = rx
        if rk[rx] == rk[ry]: rk[rx] += 1
        return True

    def is_forest(subset):
        p = list(range(n_verts)); rk = [0]*n_verts
        for i in subset:
            if not union(p, rk, edges[i][0], edges[i][1]): return False
        return True

    p = list(range(n_verts)); rk = [0]*n_verts
    rank = sum(1 for i, (u,v) in enumerate(edges) if union(p, rk, u, v))
    ref_comps = len({find(p, v) for v in range(n_verts)})

    bases = set()
    for subset in combinations(E, rank):
        if is_forest(subset):
            p2 = list(range(n_verts)); rk2 = [0]*n_verts
            for i in subset: union(p2, rk2, edges[i][0], edges[i][1])
            if len({find(p2, v) for v in range(n_verts)}) == ref_comps:
                bases.add(frozenset(subset))

    k = max(rank - 2, 0)
    actual = 0
    for s in combinations(E, k):
        fs = frozenset(s)
        if any(fs <= B for B in bases):
            actual += 1

    ambient = comb(len(E), k) if rank >= 2 else 1
    return len(E), rank, actual, ambient, len(bases)


# Compute data for different graph families
ns = list(range(4, 8))

path_data = []
cycle_data = []
complete_data = []

for n in ns:
    # Path
    edges = [(i, i+1) for i in range(n-1)]
    ne, r, actual, ambient, nb = graphic_matroid_leaves(n, edges)
    path_data.append((n, ne, r, actual, ambient))

    # Cycle
    edges = [(i, (i+1) % n) for i in range(n)]
    ne, r, actual, ambient, nb = graphic_matroid_leaves(n, edges)
    cycle_data.append((n, ne, r, actual, ambient))

    # Complete
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    ne, r, actual, ambient, nb = graphic_matroid_leaves(n, edges)
    complete_data.append((n, ne, r, actual, ambient))


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Absolute leaf counts
ax = axes[0]
x = ns
ax.plot(x, [d[3] for d in path_data], 'o-', label='Path $P_n$', linewidth=2, markersize=8)
ax.plot(x, [d[3] for d in cycle_data], 's-', label='Cycle $C_n$', linewidth=2, markersize=8)
ax.plot(x, [d[3] for d in complete_data], '^-', label='Complete $K_n$', linewidth=2, markersize=8)
ax.set_xlabel('Number of Vertices', fontsize=12)
ax.set_ylabel('Quadratic Leaf Count', fontsize=12)
ax.set_title('Actual Leaf Counts', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Plot 2: Ambient vs Actual
ax = axes[1]
for data, label, marker in [(path_data, 'Path', 'o'), (cycle_data, 'Cycle', 's'),
                              (complete_data, 'Complete', '^')]:
    ax.plot(x, [d[4] for d in data], f'{marker}--', alpha=0.4, label=f'{label} (ambient)')
    ax.plot(x, [d[3] for d in data], f'{marker}-', label=f'{label} (actual)')
ax.set_xlabel('Number of Vertices', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Ambient vs. Actual', fontsize=13)
ax.legend(fontsize=8, ncol=2)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Plot 3: Compression ratios
ax = axes[2]
ax.plot(x, [d[3]/d[4] if d[4] > 0 else 1 for d in path_data],
        'o-', label='Path $P_n$', linewidth=2, markersize=8)
ax.plot(x, [d[3]/d[4] if d[4] > 0 else 1 for d in cycle_data],
        's-', label='Cycle $C_n$', linewidth=2, markersize=8)
ax.plot(x, [d[3]/d[4] if d[4] > 0 else 1 for d in complete_data],
        '^-', label='Complete $K_n$', linewidth=2, markersize=8)
ax.set_xlabel('Number of Vertices', fontsize=12)
ax.set_ylabel('Compression Ratio (actual/ambient)', fontsize=12)
ax.set_title('Compression by Graph Family', fontsize=13)
ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5, label='No compression')
ax.legend(fontsize=10)
ax.set_ylim(0, 1.1)
ax.grid(True, alpha=0.3)

plt.suptitle('Support Compression for Graphic Matroids', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_graph_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_graph_comparison.png")
