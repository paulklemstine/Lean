#!/usr/bin/env python3
"""
Demo 3: Vandermonde Determinant Landscape

Visualizes the Vandermonde determinant |∏_{i<j} (λ_j - λ_i)|^β as a function
of two eigenvalues (with the rest fixed). Shows the "repulsive potential" that
pushes eigenvalues apart.

Generates: vandermonde_landscape.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def vandermonde_product(eigenvalues):
    """Compute |∏_{i<j} (λ_j - λ_i)|."""
    n = len(eigenvalues)
    prod = 1.0
    for i in range(n):
        for j in range(i+1, n):
            prod *= abs(eigenvalues[j] - eigenvalues[i])
    return prod

def repulsion_factor(eigenvalues, beta):
    """Compute |∏_{i<j} (λ_j - λ_i)|^β."""
    return vandermonde_product(eigenvalues) ** beta

def coulomb_energy(eigenvalues):
    """Compute -∑_{i<j} log|λ_j - λ_i|."""
    n = len(eigenvalues)
    E = 0.0
    for i in range(n):
        for j in range(i+1, n):
            diff = abs(eigenvalues[j] - eigenvalues[i])
            if diff > 1e-15:
                E -= np.log(diff)
            else:
                E += 50  # "infinity" cap
    return E

# ===== Figure 1: 2D landscape for 2 eigenvalues =====
fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('The Repulsion Landscape: Vandermonde Factor for Two Eigenvalues',
             fontsize=15, fontweight='bold', y=1.02)

resolution = 200
x = np.linspace(-3, 3, resolution)
y = np.linspace(-3, 3, resolution)
X, Y = np.meshgrid(x, y)

betas = [1, 2, 4]
titles = [r'$|\lambda_2 - \lambda_1|^1$ (GOE)',
          r'$|\lambda_2 - \lambda_1|^2$ (GUE)',
          r'$|\lambda_2 - \lambda_1|^4$ (GSE)']

for idx, (beta, title) in enumerate(zip(betas, titles)):
    Z = np.abs(Y - X) ** beta
    # Apply Gaussian weight
    Z_weighted = Z * np.exp(-0.5 * (X**2 + Y**2))

    ax = axes[idx]
    im = ax.contourf(X, Y, Z_weighted, levels=50, cmap='hot')
    ax.plot([-3, 3], [-3, 3], 'c--', linewidth=2, alpha=0.8, label=r'$\lambda_1 = \lambda_2$ (zero)')
    ax.set_xlabel(r'$\lambda_1$', fontsize=13)
    ax.set_ylabel(r'$\lambda_2$', fontsize=13)
    ax.set_title(title, fontsize=13)
    ax.set_aspect('equal')
    ax.legend(fontsize=10, loc='upper left')
    plt.colorbar(im, ax=ax, shrink=0.8, label='Joint density weight')

plt.tight_layout()
plt.savefig('Random Matrix/demos/vandermonde_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/vandermonde_landscape.png")
plt.close()

# ===== Figure 2: 3D surface plot =====
fig = plt.figure(figsize=(16, 5))
fig.suptitle('Repulsion Factor as 3D Surface', fontsize=15, fontweight='bold', y=1.0)

resolution = 100
x = np.linspace(-3, 3, resolution)
y = np.linspace(-3, 3, resolution)
X, Y = np.meshgrid(x, y)

for idx, (beta, title) in enumerate(zip(betas, titles)):
    ax = fig.add_subplot(1, 3, idx + 1, projection='3d')
    Z = np.abs(Y - X) ** beta * np.exp(-0.5 * (X**2 + Y**2))

    surf = ax.plot_surface(X, Y, Z, cmap='viridis', alpha=0.85,
                           linewidth=0, antialiased=True)
    ax.set_xlabel(r'$\lambda_1$', fontsize=11)
    ax.set_ylabel(r'$\lambda_2$', fontsize=11)
    ax.set_zlabel('Weight', fontsize=11)
    ax.set_title(title, fontsize=12, pad=10)
    ax.view_init(elev=25, azim=-60)

plt.tight_layout()
plt.savefig('Random Matrix/demos/vandermonde_3d_surface.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/vandermonde_3d_surface.png")
plt.close()

# ===== Figure 3: Coulomb energy landscape =====
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))
fig.suptitle('Coulomb Energy vs. Repulsion Factor', fontsize=15, fontweight='bold', y=1.02)

resolution = 200
x = np.linspace(-3, 3, resolution)
y = np.linspace(-3, 3, resolution)
X, Y = np.meshgrid(x, y)

# Coulomb energy
Z_energy = np.zeros_like(X)
for i in range(resolution):
    for j in range(resolution):
        diff = abs(Y[i,j] - X[i,j])
        if diff > 0.01:
            Z_energy[i,j] = -np.log(diff)
        else:
            Z_energy[i,j] = 5  # cap

ax = axes[0]
im = ax.contourf(X, Y, Z_energy, levels=50, cmap='RdYlBu_r')
ax.plot([-3, 3], [-3, 3], 'k--', linewidth=2, alpha=0.8, label=r'$\lambda_1 = \lambda_2$ ($E \to \infty$)')
ax.set_xlabel(r'$\lambda_1$', fontsize=13)
ax.set_ylabel(r'$\lambda_2$', fontsize=13)
ax.set_title('Coulomb Energy $E = -\\log|\\lambda_2 - \\lambda_1|$', fontsize=13)
ax.set_aspect('equal')
ax.legend(fontsize=10, loc='upper left')
plt.colorbar(im, ax=ax, shrink=0.8, label='Energy')

# Total energy (Coulomb + confining)
Z_total = np.zeros_like(X)
for i in range(resolution):
    for j in range(resolution):
        diff = abs(Y[i,j] - X[i,j])
        if diff > 0.01:
            Z_total[i,j] = -2 * np.log(diff) + 0.5 * (X[i,j]**2 + Y[i,j]**2)
        else:
            Z_total[i,j] = 15

ax = axes[1]
im = ax.contourf(X, Y, Z_total, levels=50, cmap='RdYlBu_r')
ax.plot([-3, 3], [-3, 3], 'k--', linewidth=2, alpha=0.8,
        label=r'$\lambda_1 = \lambda_2$ (barrier)')
ax.set_xlabel(r'$\lambda_1$', fontsize=13)
ax.set_ylabel(r'$\lambda_2$', fontsize=13)
ax.set_title(r'Total Energy $E = -2\log|\lambda_2 - \lambda_1| + \frac{1}{2}(\lambda_1^2 + \lambda_2^2)$',
             fontsize=12)
ax.set_aspect('equal')
ax.legend(fontsize=10, loc='upper left')
plt.colorbar(im, ax=ax, shrink=0.8, label='Energy')

plt.tight_layout()
plt.savefig('Random Matrix/demos/coulomb_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/coulomb_energy_landscape.png")
plt.close()
