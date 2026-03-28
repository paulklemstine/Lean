#!/usr/bin/env python3
"""
Demo 2: Coulomb Gas Visualization

Shows eigenvalue configurations from GOE/GUE/GSE as charged particles on a line,
and compares their density with the Wigner semicircle law.

Generates: coulomb_gas_simulation.png
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.linalg import eigvalsh

np.random.seed(42)

N = 50  # Matrix size
num_hist_samples = 500

fig, axes = plt.subplots(2, 3, figsize=(18, 10))
fig.suptitle('Eigenvalues as a Coulomb Gas at Different Temperatures',
             fontsize=16, fontweight='bold', y=0.98)

betas = [1, 2, 4]
labels = [r'GOE ($\beta=1$, Hot)', r'GUE ($\beta=2$, Warm)', r'GSE ($\beta=4$, Cold)']
colors = ['#2166ac', '#b2182b', '#1b7837']

def sample_ensemble(N, beta):
    """Sample eigenvalues from the appropriate ensemble."""
    if beta == 1:
        A = np.random.randn(N, N)
        H = (A + A.T) / (2 * np.sqrt(2 * N))
    elif beta == 2:
        A = np.random.randn(N, N) + 1j * np.random.randn(N, N)
        H = (A + A.conj().T) / (2 * np.sqrt(2 * N))
    elif beta == 4:
        # Dumitriu-Edelman tridiagonal model for beta=4
        n = N
        diag = np.array([np.random.normal(0, np.sqrt(2)) for _ in range(n)])
        offdiag = np.array([np.random.chisquare(4*(n-i-1)) ** 0.5 for i in range(n-1)])
        H = np.diag(diag) + np.diag(offdiag, 1) + np.diag(offdiag, -1)
        H = H / (2 * np.sqrt(2 * N))
    return np.sort(np.real(np.linalg.eigvalsh(H)))

def semicircle_density(x):
    """Wigner semicircle on [-1, 1]."""
    mask = np.abs(x) < 1
    d = np.zeros_like(x)
    d[mask] = (2/np.pi) * np.sqrt(1 - x[mask]**2)
    return d

for idx, (beta, label, color) in enumerate(zip(betas, labels, colors)):
    print(f"Sampling beta={beta}...")

    # Single sample for particle visualization
    evals = sample_ensemble(N, beta)

    # Top row: Particle positions on a line
    ax = axes[0, idx]
    ax.scatter(evals, np.zeros_like(evals), c=color, s=80, zorder=5,
               edgecolors='black', linewidth=0.5)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 0.5)
    ax.set_yticks([])
    ax.set_xlabel('Position', fontsize=12)
    ax.set_title(label, fontsize=14)
    ax.axhline(y=0, color='gray', linewidth=0.5)

    # Annotate: spacing statistics
    spacings = np.diff(evals)
    ax.text(0.5, 0.85, f'Mean spacing: {np.mean(spacings):.3f}\n'
            f'Min spacing: {np.min(spacings):.4f}\n'
            f'Std of spacings: {np.std(spacings):.3f}',
            transform=ax.transAxes, fontsize=9, ha='center',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

    # Bottom row: Density histogram
    ax = axes[1, idx]
    all_evals = []
    for _ in range(num_hist_samples):
        all_evals.extend(sample_ensemble(N, beta))

    ax.hist(all_evals, bins=60, range=(-1.5, 1.5), density=True,
            alpha=0.6, color=color, edgecolor='white', linewidth=0.3,
            label='Simulation')
    x = np.linspace(-1.5, 1.5, 300)
    ax.plot(x, semicircle_density(x), 'k-', linewidth=2.5, label='Semicircle law')
    ax.set_xlabel('Eigenvalue', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title(f'Density ({label})', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(-1.5, 1.5)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('Random Matrix/demos/coulomb_gas_simulation.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/coulomb_gas_simulation.png")
plt.close()
