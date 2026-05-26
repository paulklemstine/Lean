"""
Visualization: Tropical State Graph and Path System

Illustrates the state graph for a degree-3 polynomial in 2 variables,
showing lattice points in the Newton simplex, adjacency edges, and
highlighted canonical paths demonstrating the tropical path system.

Output: viz_state_graph.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import defaultdict


# ============================================================
# Self-contained graph construction
# ============================================================

def gen_lattice_points(d, n):
    """Generate lattice points in {x : sum(x) <= d, x >= 0}."""
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
    """Build adjacency: differ by ±1 in one coordinate."""
    s2i = {s: i for i, s in enumerate(states)}
    adj = defaultdict(list)
    for i, s in enumerate(states):
        for c in range(n):
            for delta in [-1, 1]:
                nb = list(s)
                nb[c] += delta
                nbt = tuple(nb)
                if nbt in s2i:
                    j = s2i[nbt]
                    if j not in adj[i]:
                        adj[i].append(j)
    return dict(adj)


def bfs_path(ns, adj, src, tgt):
    """Single BFS shortest path from src to tgt."""
    dist = [-1] * ns
    par = [-1] * ns
    dist[src] = 0
    q = [src]
    h = 0
    while h < len(q):
        u = q[h]; h += 1
        if u == tgt:
            break
        for v in adj.get(u, []):
            if dist[v] == -1:
                dist[v] = dist[u] + 1
                par[v] = u
                q.append(v)
    path = []
    v = tgt
    while v != -1:
        path.append(v)
        v = par[v]
    path.reverse()
    return path


# ============================================================
# Visualization
# ============================================================

d = 4  # Degree
n = 2  # Variables

states = gen_lattice_points(d, n)
ns = len(states)
adj = build_adj(states, n)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: Full state graph ---
ax = axes[0]
ax.set_title(f'Newton Simplex State Graph\nd={d}, n={n} ({ns} states)',
             fontsize=13, fontweight='bold')

# Position states at their lattice coordinates
positions = {i: (s[0], s[1]) for i, s in enumerate(states)}

# Draw edges
for i in range(ns):
    for j in adj.get(i, []):
        if j > i:  # Draw each edge once
            x = [positions[i][0], positions[j][0]]
            y = [positions[i][1], positions[j][1]]
            ax.plot(x, y, 'k-', alpha=0.3, linewidth=1)

# Color by degree sum
deg_sums = [sum(s) for s in states]
max_deg = max(deg_sums)
colors_map = plt.cm.viridis(np.array(deg_sums) / max(max_deg, 1))

for i in range(ns):
    ax.scatter(*positions[i], c=[colors_map[i]], s=200, zorder=5,
              edgecolors='black', linewidth=1)
    ax.annotate(f'{states[i]}', positions[i],
               textcoords="offset points", xytext=(0, -15),
               ha='center', fontsize=7, color='gray')

# Draw the simplex boundary
ax.plot([0, d, 0, 0], [0, 0, d, 0], 'b-', alpha=0.2, linewidth=2)

ax.set_xlabel('$x_1$', fontsize=12)
ax.set_ylabel('$x_2$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.2)

# --- Right panel: Highlighted canonical paths ---
ax2 = axes[1]
ax2.set_title(f'Canonical Tropical Paths\nDiameter highlighted in red',
              fontsize=13, fontweight='bold')

# Draw all edges lightly
for i in range(ns):
    for j in adj.get(i, []):
        if j > i:
            x = [positions[i][0], positions[j][0]]
            y = [positions[i][1], positions[j][1]]
            ax2.plot(x, y, 'k-', alpha=0.15, linewidth=1)

# Draw all vertices
for i in range(ns):
    ax2.scatter(*positions[i], c='lightgray', s=150, zorder=3,
               edgecolors='gray', linewidth=0.5)

# Find the diameter path
max_len = 0
max_path = None
for i in range(ns):
    for j in range(ns):
        p = bfs_path(ns, adj, i, j)
        if len(p) - 1 > max_len:
            max_len = len(p) - 1
            max_path = p

# Highlight the diameter path
if max_path:
    for k in range(len(max_path) - 1):
        x = [positions[max_path[k]][0], positions[max_path[k+1]][0]]
        y = [positions[max_path[k]][1], positions[max_path[k+1]][1]]
        ax2.plot(x, y, 'r-', linewidth=3, alpha=0.8, zorder=4)
    for v in max_path:
        ax2.scatter(*positions[v], c='red', s=200, zorder=5,
                   edgecolors='darkred', linewidth=1.5)

    # Highlight start and end
    ax2.scatter(*positions[max_path[0]], c='green', s=300, zorder=6,
               edgecolors='darkgreen', linewidth=2, marker='s', label='Start')
    ax2.scatter(*positions[max_path[-1]], c='blue', s=300, zorder=6,
               edgecolors='darkblue', linewidth=2, marker='^', label='End')

    ax2.annotate(f'Diameter = {max_len}',
                xy=(0.02, 0.98), xycoords='axes fraction',
                fontsize=11, fontweight='bold', color='red',
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Also show a few other paths in different colors
sample_pairs = [(0, ns-1), (1, ns-2)]
path_colors = ['#2196F3', '#FF9800']
for idx, (i, j) in enumerate(sample_pairs):
    if i < ns and j < ns and i != j:
        p = bfs_path(ns, adj, i, j)
        if p and p != max_path:
            for k in range(len(p) - 1):
                x = [positions[p[k]][0], positions[p[k+1]][0]]
                y = [positions[p[k]][1], positions[p[k+1]][1]]
                ax2.plot(x, y, color=path_colors[idx % len(path_colors)],
                        linewidth=2, alpha=0.6, zorder=4)

ax2.set_xlabel('$x_1$', fontsize=12)
ax2.set_ylabel('$x_2$', fontsize=12)
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.2)
ax2.legend(fontsize=9, loc='lower right')

plt.tight_layout()
plt.savefig('viz_state_graph.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_state_graph.png")
