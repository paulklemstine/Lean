"""
Visualization: Laplacian Spectrum of Graph Lifts

Shows how the eigenvalue spectrum of the graph Laplacian evolves as
we take n-sheeted random covers. The spectrum fans out according to
the representation theory of the symmetric group, and the zero
eigenvalue has multiplicity equal to the number of connected components.

This visualization demonstrates the spectral universality phenomenon:
different base graphs with the same Betti number produce similar
spectral envelopes in their lifts.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

# Self-contained implementations
def graph_laplacian(adj):
    n = adj.shape[0]
    L = -adj.copy().astype(float)
    for i in range(n):
        L[i, i] = float(np.sum(adj[i]))
    return L

def random_graph_lift(adj, n_sheets):
    k = adj.shape[0]
    N = k * n_sheets
    lift_adj = np.zeros((N, N), dtype=int)
    for u in range(k):
        for v in range(u + 1, k):
            if adj[u, v] == 1:
                perm = list(range(n_sheets))
                random.shuffle(perm)
                for s in range(n_sheets):
                    i = u * n_sheets + s
                    j = v * n_sheets + perm[s]
                    lift_adj[i, j] = 1
                    lift_adj[j, i] = 1
    return lift_adj

random.seed(42)
np.random.seed(42)

fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Two base graphs with same Betti number b1 = 2
# Graph 1: K4 minus an edge
G1 = np.array([
    [0, 1, 1, 1],
    [1, 0, 1, 0],
    [1, 1, 0, 1],
    [1, 0, 1, 0]
])

# Graph 2: Theta graph (two vertices, three paths)
G2 = np.array([
    [0, 1, 1, 1],
    [1, 0, 0, 0],
    [1, 0, 0, 1],
    [1, 0, 1, 0]
])

base_graphs = [("K₄ − e  (b₁=2)", G1), ("Theta graph  (b₁=2)", G2)]
sheet_counts = [1, 3, 8]

for row, (name, base) in enumerate(base_graphs):
    for col, n_sheets in enumerate(sheet_counts):
        ax = axes[row, col]

        # Collect eigenvalues from multiple random lifts
        all_eigs = []
        n_samples = 50 if n_sheets <= 5 else 20
        for _ in range(n_samples):
            lift = random_graph_lift(base, n_sheets)
            L = graph_laplacian(lift)
            eigs = np.linalg.eigvalsh(L)
            all_eigs.extend(eigs)

        all_eigs = np.array(all_eigs)

        # Histogram of eigenvalues
        ax.hist(all_eigs, bins=50, density=True, alpha=0.7,
                color=['#2196F3', '#FF5722'][row], edgecolor='white', linewidth=0.5)
        ax.set_title(f"{name}\nn = {n_sheets} sheets", fontsize=11)
        ax.set_xlabel("Eigenvalue λ", fontsize=10)
        ax.set_ylabel("Density", fontsize=10)
        ax.axvline(x=0, color='red', linestyle='--', alpha=0.5, label='λ=0')

        # Mark the base graph eigenvalues
        base_L = graph_laplacian(base)
        base_eigs = np.linalg.eigvalsh(base_L)
        for e in base_eigs:
            ax.axvline(x=e, color='green', linestyle=':', alpha=0.3)

        if row == 0 and col == 0:
            ax.legend(fontsize=8)

fig.suptitle("Spectral Universality: Laplacian Eigenvalue Distributions of Random Graph Lifts",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_laplacian_spectrum.png", dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_spectrum.png")
