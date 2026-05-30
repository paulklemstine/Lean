#!/usr/bin/env python3
"""
Visualization: Cramér-Rao / Optimization Duality

Shows the cross-domain connection between information theory and optimization:
the Fisher information matrix simultaneously controls estimation variance
(Cramér-Rao bound) and optimization convergence (natural gradient rate).

The duality product Var × κ = λ_max / λ_min² is a constant that captures
the fundamental tradeoff between estimation and optimization.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Cramér-Rao bound vs condition number
ax = axes[0]
lambda_min_vals = np.logspace(-1, 1, 50)
kappas = [1, 5, 20, 100]

for kappa in kappas:
    lambda_max = kappa * lambda_min_vals
    variance_bound = 1.0 / lambda_min_vals
    ax.loglog(lambda_min_vals, variance_bound, linewidth=2, label=f'κ = {kappa}')

ax.set_xlabel('Fisher Information λ_min', fontsize=12)
ax.set_ylabel('Cramér-Rao Variance Bound', fontsize=12)
ax.set_title('Estimation: More Fisher Info → Less Variance', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Duality product
ax = axes[1]
kappa_range = np.logspace(0, 3, 100)

for lambda_min in [0.1, 0.5, 1.0, 2.0]:
    variance = 1.0 / lambda_min
    duality = variance * kappa_range
    theoretical = kappa_range * lambda_min / lambda_min**2  # λ_max / λ_min²
    
    ax.loglog(kappa_range, duality, linewidth=2, label=f'λ_min = {lambda_min}')

ax.set_xlabel('Condition Number κ', fontsize=12)
ax.set_ylabel('Duality Product: Var × κ', fontsize=12)
ax.set_title('Cramér-Rao × Optimization Duality', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Convergence rate landscape
ax = axes[2]

# Create heatmap: x-axis = dimension d, y-axis = condition number κ
dims = np.arange(2, 51)
kappas_heat = np.logspace(0, 3, 50)
D, K = np.meshgrid(dims, kappas_heat)

# Natural gradient iterations for ε = 0.01: T_ng ∝ d
# Standard gradient iterations: T_gd ∝ κ
# Speedup = T_gd / T_ng ∝ κ / d
speedup = K / D

im = ax.pcolormesh(dims, kappas_heat, np.log10(speedup), 
                   cmap='RdYlGn', shading='auto', vmin=-1, vmax=3)
ax.set_yscale('log')
ax.set_xlabel('Dimension d', fontsize=12)
ax.set_ylabel('Condition Number κ', fontsize=12)
ax.set_title('log₁₀(Speedup): NG over GD', fontsize=13, fontweight='bold')

# Contour line where speedup = 1 (κ = d)
ax.contour(dims, kappas_heat, speedup, levels=[1], colors='black', linewidths=2)
ax.text(30, 20, 'NG = GD\n(κ = d)', fontsize=10, fontweight='bold',
       bbox=dict(facecolor='white', alpha=0.8))
ax.text(10, 500, 'NG wins\n(κ > d)', fontsize=10, color='darkgreen',
       bbox=dict(facecolor='white', alpha=0.8))
ax.text(40, 3, 'GD wins\n(κ < d)', fontsize=10, color='darkred',
       bbox=dict(facecolor='white', alpha=0.8))

plt.colorbar(im, ax=ax, label='log₁₀(Speedup)')

plt.tight_layout()
plt.savefig('cramer_rao_duality.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved cramer_rao_duality.png")
