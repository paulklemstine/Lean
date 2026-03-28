#!/usr/bin/env python3
"""
Demo 6: Numerical Verification of the Fundamental Identity

Numerically verifies the key theorem:
    repulsionFactor(β, ev) = exp(-β × coulombEnergy(ev))

for random eigenvalue configurations across all three ensembles.

Generates: fundamental_identity_verification.png
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

def repulsion_factor(eigenvalues, beta):
    """Compute |∏_{i<j} (λ_j - λ_i)|^β."""
    n = len(eigenvalues)
    log_prod = 0.0
    for i in range(n):
        for j in range(i+1, n):
            log_prod += np.log(abs(eigenvalues[j] - eigenvalues[i]))
    return np.exp(beta * log_prod)

def coulomb_energy(eigenvalues):
    """Compute -∑_{i<j} log|λ_j - λ_i|."""
    n = len(eigenvalues)
    E = 0.0
    for i in range(n):
        for j in range(i+1, n):
            E -= np.log(abs(eigenvalues[j] - eigenvalues[i]))
    return E

def boltzmann_weight(eigenvalues, beta):
    """Compute exp(-β × coulombEnergy)."""
    return np.exp(-beta * coulomb_energy(eigenvalues))

# Generate many random eigenvalue configurations
num_configs = 500
N = 8  # Number of eigenvalues per config

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Numerical Verification: Repulsion Factor = exp(−β × Coulomb Energy)',
             fontsize=15, fontweight='bold', y=1.02)

betas = [1, 2, 4]
labels = [r'$\beta = 1$ (GOE)', r'$\beta = 2$ (GUE)', r'$\beta = 4$ (GSE)']
colors = ['#2166ac', '#b2182b', '#1b7837']

for idx, (beta, label, color) in enumerate(zip(betas, labels, colors)):
    lhs_values = []
    rhs_values = []

    for _ in range(num_configs):
        # Random distinct eigenvalues
        ev = np.sort(np.random.randn(N) * 2)

        lhs = repulsion_factor(ev, beta)
        rhs = boltzmann_weight(ev, beta)

        if np.isfinite(lhs) and np.isfinite(rhs) and lhs > 0 and rhs > 0:
            lhs_values.append(np.log10(lhs))
            rhs_values.append(np.log10(rhs))

    lhs_values = np.array(lhs_values)
    rhs_values = np.array(rhs_values)

    ax = axes[idx]
    ax.scatter(lhs_values, rhs_values, c=color, alpha=0.4, s=20, edgecolors='none')

    # Perfect agreement line
    lims = [min(lhs_values.min(), rhs_values.min()),
            max(lhs_values.max(), rhs_values.max())]
    ax.plot(lims, lims, 'k-', linewidth=2, label='Perfect identity')

    # Compute max relative error
    errors = np.abs(lhs_values - rhs_values) / (np.abs(lhs_values) + 1e-15)
    max_error = np.max(errors)

    ax.set_xlabel(r'$\log_{10}$ Repulsion Factor $|\prod_{i<j}(\lambda_j - \lambda_i)|^\beta$',
                  fontsize=11)
    ax.set_ylabel(r'$\log_{10}$ Boltzmann Weight $\exp(-\beta \cdot E_{Coulomb})$',
                  fontsize=11)
    ax.set_title(label, fontsize=14)
    ax.legend(fontsize=11, loc='upper left')
    ax.set_aspect('equal')
    ax.text(0.95, 0.05, f'Max rel. error: {max_error:.2e}',
            transform=ax.transAxes, fontsize=10, ha='right',
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

plt.tight_layout()
plt.savefig('Random Matrix/demos/fundamental_identity_verification.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/fundamental_identity_verification.png")
plt.close()

# ===== Additional: Repulsion factor as function of spacing =====
fig, ax = plt.subplots(figsize=(10, 6))
fig.suptitle('Repulsion Factor vs. Eigenvalue Spacing (Two-Point Case)',
             fontsize=15, fontweight='bold', y=1.02)

d_values = np.linspace(0.01, 4, 300)

for beta, label, color in zip(betas, labels, colors):
    repulsion = np.abs(d_values) ** beta
    ax.plot(d_values, repulsion, color=color, linewidth=2.5, label=label)

ax.set_xlabel(r'Eigenvalue Spacing $d = |\lambda_2 - \lambda_1|$', fontsize=13)
ax.set_ylabel(r'Repulsion Factor $d^\beta$', fontsize=13)
ax.set_title('Two-Point Repulsion: Higher β = Stronger Repulsion', fontsize=14)
ax.legend(fontsize=12)
ax.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax.annotate('Zero spacing →\nzero probability',
            xy=(0.05, 0.01), fontsize=11, color='darkred',
            xytext=(1.0, 0.5),
            arrowprops=dict(arrowstyle='->', color='darkred', lw=2),
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

ax.set_xlim(0, 4)
ax.set_ylim(0, 5)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('Random Matrix/demos/two_point_repulsion.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/two_point_repulsion.png")
plt.close()
