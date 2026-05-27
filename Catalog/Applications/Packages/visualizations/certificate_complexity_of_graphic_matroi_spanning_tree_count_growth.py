"""
Visualization: Spanning Tree Count Growth

Plots the growth of spanning tree count τ(G) for random graphs at various
threshold ratios, showing how the Kirchhoff information bound drives the
certificate complexity phase transition. Includes comparison with Cayley's
formula τ(Kn) = n^(n-2) as the theoretical maximum.

This illustrates the information-theoretic bridge: more spanning trees →
more bases to distinguish → higher certificate complexity.
"""

import numpy as np
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def laplacian_matrix(n, edges):
    A = np.zeros((n, n), dtype=float)
    for u, v in edges:
        A[u][v] = 1.0
        A[v][u] = 1.0
    D = np.diag(A.sum(axis=1))
    return D - A


def spanning_tree_count(n, edges):
    if n <= 1:
        return 1.0
    L = laplacian_matrix(n, edges)
    L_reduced = L[1:, 1:]
    det = np.linalg.det(L_reduced)
    return max(0.0, det)


def generate_gnp(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges


# Parameters
rng = np.random.default_rng(77)
n_values = list(range(5, 46))
k_values = [0.5, 0.8, 1.0, 1.2, 1.5, 2.0]
num_trials = 30

fig, axes = plt.subplots(1, 2, figsize=(15, 6))
colors = ['#9E9E9E', '#FFC107', '#FF5722', '#4CAF50', '#2196F3', '#9C27B0']

# Left: log₂(τ(G)) vs n for various k
ax = axes[0]
for idx, k in enumerate(k_values):
    means = []
    for n in n_values:
        p_star = math.log(n) / n
        p = min(k * p_star, 1.0)
        trials = []
        for _ in range(num_trials):
            edges = generate_gnp(n, p, rng)
            tau = spanning_tree_count(n, edges)
            trials.append(math.log2(tau) if tau > 1e-10 else 0.0)
        means.append(np.mean(trials))
    ax.plot(n_values, means, '-', color=colors[idx], label=f'k = {k}',
            linewidth=2.5 if k == 1.0 else 1.8, alpha=0.9)

# Cayley's formula: τ(Kn) = n^(n-2)
cayley = [(n - 2) * math.log2(n) for n in n_values]
ax.plot(n_values, cayley, 'k--', linewidth=1.5, alpha=0.4,
        label="Cayley: (n-2)·log₂(n)")

ax.set_xlabel('Number of vertices n', fontsize=13)
ax.set_ylabel('E[log₂(τ(G))]', fontsize=13)
ax.set_title('Spanning Tree Count Growth by Threshold Ratio',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=10, ncol=2)
ax.grid(True, alpha=0.3)

# Right: Normalized growth rate
ax = axes[1]
for idx, k in enumerate(k_values):
    if k < 0.9:
        continue
    means = []
    for n in n_values:
        p_star = math.log(n) / n
        p = min(k * p_star, 1.0)
        trials = []
        for _ in range(num_trials):
            edges = generate_gnp(n, p, rng)
            tau = spanning_tree_count(n, edges)
            trials.append(math.log2(tau) if tau > 1e-10 else 0.0)
        means.append(np.mean(trials) / n if n > 0 else 0.0)
    ax.plot(n_values, means, 'o-', color=colors[idx], label=f'k = {k}',
            linewidth=2, markersize=3, alpha=0.8)

ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
ax.set_xlabel('Number of vertices n', fontsize=13)
ax.set_ylabel('E[log₂(τ(G))] / n  (normalized)', fontsize=13)
ax.set_title('Normalized Information per Vertex',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Add annotation
ax.annotate('Above threshold:\nlinear growth in n\n→ exponential τ(G)',
            xy=(35, 0.8), fontsize=10, ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                      edgecolor='orange', alpha=0.8))

plt.tight_layout()
plt.savefig('spanning_tree_growth.png', dpi=150, bbox_inches='tight')
print("Spanning tree growth plot saved to spanning_tree_growth.png")
