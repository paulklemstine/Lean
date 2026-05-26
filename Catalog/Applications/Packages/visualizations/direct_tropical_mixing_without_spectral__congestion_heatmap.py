"""
Visualization: Congestion Heatmap on Tropical State Graph

Shows the vertex congestion (number of canonical paths passing through
each vertex) as a heatmap on the Newton simplex lattice. Demonstrates
the congestion bottleneck phenomenon from the congestion_lower_bound_exists
theorem.

Output: viz_congestion_heatmap.png
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict


# ============================================================
# Self-contained implementations
# ============================================================

def gen_lattice_points(d, n):
    states = []
    def _gen(rem, dim, cur):
        if dim == 0:
            states.append(tuple(cur))
            return
        for i in range(rem + 1):
            _gen(rem - i, dim - 1, cur + [i])
    _gen(d, n, [])
    return states

def build_adj(states, n):
    s2i = {s: i for i, s in enumerate(states)}
    adj = defaultdict(list)
    for i, s in enumerate(states):
        for c in range(n):
            for delta in [-1, 1]:
                nb = list(s); nb[c] += delta; nbt = tuple(nb)
                if nbt in s2i:
                    j = s2i[nbt]
                    if j not in adj[i]: adj[i].append(j)
    return dict(adj)

def bfs_all(ns, adj):
    paths = {}
    for src in range(ns):
        dist = [-1]*ns; par = [-1]*ns; dist[src] = 0
        q = [src]; h = 0
        while h < len(q):
            u = q[h]; h += 1
            for v in adj.get(u, []):
                if dist[v] == -1:
                    dist[v] = dist[u]+1; par[v] = u; q.append(v)
        for t in range(ns):
            p = []; v = t
            while v != -1: p.append(v); v = par[v]
            p.reverse()
            paths[(src,t)] = p if dist[t] >= 0 else [src]
    return paths


# ============================================================
# Generate data
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Vertex Congestion Heatmaps on Newton Simplex Lattices',
             fontsize=15, fontweight='bold', y=0.98)

configs = [(3, 2), (4, 2), (5, 2), (3, 3)]
subplot_titles = ['d=3, n=2 (6 states)', 'd=4, n=2 (10 states)',
                  'd=5, n=2 (15 states)', 'd=3, n=3 (20 states)']

for idx, ((d, n), title) in enumerate(zip(configs, subplot_titles)):
    ax = axes[idx // 2][idx % 2]

    states = gen_lattice_points(d, n)
    ns = len(states)
    adj = build_adj(states, n)
    paths = bfs_all(ns, adj)

    # Compute vertex congestion
    load = np.zeros(ns)
    for p in paths.values():
        for v in p:
            load[v] += 1

    max_load = load.max()
    min_load = load.min()

    if n == 2:
        # 2D visualization
        positions = {i: (s[0], s[1]) for i, s in enumerate(states)}

        # Draw edges
        for i in range(ns):
            for j in adj.get(i, []):
                if j > i:
                    x = [positions[i][0], positions[j][0]]
                    y = [positions[i][1], positions[j][1]]
                    ax.plot(x, y, 'k-', alpha=0.2, linewidth=1)

        # Draw vertices colored by congestion
        xs = [positions[i][0] for i in range(ns)]
        ys = [positions[i][1] for i in range(ns)]

        scatter = ax.scatter(xs, ys, c=load, cmap='YlOrRd',
                           s=300, zorder=5, edgecolors='black',
                           linewidth=1, vmin=min_load, vmax=max_load)

        # Annotate with load values
        for i in range(ns):
            ax.annotate(f'{int(load[i])}', positions[i],
                       ha='center', va='center', fontsize=8,
                       fontweight='bold', color='black')

        # Draw simplex boundary
        ax.plot([0, d, 0, 0], [0, 0, d, 0], 'b-', alpha=0.15, linewidth=2)

        ax.set_xlabel('$x_1$', fontsize=11)
        ax.set_ylabel('$x_2$', fontsize=11)
        ax.set_aspect('equal')

    elif n == 3:
        # 3D → 2D projection using barycentric coordinates
        positions = {}
        for i, s in enumerate(states):
            total = sum(s) if sum(s) > 0 else 1
            # Barycentric to Cartesian
            x = s[0] + 0.5 * s[1]
            y = (np.sqrt(3) / 2) * s[1]
            positions[i] = (x, y)

        # Draw edges
        for i in range(ns):
            for j in adj.get(i, []):
                if j > i:
                    x = [positions[i][0], positions[j][0]]
                    y = [positions[i][1], positions[j][1]]
                    ax.plot(x, y, 'k-', alpha=0.2, linewidth=1)

        xs = [positions[i][0] for i in range(ns)]
        ys = [positions[i][1] for i in range(ns)]

        scatter = ax.scatter(xs, ys, c=load, cmap='YlOrRd',
                           s=250, zorder=5, edgecolors='black',
                           linewidth=1, vmin=min_load, vmax=max_load)

        for i in range(ns):
            ax.annotate(f'{int(load[i])}', positions[i],
                       ha='center', va='center', fontsize=7,
                       fontweight='bold', color='black')

        ax.set_xlabel('projected x', fontsize=11)
        ax.set_ylabel('projected y', fontsize=11)
        ax.set_aspect('equal')

    ax.set_title(f'{title}\nmax load = {int(max_load)}, '
                f'min load = {int(min_load)}, |Ω| = {ns}',
                fontsize=11)
    ax.grid(True, alpha=0.15)
    plt.colorbar(scatter, ax=ax, label='Vertex congestion', shrink=0.8)

    # Annotate the congestion lower bound
    ax.annotate(f'Lower bound: |Ω| = {ns}',
               xy=(0.02, 0.02), xycoords='axes fraction',
               fontsize=9, color='darkred', fontstyle='italic',
               bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.7))

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_congestion_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_congestion_heatmap.png")
