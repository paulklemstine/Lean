#!/usr/bin/env python3
"""
Visualization: Dirichlet Form Identity Verification

Plots the Dirichlet form identity verification for multiple matrix sizes,
showing that xᵀHx = ½∑ Lᵢⱼ²(xᵢ-xⱼ)² holds to machine precision.
Also shows the spectrum of the DPP log-Hessian, confirming PSD with
kernel = constants (smallest eigenvalue ≈ 0).
"""
import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import eigvalsh

def dpp_log_hessian(L):
    n = L.shape[0]
    H = -(L ** 2)
    np.fill_diagonal(H, 0)
    np.fill_diagonal(H, -H.sum(axis=1))
    return H

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left plot: Dirichlet identity errors for various n
sizes = [3, 4, 5, 6, 8, 10]
n_tests = 200
all_errors = {}

for n in sizes:
    rng = np.random.default_rng(42 + n)
    A = rng.standard_normal((n, n))
    L = A @ A.T / n
    H = dpp_log_hessian(L)

    errors = []
    for _ in range(n_tests):
        x = rng.standard_normal(n)
        x -= x.mean()
        E_quad = float(x @ H @ x)
        diff = x[:, None] - x[None, :]
        E_pair = 0.5 * np.sum(L ** 2 * diff ** 2)
        errors.append(abs(E_quad - E_pair))
    all_errors[n] = errors

positions = range(len(sizes))
bp = axes[0].boxplot([all_errors[n] for n in sizes],
                      positions=positions, widths=0.6,
                      patch_artist=True)

colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(sizes)))
for patch, color in zip(bp['boxes'], colors):
    patch.set_facecolor(color)
    patch.set_alpha(0.7)

axes[0].set_xticks(positions)
axes[0].set_xticklabels([str(n) for n in sizes])
axes[0].set_xlabel('Matrix size n', fontsize=12)
axes[0].set_ylabel('Absolute error', fontsize=12)
axes[0].set_title('Dirichlet Form Identity Error\n'
                   r'$x^T H x = \frac{1}{2}\sum L_{ij}^2(x_i-x_j)^2$',
                   fontsize=13, fontweight='bold')
axes[0].set_yscale('log')
axes[0].grid(True, alpha=0.3)

# Right plot: Eigenvalue spectrum for various n
for idx, n in enumerate(sizes):
    rng = np.random.default_rng(42 + n)
    A = rng.standard_normal((n, n))
    L = A @ A.T / n
    H = dpp_log_hessian(L)
    eigs = np.sort(eigvalsh(H))
    axes[1].scatter([idx] * len(eigs), eigs,
                     c=[colors[idx]], alpha=0.8, s=60, zorder=3,
                     edgecolors='black', linewidths=0.5)

axes[1].axhline(y=0, color='red', linestyle='--', alpha=0.5, label='λ = 0')
axes[1].set_xticks(range(len(sizes)))
axes[1].set_xticklabels([str(n) for n in sizes])
axes[1].set_xlabel('Matrix size n', fontsize=12)
axes[1].set_ylabel('Eigenvalue', fontsize=12)
axes[1].set_title('Spectrum of DPP Log-Hessian\n'
                   '(Smallest eigenvalue ≈ 0, rest positive)',
                   fontsize=13, fontweight='bold')
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_dirichlet.png', dpi=150, bbox_inches='tight')
print("Saved viz_dirichlet.png")
