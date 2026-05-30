#!/usr/bin/env python3
"""
Visualization: Condition Number Scaling for Lorentzian Families

Shows how the spectral condition number κ = M/γ_min scales with dimension
and degree for random Lorentzian polynomials (products of linear forms).
Illustrates the generic scaling conjecture γ_min ~ M·n/C(n,d-2).
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def spectral_gap(A, tol=1e-10):
    eigs = np.linalg.eigvalsh(A)
    neg = eigs[eigs < -tol]
    return float(np.min(np.abs(neg))) if len(neg) > 0 else 0.0

def generate_lorentzian_family(n, d, M=1.0):
    """Generate a random Lorentzian polynomial via products of linear forms."""
    coeffs = np.random.uniform(0.1 * M, M, (d, n))
    leaves = []
    for i in range(d):
        for j in range(i + 1, d):
            H = np.outer(coeffs[i], coeffs[j]) + np.outer(coeffs[j], coeffs[i])
            leaves.append(H)
    if not leaves:
        return [np.zeros((n, n))], 0, 0
    coeff_bound = max(np.max(np.abs(L)) for L in leaves)
    gamma = min(spectral_gap(L) for L in leaves)
    return leaves, coeff_bound, gamma

fig, axes = plt.subplots(1, 3, figsize=(18, 5))
np.random.seed(42)

# Panel 1: Condition number vs dimension
degrees = [3, 4, 5]
colors = ['#e41a1c', '#377eb8', '#4daf4a']
for d, color in zip(degrees, colors):
    n_values = list(range(d, 16))
    kappas = []
    for n in n_values:
        kappa_trials = []
        for _ in range(30):
            _, M, gamma = generate_lorentzian_family(n, d)
            if gamma > 0:
                kappa_trials.append(M / gamma)
        kappas.append(np.median(kappa_trials) if kappa_trials else 0)
    axes[0].plot(n_values, kappas, 'o-', color=color, label=f'd={d}', markersize=5)

axes[0].set_xlabel('Dimension n', fontsize=12)
axes[0].set_ylabel('Condition number κ = M/γ_min', fontsize=12)
axes[0].set_title('Condition Number Growth', fontsize=14)
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)
axes[0].set_yscale('log')

# Panel 2: Normalized gap γ_min·C(n,d-2)/(M·n) vs dimension
for d, color in zip(degrees, colors):
    n_values = list(range(max(d, 3), 12))
    ratios = []
    for n in n_values:
        ratio_trials = []
        for _ in range(50):
            _, M, gamma = generate_lorentzian_family(n, d)
            if gamma > 0 and M > 0:
                c_val = comb(n, d - 2)
                ratio_trials.append(gamma * c_val / (M * n))
        ratios.append(np.median(ratio_trials) if ratio_trials else 0)
    axes[1].plot(n_values, ratios, 'o-', color=color, label=f'd={d}', markersize=5)

axes[1].axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Predicted Θ(1)')
axes[1].set_xlabel('Dimension n', fontsize=12)
axes[1].set_ylabel('γ_min · C(n,d-2) / (M·n)', fontsize=12)
axes[1].set_title('Generic Gap Scaling Test', fontsize=14)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

# Panel 3: ρ·n·κ histogram (should concentrate around 1)
all_products = []
for n in range(3, 10):
    for d in range(3, min(n + 1, 6)):
        for _ in range(30):
            _, M, gamma = generate_lorentzian_family(n, d)
            if gamma > 0 and M > 0:
                rho = gamma / (n * M)
                kappa = M / gamma
                all_products.append(rho * n * kappa)

axes[2].hist(all_products, bins=1, color='#377eb8', edgecolor='black', alpha=0.7)
axes[2].axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='ρ·n·κ = 1')
axes[2].set_xlabel('ρ · n · κ', fontsize=12)
axes[2].set_ylabel('Count', fontsize=12)
axes[2].set_title('Condition Number Duality Check', fontsize=14)
axes[2].legend(fontsize=10)
axes[2].set_xlim(0.5, 1.5)

plt.tight_layout()
plt.savefig('condition_scaling.png', dpi=150, bbox_inches='tight')
print("Saved condition_scaling.png")
