"""
Visualization: Phase Transition Heatmap for Random Graphs

This script produces a heatmap showing how the ratio of cycle events to merge events
changes as we vary the edge density p in G(n,p). The transition from merge-dominated
(forest-like, subcritical) to cycle-dominated (dense, supercritical) regime is the
topological signature of the Erdős–Rényi phase transition, viewed through the lens
of tropical Morse theory.
"""

import matplotlib.pyplot as plt
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

def morse_stats(n, p, seed=0):
    random.seed(seed)
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            if random.random() < p:
                edges.append((random.random(), i, j))
    if not edges:
        return 0, 0, n, 0
    sorted_edges = sorted(edges, key=lambda e: e[0])
    uf = UnionFind(n)
    merges, cycles = 0, 0
    for w, u, v in sorted_edges:
        if uf.connected(u, v):
            cycles += 1
        else:
            uf.union(u, v)
            merges += 1
    return merges, cycles, uf.num_components, len(edges)

# Parameters
ns = [30, 50, 80, 120]
ps = np.linspace(0.01, 0.15, 25)
trials = 20

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for ax, n in zip(axes.flat, ns):
    cycle_ratios = []
    b1_means = []

    for p in ps:
        ratios = []
        b1s = []
        for t in range(trials):
            m, c, b0, total = morse_stats(n, p, seed=t*1000+n+int(p*10000))
            if total > 0:
                ratios.append(c / total)
            b1s.append(c)
        cycle_ratios.append(np.mean(ratios) if ratios else 0)
        b1_means.append(np.mean(b1s))

    # Plot cycle ratio
    color = np.array(cycle_ratios)
    ax.fill_between(ps, 0, cycle_ratios, alpha=0.3, color='#FF9800', label='Cycle fraction')
    ax.fill_between(ps, cycle_ratios, 1, alpha=0.3, color='#2196F3', label='Merge fraction')
    ax.plot(ps, cycle_ratios, 'o-', color='#FF9800', markersize=4, linewidth=2)

    # Mark critical threshold
    pc = 1.0 / n
    ax.axvline(x=pc, color='red', linestyle='--', linewidth=1.5, alpha=0.8)
    ax.text(pc + 0.002, 0.9, f'p_c={pc:.3f}', color='red', fontsize=9)

    ax.set_title(f'n = {n}', fontsize=14, fontweight='bold')
    ax.set_xlabel('Edge probability p', fontsize=11)
    ax.set_ylabel('Fraction of events', fontsize=11)
    ax.set_ylim(0, 1)
    ax.legend(fontsize=9, loc='center right')
    ax.grid(True, alpha=0.2)

fig.suptitle('Tropical Morse Phase Transition: Cycle vs Merge Event Fractions\nin G(n,p) Random Graphs',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('phase_transition_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition_heatmap.png")
