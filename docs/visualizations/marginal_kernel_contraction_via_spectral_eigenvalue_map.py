#!/usr/bin/env python3
"""
Visualization: Eigenvalue Mapping Under Contraction

Shows how the eigenvalue map f(x) = x(1-x) transforms the spectrum
of K into the spectrum of K - K². The contraction theorem guarantees
all eigenvalues remain nonneg since K's eigenvalues are in [0,1].
"""
import numpy as np
import matplotlib.pyplot as plt

# The contraction function f(x) = x(1-x)
x = np.linspace(-0.2, 1.2, 500)
y = x * (1 - x)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: The eigenvalue map
ax = axes[0]
ax.fill_between(x[(x >= 0) & (x <= 1)], 0, y[(x >= 0) & (x <= 1)],
                alpha=0.2, color='steelblue', label='PSD region')
ax.plot(x, y, 'b-', linewidth=2, label=r'$f(\lambda) = \lambda(1-\lambda)$')
ax.axhline(y=0, color='k', linewidth=0.5)
ax.axvline(x=0, color='k', linewidth=0.5)
ax.axhline(y=0.25, color='red', linewidth=1, linestyle='--',
           label=r'Maximum $f = 1/4$ at $\lambda = 1/2$')
ax.axvline(x=0.5, color='red', linewidth=0.5, linestyle=':')

# Plot example eigenvalues
np.random.seed(42)
n = 8
A = np.random.randn(n, n)
L = A @ A.T
beta = 1.0
eigs_L = np.linalg.eigvalsh(L)
eigs_K = beta * eigs_L / (1 + beta * eigs_L)
eigs_C = eigs_K * (1 - eigs_K)

ax.scatter(eigs_K, eigs_C, c='red', s=80, zorder=5, edgecolors='darkred',
           label=f'Eigenvalues (n={n})')
for ek, ec in zip(eigs_K, eigs_C):
    ax.plot([ek, ek], [0, ec], 'r:', linewidth=0.8, alpha=0.5)

ax.set_xlabel(r'Eigenvalue of $K$', fontsize=12)
ax.set_ylabel(r'Eigenvalue of $K - K^2$', fontsize=12)
ax.set_title('Spectral Contraction Map', fontsize=14)
ax.legend(fontsize=10, loc='upper left')
ax.set_xlim(-0.1, 1.1)
ax.set_ylim(-0.05, 0.35)
ax.grid(True, alpha=0.3)

# Right panel: Histogram of K - K² eigenvalues over many random matrices
ax = axes[1]
all_eigs = []
for trial in range(2000):
    n_trial = np.random.randint(3, 12)
    A_trial = np.random.randn(n_trial, n_trial)
    L_trial = A_trial @ A_trial.T
    beta_trial = np.random.exponential(2.0)
    eigs_L_trial = np.linalg.eigvalsh(L_trial)
    eigs_K_trial = beta_trial * eigs_L_trial / (1 + beta_trial * eigs_L_trial)
    eigs_C_trial = eigs_K_trial * (1 - eigs_K_trial)
    all_eigs.extend(eigs_C_trial)

all_eigs = np.array(all_eigs)
ax.hist(all_eigs, bins=80, density=True, color='steelblue', alpha=0.7,
        edgecolor='navy', linewidth=0.3)
ax.axvline(x=0, color='green', linewidth=2, linestyle='--',
           label=r'$\lambda = 0$ (PSD boundary)')
ax.axvline(x=0.25, color='red', linewidth=2, linestyle='--',
           label=r'$\lambda = 1/4$ (conjectured max)')

ax.set_xlabel(r'Eigenvalue of $K - K^2$', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Distribution of Contraction Eigenvalues\n(2000 random PSD matrices)',
             fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(-0.02, 0.30)
ax.grid(True, alpha=0.3)

# Add annotation
min_eig = all_eigs.min()
ax.annotate(f'Min eigenvalue: {min_eig:.2e}\n(always ≥ 0, as proved)',
            xy=(min_eig, 0), xytext=(0.08, 8),
            fontsize=9, ha='center',
            arrowprops=dict(arrowstyle='->', color='darkgreen'),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

fig.suptitle('The Contraction Theorem: Eigenvalues of K − K²',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('eigenvalue_map.png', dpi=150, bbox_inches='tight')
plt.close()
