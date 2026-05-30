"""
Visualization: Negative Dependence Defect Heatmap

Shows the pairwise negative dependence values for ideal and noisy
fermionic states as heatmaps, along with the certified defect bound.
Illustrates how noise degrades the DPP quality certificate.
"""

import numpy as np
import matplotlib.pyplot as plt

def iterated_depolarizing(K, eps, d):
    n = K.shape[0]
    c = (1 - eps) ** d
    return c * K + (1 - c) / 2 * np.eye(n)

def neg_dep_matrix(K):
    n = K.shape[0]
    P = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            P[i, j] = K[i, i] * K[j, j] - K[i, j] * K[j, i]
    return P

# Correlation matrix (8x8 for better visualization)
n = 8
np.random.seed(42)
# Create a valid correlation matrix
A = np.random.randn(n, n) * 0.3
K = A @ A.T / n
K = K / (np.max(np.linalg.eigvalsh(K)) + 0.1)
K = (K + K.T) / 2

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

configs = [
    (0.0, 0, 'Ideal (no noise)'),
    (0.01, 20, 'ε=0.01, d=20'),
    (0.01, 100, 'ε=0.01, d=100'),
    (0.05, 10, 'ε=0.05, d=10'),
    (0.05, 50, 'ε=0.05, d=50'),
    (0.1, 20, 'ε=0.1, d=20'),
]

vmin = -0.05
vmax = 0.3

for idx, (eps, d, title) in enumerate(configs):
    ax = axes[idx // 3, idx % 3]
    K_noisy = iterated_depolarizing(K, eps, d) if d > 0 else K
    P = neg_dep_matrix(K_noisy)

    im = ax.imshow(P, cmap='RdYlGn', vmin=vmin, vmax=vmax,
                    interpolation='nearest')
    ax.set_title(title, fontsize=11, fontweight='bold')

    # Add text annotations
    for i in range(n):
        for j in range(n):
            color = 'white' if abs(P[i, j]) > 0.15 else 'black'
            ax.text(j, i, f'{P[i,j]:.2f}', ha='center', va='center',
                   fontsize=6, color=color)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel('Mode j', fontsize=9)
    ax.set_ylabel('Mode i', fontsize=9)

    # Show certified bound
    if d > 0:
        eta = 3 * d * eps / 2
        bound = 2 * (2 * eta + eta**2)
        ax.text(0.02, 0.98, f'Cert. bound: {bound:.4f}',
               transform=ax.transAxes, fontsize=8,
               verticalalignment='top',
               bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

fig.colorbar(im, ax=axes, shrink=0.8, label='Pair Inclusion P(i,j)')
plt.suptitle('Pairwise Negative Dependence Values\n'
             'P(i,j) = K_ii·K_jj - K_ij·K_ji under Depolarizing Noise',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 0.92, 0.93])
plt.savefig('viz_neg_dep_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_neg_dep_heatmap.png")
