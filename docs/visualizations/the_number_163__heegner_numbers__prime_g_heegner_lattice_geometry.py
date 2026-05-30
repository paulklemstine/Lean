"""
Visualization 2: The Heegner Lattice for d = 163

Plots the level curves of the quadratic form Q(x,y) = x² + xy + 41y²,
showing the elliptical contours that define the lattice geometry.
The lattice points and their form values are overlaid.
"""

import matplotlib.pyplot as plt
import numpy as np


def heegner_form(x, y):
    """Q(x,y) = x² + xy + 41y²"""
    return x**2 + x * y + 41 * y**2


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: Contour plot of the quadratic form
x = np.linspace(-8, 8, 400)
y = np.linspace(-2, 2, 400)
X, Y = np.meshgrid(x, y)
Z = X**2 + X * Y + 41 * Y**2

levels = [1, 5, 10, 20, 41, 43, 50, 80, 100, 150, 200]
cs = ax1.contour(X, Y, Z, levels=levels, cmap='viridis', linewidths=1.5)
ax1.clabel(cs, inline=True, fontsize=9, fmt='%d')
ax1.contourf(X, Y, Z, levels=50, cmap='viridis', alpha=0.3)

# Plot lattice points
lattice_points = []
for ix in range(-7, 8):
    for iy in range(-1, 2):
        if ix == 0 and iy == 0:
            continue
        q = heegner_form(ix, iy)
        if q <= 200:
            lattice_points.append((ix, iy, q))

for ix, iy, q in lattice_points:
    color = '#e74c3c' if is_prime(q) else '#3498db'
    marker = '*' if is_prime(q) else 'o'
    size = 100 if is_prime(q) else 50
    ax1.plot(ix, iy, marker, color=color, markersize=8,
             markeredgecolor='white', markeredgewidth=0.5)
    ax1.annotate(f'{q}', (ix, iy), textcoords="offset points",
                xytext=(5, 5), fontsize=7, color='white',
                bbox=dict(boxstyle='round,pad=0.2', facecolor=color, alpha=0.7))

ax1.plot(0, 0, 'w+', markersize=15, markeredgewidth=2)
ax1.set_xlabel('x', fontsize=14)
ax1.set_ylabel('y', fontsize=14)
ax1.set_title('Heegner Quadratic Form Q(x,y) = x² + xy + 41y²\n'
              'Lattice points colored by primality', fontsize=13, fontweight='bold')
ax1.set_facecolor('#1a1a2e')
ax1.set_xlim(-8, 8)
ax1.set_ylim(-1.5, 1.5)

# Right: The completing-the-square decomposition
# 4Q = (2x+y)² + 163y² — visualize as u-v plane
u = np.linspace(-10, 10, 400)
v = np.linspace(-2, 2, 400)
U, V = np.meshgrid(u, v)
Z2 = U**2 + 163 * V**2  # This is 4Q after change of variables

levels2 = [4, 20, 40, 80, 164, 172, 200, 400, 600, 800]
cs2 = ax2.contour(U, V, Z2, levels=levels2, cmap='plasma', linewidths=1.5)
ax2.clabel(cs2, inline=True, fontsize=9, fmt='%d')
ax2.contourf(U, V, Z2, levels=50, cmap='plasma', alpha=0.3)

# Key points in (u,v) = (2x+y, y) coordinates
key_pts = [
    (2, 0, "Q=1\n(1,0)"), (1, 1, "Q=41\n(0,1)"),
    (3, 1, "Q=43\n(1,1)"), (-1, 1, "Q=41\n(-1,1)")
]
for u_pt, v_pt, label in key_pts:
    val = u_pt**2 + 163 * v_pt**2
    ax2.plot(u_pt, v_pt, 'w*', markersize=12)
    ax2.annotate(label, (u_pt, v_pt), textcoords="offset points",
                xytext=(8, 8), fontsize=9, color='white',
                bbox=dict(boxstyle='round', facecolor='#8e44ad', alpha=0.8))

ax2.set_xlabel('u = 2x + y', fontsize=14)
ax2.set_ylabel('v = y', fontsize=14)
ax2.set_title('Completing the Square: 4Q = u² + 163v²\n'
              'Reveals circular symmetry scaled by √163', fontsize=13, fontweight='bold')
ax2.set_facecolor('#1a1a2e')

plt.tight_layout()
plt.savefig('viz_heegner_lattice.png', dpi=150, bbox_inches='tight')
print("Saved viz_heegner_lattice.png")
