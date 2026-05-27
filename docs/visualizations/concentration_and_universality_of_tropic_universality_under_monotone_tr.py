#!/usr/bin/env python3
"""
Visualization 2: Universality Under Monotone Transport

Shows that applying strictly monotone transformations to edge weights
preserves the cycle-birth EDGE SET (and hence the rank-normalized CDF).
Three transformations — x², eˣ, log(x+1) — are applied to the same base
weights on the same graph, and the resulting cycle-birth indicators are
compared. The identity of the cycle-birth edge set is preserved exactly.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Inlined algorithms ───

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

def classify_edges(n, edges, weights):
    order = sorted(range(len(edges)), key=lambda i: weights[i])
    uf = UnionFind(n)
    births = []
    mst = set()
    cb = set()
    for idx in order:
        u, v = edges[idx]
        if uf.union(u, v):
            mst.add(idx)
        else:
            births.append(weights[idx])
            cb.add(idx)
    return births, mst, cb

def gnp_graph(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges

# ─── Generate data ───

rng = np.random.default_rng(77)
n, p = 150, 0.2
edges = gnp_graph(n, p, rng)
base_weights = rng.random(len(edges))

transforms = {
    'Identity: φ(x) = x': lambda x: x,
    'Square: φ(x) = x²': lambda x: x**2,
    'Exponential: φ(x) = eˣ': lambda x: np.exp(x),
    'Logarithm: φ(x) = ln(x+1)': lambda x: np.log(x + 1),
}

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
colors = ['#2c3e50', '#e74c3c', '#3498db', '#27ae60']

_, _, cb_base = classify_edges(n, edges, base_weights)

for (ax, (name, phi), color) in zip(axes.flat, transforms.items(), colors):
    transformed = phi(base_weights)
    births, mst, cb = classify_edges(n, edges, transformed)

    # Plot the classification: MST edges in gray, cycle-birth in color
    sorted_indices = sorted(range(len(edges)), key=lambda i: transformed[i])
    classification = ['cycle-birth' if i in cb else 'MST' for i in sorted_indices]

    mst_weights = [transformed[i] for i in sorted_indices if i in mst]
    cb_weights = [transformed[i] for i in sorted_indices if i in cb]

    ax.hist(mst_weights, bins=30, alpha=0.5, color='gray', label=f'MST ({len(mst)})')
    ax.hist(cb_weights, bins=30, alpha=0.7, color=color, label=f'Cycle births ({len(cb)})')

    # Check invariance
    same = (cb == cb_base)
    ax.set_title(f'{name}\nSame edge set: {"✓ YES" if same else "✗ NO"}',
                 fontsize=11, fontweight='bold')
    ax.set_xlabel('Transformed Weight', fontsize=10)
    ax.set_ylabel('Count', fontsize=10)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)

fig.suptitle('Universality: Monotone Transport Preserves Cycle-Birth Edge Sets\n'
             f'G({n}, {p}) with {len(edges)} edges',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_universality.png")
