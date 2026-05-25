"""
Visualization: Betti Number Evolution in a Graph Filtration

This script visualizes how the topological invariants β₀ (connected components)
and β₁ (independent cycles) evolve as edges are added to a graph in weight order.
The merge events (β₀ drops) and cycle events (β₁ rises) are marked, showing
the tropical Morse structure of the filtration.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random

# Import the algorithm
import sys
sys.path.insert(0, '.')

# Inline the algorithm to be self-contained
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

def compute_filtration(n, edges):
    sorted_edges = sorted(edges, key=lambda e: e[0])
    uf = UnionFind(n)
    b0, b1 = [n], [0]
    events = []
    weights = [0]
    for w, u, v in sorted_edges:
        if uf.connected(u, v):
            events.append('cycle')
            b1.append(b1[-1] + 1)
            b0.append(b0[-1])
        else:
            events.append('merge')
            uf.union(u, v)
            b0.append(b0[-1] - 1)
            b1.append(b1[-1])
        weights.append(w)
    return b0, b1, events, weights

# Generate K₆ with random weights
random.seed(42)
n = 6
edges = [(random.random(), i, j) for i in range(n) for j in range(i+1, n)]

b0, b1, events, weights = compute_filtration(n, edges)

fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(12, 10), sharex=True)

steps = np.arange(len(b0))

# Plot β₀
ax1.step(steps, b0, where='post', color='#2196F3', linewidth=2.5, label='β₀ (components)')
for i, ev in enumerate(events):
    if ev == 'merge':
        ax1.plot(i+1, b0[i+1], 'v', color='#F44336', markersize=10, zorder=5)
ax1.set_ylabel('β₀', fontsize=14, fontweight='bold')
ax1.set_title('Tropical Morse Filtration of K₆: Betti Number Evolution', fontsize=16, fontweight='bold')
ax1.legend(fontsize=12)
ax1.grid(True, alpha=0.3)
merge_marker = plt.Line2D([0], [0], marker='v', color='#F44336', linestyle='None', markersize=10, label='Merge event (β₀ drops)')
ax1.legend(handles=[mpatches.Patch(color='#2196F3', label='β₀ (components)'), merge_marker], fontsize=11)

# Plot β₁
ax2.step(steps, b1, where='post', color='#4CAF50', linewidth=2.5, label='β₁ (cycles)')
for i, ev in enumerate(events):
    if ev == 'cycle':
        ax2.plot(i+1, b1[i+1], '^', color='#FF9800', markersize=10, zorder=5)
ax2.set_ylabel('β₁', fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3)
cycle_marker = plt.Line2D([0], [0], marker='^', color='#FF9800', linestyle='None', markersize=10, label='Cycle event (β₁ rises)')
ax2.legend(handles=[mpatches.Patch(color='#4CAF50', label='β₁ (cycles)'), cycle_marker], fontsize=11)

# Plot event timeline
colors = ['#F44336' if e == 'merge' else '#FF9800' for e in events]
ax3.bar(range(1, len(events)+1), [1]*len(events), color=colors, alpha=0.8, width=0.6)
ax3.set_ylabel('Event', fontsize=14, fontweight='bold')
ax3.set_xlabel('Filtration Step', fontsize=14)
ax3.set_yticks([])
merge_patch = mpatches.Patch(color='#F44336', label='Merge (⊗)')
cycle_patch = mpatches.Patch(color='#FF9800', label='Cycle (⊕)')
ax3.legend(handles=[merge_patch, cycle_patch], fontsize=11, loc='upper right')
ax3.grid(True, alpha=0.3, axis='x')

# Add weight annotations
for i, (ev, w) in enumerate(zip(events, weights[1:])):
    ax3.text(i+1, 0.5, f'{w:.2f}', ha='center', va='center', fontsize=8, color='white', fontweight='bold')

plt.tight_layout()
plt.savefig('betti_evolution.png', dpi=150, bbox_inches='tight')
print("Saved betti_evolution.png")
