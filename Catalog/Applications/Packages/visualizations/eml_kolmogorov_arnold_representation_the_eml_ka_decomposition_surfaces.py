"""
Visualization: EML-KA Decomposition Surfaces

Shows how multiplication, geometric mean, and division are decomposed
via exp-log (EML) inner functions in Kolmogorov-Arnold form.
Each surface plot shows the target function and its EML-KA reconstruction.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

fig, axes = plt.subplots(2, 3, figsize=(16, 10),
                         subplot_kw={'projection': '3d'})

x = np.linspace(0.1, 5.0, 50)
y = np.linspace(0.1, 5.0, 50)
X, Y = np.meshgrid(x, y)

# --- Row 1: Target functions ---
# Multiplication
Z_mul = X * Y
axes[0, 0].plot_surface(X, Y, Z_mul, cmap='viridis', alpha=0.8)
axes[0, 0].set_title('Target: x · y', fontsize=12)
axes[0, 0].set_xlabel('x'); axes[0, 0].set_ylabel('y')

# Geometric mean
Z_geom = np.sqrt(X * Y)
axes[0, 1].plot_surface(X, Y, Z_geom, cmap='plasma', alpha=0.8)
axes[0, 1].set_title('Target: √(xy)', fontsize=12)
axes[0, 1].set_xlabel('x'); axes[0, 1].set_ylabel('y')

# Division
Z_div = X / Y
axes[0, 2].plot_surface(X, Y, Z_div, cmap='coolwarm', alpha=0.8)
axes[0, 2].set_title('Target: x / y', fontsize=12)
axes[0, 2].set_xlabel('x'); axes[0, 2].set_ylabel('y')

# --- Row 2: EML-KA reconstructions ---
# Multiplication via exp(log x + log y)
Z_mul_ka = np.exp(np.log(X) + np.log(Y))
axes[1, 0].plot_surface(X, Y, Z_mul_ka, cmap='viridis', alpha=0.8)
axes[1, 0].set_title('EML-KA: exp(log x + log y)', fontsize=12)
axes[1, 0].set_xlabel('x'); axes[1, 0].set_ylabel('y')

# Geometric mean via exp(½ log x + ½ log y)
Z_geom_ka = np.exp(0.5 * np.log(X) + 0.5 * np.log(Y))
axes[1, 1].plot_surface(X, Y, Z_geom_ka, cmap='plasma', alpha=0.8)
axes[1, 1].set_title('EML-KA: exp(½log x + ½log y)', fontsize=12)
axes[1, 1].set_xlabel('x'); axes[1, 1].set_ylabel('y')

# Division via exp(log x - log y)
Z_div_ka = np.exp(np.log(X) - np.log(Y))
axes[1, 2].plot_surface(X, Y, Z_div_ka, cmap='coolwarm', alpha=0.8)
axes[1, 2].set_title('EML-KA: exp(log x − log y)', fontsize=12)
axes[1, 2].set_xlabel('x'); axes[1, 2].set_ylabel('y')

plt.suptitle('EML-Kolmogorov-Arnold Decompositions:\nTarget Functions vs. EML-KA Reconstructions',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_ka_surfaces.png', dpi=150, bbox_inches='tight')
print("Saved viz_ka_surfaces.png")
