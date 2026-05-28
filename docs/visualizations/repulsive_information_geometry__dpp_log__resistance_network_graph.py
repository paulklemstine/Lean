#!/usr/bin/env python3
"""
Visualization: DPP Repulsion as a Resistance Network

Draws the DPP repulsion network as a graph where:
- Edge thickness = conductance (L[i,j]^2)
- Edge color = conductance strength (darker = stronger repulsion)
- Node positions from spectral embedding of the Laplacian
- Node labels show effective resistance to a reference node

This makes the central theorem visual: DPP repulsion IS a resistance network.
"""
import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import pinv, eigvalsh, eigh

def dpp_log_hessian(L):
    n = L.shape[0]
    H = -(L ** 2)
    np.fill_diagonal(H, 0)
    np.fill_diagonal(H, -H.sum(axis=1))
    return H

def spectral_layout(H, dim=2):
    """Compute node positions from the Fiedler vectors of the Laplacian."""
    eigvals, eigvecs = eigh(H)
    # Skip the zero eigenvalue (first), use next `dim` eigenvectors
    idx = np.argsort(eigvals)
    coords = eigvecs[:, idx[1:1+dim]]
    return coords

# Generate a structured DPP kernel
n = 7
rng = np.random.default_rng(123)
A = rng.standard_normal((n, n))
L = A @ A.T / n

H = dpp_log_hessian(L)
H_pinv = pinv(H)

# Conductances
W = L ** 2

# Spectral embedding for layout
pos = spectral_layout(H)

# Effective resistance from node 0
diag = np.diag(H_pinv)
R = diag[:, None] + diag[None, :] - 2 * H_pinv

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

for ax_idx, (ax, title, color_by) in enumerate([
    (axes[0], 'Conductance Network\n(edge width ∝ Lᵢⱼ²)', 'conductance'),
    (axes[1], 'Resistance Distance\n(edge color ∝ R_eff(i,j))', 'resistance')
]):
    # Draw edges
    max_w = np.max(W[np.triu_indices(n, k=1)])
    for i in range(n):
        for j in range(i + 1, n):
            w = W[i, j]
            r = R[i, j]
            if w < 0.01 * max_w:
                continue
            if color_by == 'conductance':
                width = 0.5 + 4 * w / max_w
                alpha = 0.3 + 0.7 * w / max_w
                color = plt.cm.Blues(0.3 + 0.7 * w / max_w)
            else:
                width = 1.5
                max_r = np.max(R[np.triu_indices(n, k=1)])
                alpha = 0.5 + 0.5 * r / max_r
                color = plt.cm.Reds(0.2 + 0.8 * r / max_r)
            ax.plot([pos[i, 0], pos[j, 0]], [pos[i, 1], pos[j, 1]],
                    color=color, linewidth=width, alpha=alpha, zorder=1)

    # Draw nodes
    node_colors = R[0, :]  # Distance from node 0
    scatter = ax.scatter(pos[:, 0], pos[:, 1], c=node_colors,
                          cmap='YlOrRd', s=300, zorder=3,
                          edgecolors='black', linewidths=1.5)
    for i in range(n):
        ax.annotate(str(i), (pos[i, 0], pos[i, 1]),
                    ha='center', va='center', fontsize=12, fontweight='bold',
                    color='white' if node_colors[i] > np.median(node_colors) else 'black')

    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')
    plt.colorbar(scatter, ax=ax, shrink=0.7,
                  label='R_eff(0, i)' if ax_idx == 1 else 'R_eff(0, i)')

plt.suptitle('DPP Repulsion = Resistance Network (n=7)',
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_resistance_network.png', dpi=150, bbox_inches='tight')
print("Saved viz_resistance_network.png")
