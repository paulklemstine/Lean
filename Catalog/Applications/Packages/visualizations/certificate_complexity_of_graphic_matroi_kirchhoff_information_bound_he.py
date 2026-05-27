"""
Visualization: Kirchhoff Information Bound Heatmap

Creates a heatmap showing log₂(τ(G)) (the information-theoretic certificate
complexity lower bound) as a function of both n (graph size) and k (threshold
ratio), revealing the sharp boundary at k = 1.

This visualizes the "cliff" in certificate complexity — the dramatic transition
from zero (disconnected regime) to large values (connected regime).
"""

import numpy as np
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


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
rng = np.random.default_rng(123)
n_values = list(range(8, 52, 2))
k_values = np.linspace(0.3, 2.5, 30)
num_trials = 30

# Compute heatmap data
heatmap = np.zeros((len(n_values), len(k_values)))

for i, n in enumerate(n_values):
    p_star = math.log(n) / n
    for j, k in enumerate(k_values):
        p = min(k * p_star, 1.0)
        total = 0.0
        for _ in range(num_trials):
            edges = generate_gnp(n, p, rng)
            tau = spanning_tree_count(n, edges)
            total += math.log2(tau) if tau > 1e-10 else 0.0
        heatmap[i, j] = total / num_trials

# Create figure
fig, ax = plt.subplots(figsize=(12, 8))

# Use imshow for heatmap
im = ax.imshow(heatmap, aspect='auto', origin='lower',
               extent=[k_values[0], k_values[-1], n_values[0], n_values[-1]],
               cmap='inferno', interpolation='bilinear')

# Add threshold line
ax.axvline(x=1.0, color='cyan', linestyle='--', linewidth=2.5, alpha=0.8,
           label='k = 1 (connectivity threshold)')

# Colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.85, pad=0.02)
cbar.set_label('E[log₂(τ(G))]  (cert complexity lower bound)', fontsize=12)

ax.set_xlabel('Threshold ratio k  (p = k · ln(n)/n)', fontsize=13)
ax.set_ylabel('Number of vertices n', fontsize=13)
ax.set_title('Kirchhoff Information Bound: Certificate Complexity Landscape',
             fontsize=15, fontweight='bold')
ax.legend(fontsize=12, loc='upper left',
          facecolor='white', edgecolor='gray', framealpha=0.9)

# Annotations
ax.text(0.55, 45, 'DISCONNECTED\n(τ = 0)', fontsize=11,
        ha='center', color='white', fontweight='bold', alpha=0.8)
ax.text(1.8, 45, 'CONNECTED\n(τ → ∞)', fontsize=11,
        ha='center', color='white', fontweight='bold', alpha=0.8)

plt.tight_layout()
plt.savefig('kirchhoff_heatmap.png', dpi=150, bbox_inches='tight')
print("Kirchhoff heatmap saved to kirchhoff_heatmap.png")
