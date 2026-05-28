"""
Visualization: Stability Landscape for Uniform Matroid Perturbations

This script creates a heatmap showing how the number of positive eigenvalues
of (J - I + t·E) changes as we vary the perturbation magnitude t and the
perturbation type E. The Lorentzian region (at most 1 positive eigenvalue)
is clearly delineated from the non-Lorentzian region.

This visualizes the "phase transition" at the stability radius: a sharp
boundary where Lorentzianity is lost.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def uniform_leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

def count_positive_eigenvalues(A, tol=1e-10):
    return int(np.sum(np.linalg.eigvalsh(A) > tol))

def perturbation_matrix(m, kind):
    if kind == 'identity':
        return np.eye(m)
    elif kind == 'diagonal_first':
        E = np.zeros((m, m))
        E[0, 0] = 1.0
        return E
    elif kind == 'off_diagonal':
        E = np.zeros((m, m))
        E[0, 1] = E[1, 0] = 1.0
        return E
    elif kind == 'all_ones':
        return np.ones((m, m))
    elif kind == 'alternating':
        E = np.zeros((m, m))
        for i in range(m):
            for j in range(m):
                E[i, j] = (-1)**(i + j)
        return E

# Parameters
m = 6
t_values = np.linspace(-2, 4, 300)
perturbation_types = ['identity', 'diagonal_first', 'off_diagonal', 'all_ones', 'alternating']
labels = ['t·I', 't·e₁₁', 't·(e₁₂+e₂₁)', 't·J', 't·alternating']

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

H = uniform_leaf_hessian(m)

for idx, (ptype, label) in enumerate(zip(perturbation_types, labels)):
    ax = axes[idx // 3][idx % 3]
    E = perturbation_matrix(m, ptype)

    # Compute eigenvalues for each t
    all_eigs = np.array([sorted(np.linalg.eigvalsh(H + t * E)) for t in t_values])
    n_positive = np.array([count_positive_eigenvalues(H + t * E) for t in t_values])

    # Plot eigenvalue trajectories
    for j in range(m):
        color = 'red' if j == m - 1 else 'blue'
        alpha = 1.0 if j == m - 1 else 0.4
        ax.plot(t_values, all_eigs[:, j], color=color, alpha=alpha, linewidth=1.5)

    # Shade Lorentzian region
    lorentzian_mask = n_positive <= 1
    for i in range(len(t_values) - 1):
        if lorentzian_mask[i]:
            ax.axvspan(t_values[i], t_values[i+1], alpha=0.05, color='green')

    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Perturbation magnitude t', fontsize=11)
    ax.set_ylabel('Eigenvalue', fontsize=11)
    ax.set_title(f'Perturbation: {label}', fontsize=12, fontweight='bold')
    ax.set_ylim(-5, 15)
    ax.grid(True, alpha=0.2)

    # Find threshold
    threshold_indices = np.where(np.diff(n_positive) != 0)[0]
    if len(threshold_indices) > 0:
        for ti in threshold_indices[:2]:
            ax.axvline(x=t_values[ti], color='red', linestyle=':', alpha=0.7)
            ax.text(t_values[ti], ax.get_ylim()[1] * 0.9, f't≈{t_values[ti]:.2f}',
                    fontsize=9, color='red', ha='center')

# Summary panel
ax_summary = axes[1][2]
m_range = range(3, 12)
thresholds_identity = []
thresholds_diag = []
for m_val in m_range:
    H_m = uniform_leaf_hessian(m_val)
    # Identity threshold
    for t in np.linspace(0, 5, 500):
        if count_positive_eigenvalues(H_m + t * np.eye(m_val)) > 1:
            thresholds_identity.append(t)
            break
    else:
        thresholds_identity.append(5.0)
    # Diagonal threshold
    E_d = np.zeros((m_val, m_val))
    E_d[0, 0] = 1.0
    for t in np.linspace(0, 10, 500):
        if count_positive_eigenvalues(H_m + t * E_d) > 1:
            thresholds_diag.append(t)
            break
    else:
        thresholds_diag.append(10.0)

ax_summary.plot(list(m_range), thresholds_identity, 'go-', markersize=8, linewidth=2,
                 label='t·I threshold')
ax_summary.plot(list(m_range), thresholds_diag, 'r^-', markersize=8, linewidth=2,
                 label='t·e₁₁ threshold')
ax_summary.axhline(y=1.0, color='green', linestyle='--', alpha=0.7, label='Predicted (gap=1)')
ax_summary.set_xlabel('Leaf dimension m', fontsize=11)
ax_summary.set_ylabel('Instability threshold t', fontsize=11)
ax_summary.set_title('Threshold vs Dimension', fontsize=12, fontweight='bold')
ax_summary.legend(fontsize=10)
ax_summary.grid(True, alpha=0.3)

plt.suptitle(f'Eigenvalue Trajectories Under Perturbation (m = {6})',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_stability_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability_landscape.png")
