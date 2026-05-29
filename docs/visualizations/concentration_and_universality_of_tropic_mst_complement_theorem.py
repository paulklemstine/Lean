"""
Visualization: MST Complement Theorem — Cycle Births as Non-Tree Edges.

This script visualizes the MST complement theorem (Theorem 5): for a weighted
graph, the cycle-birth edges are exactly the edges NOT in the minimum spanning
tree. The plot shows a small graph with MST edges (solid, blue) and cycle-birth
edges (dashed, red), along with a weight spectrum comparison.

What it visualizes: The structural duality between MST construction (Kruskal's
algorithm) and cycle-birth detection — two perspectives on the same filtration
process, connecting combinatorial optimization with tropical topology.
"""

import numpy as np
import matplotlib.pyplot as plt


class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n

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
        return True


# Create a small graph for visualization
n = 8
rng = np.random.default_rng(17)

# Generate positions for vertices on a circle
angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
positions = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

# Generate edges with random weights
edges = []
for i in range(n):
    for j in range(i + 1, n):
        if rng.random() < 0.5:
            edges.append((i, j, round(rng.random() * 10, 1)))

# Compute filtration
sorted_edges = sorted(edges, key=lambda e: e[2])
uf = UnionFind(n)
mst_edges = []
birth_edges = []
for u, v, w in sorted_edges:
    if uf.union(u, v):
        mst_edges.append((u, v, w))
    else:
        birth_edges.append((u, v, w))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('MST Complement Theorem: Cycle Births = Non-Tree Edges',
             fontsize=14, fontweight='bold')

# Left: Graph visualization
ax1.set_title('Graph with MST and Cycle-Birth Edges', fontweight='bold')
ax1.set_aspect('equal')

# Draw cycle-birth edges (dashed red) first (background)
for u, v, w in birth_edges:
    x1, y1 = positions[u]
    x2, y2 = positions[v]
    ax1.plot([x1, x2], [y1, y2], 'r--', linewidth=1.5, alpha=0.6)
    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
    ax1.text(mx, my, f'{w}', fontsize=7, ha='center', va='center',
             color='red', alpha=0.8,
             bbox=dict(boxstyle='round,pad=0.15', facecolor='white', alpha=0.7))

# Draw MST edges (solid blue)
for u, v, w in mst_edges:
    x1, y1 = positions[u]
    x2, y2 = positions[v]
    ax1.plot([x1, x2], [y1, y2], 'b-', linewidth=2.5, alpha=0.8)
    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
    ax1.text(mx, my, f'{w}', fontsize=7, ha='center', va='center',
             color='blue', fontweight='bold',
             bbox=dict(boxstyle='round,pad=0.15', facecolor='lightyellow', alpha=0.9))

# Draw vertices
for i, (x, y) in positions.items():
    ax1.plot(x, y, 'ko', markersize=12, zorder=5)
    ax1.text(x, y, str(i), fontsize=9, ha='center', va='center',
             color='white', fontweight='bold', zorder=6)

ax1.legend(['Cycle birth (non-MST)', 'MST edge'],
           loc='lower left', fontsize=9)
ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)
ax1.axis('off')

# Stats annotation
stats_text = (f"Vertices: {n}\n"
              f"Edges: {len(edges)}\n"
              f"MST edges: {len(mst_edges)}\n"
              f"Cycle births: {len(birth_edges)}\n"
              f"β₁ = {len(birth_edges)}")
ax1.text(0.02, 0.98, stats_text, transform=ax1.transAxes,
         fontsize=9, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow'))

# Right: Weight spectrum comparison
ax2.set_title('Weight Spectrum: MST vs Cycle-Birth Edges', fontweight='bold')

mst_weights = [w for _, _, w in mst_edges]
birth_weights = [w for _, _, w in birth_edges]

if mst_weights and birth_weights:
    all_weights = mst_weights + birth_weights
    bins = np.linspace(min(all_weights) - 0.5, max(all_weights) + 0.5, 15)

    ax2.hist(mst_weights, bins=bins, alpha=0.6, color='blue',
             label=f'MST edges (n={len(mst_weights)})', edgecolor='navy')
    ax2.hist(birth_weights, bins=bins, alpha=0.6, color='red',
             label=f'Cycle births (n={len(birth_weights)})', edgecolor='darkred')

    ax2.axvline(x=np.max(mst_weights), color='blue', linestyle=':', alpha=0.5)
    ax2.axvline(x=np.min(birth_weights), color='red', linestyle=':', alpha=0.5)

ax2.set_xlabel('Edge weight')
ax2.set_ylabel('Count')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

explanation = ("Kruskal's algorithm accepts\n"
               "light edges (MST) and rejects\n"
               "edges that close cycles.\n\n"
               "cycle births = E \\ MST")
ax2.text(0.95, 0.95, explanation, transform=ax2.transAxes,
         fontsize=9, ha='right', va='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow'))

plt.tight_layout()
plt.savefig('mst_complement_plot.png', dpi=150, bbox_inches='tight')
print("Saved mst_complement_plot.png")
