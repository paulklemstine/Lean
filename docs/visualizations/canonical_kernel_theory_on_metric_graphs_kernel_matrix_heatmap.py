"""
Visualization: Canonical Kernel Matrix Heatmap and Energy Pairing

Visualizes the canonical kernel matrix K and the energy pairing matrix Q
for a cycle graph with varying edge lengths, showing how the harmonic
structure encodes the metric geometry of the graph.

The kernel matrix K[i,j] = k_i(S[j]) gives the value of the i-th canonical
kernel generator at the j-th support point. The energy pairing Q = K^T L K
gives the tropical polarization on the Jacobian.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple, Dict
from dataclasses import dataclass, field


@dataclass
class MetricGraphModel:
    n_vertices: int
    edges: List[Tuple[int, int, float]]
    adj: Dict[int, List[Tuple[int, float]]] = field(default_factory=dict)

    def __post_init__(self):
        self.adj = {i: [] for i in range(self.n_vertices)}
        for i, j, length in self.edges:
            self.adj[i].append((j, length))
            self.adj[j].append((i, length))


def build_weighted_laplacian(M):
    n = M.n_vertices
    L = np.zeros((n, n))
    for i, j, length in M.edges:
        c = 1.0 / length
        L[i, j] = -c
        L[j, i] = -c
        L[i, i] += c
        L[j, j] += c
    return L


def solve_normalized_kernel(M, S, D):
    n = M.n_vertices
    L = build_weighted_laplacian(M)
    b = np.zeros(n)
    for idx, v in enumerate(S):
        b[v] = D[idx]
    A = L.copy()
    A[-1, :] = 1.0
    b[-1] = 0.0
    return np.linalg.solve(A, b)


def compute_canonical_kernel_matrix(M, S):
    m = len(S)
    K = np.zeros((m, m))
    for idx in range(1, m):
        D = np.zeros(m)
        D[idx] = 1.0
        D[0] = -1.0
        f = solve_normalized_kernel(M, S, D)
        for j in range(m):
            K[idx, j] = f[S[j]]
    return K


def compute_energy_pairing(M, S):
    m = len(S)
    generators = []
    L = build_weighted_laplacian(M)
    for idx in range(1, m):
        D = np.zeros(m)
        D[idx] = 1.0
        D[0] = -1.0
        f = solve_normalized_kernel(M, S, D)
        generators.append(f)
    r = len(generators)
    Q = np.zeros((r, r))
    for i in range(r):
        for j in range(r):
            Q[i, j] = generators[i] @ L @ generators[j]
    return Q


def cycle_graph(n, lengths=None):
    if lengths is None:
        lengths = [1.0] * n
    edges = [(i, (i + 1) % n, lengths[i]) for i in range(n)]
    return MetricGraphModel(n, edges)


# Create figure
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Canonical Kernel Theory on Metric Graphs\n'
             'Kernel Matrices K and Energy Pairings Q',
             fontsize=14, fontweight='bold')

configs = [
    ("C₅ uniform", [1, 1, 1, 1, 1]),
    ("C₅ asymmetric", [1, 2, 3, 4, 5]),
    ("C₅ extreme", [0.1, 0.1, 0.1, 0.1, 10]),
]

for col, (title, lengths) in enumerate(configs):
    M = cycle_graph(5, lengths)
    S = list(range(5))

    K = compute_canonical_kernel_matrix(M, S)
    Q = compute_energy_pairing(M, S)

    # Kernel matrix
    ax = axes[0, col]
    im = ax.imshow(K, cmap='RdBu_r', aspect='equal',
                   vmin=-np.max(np.abs(K)), vmax=np.max(np.abs(K)))
    ax.set_title(f'{title}\nKernel Matrix K', fontsize=11)
    ax.set_xlabel('Support point j')
    ax.set_ylabel('Generator i')
    ax.set_xticks(range(5))
    ax.set_yticks(range(5))
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Energy pairing
    ax = axes[1, col]
    im = ax.imshow(Q, cmap='viridis', aspect='equal')
    ax.set_title(f'Energy Pairing Q\nℓ = {lengths}', fontsize=11)
    ax.set_xlabel('Generator j')
    ax.set_ylabel('Generator i')
    ax.set_xticks(range(Q.shape[0]))
    ax.set_yticks(range(Q.shape[1]))
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Annotate eigenvalues
    eigvals = np.linalg.eigvalsh(Q)
    ax.text(0.02, -0.15, f'λ = {np.round(eigvals, 3)}',
            transform=ax.transAxes, fontsize=8, style='italic')

plt.tight_layout()
plt.savefig('viz_kernel_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_kernel_heatmap.png")
