#!/usr/bin/env python3
"""
Visualization: Fischer Inequality and Negative Dependence
==========================================================

Shows the Fischer sandwich inequality for DPP kernels:
0 ≤ det(K_{ij}) ≤ K_ii · K_jj

Each point represents a pair (i,j). The x-axis is K_ii · K_jj (product
of marginals) and y-axis is det(K_{ij}) (joint weight). Points must lie
between y=0 and y=x (the identity line).

Different colors represent different matrix types (diagonal, rank-1, generic).
"""

import numpy as np
import matplotlib.pyplot as plt


def random_psd_matrix(n, rank=None, seed=42):
    rng = np.random.default_rng(seed)
    r = rank if rank is not None else n
    A = rng.standard_normal((r, n))
    return A.T @ A


fig, axes = plt.subplots(1, 3, figsize=(17, 5))

# Generate different types of PSD matrices
n = 8
configs = [
    ("Diagonal PSD", np.diag(np.abs(np.random.default_rng(1).standard_normal(n)) + 0.1)),
    ("Rank-2 PSD", random_psd_matrix(n, rank=2, seed=2)),
    ("Generic PSD (Full Rank)", random_psd_matrix(n, seed=3)),
]

for ax, (title, K) in zip(axes, configs):
    prods = []
    joints = []
    ratios = []

    for i in range(n):
        for j in range(i + 1, n):
            prod = K[i, i] * K[j, j]
            joint = K[i, i] * K[j, j] - K[i, j] ** 2
            prods.append(prod)
            joints.append(joint)
            if prod > 1e-15:
                ratios.append(joint / prod)

    prods = np.array(prods)
    joints = np.array(joints)

    # Plot the identity line y = x
    max_val = max(max(prods), max(joints)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'k--', linewidth=1, alpha=0.5, label='y = x (upper bound)')
    ax.axhline(y=0, color='red', linestyle=':', alpha=0.5, label='y = 0 (lower bound)')

    # Fill the valid region
    ax.fill_between([0, max_val], [0, 0], [0, max_val], alpha=0.08, color='green',
                     label='Valid region')

    # Scatter plot
    scatter = ax.scatter(prods, joints, c=ratios if ratios else 'blue',
                         cmap='coolwarm', s=60, edgecolors='black', linewidth=0.5,
                         vmin=0, vmax=1, zorder=5)

    ax.set_xlabel('K_ii · K_jj (Marginal Product)', fontsize=11)
    ax.set_ylabel('det(K_{ij}) (Joint Weight)', fontsize=11)
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlim(-0.05 * max_val, max_val)
    ax.set_ylim(-0.05 * max_val, max_val)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    ax.legend(fontsize=8, loc='upper left')

    # Annotate with ratio statistics
    if ratios:
        ax.text(0.95, 0.05, f'min ratio: {min(ratios):.3f}\nmax ratio: {max(ratios):.3f}\nmean: {np.mean(ratios):.3f}',
                transform=ax.transAxes, fontsize=9, verticalalignment='bottom',
                horizontalalignment='right',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

fig.suptitle('Fischer Inequality: 0 ≤ det(K_{ij}) ≤ K_ii · K_jj\n'
             'Every pair (i,j) satisfies negative dependence',
             fontsize=14, fontweight='bold', y=1.02)
plt.colorbar(scatter, ax=axes, label='Correlation Ratio', shrink=0.8, pad=0.02)
plt.tight_layout()
plt.savefig('viz_fischer_inequality.png', dpi=150, bbox_inches='tight')
print("Saved viz_fischer_inequality.png")
