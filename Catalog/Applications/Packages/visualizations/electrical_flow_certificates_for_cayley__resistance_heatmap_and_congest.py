#!/usr/bin/env python3
"""
Visualization: Effective Resistance Heatmap and Congestion Distribution

Produces a 2-panel figure:
  Left:  Heatmap of the effective resistance matrix for S_4
  Right: Histogram of edge congestion values

This visualizes the core mathematical relationship: canonical path congestion
(right panel) provides an upper bound on effective resistance (left panel).
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from collections import defaultdict


# ─── Self-contained helper functions ───
def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def adjacent_transpositions(n):
    gens = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.append(tuple(p))
    return gens

def build_cayley_graph(n):
    elements = list(permutations(range(n)))
    elem_to_idx = {e: i for i, e in enumerate(elements)}
    gens = adjacent_transpositions(n)
    N = len(elements)
    adj = np.zeros((N, N))
    for g in elements:
        gi = elem_to_idx[g]
        for s in gens:
            sg = compose(s, g)
            adj[gi][elem_to_idx[sg]] = 1
    return elements, elem_to_idx, gens, adj

def bubble_sort_path(src, dst, n, elem_to_idx):
    diff = compose(dst, inverse(src))
    p = list(inverse(diff))
    swaps = []
    for i in range(n):
        for j in range(n - 1 - i):
            if p[j] > p[j + 1]:
                p[j], p[j + 1] = p[j + 1], p[j]
                swap = list(range(n))
                swap[j], swap[j + 1] = swap[j + 1], swap[j]
                swaps.append(tuple(swap))
    vertices = [src]
    current = src
    for s in swaps:
        current = compose(s, current)
        vertices.append(current)
    return vertices


# ─── Computation ───
n = 4
elements, elem_to_idx, gens, adj = build_cayley_graph(n)
N = len(elements)

# Effective resistance
L = np.diag(adj.sum(axis=1)) - adj
L_pinv = np.linalg.pinv(L)
diag = np.diag(L_pinv)
R = np.zeros((N, N))
for i in range(N):
    for j in range(N):
        R[i][j] = diag[i] + diag[j] - 2 * L_pinv[i][j]

# Edge congestion
edge_usage = defaultdict(int)
for src in elements:
    for dst in elements:
        if src == dst:
            continue
        vertices = bubble_sort_path(src, dst, n, elem_to_idx)
        for i in range(len(vertices) - 1):
            u = elem_to_idx[vertices[i]]
            v = elem_to_idx[vertices[i + 1]]
            edge_usage[(min(u, v), max(u, v))] += 1


# ─── Visualization ───
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: Resistance heatmap
im = ax1.imshow(R, cmap='YlOrRd', aspect='equal')
ax1.set_title(f'Effective Resistance Matrix — S₄\nmax R_eff = {R.max():.4f}',
              fontsize=13, fontweight='bold')
ax1.set_xlabel('Vertex index', fontsize=11)
ax1.set_ylabel('Vertex index', fontsize=11)
plt.colorbar(im, ax=ax1, label='R_eff(i,j)', shrink=0.85)

# Right: Congestion histogram
cong_values = list(edge_usage.values())
ax2.hist(cong_values, bins=15, color='steelblue', edgecolor='white', alpha=0.9)
ax2.axvline(x=max(cong_values), color='red', linestyle='--', linewidth=2,
            label=f'κ = {max(cong_values)}')
ax2.axvline(x=np.mean(cong_values), color='orange', linestyle='--', linewidth=2,
            label=f'mean = {np.mean(cong_values):.0f}')
ax2.set_title(f'Edge Congestion Distribution — S₄\nκ/(|G|·max R) = {max(cong_values)/(N*R.max()):.4f}',
              fontsize=13, fontweight='bold')
ax2.set_xlabel('Edge congestion (# paths using edge)', fontsize=11)
ax2.set_ylabel('Number of edges', fontsize=11)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('resistance_congestion.png', dpi=150, bbox_inches='tight')
print("Saved: resistance_congestion.png")
