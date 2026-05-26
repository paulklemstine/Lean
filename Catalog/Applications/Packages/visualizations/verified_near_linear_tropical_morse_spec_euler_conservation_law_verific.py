"""
Visualization: Euler Conservation Law Verification

Shows that the conservation law β₀ - β₁ = V - E holds at every step
of the Kruskal filtration across multiple random graphs. Each row shows
a different graph; the green line (Euler characteristic) is constant
once the filtration has processed all edges.

Uses matplotlib to produce a static plot saved as PNG.
"""

import matplotlib.pyplot as plt
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


def compute_betti_trace(n, edges):
    uf = UnionFind(n)
    sorted_edges = sorted(edges)
    beta0s, beta1s = [n], [0]
    event_types = []
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
    return beta0s, beta1s, event_types


# ── Generate multiple graphs ──────────────────────────────────────────

random.seed(2025)
graphs = []
names = []

for trial in range(6):
    n = random.randint(6, 12)
    max_edges = n * (n - 1) // 2
    m = random.randint(n, min(max_edges, int(2.5 * n)))
    all_possible = [(i, j) for i in range(n) for j in range(i+1, n)]
    chosen = random.sample(all_possible, m)
    edges = [(round(random.uniform(1, 50), 1), u, v) for u, v in chosen]
    graphs.append((n, edges))
    names.append(f'G{trial+1}: V={n}, E={m}')

# ── Create visualization ─────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

for idx, (ax, (n, edges), name) in enumerate(zip(axes.flat, graphs, names)):
    beta0s, beta1s, event_types = compute_betti_trace(n, edges)
    chis = [b0 - b1 for b0, b1 in zip(beta0s, beta1s)]
    ve = [n - i for i in range(len(beta0s))]  # V - E(≤t)
    
    steps = range(len(beta0s))
    
    ax.step(steps, beta0s, where='post', color='#2196F3', linewidth=2, label='β₀')
    ax.step(steps, beta1s, where='post', color='#F44336', linewidth=2, label='β₁')
    ax.step(steps, chis, where='post', color='#4CAF50', linewidth=2.5,
            linestyle='--', label='χ = β₀−β₁')
    ax.step(steps, ve, where='post', color='#FF9800', linewidth=1.5,
            linestyle=':', label='V−E', alpha=0.8)
    
    # Highlight that χ = V - E at every step
    violations = sum(1 for c, v in zip(chis, ve) if c != v)
    
    # Color background by event type
    for i, et in enumerate(event_types):
        color = '#E3F2FD' if et == 'merge' else '#FFEBEE'
        ax.axvspan(i + 0.5, i + 1.5, alpha=0.3, color=color)
    
    ax.set_title(f'{name}', fontsize=12, fontweight='bold')
    ax.set_xlabel('Step', fontsize=9)
    ax.set_ylabel('Value', fontsize=9)
    
    if idx == 0:
        ax.legend(fontsize=8, loc='center right')
    
    ax.grid(True, alpha=0.2)
    
    # Verify conservation
    check = '✓' if violations == 0 else '✗'
    merges = sum(1 for e in event_types if e == 'merge')
    cycles = sum(1 for e in event_types if e == 'cycle')
    ax.text(0.02, 0.02, f'M={merges} C={cycles} {check}',
            transform=ax.transAxes, fontsize=9, va='bottom',
            bbox=dict(facecolor='lightgreen' if violations == 0 else 'lightsalmon',
                      alpha=0.7))

fig.suptitle('Euler Conservation Law: β₀ − β₁ = V − E\n'
             'Verified at every step across 6 random graphs\n'
             '(Blue bg = merge event, Red bg = cycle event)',
             fontsize=15, fontweight='bold')

plt.tight_layout(rect=[0, 0, 1, 0.92])
plt.savefig('viz_euler_conservation.png', dpi=150, bbox_inches='tight')
print("Saved: viz_euler_conservation.png")
