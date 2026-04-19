"""
Demo 07: Tropical EML — Piecewise Linear Limits
===============================================
In the tropical limit (temperature → 0), EML reduces to:
  eml_trop(x, y) = max(x, 0) + max(-log y, 0) = ReLU(x) + ReLU(-log y)
This connects EML to tropical geometry and neural network activations.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: EML vs Tropical EML for various temperatures
ax = axes[0]
x_range = np.linspace(-3, 3, 300)
y_fixed = 0.5  # so -log(0.5) ≈ 0.693

for T in [0.1, 0.3, 1.0, 3.0]:
    eml_T = T * np.exp(x_range / T) - T * np.log(y_fixed)  # Scaled EML
    ax.plot(x_range, eml_T / T, linewidth=1.5, label=f'T = {T}')

# Tropical limit
tropical = np.maximum(x_range, 0) + max(-np.log(y_fixed), 0)
ax.plot(x_range, tropical, 'k--', linewidth=2.5, label='Tropical (T→0)')

ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Scaled EML', fontsize=12)
ax.set_title(f'EML Tropical Limit (y = {y_fixed})', fontsize=14)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: Tropical EML heat map
ax = axes[1]
x_grid = np.linspace(-3, 3, 200)
y_grid = np.linspace(0.01, 5, 200)
X, Y = np.meshgrid(x_grid, y_grid)
Z_trop = np.maximum(X, 0) + np.maximum(-np.log(Y), 0)

c = ax.contourf(X, Y, Z_trop, levels=20, cmap='hot')
plt.colorbar(c, ax=ax, label='Tropical EML')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.set_title('Tropical EML = ReLU(x) + ReLU(-log y)', fontsize=14)

# Plot 3: EML vs Tropical comparison
ax = axes[2]
Z_eml = np.exp(X) - np.log(Y)
Z_diff = Z_eml - Z_trop

c = ax.contourf(X, Y, Z_diff, levels=20, cmap='coolwarm')
plt.colorbar(c, ax=ax, label='EML - Tropical')
ax.contour(X, Y, Z_diff, levels=[0], colors='black', linewidths=2)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.set_title('Smooth EML minus Tropical EML', fontsize=14)

plt.tight_layout()
plt.savefig('EML/EMLv18Research/demos/tropical_eml.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 07 saved: tropical_eml.png")
