"""
Visualization 3: Correlation Matrix Evolution Under Noise
==========================================================
Heatmap visualization showing how the fermion correlation matrix
evolves as depolarizing noise is applied over multiple circuit layers.
Demonstrates the contraction toward the maximally mixed state.
"""

import numpy as np
import matplotlib.pyplot as plt


def molecular_orbital_kernel(n_orbitals, n_electrons, hopping_strength=1.0):
    H = np.zeros((n_orbitals, n_orbitals))
    for i in range(n_orbitals - 1):
        H[i, i + 1] = -hopping_strength
        H[i + 1, i] = -hopping_strength
    eigvals, eigvecs = np.linalg.eigh(H)
    occupied = eigvecs[:, :n_electrons]
    return occupied @ occupied.T


# Setup
n = 8
k = 4
K = molecular_orbital_kernel(n, k)

depths = [0, 5, 20, 100]
eps = 0.05

fig, axes = plt.subplots(2, 4, figsize=(20, 9))

for idx, d in enumerate(depths):
    K_d = K.copy()
    for _ in range(d):
        K_d = (1 - eps) * K_d + eps * np.eye(n) / 2

    # Top row: correlation matrix heatmap
    ax = axes[0, idx]
    im = ax.imshow(K_d, cmap='RdBu_r', vmin=-0.5, vmax=1.0, aspect='equal')
    ax.set_title(f'd = {d}', fontsize=14, fontweight='bold')
    if idx == 0:
        ax.set_ylabel('Mode i', fontsize=12)
    ax.set_xlabel('Mode j', fontsize=12)
    plt.colorbar(im, ax=ax, fraction=0.046)

    # Bottom row: eigenvalue spectrum
    ax2 = axes[1, idx]
    eigvals = np.linalg.eigvalsh(K_d)
    colors = ['#2196F3' if v > 0.01 else '#9E9E9E' for v in eigvals]
    ax2.bar(range(n), eigvals, color=colors, edgecolor='black', linewidth=0.5)
    ax2.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='Mixed state')
    ax2.set_ylim(-0.05, 1.05)
    ax2.set_xlabel('Eigenvalue index', fontsize=12)
    if idx == 0:
        ax2.set_ylabel('Eigenvalue', fontsize=12)
    ax2.set_title(f'Spectrum (d={d})', fontsize=12)
    if idx == 0:
        ax2.legend(fontsize=10)

    # Annotate with max entry diff
    if d > 0:
        diff = np.abs(K - K_d).max()
        ax.text(0.02, 0.02, f'‖K-K\'‖_max={diff:.3f}',
                transform=ax.transAxes, fontsize=9, color='white',
                bbox=dict(boxstyle='round', facecolor='black', alpha=0.7),
                verticalalignment='bottom')

plt.suptitle(f'Fermion Correlation Matrix Under Depolarizing Noise\n'
             f'(n={n} modes, {k} electrons, ε={eps} per gate)',
             fontsize=16, fontweight='bold', y=1.0)
plt.tight_layout()
plt.savefig("kernel_evolution.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved kernel_evolution.png")
