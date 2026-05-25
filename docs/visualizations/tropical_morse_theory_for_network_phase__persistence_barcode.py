"""
Visualization: Persistence Barcode of a Weighted Graph Filtration

This script visualizes the persistence barcode arising from the tropical Morse
filtration. Each bar represents a topological feature:
- H₀ bars: connected components (born at 0, die at merge events)
- H₁ bars: independent cycles (born at cycle events, persist to ∞)

The key result: tropical persistence = classical persistence in degree 1.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n
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
        self.num_components -= 1
        return True
    def connected(self, x, y):
        return self.find(x) == self.find(y)

# Generate a graph
random.seed(2025)
n = 8
edges = []
for i in range(n):
    for j in range(i+1, n):
        if random.random() < 0.5:
            edges.append((random.random(), i, j))

sorted_edges = sorted(edges, key=lambda e: e[0])
uf = UnionFind(n)

h0_bars = []  # (birth, death)
h1_bars = []  # (birth, inf)
merge_deaths = []
cycle_births = []

for w, u, v in sorted_edges:
    if uf.connected(u, v):
        h1_bars.append((w, None))
        cycle_births.append(w)
    else:
        uf.union(u, v)
        h0_bars.append((0, w))
        merge_deaths.append(w)

# Add surviving H₀ bars
for _ in range(uf.num_components):
    h0_bars.append((0, None))

max_w = max(e[0] for e in edges) * 1.3 if edges else 1

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))

# H₀ barcode
ax1.set_title('H₀ Persistence Barcode\n(Connected Components)', fontsize=14, fontweight='bold')
h0_sorted = sorted(h0_bars, key=lambda x: x[1] if x[1] is not None else float('inf'), reverse=True)
for idx, (birth, death) in enumerate(h0_sorted):
    end = death if death is not None else max_w
    color = '#2196F3' if death is not None else '#1565C0'
    alpha = 0.8 if death is not None else 1.0
    lw = 3 if death is None else 2
    ax1.barh(idx, end - birth, left=birth, height=0.7, color=color, alpha=alpha, linewidth=0)
    if death is None:
        ax1.plot(max_w, idx, '>', color='#1565C0', markersize=8)
        ax1.text(max_w + 0.02, idx, '∞', fontsize=12, va='center', color='#1565C0')
    else:
        ax1.plot(death, idx, 'x', color='#F44336', markersize=8, markeredgewidth=2)

ax1.set_xlabel('Weight (threshold)', fontsize=12)
ax1.set_ylabel('Feature index', fontsize=12)
ax1.set_yticks(range(len(h0_sorted)))
finite_patch = mpatches.Patch(color='#2196F3', label=f'Finite bars ({sum(1 for b,d in h0_bars if d is not None)})')
inf_patch = mpatches.Patch(color='#1565C0', label=f'Infinite bars ({sum(1 for b,d in h0_bars if d is None)})')
ax1.legend(handles=[finite_patch, inf_patch], fontsize=10)
ax1.grid(True, alpha=0.2, axis='x')

# H₁ barcode
ax2.set_title('H₁ Persistence Barcode\n(Independent Cycles — Tropical = Classical)', fontsize=14, fontweight='bold')
h1_sorted = sorted(h1_bars, key=lambda x: x[0])
for idx, (birth, _) in enumerate(h1_sorted):
    ax2.barh(idx, max_w - birth, left=birth, height=0.7, color='#4CAF50', alpha=0.8, linewidth=0)
    ax2.plot(birth, idx, 'o', color='#FF9800', markersize=8, zorder=5)
    ax2.plot(max_w, idx, '>', color='#388E3C', markersize=8)
    ax2.text(max_w + 0.02, idx, '∞', fontsize=12, va='center', color='#388E3C')

ax2.set_xlabel('Weight (threshold)', fontsize=12)
ax2.set_ylabel('Feature index', fontsize=12)
ax2.set_yticks(range(len(h1_sorted)))

if h1_bars:
    birth_marker = plt.Line2D([0], [0], marker='o', color='#FF9800', linestyle='None', markersize=8,
                               label='Birth (cycle event)')
    bar_patch = mpatches.Patch(color='#4CAF50', label=f'Cycle classes ({len(h1_bars)})')
    ax2.legend(handles=[bar_patch, birth_marker], fontsize=10)
else:
    ax2.text(0.5, 0.5, 'No cycles\n(graph is a forest)', transform=ax2.transAxes,
             ha='center', va='center', fontsize=16, color='gray')

ax2.grid(True, alpha=0.2, axis='x')

fig.suptitle(f'Persistence Barcode — Weighted Graph ({n} vertices, {len(edges)} edges)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('persistence_barcode.png', dpi=150, bbox_inches='tight')
print("Saved persistence_barcode.png")
