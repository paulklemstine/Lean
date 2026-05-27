#!/usr/bin/env python3
"""
Visualization 2: Spectral Bridge — Partition Function vs Eigenvalue Products

Visualizes the uniform specialization theorem:
    Z_K(t,...,t) = det(I + tK) = ∏(1 + tλ_i)

This bridges the DPP partition function (statistical physics) with
spectral theory (eigenvalue statistics). The plot shows how the
partition function evaluated at uniform values recovers the spectral
determinant, and how the homogeneous components correspond to
elementary symmetric polynomials of eigenvalues.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

np.random.seed(42)

def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    A = np.random.randn(rank, n)
    return A.T @ A

def principal_minor(K, S):
    S = list(S)
    if len(S) == 0:
        return 1.0
    return np.linalg.det(K[np.ix_(S, S)])

def partition_function_poly(K, t):
    """Compute Z_K(t,...,t) by summing over all subsets."""
    n = K.shape[0]
    total = 0.0
    for d in range(n + 1):
        for S in combinations(range(n), d):
            total += principal_minor(K, S) * t**d
    return total

def spectral_det(eigenvalues, t):
    """Compute ∏(1 + t*λ_i)."""
    return np.prod(1 + t * eigenvalues)

def elem_sym(eigenvalues, d):
    """Compute e_d(λ) = sum of products of d eigenvalues."""
    n = len(eigenvalues)
    if d == 0:
        return 1.0
    if d > n:
        return 0.0
    total = 0.0
    for S in combinations(range(n), d):
        total += np.prod(eigenvalues[list(S)])
    return total

# Setup
n = 5
K = random_psd_matrix(n)
eigenvalues = np.linalg.eigvalsh(K)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Z_K(t,...,t) vs det(I + tK)
ax = axes[0]
t_vals = np.linspace(-0.3, 2.0, 200)
z_poly = [partition_function_poly(K, t) for t in t_vals]
z_spec = [spectral_det(eigenvalues, t) for t in t_vals]

ax.plot(t_vals, z_poly, 'b-', linewidth=2.5, label='$Z_K(t,\\ldots,t)$ (polynomial)')
ax.plot(t_vals, z_spec, 'r--', linewidth=2, label='$\\det(I + tK)$ (spectral)')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('$t$', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Uniform Specialization\n$Z_K(t,\\ldots,t) = \\det(I + tK)$',
             fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Homogeneous components vs elementary symmetric polynomials
ax = axes[1]
degrees = range(n + 1)

# Sum of principal minors of size d
hom_coeffs = []
for d in degrees:
    total = 0.0
    for S in combinations(range(n), d):
        total += principal_minor(K, S)
    hom_coeffs.append(total)

# Elementary symmetric polynomials
esym_vals = [elem_sym(eigenvalues, d) for d in degrees]

x = np.arange(len(degrees))
width = 0.35
bars1 = ax.bar(x - width/2, hom_coeffs, width, label='$\\sum_{|S|=d} \\det K_S$',
               color='steelblue', alpha=0.8)
bars2 = ax.bar(x + width/2, esym_vals, width, label='$e_d(\\lambda_1,\\ldots,\\lambda_n)$',
               color='coral', alpha=0.8)

ax.set_xlabel('Degree $d$', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Homogeneous Components =\nElementary Symmetric Polynomials',
             fontsize=12, fontweight='bold')
ax.set_xticks(x)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

# Plot 3: Eigenvalue spectrum and partition function factors
ax = axes[2]
sorted_evals = np.sort(eigenvalues)[::-1]
colors = plt.cm.viridis(np.linspace(0.2, 0.8, n))

t_dense = np.linspace(-0.1, 1.5, 300)

# Plot individual factors (1 + t*λ_i)
for k, (lam, color) in enumerate(zip(sorted_evals, colors)):
    factor = 1 + t_dense * lam
    ax.plot(t_dense, factor, '--', color=color, alpha=0.6, linewidth=1.2,
            label=f'$1 + t\\lambda_{k+1}$ ($\\lambda_{k+1}={lam:.2f}$)')

# Product
product = np.array([spectral_det(eigenvalues, t) for t in t_dense])
ax.plot(t_dense, product, 'k-', linewidth=2.5, label='$\\prod_i(1+t\\lambda_i)$')

ax.set_xlabel('$t$', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Spectral Factorization\n$\\det(I+tK) = \\prod_i(1+t\\lambda_i)$',
             fontsize=12, fontweight='bold')
ax.legend(fontsize=8, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_ylim(-5, max(product) * 1.1)

fig.suptitle(f'The Spectral Bridge: DPP Partition Function ↔ Eigenvalue Statistics (n={n})',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_spectral_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_bridge.png")
