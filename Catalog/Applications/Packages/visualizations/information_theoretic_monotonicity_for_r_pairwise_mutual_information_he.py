#!/usr/bin/env python3
"""
Visualization: Pairwise Mutual Information Heatmap for Lorentzian Measures

Visualizes the pairwise mutual information proxy matrix for uniform matroid
distributions of varying rank, showing how Lorentzian negativity suppresses
pairwise information. The uniformity of the heatmap demonstrates the
symmetry and boundedness predicted by the formal theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from math import log


def uniform_matroid_law(n, r):
    subs = [frozenset(c) for c in combinations(range(n), r)]
    w = 1.0 / len(subs)
    weights = {}
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        weights[s] = w if s in set(subs) else 0.0
    return n, weights


def coord_prob(n, weights, i):
    return sum(w for s, w in weights.items() if i in s)


def coord_cov(n, weights, i, j):
    pij = sum(w for s, w in weights.items() if i in s and j in s)
    return pij - coord_prob(n, weights, i) * coord_prob(n, weights, j)


def mi_proxy(n, weights, i, j):
    p = coord_prob(n, weights, i)
    q = coord_prob(n, weights, j)
    c = coord_cov(n, weights, i, j)
    if p <= 0 or p >= 1 or q <= 0 or q >= 1:
        return 0.0
    return c**2 / (p*(1-p)*q*(1-q))


fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
configs = [(6, 2), (6, 3), (8, 4)]

for ax, (n, r) in zip(axes, configs):
    nn, weights = uniform_matroid_law(n, r)
    mi_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                mi_matrix[i, j] = mi_proxy(n, weights, i, j)

    im = ax.imshow(mi_matrix, cmap='YlOrRd', interpolation='nearest',
                   vmin=0, vmax=max(0.01, np.max(mi_matrix)))
    ax.set_title(f'U({n},{r}): MI Proxy Matrix', fontsize=12, fontweight='bold')
    ax.set_xlabel('Coordinate j')
    ax.set_ylabel('Coordinate i')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    # Find max eps
    best_eps = 0.0
    for eps in np.linspace(0.001, 0.49, 200):
        ok = True
        for i in range(n):
            p = coord_prob(n, weights, i)
            if p < eps or p > 1-eps: ok = False
        for i in range(n):
            for j in range(n):
                if i != j and abs(coord_cov(n, weights, i, j)) > eps: ok = False
        if ok: best_eps = eps
    bound = 1/(1-best_eps)**2 if best_eps > 0 else float('inf')
    ax.text(0.5, -0.18, f'ε={best_eps:.3f}, bound={bound:.3f}\nmax MI={np.max(mi_matrix):.5f}',
            transform=ax.transAxes, ha='center', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))

fig.suptitle('Pairwise Mutual Information Under Lorentzian Negativity',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mi_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved mi_heatmap.png")
