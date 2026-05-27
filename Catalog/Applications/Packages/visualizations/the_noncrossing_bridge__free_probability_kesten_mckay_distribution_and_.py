#!/usr/bin/env python3
"""
Visualization 3: Kesten-McKay Distribution and Noncrossing Partitions

Visualizes the Kesten-McKay spectral density for various degrees d,
showing how the distribution shape is determined by the moment sequence
μ_{2k} = C_k · d · (d-1)^{k-1}.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, sqrt, pi

def catalan(n):
    return comb(2 * n, n) // (n + 1)

def kesten_mckay_density(x, d):
    """The Kesten-McKay spectral density for d-regular graphs.
    
    ρ_d(x) = d·√(4(d-1) - x²) / (2π(d² - x²))
    supported on [-2√(d-1), 2√(d-1)].
    """
    radius = 2 * sqrt(d - 1)
    if abs(x) >= radius:
        return 0.0
    numerator = d * sqrt(4 * (d - 1) - x**2)
    denominator = 2 * pi * (d**2 - x**2)
    if abs(denominator) < 1e-15:
        return 0.0
    return numerator / denominator

def empirical_spectral_density(n, num_samples=500, bins=50):
    """Compute empirical spectral density for Cay(S_n, {σ,σ⁻¹,τ,τ⁻¹})."""
    all_eigs = []
    for _ in range(num_samples):
        sigma = np.random.permutation(n)
        tau = np.random.permutation(n)
        A = np.zeros((n, n))
        for i in range(n):
            A[i, sigma[i]] += 1
            A[sigma[i], i] += 1
            A[i, tau[i]] += 1
            A[tau[i], i] += 1
        eigenvalues = np.linalg.eigvalsh(A)
        all_eigs.extend(eigenvalues)
    return np.array(all_eigs)

np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: KM density for various d
x = np.linspace(-6, 6, 1000)
for d in [3, 4, 5, 8, 12]:
    y = np.array([kesten_mckay_density(xi, d) for xi in x])
    axes[0, 0].plot(x, y, linewidth=2, label=f'd={d}')

axes[0, 0].set_xlabel('x', fontsize=13)
axes[0, 0].set_ylabel(r'$\rho_d(x)$', fontsize=13)
axes[0, 0].set_title('Kesten-McKay Spectral Density', fontsize=14)
axes[0, 0].legend(fontsize=11)
axes[0, 0].grid(True, alpha=0.3)

# Panel 2: Empirical vs theoretical for d=4, n=20
eigs = empirical_spectral_density(20, num_samples=300)
axes[0, 1].hist(eigs, bins=60, density=True, alpha=0.5, color='steelblue',
               label='Empirical (n=20)')
x_km = np.linspace(-2*sqrt(3) - 0.5, 2*sqrt(3) + 0.5, 500)
y_km = np.array([kesten_mckay_density(xi, 4) for xi in x_km])
axes[0, 1].plot(x_km, y_km, 'r-', linewidth=2.5, label='KM₄ theory')
axes[0, 1].set_xlabel('Eigenvalue', fontsize=13)
axes[0, 1].set_ylabel('Density', fontsize=13)
axes[0, 1].set_title('Empirical Spectrum vs KM₄ (n=20)', fontsize=14)
axes[0, 1].legend(fontsize=11)
axes[0, 1].grid(True, alpha=0.3)

# Panel 3: Catalan numbers with interpretations
ks = list(range(10))
catalans = [catalan(k) for k in ks]
bars = axes[1, 0].bar(ks, catalans, color='coral', alpha=0.8, edgecolor='black')
for i, (k, c) in enumerate(zip(ks, catalans)):
    axes[1, 0].text(k, c + max(catalans)*0.02, str(c), ha='center', fontsize=9, fontweight='bold')

axes[1, 0].set_xlabel('k', fontsize=13)
axes[1, 0].set_ylabel(r'$C_k$', fontsize=13)
axes[1, 0].set_title('Catalan Numbers: |NC₂(2k)| = C_k', fontsize=14)
axes[1, 0].grid(True, alpha=0.3, axis='y')

# Panel 4: Moment comparison across n values
ns_test = [8, 12, 16, 20]
km_moments = {k: catalan(k) * 4 * 3**(k-1) if k > 0 else 1.0 for k in range(5)}
moment_orders = [1, 2, 3, 4]
bar_width = 0.15

for idx, n in enumerate(ns_test):
    emp_moments = []
    for _ in range(100):
        sigma = np.random.permutation(n)
        tau = np.random.permutation(n)
        A = np.zeros((n, n))
        for i in range(n):
            A[i, sigma[i]] += 1
            A[sigma[i], i] += 1
            A[i, tau[i]] += 1
            A[tau[i], i] += 1
        evals = np.linalg.eigvalsh(A)
        emp_moments.append([np.mean(evals ** (2*k)) for k in moment_orders])
    
    means = np.mean(emp_moments, axis=0)
    x_pos = np.array(moment_orders) + idx * bar_width - 1.5 * bar_width
    axes[1, 1].bar(x_pos, means, bar_width, label=f'n={n}', alpha=0.8)

# Add theoretical values
for k in moment_orders:
    axes[1, 1].axhline(y=km_moments[k], xmin=(k-0.5)/5, xmax=(k+0.5)/5,
                       color='red', linestyle='--', linewidth=1.5)

axes[1, 1].set_xlabel('Moment order k', fontsize=13)
axes[1, 1].set_ylabel(r'$\mu_{2k}$', fontsize=13)
axes[1, 1].set_title('Moment Convergence (d=4, dashed = KM₄)', fontsize=14)
axes[1, 1].legend(fontsize=10)
axes[1, 1].set_yscale('log')
axes[1, 1].grid(True, alpha=0.3)

plt.suptitle('The Kesten-McKay Distribution: Noncrossing Partitions in Action',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_kesten_mckay.png', dpi=150, bbox_inches='tight')
print("Saved viz_kesten_mckay.png")
