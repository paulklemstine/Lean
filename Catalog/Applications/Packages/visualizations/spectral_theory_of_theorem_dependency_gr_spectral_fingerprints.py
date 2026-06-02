"""
Visualization: Spectral Fingerprints of Graph Families

Generates a heatmap comparing spectral moments across different graph
families, showing how the moment profile distinguishes graph topologies.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def walk_count_matrix(adj: np.ndarray, k: int) -> np.ndarray:
    """Compute A^k via matrix exponentiation."""
    n = adj.shape[0]
    result = np.eye(n)
    base = adj.copy()
    for _ in range(k):
        result = result @ base
    return result


def spectral_moments(adj: np.ndarray, max_k: int) -> list[float]:
    """Compute normalized spectral moments mu_k = tr(A^k) / n."""
    n = adj.shape[0]
    if n == 0:
        return [0.0] * (max_k + 1)
    moments = []
    power = np.eye(n)
    for k in range(max_k + 1):
        moments.append(np.trace(power) / n)
        power = power @ adj
    return moments


def degree_variance(adj: np.ndarray) -> float:
    """Compute out-degree variance."""
    degs = adj.sum(axis=1)
    return float(np.var(degs))


def make_path(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(n - 1):
        adj[i][i + 1] = 1
    return adj


def make_cycle(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i][(i + 1) % n] = 1
    return adj


def make_complete_dag(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            adj[i][j] = 1
    return adj


def make_binary_tree(depth: int) -> np.ndarray:
    n = 2 ** (depth + 1) - 1
    adj = np.zeros((n, n))
    for i in range(n):
        left = 2 * i + 1
        right = 2 * i + 2
        if left < n:
            adj[i][left] = 1
        if right < n:
            adj[i][right] = 1
    return adj


def make_star(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(1, n):
        adj[0][i] = 1
    return adj


def make_bidirectional_cycle(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i][(i + 1) % n] = 1
        adj[(i + 1) % n][i] = 1
    return adj


if __name__ == "__main__":
    max_k = 10
    graphs = {
        "Path-8": make_path(8),
        "Cycle-8": make_cycle(8),
        "BiCycle-8": make_bidirectional_cycle(8),
        "CompDAG-6": make_complete_dag(6),
        "BinTree-3": make_binary_tree(3),
        "Star-8": make_star(8),
    }

    # Compute moments
    all_moments = {}
    for name, adj in graphs.items():
        all_moments[name] = spectral_moments(adj, max_k)

    # Figure 1: Moment heatmap
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    names = list(graphs.keys())
    moment_matrix = np.array([all_moments[n] for n in names])

    ax = axes[0]
    im = ax.imshow(moment_matrix, aspect='auto', cmap='RdBu_r', vmin=-1, vmax=1)
    ax.set_yticks(range(len(names)))
    ax.set_yticklabels(names)
    ax.set_xlabel('Moment order k')
    ax.set_ylabel('Graph family')
    ax.set_title('Spectral Moment Fingerprints')
    plt.colorbar(im, ax=ax, label='μ_k = tr(A^k)/n')

    # Figure 2: Degree variance comparison
    ax2 = axes[1]
    variances = [degree_variance(graphs[n]) for n in names]
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(names)))
    bars = ax2.barh(range(len(names)), variances, color=colors)
    ax2.set_yticks(range(len(names)))
    ax2.set_yticklabels(names)
    ax2.set_xlabel('Degree Variance')
    ax2.set_title('Degree Distribution Variance\n(Higher = More Hub-like Structure)')

    plt.tight_layout()
    plt.savefig('spectral_fingerprints.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_fingerprints.png")

    # Figure 3: Spectral distance matrix
    fig2, ax3 = plt.subplots(figsize=(7, 6))
    n_graphs = len(names)
    dist_matrix = np.zeros((n_graphs, n_graphs))
    for i in range(n_graphs):
        for j in range(n_graphs):
            dist_matrix[i][j] = max(
                abs(all_moments[names[i]][k] - all_moments[names[j]][k])
                for k in range(max_k + 1)
            )

    im3 = ax3.imshow(dist_matrix, cmap='YlOrRd')
    ax3.set_xticks(range(n_graphs))
    ax3.set_xticklabels(names, rotation=45, ha='right')
    ax3.set_yticks(range(n_graphs))
    ax3.set_yticklabels(names)
    ax3.set_title(f'Spectral Distance Matrix (K={max_k})')
    plt.colorbar(im3, ax=ax3, label='d_K(G₁, G₂)')

    plt.tight_layout()
    plt.savefig('spectral_distances.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_distances.png")
