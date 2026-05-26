"""
Visualization: Cycle Support Weight Heatmap

This script creates a heatmap showing the cycle support weight (csw) of
each edge in a weighted graph. The csw captures the "tropical shadow"
of the global systole: it measures how close each edge is to participating
in a minimum-weight cycle.

Edges with csw equal to the weighted systole are part of optimal cycles.
Edges with csw = infinity are bridges (never in any cycle).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict

# ===== Inline all needed functions =====

class WeightedGraph:
    def __init__(self):
        self.vertices = set()
        self.edges = {}
        self.adj = defaultdict(set)
    def add_edge(self, u, v, weight):
        a, b = min(u, v), max(u, v)
        self.vertices.add(a); self.vertices.add(b)
        self.edges[(a, b)] = weight
        self.adj[a].add(b); self.adj[b].add(a)

def enumerate_simple_cycles(G):
    vertices = sorted(G.vertices)
    cycles, seen = [], set()
    def dfs(start, current, path, visited):
        for nb in sorted(G.adj[current]):
            if nb == start and len(path) >= 3:
                ce = []
                for i in range(len(path)):
                    u, v = path[i], path[(i+1) % len(path)]
                    ce.append((min(u,v), max(u,v)))
                key = tuple(sorted(ce))
                if key not in seen: seen.add(key); cycles.append(ce)
            elif nb > start and nb not in visited:
                visited.add(nb); path.append(nb)
                dfs(start, nb, path, visited)
                path.pop(); visited.remove(nb)
    for v in vertices: dfs(v, v, [v], {v})
    return cycles

def cycle_weight(G, c): return sum(G.edges[e] for e in c)

def cycle_support_weight(G, edge):
    cycles = enumerate_simple_cycles(G)
    relevant = [c for c in cycles if edge in c]
    return min(cycle_weight(G, c) for c in relevant) if relevant else float('inf')

# ===== Build example: K5 with random weights =====

import random
random.seed(2025)

G = WeightedGraph()
n = 6
for i in range(n):
    for j in range(i+1, n):
        G.add_edge(i, j, random.randint(1, 8))

edges = sorted(G.edges.keys())
csw_values = {e: cycle_support_weight(G, e) for e in edges}
min_csw = min(csw_values.values())

# ===== Create visualization =====

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Graph with edges colored by CSW
angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
pos = {i: (1.2*np.cos(a), 1.2*np.sin(a)) for i, a in enumerate(angles)}

ax1.set_aspect('equal')
ax1.set_xlim(-2, 2); ax1.set_ylim(-2, 2)
ax1.set_title(f'K{n} with Cycle Support Weights', fontsize=14, fontweight='bold')
ax1.axis('off')

finite_csw = [v for v in csw_values.values() if v < float('inf')]
vmin, vmax = min(finite_csw), max(finite_csw)
cmap = plt.cm.RdYlGn_r

for (u, v), csw in csw_values.items():
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    t = (csw - vmin) / (vmax - vmin) if vmax > vmin else 0.5
    color = cmap(t)
    lw = 4 if abs(csw - min_csw) < 0.01 else 2
    ax1.plot(x, y, color=color, linewidth=lw, zorder=1)
    mx, my = (x[0]+x[1])/2 + 0.05, (y[0]+y[1])/2 + 0.05
    ax1.text(mx, my, f'{G.edges[(u,v)]}', ha='center', va='center',
            fontsize=8, color='#333',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='white', alpha=0.7))

for v_id, (x, y) in pos.items():
    ax1.plot(x, y, 'o', color='#2196F3', markersize=22, zorder=2)
    ax1.text(x, y, str(v_id), ha='center', va='center',
            fontsize=12, color='white', fontweight='bold', zorder=3)

sm = plt.cm.ScalarMappable(cmap=cmap, norm=plt.Normalize(vmin=vmin, vmax=vmax))
plt.colorbar(sm, ax=ax1, label='Cycle Support Weight', shrink=0.8)

# Panel 2: Bar chart of CSW values
edge_labels = [f'{u}-{v}' for u, v in edges]
csw_vals = [csw_values[e] for e in edges]
colors = ['#27ae60' if abs(v - min_csw) < 0.01 else '#e74c3c' if v > min_csw * 1.5 else '#f39c12'
          for v in csw_vals]

bars = ax2.barh(range(len(edges)), csw_vals, color=colors, edgecolor='white')
ax2.set_yticks(range(len(edges)))
ax2.set_yticklabels(edge_labels, fontsize=9)
ax2.set_xlabel('Cycle Support Weight', fontsize=12)
ax2.set_title('CSW per Edge\n(green = in minimum cycle)', fontsize=14, fontweight='bold')
ax2.axvline(x=min_csw, color='#27ae60', linestyle='--', linewidth=2, label=f'Min CSW = {min_csw}')
ax2.legend(fontsize=10)
ax2.invert_yaxis()

for i, (bar, val) in enumerate(zip(bars, csw_vals)):
    ax2.text(val + 0.3, i, f'{val:.0f}', va='center', fontsize=9)

fig.suptitle('Cycle Support Weight: The Tropical Shadow of the Systole',
             fontsize=16, fontweight='bold', y=0.98)
plt.tight_layout()
plt.savefig('viz_cycle_support_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_cycle_support_heatmap.png")
