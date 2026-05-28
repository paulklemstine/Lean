#!/usr/bin/env python3
"""
Visualization: Energy Landscape of the Period Form

Shows the quadratic energy functional x^T Q x = Σ_e ℓ_e (Σ_i C_ei x_i)²
as a surface/contour plot over the cycle coordinate space ℝ^g.

For genus g=2, this creates a 3D surface showing the energy landscape,
with level curves corresponding to "tropical circles" in the Jacobian torus.
The shape of these level curves reveals the geometry of the tropical Jacobian.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from numpy.linalg import eigvalsh


def compute_period_matrix(C, lengths):
    CR = C.astype(float)
    return CR.T @ np.diag(lengths) @ CR


# ──────────────────────────────────────────────────
# Theta graph (genus 2)
# ──────────────────────────────────────────────────

C = np.array([[1, 1], [-1, 0], [0, -1]], dtype=int)

fig = plt.figure(figsize=(16, 10))
fig.suptitle("Energy Landscape of the Tropical Jacobian Period Form",
             fontsize=15, fontweight='bold')

length_configs = [
    (np.array([1.0, 1.0, 1.0]), "Uniform: ℓ = (1, 1, 1)"),
    (np.array([1.0, 2.0, 3.0]), "Asymmetric: ℓ = (1, 2, 3)"),
    (np.array([0.5, 0.5, 4.0]), "Near-degenerate: ℓ = (0.5, 0.5, 4)"),
    (np.array([3.0, 3.0, 0.1]), "Short bridge: ℓ = (3, 3, 0.1)"),
]

n_grid = 100
x_range = np.linspace(-2, 2, n_grid)
y_range = np.linspace(-2, 2, n_grid)
X, Y = np.meshgrid(x_range, y_range)

for idx, (lengths, title) in enumerate(length_configs):
    Q = compute_period_matrix(C, lengths)
    eigs = eigvalsh(Q)
    
    # Compute energy landscape
    Z = np.zeros_like(X)
    for i in range(n_grid):
        for j in range(n_grid):
            v = np.array([X[i, j], Y[i, j]])
            Z[i, j] = float(v @ Q @ v)
    
    # Contour plot
    ax = fig.add_subplot(2, 4, idx + 1)
    levels = np.linspace(0, 10, 20)
    cp = ax.contourf(X, Y, Z, levels=levels, cmap='magma_r', extend='max')
    ax.contour(X, Y, Z, levels=levels, colors='white', alpha=0.3, linewidths=0.5)
    
    # Mark eigenvector directions
    _, evecs = np.linalg.eigh(Q)
    for k in range(2):
        scale = 1.5
        v = evecs[:, k] * scale
        ax.annotate('', xy=(v[0], v[1]), xytext=(0, 0),
                    arrowprops=dict(arrowstyle='->', color=['#00ff88', '#ff4444'][k],
                                   lw=2))
    
    ax.set_xlabel('x₁', fontsize=10)
    ax.set_ylabel('x₂', fontsize=10)
    ax.set_title(f'{title}\nλ = ({eigs[0]:.2f}, {eigs[1]:.2f})', fontsize=9)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    
    # 3D surface
    ax3d = fig.add_subplot(2, 4, idx + 5, projection='3d')
    Z_clipped = np.clip(Z, 0, 10)
    surf = ax3d.plot_surface(X, Y, Z_clipped, cmap='magma_r', alpha=0.8,
                              edgecolor='none', rstride=3, cstride=3)
    ax3d.set_xlabel('x₁', fontsize=9)
    ax3d.set_ylabel('x₂', fontsize=9)
    ax3d.set_zlabel('x^TQx', fontsize=9)
    ax3d.set_zlim(0, 10)
    ax3d.view_init(elev=30, azim=-60)
    ax3d.set_title(f'det(Q) = {np.linalg.det(Q):.2f}', fontsize=9)

plt.tight_layout()
plt.savefig('energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved energy_landscape.png")
