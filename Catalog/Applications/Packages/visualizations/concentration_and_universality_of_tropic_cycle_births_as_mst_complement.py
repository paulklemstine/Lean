"""
Visualization: Cycle Births as MST Complement

Illustrates Theorem 5: cycle-birth edges are exactly the non-MST edges.
Shows a small weighted graph with MST edges (blue) and cycle-birth edges (red),
plus a histogram comparing birth weights to MST weights.

This connects tropical Morse theory to combinatorial optimization:
the "tropical critical spectrum" of a graph is literally the weight spectrum
of edges rejected by Kruskal's algorithm.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


# Self-contained
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
    def connected(self, x, y):
        return self.find(x) == self.find(y)


def compute_births_and_mst(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    births = []
    mst = []
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            births.append((u, v, w))
        else:
            uf.union(u, v)
            mst.append((u, v, w))
    return births, mst


# Create a small example graph (K6 with specific weights)
n = 8
rng = np.random.default_rng(77)
edges = []
for i in range(n):
    for j in range(i + 1, n):
        if rng.random() < 0.5:
            edges.append((i, j, round(rng.random(), 2)))

births, mst = compute_births_and_mst(n, edges)

# Layout: circular
angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Graph with MST vs cycle-birth edges
ax = axes[0]

# Draw cycle-birth edges (red, dashed)
for u, v, w in births:
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    ax.plot(x, y, 'r--', linewidth=1.5, alpha=0.6)
    mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax.text(mx, my, f'{w}', fontsize=7, color='red', ha='center',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='white', alpha=0.8))

# Draw MST edges (blue, solid)
for u, v, w in mst:
    x = [pos[u][0], pos[v][0]]
    y = [pos[u][1], pos[v][1]]
    ax.plot(x, y, 'b-', linewidth=2.5, alpha=0.8)
    mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
    ax.text(mx, my, f'{w}', fontsize=7, color='blue', ha='center',
            bbox=dict(boxstyle='round,pad=0.15', facecolor='white', alpha=0.8))

# Draw vertices
for i in range(n):
    ax.plot(pos[i][0], pos[i][1], 'ko', markersize=12, zorder=5)
    ax.text(pos[i][0], pos[i][1], str(i), fontsize=9, ha='center',
            va='center', color='white', fontweight='bold', zorder=6)

mst_patch = mpatches.Patch(color='blue', label=f'MST edges ({len(mst)})')
birth_patch = mpatches.Patch(color='red', label=f'Cycle births ({len(births)})')
ax.legend(handles=[mst_patch, birth_patch], fontsize=10, loc='upper left')
ax.set_title(f'Graph (n={n}, m={len(edges)})\nMST ∪ CycleBirths = All Edges',
             fontsize=12, fontweight='bold')
ax.set_xlim(-1.4, 1.4)
ax.set_ylim(-1.4, 1.4)
ax.set_aspect('equal')
ax.axis('off')

# Verification text
ax.text(0.5, -0.08, f'Theorem 5: {len(mst)} + {len(births)} = {len(edges)} ✓',
        transform=ax.transAxes, fontsize=11, ha='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# Right panel: Weight distributions
ax = axes[1]

mst_w = [e[2] for e in mst]
birth_w = [e[2] for e in births]
all_w = sorted([e[2] for e in edges])

bins = np.linspace(0, 1, 15)
if mst_w:
    ax.hist(mst_w, bins=bins, alpha=0.6, color='blue', label='MST (merge) weights',
            edgecolor='white')
if birth_w:
    ax.hist(birth_w, bins=bins, alpha=0.6, color='red', label='Cycle-birth weights',
            edgecolor='white')

ax.set_xlabel('Edge Weight', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Weight Distribution:\nMST vs Cycle-Birth Edges', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Add summary statistics
if mst_w and birth_w:
    stats_text = (f'MST:  mean={np.mean(mst_w):.3f}, n={len(mst_w)}\n'
                  f'Birth: mean={np.mean(birth_w):.3f}, n={len(birth_w)}\n'
                  f'β₁ = {len(birth_w)}')
    ax.text(0.97, 0.97, stats_text, transform=ax.transAxes, fontsize=9,
            va='top', ha='right',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

fig.suptitle('Theorem 5: Cycle-Birth Edges = MST Complement',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mst_complement_plot.png', dpi=150, bbox_inches='tight')
print("Saved mst_complement_plot.png")
