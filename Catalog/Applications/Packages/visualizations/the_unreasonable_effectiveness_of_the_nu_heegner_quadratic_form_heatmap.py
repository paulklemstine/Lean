"""
Visualization 2: The Heegner Quadratic Form x² + xy + 41y²
==============================================================
Heatmap of the positive definite quadratic form of discriminant -163.
Shows the lattice structure and level curves.
"""

import matplotlib.pyplot as plt
import numpy as np


def heegner_form(x, y):
    return x**2 + x * y + 41 * y**2


R = 5
x = np.linspace(-R, R, 500)
y = np.linspace(-R, R, 500)
X, Y = np.meshgrid(x, y)
Z = X**2 + X * Y + 41 * Y**2

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Heatmap
ax1 = axes[0]
im = ax1.pcolormesh(X, Y, np.log1p(Z), cmap='inferno', shading='auto')
ax1.contour(X, Y, Z, levels=[1, 5, 10, 20, 41, 43, 50, 100, 200, 500], colors='white', linewidths=0.5, alpha=0.6)
cbar = plt.colorbar(im, ax=ax1, label='log(1 + Q(x,y))')

# Mark lattice points with small form values
for ix in range(-R, R + 1):
    for iy in range(-R, R + 1):
        val = heegner_form(ix, iy)
        if val <= 50 and (ix != 0 or iy != 0):
            ax1.plot(ix, iy, 'wo', markersize=4, markeredgecolor='cyan', markeredgewidth=0.5)
            ax1.annotate(str(val), (ix, iy), textcoords="offset points",
                        xytext=(3, 3), fontsize=6, color='cyan')

ax1.plot(0, 0, 'w+', markersize=10, markeredgewidth=2)
ax1.set_xlabel('x', fontsize=13)
ax1.set_ylabel('y', fontsize=13)
ax1.set_title('Heegner Quadratic Form Q(x,y) = x² + xy + 41y²\n'
              'Discriminant = -163 (Class Number 1)',
              fontsize=13, fontweight='bold')
ax1.set_aspect('equal')

# Right: Level curves with the completing-the-square transformation
ax2 = axes[1]
# Show the rotated coordinate system: u = 2x+y, v = y
# Then 4Q = u² + 163v²
u = np.linspace(-20, 20, 500)
v = np.linspace(-5, 5, 500)
U, V = np.meshgrid(u, v)
Z2 = U**2 + 163 * V**2  # = 4Q in transformed coords

levels = [4, 20, 40, 80, 164, 172, 200, 400, 800]
cs = ax2.contour(U, V, Z2, levels=levels, cmap='viridis', linewidths=1.5)
ax2.clabel(cs, inline=True, fontsize=8, fmt='4Q=%g')

ax2.set_xlabel('u = 2x + y', fontsize=13)
ax2.set_ylabel('v = y', fontsize=13)
ax2.set_title('Completed Square: 4Q = (2x+y)² + 163y²\n'
              'Ellipses with axis ratio √163 ≈ 12.8',
              fontsize=13, fontweight='bold')
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_quadratic_form.png', dpi=150, bbox_inches='tight')
print("Saved viz_quadratic_form.png")
