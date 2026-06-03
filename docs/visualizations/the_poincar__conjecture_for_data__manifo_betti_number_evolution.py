"""
Visualization: Betti Number Evolution for Point Clouds on Spheres

Generates a plot showing how Betti numbers change as the scale parameter
epsilon varies in the Vietoris-Rips filtration. This visualizes the
"detection window" where sphere-like homology appears.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pairwise_distances(points):
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def connected_components(n, edges):
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    for i, j in edges:
        union(i, j)
    return len(set(find(i) for i in range(n)))


def estimate_betti(dist_matrix, epsilon, max_dim=2):
    n = dist_matrix.shape[0]
    edges = [(i, j) for i in range(n) for j in range(i+1, n) if dist_matrix[i,j] <= epsilon]
    beta_0 = connected_components(n, edges)

    adj = {i: set() for i in range(n)}
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)

    n_triangles = 0
    if max_dim >= 2:
        for i, j in edges:
            n_triangles += len(adj[i] & adj[j] - {i, j})
        n_triangles //= 3

    f0, f1, f2 = n, len(edges), n_triangles
    chi = f0 - f1 + f2
    beta_1 = max(0, beta_0 - chi)
    beta_2 = max(0, chi - beta_0 + beta_1)

    return [beta_0, beta_1, beta_2]


def sample_sphere(n, d):
    points = np.random.randn(n, d + 1)
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    return points / norms


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    for idx, (d, n) in enumerate([(1, 80), (2, 120)]):
        points = sample_sphere(n, d)
        dist_mat = pairwise_distances(points)
        max_dist = np.max(dist_mat)

        epsilons = np.linspace(0.01, max_dist * 0.9, 80)
        betti_vals = {k: [] for k in range(3)}

        for eps in epsilons:
            b = estimate_betti(dist_mat, eps, max_dim=2)
            for k in range(3):
                betti_vals[k].append(b[k] if k < len(b) else 0)

        ax = axes[idx]
        colors = ['#2196F3', '#FF5722', '#4CAF50']
        labels = [r'$\beta_0$', r'$\beta_1$', r'$\beta_2$']
        for k in range(min(3, d + 1)):
            ax.plot(epsilons, betti_vals[k], color=colors[k], linewidth=2,
                    label=labels[k])

        # Mark detection window
        sphere_eps = [eps for eps, b0, bd in zip(epsilons, betti_vals[0],
                      betti_vals[d]) if b0 == 1 and bd == 1]
        if sphere_eps:
            ax.axvspan(min(sphere_eps), max(sphere_eps), alpha=0.15,
                       color='gold', label='Detection window')
            ax.axvline(min(sphere_eps), color='gold', linestyle='--',
                       linewidth=1.5, alpha=0.7)

        ax.set_xlabel(r'Scale $\varepsilon$', fontsize=13)
        ax.set_ylabel('Betti number', fontsize=13)
        ax.set_title(f'Betti Evolution: {n} pts on $S^{d}$', fontsize=14)
        ax.legend(fontsize=11, loc='upper right')
        ax.set_ylim(-0.5, max(max(betti_vals[0]), 10) + 1)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_betti_evolution.png', dpi=150, bbox_inches='tight')
    print("Saved viz_betti_evolution.png")


if __name__ == "__main__":
    main()
