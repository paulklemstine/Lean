"""
Visualization 2: The Möbius Key Identity Heatmap
==================================================

Visualizes the key identity of the Poincaré disk:
  |1 - conj(a)·z|² - |z - a|² = (1 - |a|²)(1 - |z|²)

Shows how the "room left in the disk" after a Möbius transform
depends on both the center a and the input z.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def normSq(z):
    return np.real(z)**2 + np.imag(z)**2


# Create a grid of points in the disk
n = 400
x = np.linspace(-0.99, 0.99, n)
y = np.linspace(-0.99, 0.99, n)
X, Y = np.meshgrid(x, y)
Z = X + 1j * Y

# Mask: only inside the disk
mask = X**2 + Y**2 < 1

# Fixed center a = 0.5 + 0.3i
a = 0.5 + 0.3j

# Compute the Möbius transform
denom = 1 - np.conj(a) * Z
T = (Z - a) / denom

# Compute normSq of the transform
normSq_T = normSq(T)

# Compute the complement: 1 - |T_a(z)|²
complement = np.where(mask, 1 - normSq_T, np.nan)

# Compute the formula: (1 - |a|²)(1 - |z|²) / |1 - conj(a)z|²
formula = np.where(mask, 
    (1 - normSq(a)) * (1 - normSq(Z)) / normSq(denom),
    np.nan)

# Compute the error
error = np.where(mask, np.abs(complement - formula), np.nan)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: 1 - |T_a(z)|² 
im0 = axes[0].pcolormesh(X, Y, complement, cmap='viridis', shading='auto')
axes[0].set_title('$1 - |T_a(z)|^2$\n(room left in disk)', fontsize=13)
axes[0].set_aspect('equal')
circle0 = plt.Circle((0,0), 1, fill=False, color='white', linewidth=2)
axes[0].add_patch(circle0)
axes[0].plot(a.real, a.imag, 'r*', markersize=15, label=f'a = {a}')
axes[0].legend(fontsize=10)
plt.colorbar(im0, ax=axes[0], shrink=0.8)

# Plot 2: The formula value
im1 = axes[1].pcolormesh(X, Y, formula, cmap='viridis', shading='auto')
axes[1].set_title('$(1-|a|^2)(1-|z|^2) / |1-\\bar{a}z|^2$\n(Key Identity RHS)', fontsize=13)
axes[1].set_aspect('equal')
circle1 = plt.Circle((0,0), 1, fill=False, color='white', linewidth=2)
axes[1].add_patch(circle1)
axes[1].plot(a.real, a.imag, 'r*', markersize=15)
plt.colorbar(im1, ax=axes[1], shrink=0.8)

# Plot 3: Error (should be ~0 everywhere)
im2 = axes[2].pcolormesh(X, Y, error, cmap='hot', shading='auto',
                          vmin=0, vmax=1e-14)
axes[2].set_title('|Error| (machine precision)\n(verifying the identity)', fontsize=13)
axes[2].set_aspect('equal')
circle2 = plt.Circle((0,0), 1, fill=False, color='white', linewidth=2)
axes[2].add_patch(circle2)
plt.colorbar(im2, ax=axes[2], shrink=0.8, label='Error')

for ax in axes:
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')

plt.suptitle('The Möbius Key Identity: Engine of Hyperbolic Geometry', 
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_key_identity.png', dpi=150, bbox_inches='tight')
print("Saved key identity visualization")
