#!/usr/bin/env python3
"""
Visualization: Poincaré Threshold Scaling Law

Plots the connectivity threshold vs n for different sphere dimensions,
comparing with the theoretical prediction ε* ~ C · d^{1/2} · n^{-1/d}.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pairwise_distances(points):
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def connectivity_threshold(dist_matrix):
    n = dist_matrix.shape[0]
    if n <= 1:
        return 0.0
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((dist_matrix[i, j], i, j))
    edges.sort()
    parent = list(range(n))
    rank = [0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px == py: return False
        if rank[px] < rank[py]: px, py = py, px
        parent[py] = px
        if rank[px] == rank[py]: rank[px] += 1
        return True
    max_edge = 0.0
    added = 0
    for w, i, j in edges:
        if union(i, j):
            max_edge = w
            added += 1
            if added == n - 1: break
    return max_edge


def sample_sphere(n, d, seed=42):
    rng = np.random.default_rng(seed)
    points = rng.standard_normal((n, d + 1))
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    return points / norms


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
dims = [1, 2, 3]
ns = [10, 15, 20, 30, 50, 75, 100]
n_trials = 10

for ax, dim in zip(axes, dims):
    mean_eps = []
    std_eps = []
    for n in ns:
        eps_vals = []
        for seed in range(n_trials):
            pts = sample_sphere(n, dim, seed=seed)
            dist = pairwise_distances(pts)
            eps_vals.append(connectivity_threshold(dist))
        mean_eps.append(np.mean(eps_vals))
        std_eps.append(np.std(eps_vals))

    ax.errorbar(ns, mean_eps, yerr=std_eps, fmt='o-', capsize=3, label='Measured ε₀')

    # Fit C · n^{-1/d}
    log_n = np.log(ns)
    log_eps = np.log(mean_eps)
    slope, intercept = np.polyfit(log_n, log_eps, 1)
    C_fit = np.exp(intercept)
    n_fine = np.linspace(8, 110, 100)
    ax.plot(n_fine, C_fit * n_fine ** slope, '--', color='red',
            label=f'Fit: {C_fit:.2f}·n^{{{slope:.3f}}}')
    ax.plot(n_fine, C_fit * n_fine ** (-1.0/dim), ':', color='green',
            label=f'Theory: C·n^{{{-1.0/dim:.3f}}}')

    ax.set_xlabel('Number of points n')
    ax.set_ylabel('Connectivity threshold ε₀')
    ax.set_title(f'S^{dim} (d={dim})')
    ax.legend(fontsize=8)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

plt.suptitle('Connectivity Threshold Scaling: ε₀ vs n for Sphere Point Clouds',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('scaling_law.png', dpi=150, bbox_inches='tight')
print("Saved scaling_law.png")
