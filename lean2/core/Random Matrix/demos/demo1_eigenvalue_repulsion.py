#!/usr/bin/env python3
"""
Demo 1: Eigenvalue Repulsion Visualization

Compares the eigenvalue spacing distribution of GOE/GUE random matrices
against independent random points (Poisson). Shows that eigenvalues repel —
small spacings are suppressed relative to the Poisson prediction.

Generates: eigenvalue_repulsion.png
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.linalg import eigvalsh

np.random.seed(42)

def sample_goe(n):
    """Sample from Gaussian Orthogonal Ensemble (beta=1)."""
    A = np.random.randn(n, n)
    return (A + A.T) / 2

def sample_gue(n):
    """Sample from Gaussian Unitary Ensemble (beta=2)."""
    A = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    return (A + A.conj().T) / 2

def unfolded_spacings(eigenvalues):
    """Compute nearest-neighbor spacings after unfolding to unit mean spacing."""
    spacings = np.diff(eigenvalues)
    mean_spacing = np.mean(spacings)
    if mean_spacing > 0:
        spacings = spacings / mean_spacing
    return spacings

def wigner_surmise(s, beta):
    """Wigner surmise for nearest-neighbor spacing distribution P(s)."""
    if beta == 1:
        return (np.pi / 2) * s * np.exp(-np.pi * s**2 / 4)
    elif beta == 2:
        return (32 / np.pi**2) * s**2 * np.exp(-4 * s**2 / np.pi)
    elif beta == 4:
        return (2**18 / (3**6 * np.pi**3)) * s**4 * np.exp(-64 * s**2 / (9 * np.pi))

# Parameters
N = 100
num_samples = 2000

# Collect spacings
spacings_goe = []
spacings_gue = []
spacings_poisson = []

print("Sampling GOE matrices...")
for _ in range(num_samples):
    H = sample_goe(N)
    evals = eigvalsh(H)
    spacings_goe.extend(unfolded_spacings(evals))

print("Sampling GUE matrices...")
for _ in range(num_samples):
    H = sample_gue(N)
    evals = np.sort(np.real(np.linalg.eigvalsh(H)))
    spacings_gue.extend(unfolded_spacings(evals))

print("Generating Poisson spacings...")
spacings_poisson = np.random.exponential(1.0, size=N * num_samples)

# Plot
fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Eigenvalue Repulsion: Random Matrix vs. Independent Points',
             fontsize=16, fontweight='bold', y=1.02)

s = np.linspace(0, 4, 300)

configs = [
    (axes[0], spacings_poisson, None, 'Poisson\n(Independent Points)',
     '#888888', r'$P(s) = e^{-s}$'),
    (axes[1], spacings_goe, 1, r'GOE ($\beta = 1$)' + '\nReal Symmetric',
     '#2166ac', 'Wigner surmise'),
    (axes[2], spacings_gue, 2, r'GUE ($\beta = 2$)' + '\nComplex Hermitian',
     '#b2182b', 'Wigner surmise'),
]

for ax, data, beta, title, color, theory_label in configs:
    ax.hist(data, bins=80, range=(0, 4), density=True, alpha=0.6,
            color=color, edgecolor='white', linewidth=0.5)
    if beta is None:
        ax.plot(s, np.exp(-s), 'k-', linewidth=2.5, label=theory_label)
    else:
        ax.plot(s, wigner_surmise(s, beta), 'k-', linewidth=2.5, label=theory_label)
    ax.set_xlabel('Normalized Spacing $s$', fontsize=13)
    ax.set_ylabel('Probability Density $P(s)$', fontsize=13)
    ax.set_title(title, fontsize=14)
    ax.legend(fontsize=12, loc='upper right')
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 1.15)

    if beta is not None:
        ax.annotate(f'$P(s) \\sim s^{beta}$ as $s \\to 0$\n(repulsion!)',
                    xy=(0.35, 0.85), fontsize=11, color='darkred',
                    xycoords='axes fraction',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.8))
    else:
        ax.annotate('$P(0) > 0$\n(no repulsion)',
                    xy=(0.35, 0.85), fontsize=11, color='darkred',
                    xycoords='axes fraction',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('Random Matrix/demos/eigenvalue_repulsion.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/eigenvalue_repulsion.png")
plt.close()
