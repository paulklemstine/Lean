#!/usr/bin/env python3
"""
Visualization: Transfer Matrix Structure and Perron-Frobenius Eigenvector
=========================================================================

Visualizes the structure of Wilson transfer matrices and their Perron-Frobenius
eigenvectors. Shows how positive entries guarantee a unique positive ground state.

The heatmaps show:
- Transfer matrix entries (all positive, confirming positivity-improving)
- Perron-Frobenius eigenvector (all positive entries - the unique vacuum state)
- Eigenvalue spectrum
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def build_wilson_transfer_matrix(n: int, beta: float) -> np.ndarray:
    """Build Wilson transfer matrix with cyclic cosine weight."""
    T = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            T[i, j] = np.exp(beta * np.cos(2 * np.pi * (i - j) / n))
    return T


fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(3, 4, hspace=0.4, wspace=0.4)

betas = [0.5, 1.0, 2.0, 4.0]
n = 8

for col, beta in enumerate(betas):
    T = build_wilson_transfer_matrix(n, beta)
    eigenvalues, eigenvectors = np.linalg.eigh(T)
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    # Ensure Perron vector is positive
    perron = eigenvectors[:, 0]
    if perron[0] < 0:
        perron = -perron

    # Row 1: Transfer matrix heatmap
    ax = fig.add_subplot(gs[0, col])
    im = ax.imshow(T, cmap='YlOrRd', aspect='equal')
    ax.set_title(f'β = {beta}', fontsize=13, fontweight='bold')
    if col == 0:
        ax.set_ylabel('Transfer Matrix T', fontsize=11)
    ax.set_xticks([])
    ax.set_yticks([])
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Row 2: Eigenvalue spectrum
    ax = fig.add_subplot(gs[1, col])
    colors_eig = ['#FF5722' if i == 0 else '#2196F3' for i in range(len(eigenvalues))]
    ax.bar(range(len(eigenvalues)), eigenvalues, color=colors_eig, alpha=0.8)
    ax.set_xlabel('Eigenvalue index', fontsize=10)
    if col == 0:
        ax.set_ylabel('Eigenvalue', fontsize=11)
    gap = eigenvalues[0] - eigenvalues[1]
    ax.annotate(f'Gap = {gap:.2f}', xy=(0.5, eigenvalues[0]),
                fontsize=8, ha='center', va='bottom',
                color='#FF5722', fontweight='bold')

    # Row 3: Perron vector
    ax = fig.add_subplot(gs[2, col])
    ax.bar(range(n), perron, color='#4CAF50', alpha=0.8)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('Configuration index', fontsize=10)
    if col == 0:
        ax.set_ylabel('Perron Vector', fontsize=11)
    all_pos = np.all(perron > 0)
    ax.set_title(f'All positive: {all_pos}', fontsize=10,
                color='green' if all_pos else 'red')

fig.suptitle('Wilson Transfer Matrix: Structure, Spectrum & Perron Vector\n'
             '(n=8 discretized gauge model)',
             fontsize=15, fontweight='bold', y=1.02)

plt.savefig('transfer_matrix_structure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: transfer_matrix_structure.png")
