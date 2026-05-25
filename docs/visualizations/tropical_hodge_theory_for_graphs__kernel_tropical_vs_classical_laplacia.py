#!/usr/bin/env python3
"""
Visualization 1: Tropical Laplacian Heatmap

Visualizes the tropical Laplacian matrix for several graph families,
showing how the min-plus structure differs from the classical Laplacian.
The tropical Laplacian has entries: deg(v) on diagonal, 0 for adjacent
pairs, and ∞ (shown as white/blank) for non-adjacent pairs.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from collections import defaultdict

INF = float('inf')

def tropical_laplacian(n, edges):
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    L = [[INF] * n for _ in range(n)]
    for i in range(n):
        L[i][i] = len(adj[i])
        for j in adj[i]:
            L[i][j] = 0
    return L

def classical_laplacian(n, edges):
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    L = [[0] * n for _ in range(n)]
    for i in range(n):
        L[i][i] = len(adj[i])
        for j in adj[i]:
            L[i][j] = -1
    return L

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Tropical vs Classical Laplacian Matrices', fontsize=16, fontweight='bold')

graphs = [
    ("Path P₅", 5, [(0,1),(1,2),(2,3),(3,4)]),
    ("Cycle C₅", 5, [(0,1),(1,2),(2,3),(3,4),(4,0)]),
    ("Complete K₅", 5, [(i,j) for i in range(5) for j in range(i+1,5)]),
]

for col, (name, n, edges) in enumerate(graphs):
    # Classical
    L_class = np.array(classical_laplacian(n, edges), dtype=float)
    ax = axes[0][col]
    im = ax.imshow(L_class, cmap='RdBu_r', vmin=-2, vmax=4)
    ax.set_title(f'{name}\nClassical Laplacian', fontsize=11)
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{int(L_class[i][j])}', ha='center', va='center', fontsize=12)
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Tropical
    L_trop = tropical_laplacian(n, edges)
    L_display = np.array([[v if v != INF else np.nan for v in row] for row in L_trop])
    ax = axes[1][col]
    cmap = plt.cm.YlOrRd.copy()
    cmap.set_bad(color='white')
    im = ax.imshow(L_display, cmap=cmap, vmin=0, vmax=4)
    ax.set_title(f'{name}\nTropical Laplacian', fontsize=11)
    for i in range(n):
        for j in range(n):
            val = L_trop[i][j]
            text = '∞' if val == INF else str(int(val))
            ax.text(j, i, text, ha='center', va='center', fontsize=12,
                   color='gray' if val == INF else 'black')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    plt.colorbar(im, ax=ax, shrink=0.8)

plt.tight_layout()
plt.savefig('viz_tropical_laplacian.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_laplacian.png")
