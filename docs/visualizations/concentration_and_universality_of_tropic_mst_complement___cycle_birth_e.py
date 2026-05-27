"""
Visualization: MST Complement = Cycle-Birth Edges

Illustrates Theorem 5: in a weighted graph filtration, cycle-birth edges
are exactly the edges NOT in the minimum spanning tree. Shows a small
graph example with MST edges (blue) and cycle-birth edges (red), plus
the weight spectrum decomposition.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ---- Inlined algorithms ----

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
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True


# ---- Build a small example ----

n = 8
np.random.seed(42)
positions = np.array([
    [0, 1], [1, 1.8], [2, 1], [1, 0],
    [3, 1.5], [4, 1], [3, 0], [4, 0]
], dtype=float)

# Generate edges with weights = Euclidean distance + noise
edges = []
for i in range(n):
    for j in range(i+1, n):
        dist = np.linalg.norm(positions[i] - positions[j])
        if dist < 2.5:  # only nearby edges
            w = dist + np.random.uniform(-0.1, 0.1)
            edges.append((i, j, w))

# Classify edges
sorted_edges = sorted(edges, key=lambda e: e[2])
uf = UnionFind(n)
mst_edges = []
cycle_edges = []
for u, v, w in sorted_edges:
    if uf.union(u, v):
        mst_edges.append((u, v, w))
    else:
        cycle_edges.append((u, v, w))

# ---- Plot ----

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Theorem 5: Cycle-Birth Edges = Non-MST Edges',
             fontsize=14, fontweight='bold')

# Left: Graph with edge classification
ax1.set_title('Graph with Edge Classification', fontsize=12, fontweight='bold')

# Draw cycle-birth edges (red, dashed)
for u, v, w in cycle_edges:
    x = [positions[u][0], positions[v][0]]
    y = [positions[u][1], positions[v][1]]
    ax1.plot(x, y, 'r--', linewidth=1.5, alpha=0.6)
    mid_x, mid_y = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax1.text(mid_x, mid_y + 0.1, f'{w:.2f}', fontsize=7, ha='center', color='red')

# Draw MST edges (blue, solid)
for u, v, w in mst_edges:
    x = [positions[u][0], positions[v][0]]
    y = [positions[u][1], positions[v][1]]
    ax1.plot(x, y, 'b-', linewidth=2.5, alpha=0.8)
    mid_x, mid_y = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax1.text(mid_x, mid_y + 0.1, f'{w:.2f}', fontsize=7, ha='center', color='blue')

# Draw vertices
for i, (x, y) in enumerate(positions):
    ax1.scatter(x, y, s=200, c='white', edgecolors='black', linewidth=2, zorder=5)
    ax1.text(x, y, str(i), fontsize=10, ha='center', va='center', zorder=6,
             fontweight='bold')

ax1.legend(
    [plt.Line2D([0], [0], color='blue', linewidth=2.5),
     plt.Line2D([0], [0], color='red', linewidth=1.5, linestyle='--')],
    [f'MST edges ({len(mst_edges)})',
     f'Cycle-birth edges ({len(cycle_edges)})'],
    fontsize=10, loc='lower right'
)
ax1.set_xlim(-0.5, 4.5)
ax1.set_ylim(-0.5, 2.3)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.2)

# Right: Weight spectrum decomposition
ax2.set_title('Weight Spectrum Decomposition', fontsize=12, fontweight='bold')

mst_w = [w for _, _, w in mst_edges]
cycle_w = [w for _, _, w in cycle_edges]

bins = np.linspace(
    min(w for _, _, w in sorted_edges) - 0.1,
    max(w for _, _, w in sorted_edges) + 0.1,
    15
)

ax2.hist(mst_w, bins=bins, alpha=0.7, color='steelblue',
         label=f'MST edges (n-1 = {len(mst_edges)})', edgecolor='white')
ax2.hist(cycle_w, bins=bins, alpha=0.7, color='salmon',
         label=f'Cycle births (β₁ = {len(cycle_edges)})', edgecolor='white')
ax2.set_xlabel('Edge weight', fontsize=11)
ax2.set_ylabel('Count', fontsize=11)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Annotations
total = len(mst_edges) + len(cycle_edges)
ax2.annotate(
    f'Total edges: {total}\n'
    f'MST edges: {len(mst_edges)} = n-1\n'
    f'Cycle births: {len(cycle_edges)} = β₁\n'
    f'Sum: {len(mst_edges)} + {len(cycle_edges)} = {total} ✓',
    xy=(0.95, 0.95), xycoords='axes fraction',
    fontsize=9, ha='right', va='top',
    bbox=dict(boxstyle='round', fc='lightyellow', alpha=0.9)
)

plt.tight_layout()
plt.savefig('viz_mst_complement.png', dpi=150, bbox_inches='tight')
print("Saved viz_mst_complement.png")
