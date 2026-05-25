#!/usr/bin/env python3
"""
Visualization 2: Approximation Gap Heatmap

Visualizes the empirical approximation gap (integral cost / fractional cost)
as a function of hypergraph density (number of edges) and maximum edge size,
demonstrating that the gap is always bounded by d_max.
"""

import numpy as np
from scipy.optimize import linprog
import matplotlib.pyplot as plt


def random_hypergraph(n, m, max_size, seed):
    rng = np.random.default_rng(seed)
    edges = set()
    for _ in range(m):
        k = rng.integers(2, max_size + 1)
        e = tuple(sorted(rng.choice(n, size=min(k, n), replace=False)))
        edges.add(e)
    return list(edges)


def solve_and_round(n, edges, w):
    if not edges:
        return None, None, None
    d = max(len(e) for e in edges)
    A_ub = [[-1.0 if v in e else 0.0 for v in range(n)] for e in edges]
    b_ub = [-1.0] * len(edges)
    res = linprog(w, A_ub=A_ub, b_ub=b_ub, bounds=[(0, None)]*n, method='highs')
    if not res.success:
        return None, None, None
    x = res.x
    S = np.where(x >= 1.0/d - 1e-12)[0]
    ind = np.zeros(n); ind[S] = 1.0
    frac_cost = np.dot(w, x)
    int_cost = np.dot(w, ind)
    if frac_cost < 1e-10:
        return None, None, None
    return int_cost / frac_cost, d, frac_cost


n = 20
edge_counts = [5, 8, 12, 16, 20, 25, 30]
max_sizes = [2, 3, 4, 5]
num_trials = 50

gap_matrix = np.zeros((len(max_sizes), len(edge_counts)))
gap_counts = np.zeros((len(max_sizes), len(edge_counts)))

for i, ms in enumerate(max_sizes):
    for j, mc in enumerate(edge_counts):
        gaps = []
        for t in range(num_trials):
            seed = i * 10000 + j * 100 + t
            edges = random_hypergraph(n, mc, ms, seed)
            if not edges:
                continue
            rng = np.random.default_rng(seed + 99999)
            w = rng.uniform(0.5, 5.0, size=n)
            gap, d, _ = solve_and_round(n, edges, w)
            if gap is not None:
                gaps.append(gap)
        if gaps:
            gap_matrix[i, j] = np.mean(gaps)
            gap_counts[i, j] = len(gaps)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# Heatmap of mean gap
im1 = ax1.imshow(gap_matrix, aspect='auto', cmap='YlOrRd', origin='lower',
                  vmin=1.0, vmax=max(max_sizes))
ax1.set_xticks(range(len(edge_counts)))
ax1.set_xticklabels(edge_counts)
ax1.set_yticks(range(len(max_sizes)))
ax1.set_yticklabels(max_sizes)
ax1.set_xlabel('Number of edges (m)', fontsize=13)
ax1.set_ylabel('Maximum edge size (d_max)', fontsize=13)
ax1.set_title('Mean Approximation Gap\n(int cost / frac cost)', fontsize=14)

for i in range(len(max_sizes)):
    for j in range(len(edge_counts)):
        ax1.text(j, i, f'{gap_matrix[i,j]:.2f}', ha='center', va='center',
                fontsize=10, color='black' if gap_matrix[i,j] < max_sizes[-1]*0.7 else 'white')

plt.colorbar(im1, ax=ax1, label='Gap ratio')

# Normalized gap (gap / d_max)
norm_matrix = np.zeros_like(gap_matrix)
for i, ms in enumerate(max_sizes):
    norm_matrix[i, :] = gap_matrix[i, :] / ms

im2 = ax2.imshow(norm_matrix, aspect='auto', cmap='Blues', origin='lower',
                  vmin=0, vmax=1.0)
ax2.set_xticks(range(len(edge_counts)))
ax2.set_xticklabels(edge_counts)
ax2.set_yticks(range(len(max_sizes)))
ax2.set_yticklabels(max_sizes)
ax2.set_xlabel('Number of edges (m)', fontsize=13)
ax2.set_ylabel('Maximum edge size (d_max)', fontsize=13)
ax2.set_title('Normalized Gap (gap / d_max)\n≤ 1.0 by theorem', fontsize=14)

for i in range(len(max_sizes)):
    for j in range(len(edge_counts)):
        ax2.text(j, i, f'{norm_matrix[i,j]:.2f}', ha='center', va='center',
                fontsize=10, color='black')

plt.colorbar(im2, ax=ax2, label='Normalized ratio')

plt.suptitle(f'Weighted Threshold Rounding: Approximation Gap Analysis (n={n})',
             fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_gap_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_heatmap.png")
