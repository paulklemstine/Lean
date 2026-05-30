"""
Visualization 1: Tropical Spectrum of Graph Filtrations

Visualizes the tropical spectrum (cycle-birth weights) for several
graph families, showing how topological complexity accumulates
during the edge-insertion process.

What it shows:
- The filtration process for complete graphs K3 through K7
- Merge events (green) vs cycle-birth events (red)
- The tropical spectrum highlighted as the cycle-birth weights
- The cumulative cycle-birth CDF (monotone step function)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random


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


def extract_filtration(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    merges = []
    cycles = []
    for u, v, w in sorted_edges:
        if uf.union(u, v):
            merges.append(w)
        else:
            cycles.append(w)
    return merges, cycles


fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Tropical Spectrum of Complete Graph Filtrations',
             fontsize=16, fontweight='bold', y=0.98)

for idx, n in enumerate([3, 4, 5, 6, 7]):
    row, col = idx // 3, idx % 3
    ax = axes[row][col]

    # Complete graph with sequential weights
    edges = []
    w = 1
    for i in range(n):
        for j in range(i+1, n):
            edges.append((i, j, w))
            w += 1

    merges, cycles = extract_filtration(n, edges)
    m = len(edges)

    # Plot filtration timeline
    all_weights = sorted([e[2] for e in edges])
    merge_set = set(merges)
    cycle_set = set(cycles)

    colors = []
    for w in all_weights:
        if w in cycle_set:
            colors.append('#e74c3c')  # red for cycle births
        else:
            colors.append('#2ecc71')  # green for merges

    ax.bar(range(m), all_weights, color=colors, alpha=0.8, width=0.8)

    # Highlight tropical spectrum
    ax.set_title(f'K_{n}: {len(cycles)} cycles, {len(merges)} merges',
                 fontsize=12, fontweight='bold')
    ax.set_xlabel('Edge insertion order')
    ax.set_ylabel('Edge weight')

    # Add spectrum annotation
    if cycles:
        spec_str = ', '.join(str(int(c)) for c in cycles[:5])
        if len(cycles) > 5:
            spec_str += '...'
        ax.text(0.02, 0.95, f'σ = [{spec_str}]',
                transform=ax.transAxes, fontsize=9,
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    # Euler-Poincaré verification
    ep_text = f'{m} = {len(merges)} + {len(cycles)}'
    ax.text(0.02, 0.82, f'E-P: {ep_text}',
            transform=ax.transAxes, fontsize=8, color='#555')

# Last panel: Cumulative CDF comparison
ax = axes[1][2]
for n, color, label in [(4, '#3498db', 'K₄'), (5, '#e67e22', 'K₅'),
                         (6, '#9b59b6', 'K₆'), (7, '#1abc9c', 'K₇')]:
    edges = []
    w = 1
    for i in range(n):
        for j in range(i+1, n):
            edges.append((i, j, w))
            w += 1
    _, cycles = extract_filtration(n, edges)
    total_cycles = len(cycles)
    if total_cycles == 0:
        continue
    # CDF
    all_w = sorted([e[2] for e in edges])
    ts = np.linspace(0, max(all_w) + 1, 200)
    cdf = [sum(1 for c in cycles if c <= t) / total_cycles for t in ts]
    ax.plot(ts, cdf, color=color, linewidth=2, label=label)

ax.set_title('Cycle-Birth CDF (Normalized)', fontsize=12, fontweight='bold')
ax.set_xlabel('Threshold t')
ax.set_ylabel('Fraction of cycles born ≤ t')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Legend
merge_patch = mpatches.Patch(color='#2ecc71', alpha=0.8, label='Merge (connects components)')
cycle_patch = mpatches.Patch(color='#e74c3c', alpha=0.8, label='Cycle birth (creates loop)')
fig.legend(handles=[merge_patch, cycle_patch], loc='lower center',
           ncol=2, fontsize=11, frameon=True, fancybox=True)

plt.tight_layout(rect=[0, 0.05, 1, 0.95])
plt.savefig('viz_tropical_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_spectrum.png")
