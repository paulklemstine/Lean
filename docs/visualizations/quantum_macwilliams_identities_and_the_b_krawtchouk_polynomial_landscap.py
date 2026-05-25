"""
Visualization: Krawtchouk Polynomial Landscapes

Visualizes the Krawtchouk polynomials K_j(x; n) as both 2D line plots
and a 3D surface, revealing their role as eigenfunctions of the Hamming
distance operator and their oscillatory orthogonality structure.
"""

import numpy as np
from math import comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def krawtchouk(n, j, x):
    return sum((-1)**l * comb(x, l) * comb(n - x, j - l) for l in range(j + 1))


n = 10
fig = plt.figure(figsize=(16, 10))

# Top row: line plots for individual polynomials
ax1 = fig.add_subplot(2, 2, 1)
xs = np.arange(n + 1)
for j in range(min(6, n + 1)):
    vals = [krawtchouk(n, j, x) for x in range(n + 1)]
    ax1.plot(xs, vals, 'o-', linewidth=2, markersize=5, label=f'K_{j}(x; {n})')
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel(f'K_j(x; {n})', fontsize=12)
ax1.set_title(f'Krawtchouk Polynomials (n={n})', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Top right: eigenvalue plot K_1(j; n) = n - 2j
ax2 = fig.add_subplot(2, 2, 2)
js = np.arange(n + 1)
eigenvalues = [n - 2*j for j in range(n + 1)]
ax2.bar(js, eigenvalues, color='steelblue', alpha=0.7)
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.set_xlabel('Eigenspace index j', fontsize=12)
ax2.set_ylabel('Eigenvalue K_1(j; n) = n - 2j', fontsize=12)
ax2.set_title(f'Hamming Distance Eigenvalues (n={n})', fontsize=13)
ax2.grid(True, alpha=0.3)

# Bottom left: heatmap
ax3 = fig.add_subplot(2, 2, 3)
K = np.array([[krawtchouk(n, j, i) for i in range(n + 1)] for j in range(n + 1)], dtype=float)
vmax = np.max(np.abs(K))
im = ax3.imshow(K, cmap='RdBu_r', aspect='auto', vmin=-vmax, vmax=vmax,
                interpolation='nearest')
ax3.set_xlabel('x (evaluation point)', fontsize=12)
ax3.set_ylabel('j (polynomial index)', fontsize=12)
ax3.set_title(f'Krawtchouk Matrix K_j(x; {n})', fontsize=13)
plt.colorbar(im, ax=ax3, shrink=0.8)

# Bottom right: 3D surface
ax4 = fig.add_subplot(2, 2, 4, projection='3d')
J, X = np.meshgrid(np.arange(n + 1), np.arange(n + 1))
Z = np.array([[krawtchouk(n, j, x) for j in range(n + 1)] for x in range(n + 1)])
ax4.plot_surface(X, J, Z, cmap='viridis', alpha=0.8, edgecolor='none')
ax4.set_xlabel('x')
ax4.set_ylabel('j')
ax4.set_zlabel('K_j(x; n)')
ax4.set_title(f'Krawtchouk Surface (n={n})', fontsize=13)

plt.suptitle('Krawtchouk Polynomials: The Character Table of the Hamming Scheme',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('krawtchouk_landscape.png', dpi=150, bbox_inches='tight')
print("✓ Saved krawtchouk_landscape.png")
