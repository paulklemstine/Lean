#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs Coupling Strength
=================================================

Visualizes the key result: how the spectral gap of the Wilson transfer matrix
depends on the coupling constant β, for various discretization sizes.
This illustrates the finite-volume mass gap that was formally proved to exist.

The plot shows:
- Top eigenvalue λ₀ and second eigenvalue λ₁ vs β
- The spectral gap Δ = λ₀ - λ₁ vs β
- The normalized gap Δ/λ₀ vs β (monotonically decreasing - the conjecture)
"""

import numpy as np
import matplotlib.pyplot as plt


def build_wilson_transfer_matrix(n: int, beta: float) -> np.ndarray:
    """Build Wilson transfer matrix with cyclic cosine weight."""
    T = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            T[i, j] = np.exp(beta * np.cos(2 * np.pi * (i - j) / n))
    return T


def compute_spectral_data(n: int, betas: np.ndarray):
    """Compute eigenvalue data for a range of β values."""
    lam0s, lam1s, gaps, norm_gaps = [], [], [], []
    for beta in betas:
        T = build_wilson_transfer_matrix(n, beta)
        eigs = np.sort(np.linalg.eigvalsh(T))[::-1]
        lam0s.append(eigs[0])
        lam1s.append(eigs[1])
        gaps.append(eigs[0] - eigs[1])
        norm_gaps.append((eigs[0] - eigs[1]) / eigs[0])
    return np.array(lam0s), np.array(lam1s), np.array(gaps), np.array(norm_gaps)


# Generate data
betas = np.linspace(0.05, 5.0, 200)
sizes = [4, 8, 16]
colors = ['#2196F3', '#FF5722', '#4CAF50']

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Eigenvalues vs β
ax = axes[0, 0]
for n, color in zip(sizes, colors):
    lam0, lam1, _, _ = compute_spectral_data(n, betas)
    ax.plot(betas, lam0, '-', color=color, linewidth=2, label=f'λ₀ (n={n})')
    ax.plot(betas, lam1, '--', color=color, linewidth=1.5, label=f'λ₁ (n={n})')
ax.set_xlabel('Coupling β', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)
ax.set_title('Top Two Eigenvalues of Transfer Matrix', fontsize=13)
ax.legend(fontsize=9, ncol=2)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Spectral gap vs β
ax = axes[0, 1]
for n, color in zip(sizes, colors):
    _, _, gaps, _ = compute_spectral_data(n, betas)
    ax.plot(betas, gaps, '-', color=color, linewidth=2, label=f'n={n}')
ax.set_xlabel('Coupling β', fontsize=12)
ax.set_ylabel('Spectral Gap Δ = λ₀ - λ₁', fontsize=12)
ax.set_title('Spectral Gap (Mass Gap) vs Coupling', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Normalized gap vs β (monotonicity test)
ax = axes[1, 0]
for n, color in zip(sizes, colors):
    _, _, _, norm_gaps = compute_spectral_data(n, betas)
    ax.plot(betas, norm_gaps, '-', color=color, linewidth=2, label=f'n={n}')
ax.set_xlabel('Coupling β', fontsize=12)
ax.set_ylabel('Normalized Gap Δ/λ₀', fontsize=12)
ax.set_title('Normalized Gap (Monotonicity Conjecture)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1)

# Panel 4: Log of top eigenvalue (convexity test)
ax = axes[1, 1]
for n, color in zip(sizes, colors):
    lam0, _, _, _ = compute_spectral_data(n, betas)
    ax.plot(betas, np.log(lam0), '-', color=color, linewidth=2, label=f'n={n}')
ax.set_xlabel('Coupling β', fontsize=12)
ax.set_ylabel('log(λ₀)', fontsize=12)
ax.set_title('Log Top Eigenvalue (Convexity = Free Energy)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Reflection Positivity → Spectral Gap: The OS-to-Operator Bridge',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_gap_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: spectral_gap_visualization.png")
