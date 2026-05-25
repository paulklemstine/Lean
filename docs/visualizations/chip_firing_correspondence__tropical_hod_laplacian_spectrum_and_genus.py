"""
Visualization: Laplacian Spectrum and Genus.

Plots the eigenvalue spectrum of the graph Laplacian for several families
of graphs, showing how the number of zero eigenvalues relates to
connected components and how the nonzero eigenvalues encode cycle structure.

The key insight: for a connected graph, the Laplacian has exactly one
zero eigenvalue. The genus = |E| - |V| + 1 controls the dimension of
the cycle space, visible in the spectral structure.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj


def complete_graph(n):
    adj = np.ones((n, n), dtype=int)
    np.fill_diagonal(adj, 0)
    return adj


def cycle_graph(n):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj[i, (i+1)%n] = adj[(i+1)%n, i] = 1
    return adj


def path_graph(n):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n-1):
        adj[i, i+1] = adj[i+1, i] = 1
    return adj


def petersen_graph():
    adj = np.zeros((10, 10), dtype=int)
    for i in range(5):
        adj[i, (i+1)%5] = adj[(i+1)%5, i] = 1
    for i in range(5):
        adj[5+i, 5+(i+2)%5] = adj[5+(i+2)%5, 5+i] = 1
    for i in range(5):
        adj[i, 5+i] = adj[5+i, i] = 1
    return adj


fig, axes = plt.subplots(2, 3, figsize=(14, 8))
fig.suptitle('Laplacian Spectra and Graph Genus', fontsize=16, fontweight='bold')

graphs = [
    ("Path P₅ (g=0)", path_graph(5)),
    ("Cycle C₆ (g=1)", cycle_graph(6)),
    ("K₄ (g=3)", complete_graph(4)),
    ("K₅ (g=6)", complete_graph(5)),
    ("Petersen (g=6)", petersen_graph()),
    ("K₃,₃ (g=4)", None),  # will build manually
]

# Build K_3,3
adj_k33 = np.zeros((6, 6), dtype=int)
for i in range(3):
    for j in range(3, 6):
        adj_k33[i, j] = adj_k33[j, i] = 1
graphs[5] = ("K₃,₃ (g=4)", adj_k33)

colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6', '#f39c12', '#1abc9c']

for idx, (name, adj) in enumerate(graphs):
    ax = axes[idx // 3][idx % 3]
    L = graph_laplacian(adj)
    eigenvalues = np.sort(np.linalg.eigvalsh(L.astype(float)))

    n = adj.shape[0]
    m = np.sum(adj) // 2
    genus = m - n + 1

    # Bar plot of eigenvalues
    bars = ax.bar(range(len(eigenvalues)), eigenvalues,
                  color=[colors[idx]] * len(eigenvalues),
                  alpha=0.8, edgecolor='black', linewidth=0.5)

    # Highlight zero eigenvalue
    for i, ev in enumerate(eigenvalues):
        if abs(ev) < 1e-10:
            bars[i].set_color('#e74c3c')
            bars[i].set_alpha(1.0)

    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.set_xlabel('Index', fontsize=9)
    ax.set_ylabel('Eigenvalue', fontsize=9)
    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
    ax.set_xticks(range(len(eigenvalues)))

    # Annotation
    ax.text(0.95, 0.95, f'n={n}, m={m}\ng={genus}',
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top', horizontalalignment='right',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('viz_laplacian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_spectrum.png")
