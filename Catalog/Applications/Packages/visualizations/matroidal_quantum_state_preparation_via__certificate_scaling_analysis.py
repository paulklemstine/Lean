"""
Visualization: Certificate Scaling Analysis

Plots how certificate size and depth scale with graph complexity for
graphic matroids, comparing complete graphs, cycle graphs, and grid graphs.
Demonstrates the conjecture that treewidth controls certificate complexity.
"""

import itertools
import math
import matplotlib.pyplot as plt
import numpy as np

# --- Inline matroid construction ---
def build_graphic_matroid(n_verts, edges):
    n = n_verts
    def is_forest(es):
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for idx in es:
            u, v = edges[idx]
            rx, ry = find(u), find(v)
            if rx == ry: return False
            parent[rx] = ry
        return True
    def spans(es):
        if n <= 1: return True
        adj = {i: set() for i in range(n)}
        for idx in es:
            u, v = edges[idx]
            adj[u].add(v); adj[v].add(u)
        visited = set(); stack = [0]
        while stack:
            nd = stack.pop()
            if nd in visited: continue
            visited.add(nd); stack.extend(adj[nd] - visited)
        return len(visited) == n
    bases = set()
    for combo in itertools.combinations(range(len(edges)), n - 1):
        fs = frozenset(combo)
        if is_forest(fs) and spans(fs):
            bases.add(fs)
    return bases

def compile_stats(bases, n_edges):
    """Get certificate depth and size via deletion/contraction recursion."""
    depth = [0]; size = [0]
    def _recurse(current_bases, ground, d):
        size[0] += 1; depth[0] = max(depth[0], d)
        if not ground or len(current_bases) <= 1:
            return
        e = min(ground)
        new_ground = ground - {e}
        del_bases = {B for B in current_bases if e not in B}
        con_bases = {frozenset(x for x in B if x != e) for B in current_bases if e in B}
        if del_bases: _recurse(del_bases, new_ground, d+1)
        if con_bases: _recurse(con_bases, new_ground, d+1)
    _recurse(bases, set(range(n_edges)), 0)
    return depth[0], size[0]

# Build data
results = {"Complete K_n": [], "Cycle C_n": [], "Wheel W_n": []}

for n in range(3, 9):
    # Complete graph K_n
    edges = [(i,j) for i in range(n) for j in range(i+1,n)]
    bases = build_graphic_matroid(n, edges)
    d, s = compile_stats(bases, len(edges))
    results["Complete K_n"].append((n, len(edges), len(bases), d, s))

for n in range(3, 16):
    # Cycle C_n
    edges = [(i, (i+1) % n) for i in range(n)]
    bases = build_graphic_matroid(n, edges)
    d, s = compile_stats(bases, len(edges))
    results["Cycle C_n"].append((n, len(edges), len(bases), d, s))

for n in range(4, 10):
    # Wheel W_n (hub + cycle)
    edges = [(i, (i+1) % (n-1)) for i in range(n-1)]  # outer cycle
    edges += [(n-1, i) for i in range(n-1)]  # hub to all
    bases = build_graphic_matroid(n, edges)
    d, s = compile_stats(bases, len(edges))
    results["Wheel W_n"].append((n, len(edges), len(bases), d, s))

# Plot
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

colors = {'Complete K_n': '#E53935', 'Cycle C_n': '#1E88E5', 'Wheel W_n': '#43A047'}
markers = {'Complete K_n': 'o', 'Cycle C_n': 's', 'Wheel W_n': '^'}

# Plot 1: Number of bases
ax = axes[0]
for name, data in results.items():
    ns = [d[0] for d in data]
    n_bases = [d[2] for d in data]
    ax.semilogy(ns, n_bases, '-'+markers[name], color=colors[name], 
                label=name, markersize=7, linewidth=2)
ax.set_xlabel("Number of vertices n")
ax.set_ylabel("Number of bases (log scale)")
ax.set_title("Basis Count vs. Graph Size", fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Certificate size
ax = axes[1]
for name, data in results.items():
    ns = [d[0] for d in data]
    sizes = [d[4] for d in data]
    ax.semilogy(ns, sizes, '-'+markers[name], color=colors[name],
                label=name, markersize=7, linewidth=2)
ax.set_xlabel("Number of vertices n")
ax.set_ylabel("Certificate size (log scale)")
ax.set_title("Certificate Size vs. Graph Size", fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Certificate depth
ax = axes[2]
for name, data in results.items():
    ns = [d[0] for d in data]
    depths = [d[3] for d in data]
    ax.plot(ns, depths, '-'+markers[name], color=colors[name],
            label=name, markersize=7, linewidth=2)
ax.set_xlabel("Number of vertices n")
ax.set_ylabel("Certificate depth")
ax.set_title("Certificate Depth vs. Graph Size", fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

fig.suptitle("Certificate Compilation Scaling for Graphic Matroids",
            fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_certificate_scaling.png", dpi=150, bbox_inches='tight')
print("Saved viz_certificate_scaling.png")
