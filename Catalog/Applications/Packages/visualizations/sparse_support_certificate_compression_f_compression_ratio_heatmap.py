"""
Visualization 1: Compression Ratio Heatmap

Visualizes the compression ratio (actual leaves / ambient bound) across
different matroid parameters (n, r) for uniform matroids and compares
with graphic matroid families. Shows that for uniform matroids the ratio
is always 1 (no compression), while for sparse graphic matroids the ratio
drops dramatically as the graph becomes sparser relative to the ambient space.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def graphic_matroid_bases(edges, num_vertices):
    """Compute spanning forest bases of a graphic matroid."""
    m = len(edges)
    # Find number of components
    parent = list(range(num_vertices))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    components = num_vertices
    for u, v in edges:
        pu, pv = find(u), find(v)
        if pu != pv:
            parent[pu] = pv
            components -= 1
    rank = num_vertices - components

    bases = []
    for subset in combinations(range(m), rank):
        par = list(range(num_vertices))
        def find2(x):
            while par[x] != x:
                par[x] = par[par[x]]
                x = par[x]
            return x
        ok = True
        c = num_vertices
        for idx in subset:
            u, v = edges[idx]
            pu, pv = find2(u), find2(v)
            if pu == pv:
                ok = False
                break
            par[pu] = pv
            c -= 1
        if ok and c == components:
            bases.append(frozenset(subset))
    return bases, rank


def count_indep_sets(bases, k, ground_size):
    """Count k-element independent sets."""
    ground = set()
    for b in bases:
        ground |= b
    count = 0
    for subset in combinations(sorted(ground), k):
        fs = frozenset(subset)
        for b in bases:
            if fs <= b:
                count += 1
                break
    return count


# --- Panel 1: Uniform matroid leaf counts vs C(n, r-2) ---
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Leaf counts for uniform matroids
ns = list(range(4, 13))
for r in [3, 4, 5, 6]:
    leaves = [comb(n, r-2) for n in ns if n >= r]
    valid_ns = [n for n in ns if n >= r]
    axes[0].plot(valid_ns, leaves, 'o-', label=f'r={r}', markersize=4)

axes[0].set_xlabel('n (ground set size)', fontsize=12)
axes[0].set_ylabel('Quadratic leaves', fontsize=12)
axes[0].set_title('Uniform Matroid $U_{r,n}$\nLeaves = $\\binom{n}{r-2}$', fontsize=13)
axes[0].legend()
axes[0].set_yscale('log')
axes[0].grid(True, alpha=0.3)

# Panel 2: Compression ratios for graphic matroids
graph_types = {
    'Path': lambda n: [(i, i+1) for i in range(n-1)],
    'Cycle': lambda n: [(i, (i+1) % n) for i in range(n)],
    'Complete': lambda n: [(i, j) for i in range(n) for j in range(i+1, n)],
}

for gtype, gen_edges in graph_types.items():
    ratios = []
    valid_ns = []
    for nv in range(4, 7):
        edges = gen_edges(nv)
        m = len(edges)
        bases, rank = graphic_matroid_bases(edges, nv)
        if rank < 2 or not bases:
            continue
        leaves = count_indep_sets(bases, rank - 2, m)
        amb = comb(m, rank - 2)
        if amb > 0:
            ratios.append(leaves / amb)
            valid_ns.append(nv)
    if ratios:
        axes[1].plot(valid_ns, ratios, 's-', label=gtype, markersize=6)

axes[1].set_xlabel('Number of vertices', fontsize=12)
axes[1].set_ylabel('Compression ratio', fontsize=12)
axes[1].set_title('Graphic Matroids\nleaves / ambient bound', fontsize=13)
axes[1].legend()
axes[1].set_ylim(0, 1.1)
axes[1].grid(True, alpha=0.3)
axes[1].axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)

# Panel 3: Active variable bound effectiveness
data_n = []
data_active = []
data_ambient = []
data_actual = []

for nv in range(4, 7):
    # Path graph
    edges = [(i, i+1) for i in range(nv-1)]
    m = len(edges)
    bases, rank = graphic_matroid_bases(edges, nv)
    if rank < 2 and bases:
        continue
    active = len(set().union(*bases))
    leaves = count_indep_sets(bases, rank - 2, m)
    data_n.append(f'P_{nv}')
    data_actual.append(leaves)
    data_active.append(comb(active, rank - 2))
    data_ambient.append(comb(m, rank - 2))

x = np.arange(len(data_n))
width = 0.25
axes[2].bar(x - width, data_ambient, width, label='Ambient C(m,r-2)', color='#e74c3c', alpha=0.8)
axes[2].bar(x, data_active, width, label='Active C(ω,r-2)', color='#f39c12', alpha=0.8)
axes[2].bar(x + width, data_actual, width, label='Actual leaves', color='#27ae60', alpha=0.8)
axes[2].set_xlabel('Graph', fontsize=12)
axes[2].set_ylabel('Count', fontsize=12)
axes[2].set_title('Bound Comparison\n(Path Graphs)', fontsize=13)
axes[2].set_xticks(x)
axes[2].set_xticklabels(data_n)
axes[2].legend(fontsize=9)
axes[2].grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_compression_heatmap.png")
