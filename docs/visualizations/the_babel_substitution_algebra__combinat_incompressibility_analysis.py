#!/usr/bin/env python3
"""
visualize_babel.py — Visualization of Library of Babel incompressibility.

Plots the fraction of compressible books as a function of compression ratio
for various alphabet sizes.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def compressible_fraction(alpha: int, N: int, M: int) -> float:
    """Upper bound on fraction of compressible books: α^(M-N)."""
    if M >= N:
        return 1.0
    return alpha ** (M - N)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Compressible fraction vs compression ratio
ax1 = axes[0]
N = 100
ratios = np.linspace(0.01, 0.99, 200)
for alpha in [2, 5, 10, 25]:
    fracs = [compressible_fraction(alpha, N, int(N * r)) for r in ratios]
    ax1.semilogy(ratios, fracs, label=f'α = {alpha}', linewidth=2)

ax1.set_xlabel('Compression Ratio M/N', fontsize=12)
ax1.set_ylabel('Compressible Fraction (upper bound)', fontsize=12)
ax1.set_title('Incompressibility: Almost All Books Are Random', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-100, 10)

# Plot 2: Hamming ball volume vs radius
ax2 = axes[1]
N = 50
import math
for alpha in [2, 5, 10, 25]:
    radii = range(0, N + 1)
    volumes = []
    for r in radii:
        vol = sum(math.comb(N, k) * (alpha - 1) ** k for k in range(r + 1))
        total = alpha ** N
        volumes.append(vol / total)
    ax2.plot(list(radii), volumes, label=f'α = {alpha}', linewidth=2)

ax2.set_xlabel('Hamming Ball Radius r', fontsize=12)
ax2.set_ylabel('Volume Fraction |B(b,r)| / α^N', fontsize=12)
ax2.set_title(f'Hamming Ball Volume Growth (N={N})', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('babel_incompressibility.png', dpi=150, bbox_inches='tight')
print("Saved: babel_incompressibility.png")
