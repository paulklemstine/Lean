"""
Visualization: Laplacian Energy Identity

Illustrates the fundamental identity:
    v^T M v = -(1/2) ∑_{i≠j} w_{ij} (v_i - v_j)^2

Shows how the quadratic form of a negative Laplacian decomposes into
edge-weighted squared differences, revealing the graph energy structure
behind conditional negative semidefiniteness.
"""

import numpy as np
import matplotlib.pyplot as plt


def neg_laplacian(w):
    """Construct negative Laplacian from weight matrix."""
    n = w.shape[0]
    M = w.copy()
    for i in range(n):
        M[i, i] = -sum(w[i, j] for j in range(n) if j != i)
    return M


def quadratic_form(M, v):
    return v @ M @ v


def edge_energy_decomposition(w, v):
    """Compute edge-by-edge energy contributions."""
    n = w.shape[0]
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if w[i, j] > 1e-12:
                energy = -w[i, j] * (v[i] - v[j])**2
                edges.append({
                    'i': i, 'j': j,
                    'weight': w[i, j],
                    'diff': v[i] - v[j],
                    'energy': energy
                })
    return edges


# Create a weighted graph (pentagon with varying edge weights)
n = 5
w = np.zeros((n, n))
edge_list = [(0,1,3), (1,2,1), (2,3,2), (3,4,1.5), (4,0,2.5), (0,2,0.5), (1,3,1)]
for i, j, wt in edge_list:
    w[i, j] = wt
    w[j, i] = wt

M = neg_laplacian(w)

# Test with various zero-sum vectors
np.random.seed(42)
n_vectors = 6
vectors = []
for k in range(n_vectors):
    v = np.random.randn(n)
    v -= v.mean()  # project to zero-sum
    v /= np.linalg.norm(v)
    vectors.append(v)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

for idx, v in enumerate(vectors):
    ax = axes[idx // 3, idx % 3]

    edges = edge_energy_decomposition(w, v)
    total = quadratic_form(M, v)
    edge_sum = sum(e['energy'] for e in edges)

    # Sort edges by absolute energy
    edges.sort(key=lambda e: abs(e['energy']), reverse=True)

    # Bar chart of edge energies
    labels = [f"({e['i']},{e['j']})" for e in edges]
    energies = [e['energy'] for e in edges]
    colors = ['#d32f2f' if e < 0 else '#1976d2' for e in energies]

    bars = ax.barh(range(len(edges)), energies, color=colors, edgecolor='black',
                   linewidth=0.5, height=0.6)
    ax.set_yticks(range(len(edges)))
    ax.set_yticklabels(labels, fontsize=9)
    ax.axvline(x=0, color='black', linewidth=0.8)
    ax.set_xlabel('Edge energy −w_{ij}(v_i−v_j)²', fontsize=9)
    ax.set_title(f'v = [{", ".join(f"{x:.2f}" for x in v)}]\n'
                 f'v^T M v = {total:.4f} = Σ edges = {edge_sum:.4f}',
                 fontsize=10, fontweight='bold')

    # Verification annotation
    ax.annotate(f'Identity holds: {np.isclose(total, edge_sum)}',
                xy=(0.02, 0.02), xycoords='axes fraction',
                fontsize=8, color='green' if np.isclose(total, edge_sum) else 'red')

fig.suptitle('Laplacian Energy Identity: v^T M v = −½ Σ_{i≠j} w_{ij}(v_i − v_j)²\n'
             '(All energies nonpositive ⟹ NSD)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_laplacian_energy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_laplacian_energy.png")
