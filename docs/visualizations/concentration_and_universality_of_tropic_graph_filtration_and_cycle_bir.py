"""
Visualization: Graph Filtration and Cycle-Birth Process

This script visualizes the tropical Morse filtration of a small weighted graph,
showing how edges are added in order of weight and how each addition either
merges two components (MST edge) or creates a cycle (cycle-birth edge).

The plot shows the filtration timeline with merge events below and cycle-birth
events above, plus the evolving Betti numbers β₀ (components) and β₁ (cycles).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


# ============================================================
# Inline implementations (self-contained)
# ============================================================

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.n_components = n

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
        self.n_components -= 1
        return True


# ============================================================
# Generate a small example
# ============================================================

rng = np.random.default_rng(17)
n = 8
edges = []
for i in range(n):
    for j in range(i + 1, n):
        if rng.random() < 0.45:
            edges.append((i, j))

m = len(edges)
weights = rng.uniform(0, 1, m)

# Run Kruskal
order = np.argsort(weights)
uf = UnionFind(n)

steps = []  # (weight, edge, is_merge, beta0, beta1)
beta0, beta1 = n, 0

for idx in order:
    w = weights[idx]
    u, v = edges[idx]
    is_merge = uf.union(u, v)
    if is_merge:
        beta0 -= 1
        steps.append((w, (u, v), True, beta0, beta1))
    else:
        beta1 += 1
        steps.append((w, (u, v), False, beta0, beta1))

# ============================================================
# Create figure
# ============================================================

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 8), height_ratios=[3, 2],
                                gridspec_kw={'hspace': 0.3})

fig.suptitle('Tropical Morse Filtration: Merge vs Cycle-Birth Events',
             fontsize=16, fontweight='bold', y=0.98)

# Top panel: Event timeline
merge_color = '#2196F3'
cycle_color = '#FF5722'

for i, (w, (u, v), is_merge, b0, b1) in enumerate(steps):
    if is_merge:
        ax1.bar(i, -1, bottom=0, color=merge_color, alpha=0.7, width=0.8,
               edgecolor='white', linewidth=0.5)
        ax1.text(i, -0.5, f'{u}-{v}', ha='center', va='center',
                fontsize=7, color='white', fontweight='bold')
    else:
        ax1.bar(i, 1, bottom=0, color=cycle_color, alpha=0.7, width=0.8,
               edgecolor='white', linewidth=0.5)
        ax1.text(i, 0.5, f'{u}-{v}', ha='center', va='center',
                fontsize=7, color='white', fontweight='bold')

    # Weight label
    ax1.text(i, -1.4 if is_merge else 1.3, f'{w:.2f}',
            ha='center', va='center', fontsize=7, rotation=45)

ax1.axhline(y=0, color='black', linewidth=1.5)
ax1.set_xlim(-0.5, len(steps) - 0.5)
ax1.set_ylim(-1.8, 1.8)
ax1.set_xlabel('Edge insertion order (by weight)', fontsize=11)
ax1.set_ylabel('Event type', fontsize=11)
ax1.set_yticks([-0.5, 0.5])
ax1.set_yticklabels(['MERGE\n(MST edge)', 'CYCLE BIRTH\n(non-MST edge)'], fontsize=9)

merge_patch = mpatches.Patch(color=merge_color, alpha=0.7, label=f'Merge events (MST edges)')
cycle_patch = mpatches.Patch(color=cycle_color, alpha=0.7, label=f'Cycle births (non-MST edges)')
ax1.legend(handles=[merge_patch, cycle_patch], loc='upper right', fontsize=10)

# Count events
n_merges = sum(1 for _, _, m, _, _ in steps if m)
n_cycles = sum(1 for _, _, m, _, _ in steps if not m)
ax1.text(0.02, 0.95, f'n={n}, m={len(steps)}\nMerges: {n_merges}, Cycles: {n_cycles}',
        transform=ax1.transAxes, fontsize=10,
        verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Bottom panel: Betti numbers
x_vals = list(range(len(steps)))
b0_vals = [s[3] for s in steps]
b1_vals = [s[4] for s in steps]

ax2.step(x_vals, b0_vals, where='post', color=merge_color, linewidth=2.5,
        label='β₀ (components)', marker='o', markersize=4)
ax2.step(x_vals, b1_vals, where='post', color=cycle_color, linewidth=2.5,
        label='β₁ (cycles)', marker='s', markersize=4)

ax2.set_xlabel('Edge insertion order', fontsize=11)
ax2.set_ylabel('Betti number', fontsize=11)
ax2.legend(fontsize=11, loc='center right')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, len(steps) - 0.5)

# Add Euler characteristic annotation
chi = b0_vals[-1] - b1_vals[-1]
ax2.text(0.02, 0.95, f'Final: β₀={b0_vals[-1]}, β₁={b1_vals[-1]}\n'
        f'χ = β₀ - β₁ = {chi}\n'
        f'V - E = {n} - {len(steps)} = {n - len(steps)}',
        transform=ax2.transAxes, fontsize=10,
        verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.savefig('viz_filtration.png', dpi=150, bbox_inches='tight')
print("Saved viz_filtration.png")
