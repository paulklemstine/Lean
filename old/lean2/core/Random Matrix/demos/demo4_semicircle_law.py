#!/usr/bin/env python3
"""
Demo 4: Wigner Semicircle Law

Shows convergence of the empirical eigenvalue distribution to the Wigner
semicircle as matrix size N grows. The semicircle is the equilibrium density
of the Coulomb gas — the balance between repulsion and confinement.

Generates: semicircle_law.png
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.linalg import eigvalsh

np.random.seed(42)

def semicircle_density(x, sigma=1.0):
    """Wigner semicircle density ρ(x) = (2/π) √(1 - x²) on [-1, 1], rescaled."""
    R = 2 * sigma
    mask = np.abs(x) < R
    density = np.zeros_like(x)
    density[mask] = (1 / (2 * np.pi * sigma**2)) * np.sqrt(4 * sigma**2 - x[mask]**2)
    return density

fig, axes = plt.subplots(2, 3, figsize=(18, 10))
fig.suptitle("Wigner's Semicircle Law: Eigenvalue Density Converges as N → ∞",
             fontsize=16, fontweight='bold', y=0.98)

sizes = [5, 20, 50, 100, 500, 2000]
num_samples_list = [5000, 2000, 1000, 500, 100, 20]

for idx, (N, num_samples) in enumerate(zip(sizes, num_samples_list)):
    row, col = idx // 3, idx % 3
    ax = axes[row, col]

    print(f"Sampling {num_samples} GUE matrices of size {N}x{N}...")

    all_evals = []
    for _ in range(num_samples):
        A = np.random.randn(N, N) + 1j * np.random.randn(N, N)
        H = (A + A.conj().T) / (2 * np.sqrt(2 * N))
        evals = np.sort(np.real(np.linalg.eigvalsh(H)))
        all_evals.extend(evals)

    all_evals = np.array(all_evals)

    ax.hist(all_evals, bins=min(80, max(20, N//2)), density=True,
            alpha=0.6, color='#2166ac', edgecolor='white', linewidth=0.3,
            label=f'Empirical (N={N})')

    x = np.linspace(-1.5, 1.5, 500)
    ax.plot(x, semicircle_density(x), 'r-', linewidth=2.5,
            label='Semicircle law')

    ax.set_xlabel('Eigenvalue', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title(f'N = {N}  ({num_samples} samples)', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(0, 0.45)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('Random Matrix/demos/semicircle_law.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/semicircle_law.png")
plt.close()
