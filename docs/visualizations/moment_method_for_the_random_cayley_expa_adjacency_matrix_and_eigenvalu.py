#!/usr/bin/env python3
"""
Visualization 2: Adjacency Matrix Heatmap and Spectral Structure

Visualizes the adjacency matrix of a Cayley graph Cay(S_n, {σ,σ⁻¹,τ,τ⁻¹})
and its eigenvalue distribution. The left panel shows the sparsity pattern
of the adjacency matrix; the right panel shows the eigenvalue histogram
compared to the Kesten-McKay distribution (the spectral measure for the
infinite 4-regular tree / free group F_2).
"""

import itertools
import numpy as np
from math import factorial, pi, sqrt
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Self-contained utilities ───

def compose(p, q):
    return [p[q[i]] for i in range(len(p))]

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return inv

def cayley_adj_matrix(sigma, tau):
    n = len(sigma)
    perms = list(itertools.permutations(range(n)))
    perm_to_idx = {p: i for i, p in enumerate(perms)}
    N = len(perms)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    A = np.zeros((N, N), dtype=float)
    for g_idx, g in enumerate(perms):
        for s in gens:
            h = tuple(compose(s, list(g)))
            h_idx = perm_to_idx[h]
            A[h_idx][g_idx] += 1
    return A

def kesten_mckay_density(x, d=4):
    """Kesten-McKay density for d-regular graphs.
    
    This is the spectral measure of the infinite d-regular tree,
    which is the Cayley graph of the free group on d/2 generators.
    """
    if abs(x) >= 2 * sqrt(d - 1) / d:
        return 0.0
    return d * sqrt(4 * (d - 1) - (d * x) ** 2) / (2 * pi * (d ** 2 - (d * x) ** 2))

# ─── Build adjacency matrix for S_4 ───

n = 4
sigma = [1, 2, 3, 0]  # (0 1 2 3) cycle
tau = [1, 0, 2, 3]    # (0 1) transposition

A = cayley_adj_matrix(sigma, tau)
A_norm = A / 4.0  # Normalized

# Eigenvalues
eigenvalues = np.linalg.eigvalsh(A_norm)

# ─── Plotting ───

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle(f'Cayley Graph Structure: Cay(S_{n}, {{σ,σ⁻¹,τ,τ⁻¹}})\n'
             f'σ = (0 1 2 3), τ = (0 1)', fontsize=13, fontweight='bold')

# Left: Adjacency matrix heatmap
im = ax1.imshow(A, cmap='YlOrRd', interpolation='nearest', aspect='auto')
ax1.set_title(f'Adjacency Matrix ({factorial(n)}×{factorial(n)})')
ax1.set_xlabel('Column index (group element)')
ax1.set_ylabel('Row index (group element)')
plt.colorbar(im, ax=ax1, label='# of generators connecting g→h')

# Right: Eigenvalue histogram vs Kesten-McKay
ax2.hist(eigenvalues, bins=30, density=True, alpha=0.7, 
         color='#2196F3', edgecolor='black', label='Empirical eigenvalues')

# Kesten-McKay overlay
x_vals = np.linspace(-1, 1, 500)
km_vals = [kesten_mckay_density(x) for x in x_vals]
ax2.plot(x_vals, km_vals, 'r-', linewidth=2.5, 
         label='Kesten-McKay (F₂ limit)')

ax2.set_title('Eigenvalue Distribution vs Free-Group Limit')
ax2.set_xlabel('Eigenvalue (normalized)')
ax2.set_ylabel('Density')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Annotate spectral gap
sorted_eigs = np.sort(eigenvalues)[::-1]
lambda2 = sorted_eigs[1]
ax2.axvline(x=lambda2, color='green', linestyle='--', alpha=0.7,
            label=f'λ₂ = {lambda2:.4f}')
ax2.axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
ax2.annotate(f'λ₂ = {lambda2:.4f}\ngap = {1-lambda2:.4f}',
             xy=(lambda2, 0.5), fontsize=10,
             bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

plt.tight_layout()
plt.savefig('visualize_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: visualize_heatmap.png")
