"""
Visualization: MST Complement and Filtration Dichotomy

Illustrates Theorem 5: the fundamental partition of graph edges into
MST edges (merges) and cycle-birth edges (non-MST). Shows a small
graph with edges colored by their classification, plus the Betti
number trajectory through the filtration.

This visualizes the bridge between combinatorial optimization (MST)
and tropical topology (cycle births).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib


# ── Inline dependencies ──
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.nc = n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.nc -= 1
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)


# ── Generate a small graph for visualization ──
matplotlib.rcParams.update({'font.size': 11})
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

n = 8
rng = np.random.default_rng(55)

# Place vertices on a circle
angles = np.linspace(0, 2*np.pi, n, endpoint=False)
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

# Generate random edges
edges = []
for i in range(n):
    for j in range(i+1, n):
        if rng.random() < 0.5:
            edges.append((i, j, round(rng.random(), 3)))

# Sort by weight and classify
sorted_edges = sorted(edges, key=lambda e: e[2])
uf = UnionFind(n)
merge_edges = []
cb_edges = []
beta0_traj = [n]
beta1_traj = [0]
components = n
cycles = 0

for u, v, w in sorted_edges:
    if uf.connected(u, v):
        cb_edges.append((u, v, w))
        cycles += 1
    else:
        uf.union(u, v)
        merge_edges.append((u, v, w))
        components -= 1
    beta0_traj.append(components)
    beta1_traj.append(cycles)

# Left panel: Graph with edge coloring
ax = axes[0]
ax.set_xlim(-1.6, 1.6)
ax.set_ylim(-1.6, 1.6)
ax.set_aspect('equal')

# Draw MST edges (blue, thick)
for u, v, w in merge_edges:
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    ax.plot(x, y, 'b-', linewidth=2.5, alpha=0.7, zorder=1)
    mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax.text(mx, my, f'{w:.3f}', fontsize=7, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='lightblue', alpha=0.8))

# Draw cycle-birth edges (red, dashed)
for u, v, w in cb_edges:
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    ax.plot(x, y, 'r--', linewidth=2, alpha=0.7, zorder=1)
    mx, my = (x[0]+x[1])/2 + 0.05, (y[0]+y[1])/2 + 0.05
    ax.text(mx, my, f'{w:.3f}', fontsize=7, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='lightyellow', alpha=0.8))

# Draw vertices
for i in range(n):
    ax.plot(pos[i][0], pos[i][1], 'ko', markersize=12, zorder=2)
    ax.text(pos[i][0], pos[i][1], str(i), fontsize=9, ha='center', va='center',
            color='white', fontweight='bold', zorder=3)

blue_patch = mpatches.Patch(color='blue', label=f'MST edges ({len(merge_edges)})')
red_patch = mpatches.Patch(color='red', label=f'Cycle births ({len(cb_edges)})')
ax.legend(handles=[blue_patch, red_patch], loc='upper right', fontsize=10)
ax.set_title(f'Edge Partition: MST vs Cycle Births\n'
             f'{n} vertices, {len(edges)} edges', fontsize=13)
ax.axis('off')

# Right panel: Betti trajectory
ax = axes[1]
steps = range(len(beta0_traj))
ax.step(steps, beta0_traj, where='post', color='blue', linewidth=2,
        label='β₀ (components)')
ax.step(steps, beta1_traj, where='post', color='red', linewidth=2,
        label='β₁ (cycles)')

# Mark merge events and cycle births
merge_idx = 0
cb_idx = 0
for k, (u, v, w) in enumerate(sorted_edges):
    if (u, v, w) in merge_edges:
        ax.axvline(x=k+1, color='blue', alpha=0.15, linewidth=8)
    else:
        ax.axvline(x=k+1, color='red', alpha=0.15, linewidth=8)

ax.set_xlabel('Edge Insertion Order', fontsize=12)
ax.set_ylabel('Betti Number', fontsize=12)
ax.set_title('Betti Trajectory Through Filtration\n'
             'Blue bands = merges, Red bands = cycle births', fontsize=13)
ax.legend(fontsize=11)
ax.set_xlim(0, len(sorted_edges)+0.5)
ax.grid(True, alpha=0.3)

fig.suptitle('The Kruskal–Morse Duality\n'
             'MST edges decrease β₀, non-MST edges increase β₁',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mst_complement.png', dpi=150, bbox_inches='tight')
print("Saved viz_mst_complement.png")
