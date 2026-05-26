"""
Visualization: Betti Number Evolution During Kruskal Filtration

Shows how β₀ (connected components) and β₁ (independent cycles) evolve
as edges are added in weight order. Demonstrates the Euler conservation
law β₀ - β₁ = V - E at every step.

Uses matplotlib to produce a static plot saved as PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random


# ── Self-contained TMS implementation ─────────────────────────────────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.n = n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def same(self, u, v): return self.find(u) == self.find(v)
    def union(self, u, v):
        ru, rv = self.find(u), self.find(v)
        if ru == rv: return False
        if self.rank[ru] < self.rank[rv]: ru, rv = rv, ru
        self.parent[rv] = ru
        if self.rank[ru] == self.rank[rv]: self.rank[ru] += 1
        return True


def compute_betti_evolution(n, edges):
    """Compute β₀, β₁ at each step of the filtration."""
    uf = UnionFind(n)
    sorted_edges = sorted(edges)
    
    weights = [0.0]
    beta0s = [n]
    beta1s = [0]
    event_types = ['init']
    
    for w, u, v in sorted_edges:
        if uf.same(u, v):
            beta0s.append(beta0s[-1])
            beta1s.append(beta1s[-1] + 1)
            event_types.append('cycle')
        else:
            uf.union(u, v)
            beta0s.append(beta0s[-1] - 1)
            beta1s.append(beta1s[-1])
            event_types.append('merge')
        weights.append(w)
    
    return weights, beta0s, beta1s, event_types


# ── Generate example graph ────────────────────────────────────────────

random.seed(42)
n = 10
edges = []
for i in range(n):
    for j in range(i + 1, n):
        if random.random() < 0.45:
            edges.append((round(random.uniform(1, 20), 1), i, j))

weights, beta0s, beta1s, event_types = compute_betti_evolution(n, edges)
chis = [b0 - b1 for b0, b1 in zip(beta0s, beta1s)]

# ── Create visualization ─────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), sharex=True,
                                gridspec_kw={'height_ratios': [3, 1]})

steps = list(range(len(weights)))

# Top panel: Betti numbers
ax1.step(steps, beta0s, where='post', color='#2196F3', linewidth=2.5,
         label='β₀ (components)', zorder=3)
ax1.step(steps, beta1s, where='post', color='#F44336', linewidth=2.5,
         label='β₁ (cycles)', zorder=3)
ax1.step(steps, chis, where='post', color='#4CAF50', linewidth=2,
         linestyle='--', label='χ = β₀ - β₁', zorder=2)

# Mark merge and cycle events
for i, et in enumerate(event_types):
    if et == 'merge':
        ax1.plot(i, beta0s[i], 'v', color='#2196F3', markersize=8, zorder=4)
    elif et == 'cycle':
        ax1.plot(i, beta1s[i], '^', color='#F44336', markersize=8, zorder=4)

ax1.set_ylabel('Betti Number', fontsize=13)
ax1.set_title('Betti Number Evolution During Kruskal Filtration\n'
              f'({n} vertices, {len(edges)} edges)', fontsize=15, fontweight='bold')
ax1.legend(fontsize=11, loc='center right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.5, max(beta0s) + 1)

# Add text annotation
ax1.text(0.98, 0.95, 'Euler Conservation Law:\nβ₀ - β₁ = V - E at every step',
         transform=ax1.transAxes, fontsize=10, verticalalignment='top',
         horizontalalignment='right',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Bottom panel: Event type bar chart
colors = []
for et in event_types:
    if et == 'merge':
        colors.append('#2196F3')
    elif et == 'cycle':
        colors.append('#F44336')
    else:
        colors.append('#CCCCCC')

ax2.bar(steps, [1] * len(steps), color=colors, width=0.8, alpha=0.7)
ax2.set_ylabel('Event', fontsize=13)
ax2.set_xlabel('Filtration Step', fontsize=13)
ax2.set_yticks([])

merge_patch = mpatches.Patch(color='#2196F3', alpha=0.7, label='Merge (β₀ ↓)')
cycle_patch = mpatches.Patch(color='#F44336', alpha=0.7, label='Cycle (β₁ ↑)')
ax2.legend(handles=[merge_patch, cycle_patch], fontsize=10, loc='upper right')

# Add weight labels on x-axis
for i, w in enumerate(weights):
    if i > 0 and i % 2 == 0:
        ax2.text(i, -0.3, f'{w:.1f}', ha='center', va='top', fontsize=7,
                 color='gray')

plt.tight_layout()
plt.savefig('viz_betti_evolution.png', dpi=150, bbox_inches='tight')
print("Saved: viz_betti_evolution.png")
