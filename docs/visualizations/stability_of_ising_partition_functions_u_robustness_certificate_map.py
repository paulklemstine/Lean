#!/usr/bin/env python3
"""
Visualization 2: Robustness Certificate Map

Shows the certified safe perturbation region as a function of system size n
and spectral gap ε, illustrating the theorem:
    δ_safe = ε / (2n²)

Also visualizes the relationship between the Lorentzian spectral gap
and the thermodynamic stability region.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('Robustness Certificates for Ising Models with Lorentzian Structure',
             fontsize=15, fontweight='bold', y=1.02)

# Panel 1: Safe perturbation radius as function of n and epsilon
ax = axes[0]
n_range = np.arange(2, 20)
eps_values = [0.1, 0.3, 0.5, 1.0, 2.0]
colors = plt.cm.plasma(np.linspace(0.15, 0.85, len(eps_values)))

for eps, col in zip(eps_values, colors):
    safe_delta = eps / (2 * n_range.astype(float)**2)
    ax.semilogy(n_range, safe_delta, 'o-', color=col, markersize=4,
                label=f'ε = {eps}')

ax.set_xlabel('System size n', fontsize=12)
ax.set_ylabel('Safe perturbation δ_safe', fontsize=12)
ax.set_title('Certified Perturbation Tolerance\nδ_safe = ε / (2n²)', fontsize=13)
ax.legend(fontsize=9, title='Spectral gap')
ax.grid(True, alpha=0.3, which='both')
ax.set_xlim(1.5, 20)

# Panel 2: Heat map of free energy bound
ax = axes[1]
n_grid = np.arange(2, 16)
beta_grid = np.linspace(0.1, 3.0, 30)
N, B = np.meshgrid(n_grid, beta_grid)

# For a fixed spectral gap, compute the free energy change at the safe boundary
eps_fixed = 0.5
safe_delta_grid = eps_fixed / (2 * N.astype(float)**2)
free_energy_bound = B * N.astype(float)**2 * safe_delta_grid  # = β · ε/2

im = ax.pcolormesh(n_grid, beta_grid, free_energy_bound,
                   cmap='YlOrRd', shading='auto')
plt.colorbar(im, ax=ax, label='|Δ log Z| bound')
ax.set_xlabel('System size n', fontsize=12)
ax.set_ylabel('Inverse temperature β', fontsize=12)
ax.set_title(f'Free Energy Stability at Safe Boundary\n(ε = {eps_fixed})',
             fontsize=13)

# Panel 3: Comparison of n² vs n scaling
ax = axes[2]
n_range = np.arange(2, 25)

# n² bound (what we prove)
safe_n2 = 1.0 / (2 * n_range.astype(float)**2)
# n bound (conjectured sharp, from LorentzianSharpStability)
safe_n1 = 1.0 / (2 * n_range.astype(float))
# n^3 bound (naive)
safe_n3 = 1.0 / (2 * n_range.astype(float)**3)

ax.semilogy(n_range, safe_n1, 's-', color='#4CAF50', markersize=5,
            label='1/(2n) — sharp (catalog)', linewidth=2)
ax.semilogy(n_range, safe_n2, 'o-', color='#2196F3', markersize=5,
            label='1/(2n²) — proved here', linewidth=2)
ax.semilogy(n_range, safe_n3, '^-', color='#F44336', markersize=5,
            label='1/(2n³) — naive', linewidth=1.5, alpha=0.7)

ax.fill_between(n_range, safe_n2, safe_n1, alpha=0.15, color='#4CAF50',
                label='Improvement gap')
ax.set_xlabel('System size n', fontsize=12)
ax.set_ylabel('Safe δ / ε', fontsize=12)
ax.set_title('Scaling Comparison of\nPerturbation Tolerances', fontsize=13)
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3, which='both')

plt.tight_layout()
plt.savefig('robustness_certificate.png', dpi=150, bbox_inches='tight')
print("Saved: robustness_certificate.png")
