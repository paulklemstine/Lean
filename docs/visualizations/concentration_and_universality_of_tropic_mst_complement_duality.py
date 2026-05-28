#!/usr/bin/env python3
"""
Visualization 3: MST Complement Duality (Theorem 5)

Illustrates that cycle-birth edges are exactly the complement of the
minimum spanning tree edges. Shows a small graph with MST edges (blue)
and cycle-birth edges (red), plus the Euler characteristic identity.
"""

import numpy as np
import matplotlib.pyplot as plt


class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return True


# K6 graph
n = 6
edges = []
for i in range(n):
    for j in range(i+1, n):
        edges.append((i, j))

rng = np.random.default_rng(42)
weights = rng.random(len(edges))

# Compute cycle births
order = np.argsort(weights)
uf = UnionFind(n)
mst_idx, birth_idx = [], []
for idx in order:
    u, v = edges[idx]
    if uf.union(u, v):
        mst_idx.append(idx)
    else:
        birth_idx.append(idx)

# Layout: hexagonal
angles = np.linspace(0, 2*np.pi, n, endpoint=False) + np.pi/2
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))
fig.suptitle('MST Complement Duality (Theorem 5)\n'
             'Cycle births = all edges \\ MST edges',
             fontsize=14, fontweight='bold')

# Panel 1: All edges
ax = axes[0]
ax.set_title(f'All Edges ({len(edges)} edges)', fontsize=11)
for idx, (u, v) in enumerate(edges):
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax.plot(x, y, 'gray', linewidth=1.5, alpha=0.6)
    ax.text(mx, my, f'{weights[idx]:.2f}', fontsize=6, ha='center',
            bbox=dict(boxstyle='round,pad=0.1', facecolor='white', alpha=0.8))
for i in range(n):
    ax.plot(*pos[i], 'ko', markersize=12, zorder=5)
    ax.text(pos[i][0], pos[i][1], str(i), color='white', fontsize=8,
            ha='center', va='center', zorder=6, fontweight='bold')
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Panel 2: MST + Birth classification
ax = axes[1]
ax.set_title('MST (blue) vs Cycle Births (red)', fontsize=11)
for idx, (u, v) in enumerate(edges):
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    if idx in mst_idx:
        ax.plot(x, y, '#2196F3', linewidth=3, alpha=0.8, zorder=2)
    else:
        ax.plot(x, y, '#F44336', linewidth=2, alpha=0.6, linestyle='--', zorder=1)
for i in range(n):
    ax.plot(*pos[i], 'ko', markersize=12, zorder=5)
    ax.text(pos[i][0], pos[i][1], str(i), color='white', fontsize=8,
            ha='center', va='center', zorder=6, fontweight='bold')
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], color='#2196F3', linewidth=3, label=f'MST ({len(mst_idx)} edges)'),
    Line2D([0], [0], color='#F44336', linewidth=2, linestyle='--',
           label=f'Cycle Births ({len(birth_idx)} edges)'),
]
ax.legend(handles=legend_elements, loc='lower center', fontsize=9)

# Panel 3: Euler characteristic and Betti numbers
ax = axes[2]
ax.axis('off')
beta0 = n - len(mst_idx)
beta1 = len(birth_idx)
chi = n - len(edges)

text = (
    f"  K₆ with random weights\n\n"
    f"  V = {n} vertices\n"
    f"  E = {len(edges)} edges\n\n"
    f"  ─── Partition ───\n"
    f"  MST edges (merges):    {len(mst_idx)}\n"
    f"  Cycle births:          {len(birth_idx)}\n"
    f"  Total:                 {len(mst_idx)} + {len(birth_idx)} = {len(edges)} ✓\n\n"
    f"  ─── Betti Numbers ───\n"
    f"  β₀ = V - merges = {n} - {len(mst_idx)} = {beta0}\n"
    f"  β₁ = cycle births = {beta1}\n\n"
    f"  ─── Euler Characteristic ───\n"
    f"  χ = V - E = {n} - {len(edges)} = {chi}\n"
    f"  χ = β₀ - β₁ = {beta0} - {beta1} = {beta0 - beta1} ✓\n\n"
    f"  ─── Tree Test ───\n"
    f"  β₁ = 0? {'Yes → Tree' if beta1 == 0 else 'No → Has cycles'}"
)

ax.text(0.05, 0.95, text, transform=ax.transAxes, fontsize=10,
        verticalalignment='top', fontfamily='monospace',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_mst_complement.png', dpi=150, bbox_inches='tight')
print("Saved viz_mst_complement.png")
