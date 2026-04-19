"""
Demo 03: Bregman Divergence from exp and Itakura-Saito Divergence
================================================================
EML decomposes into two canonical divergences:
- D_exp(x₁, x₂) = exp(x₁) - exp(x₂) - exp(x₂)·(x₁-x₂) ≥ 0 (Bregman from exp)
- D_IS(y₁, y₂) = log(y₂/y₁) + y₁/y₂ - 1 ≥ 0 (Itakura-Saito)
Both verified non-negative in Lean.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Bregman divergence from exp
ax = axes[0]
x2_fixed = 1.0
x1 = np.linspace(-2, 4, 500)
D_exp = np.exp(x1) - np.exp(x2_fixed) - np.exp(x2_fixed) * (x1 - x2_fixed)
tangent = np.exp(x2_fixed) + np.exp(x2_fixed) * (x1 - x2_fixed)

ax.plot(x1, np.exp(x1), 'b-', linewidth=2, label=r'$e^{x_1}$')
ax.plot(x1, tangent, 'r--', linewidth=1.5, label=f'Tangent at x₂ = {x2_fixed}')
ax.fill_between(x1, tangent, np.exp(x1), alpha=0.15, color='green',
                label=r'$D_{\exp}(x_1, x_2) \geq 0$')
ax.plot(x2_fixed, np.exp(x2_fixed), 'ko', markersize=8)
ax.set_xlim(-2, 4)
ax.set_ylim(-2, 20)
ax.set_xlabel(r'$x_1$', fontsize=12)
ax.set_title(r'Bregman Divergence $D_{\exp}$', fontsize=14)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: Itakura-Saito divergence
ax = axes[1]
y2_fixed = 1.0
y1 = np.linspace(0.1, 5, 500)
D_IS = np.log(y2_fixed / y1) + y1 / y2_fixed - 1

ax.plot(y1, D_IS, 'purple', linewidth=2, label=r'$D_{IS}(y_1, y_2) = \ln(y_2/y_1) + y_1/y_2 - 1$')
ax.axhline(y=0, color='k', linewidth=0.5)
ax.fill_between(y1, 0, D_IS, alpha=0.15, color='purple')
ax.plot(y2_fixed, 0, 'ro', markersize=8, label=f'Min at y₁ = y₂ = {y2_fixed}')
ax.set_xlabel(r'$y_1$', fontsize=12)
ax.set_title(f'Itakura-Saito (y₂ = {y2_fixed})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: EML as sum of divergences
ax = axes[2]
# Heat map of combined divergence
x_grid = np.linspace(-2, 3, 100)
y_grid = np.linspace(0.1, 5, 100)
X, Y = np.meshgrid(x_grid, y_grid)

# EML(x, y) relative to the reference point (0, 1)
x_ref, y_ref = 0, 1
D_bregman = np.exp(X) - np.exp(x_ref) - np.exp(x_ref) * (X - x_ref)
D_itakura = np.log(y_ref / Y) + Y / y_ref - 1
D_total = D_bregman + D_itakura

c = ax.contourf(X, Y, D_total, levels=20, cmap='viridis')
plt.colorbar(c, ax=ax, label='Combined Divergence')
ax.plot(x_ref, y_ref, 'r*', markersize=15, label=f'Reference ({x_ref}, {y_ref})')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.set_title('Bregman + Itakura-Saito', fontsize=14)
ax.legend(fontsize=10)

plt.tight_layout()
plt.savefig('EML/EMLv18Research/demos/bregman_itakura_saito.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 03 saved: bregman_itakura_saito.png")
