"""
Heatmap Visualization: Lorentzian Gap Across Parameter Space

This script produces a heatmap showing how the Lorentzian gap varies
across a 2D parameter space of matrix perturbations. The contour where
the gap crosses zero represents the phase transition boundary.

Visualizes: The gap landscape for a K4 matching Hessian under a
2-parameter family of perturbations, with the zero-gap contour
marking the quantum-classical boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm


def compute_lorentzian_gap(A):
    eigenvalues = np.linalg.eigvalsh(A)
    eigenvalues = np.sort(eigenvalues)[::-1]
    return -eigenvalues[1] if A.shape[0] >= 2 else float('inf')


# Base matrix: K4 matching Hessian
n = 4
adj = np.ones((n, n)) - np.eye(n)
H = adj

# Two perturbation directions
E1 = np.array([[0, 1, 0, 0],
               [1, 0, 0, 0],
               [0, 0, 0, 1],
               [0, 0, 1, 0]], dtype=float)

E2 = np.array([[0, 0, 1, 0],
               [0, 0, 0, 1],
               [1, 0, 0, 0],
               [0, 1, 0, 0]], dtype=float)

# Compute gap landscape
resolution = 150
alpha_range = np.linspace(-4, 4, resolution)
beta_range = np.linspace(-4, 4, resolution)
gap_landscape = np.zeros((resolution, resolution))

for i, alpha in enumerate(alpha_range):
    for j, beta in enumerate(beta_range):
        perturbed = H + alpha * E1 + beta * E2
        gap_landscape[j, i] = compute_lorentzian_gap(perturbed)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Gap heatmap with phase boundary
ax = axes[0]
norm = TwoSlopeNorm(vmin=gap_landscape.min(), vcenter=0, vmax=gap_landscape.max())
im = ax.pcolormesh(alpha_range, beta_range, gap_landscape,
                   cmap='RdYlBu_r', norm=norm, shading='auto')
ax.contour(alpha_range, beta_range, gap_landscape, levels=[0],
           colors='black', linewidths=2.5)

# Mark certified safe zone (circle of radius threshold)
base_gap = compute_lorentzian_gap(H)
threshold = base_gap / 2
# The norm of alpha*E1 + beta*E2 as operator: approximate
circle = plt.Circle((0, 0), threshold, fill=False, color='lime',
                    linewidth=2.5, linestyle='--', label='Certified safe zone')
ax.add_patch(circle)
ax.plot(0, 0, 'w*', markersize=15, zorder=5, label='Base matrix')

cbar = plt.colorbar(im, ax=ax)
cbar.set_label('Lorentzian gap', fontsize=12)
ax.set_xlabel('Perturbation parameter α', fontsize=13)
ax.set_ylabel('Perturbation parameter β', fontsize=13)
ax.set_title('Gap Landscape: K₄ Matching Hessian\n'
             '(Black contour = phase boundary, gap = 0)',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.set_aspect('equal')
ax.set_xlim(-4, 4)
ax.set_ylim(-4, 4)

# Panel 2: Radial gap profile
ax = axes[1]
angles = np.linspace(0, 2 * np.pi, 36)
radii = np.linspace(0, 4, 100)

for angle_idx, angle in enumerate(angles[::6]):
    direction_alpha = np.cos(angle)
    direction_beta = np.sin(angle)
    gaps_along_ray = []
    for r in radii:
        perturbed = H + r * direction_alpha * E1 + r * direction_beta * E2
        g = compute_lorentzian_gap(perturbed)
        gaps_along_ray.append(g)
    label = f'θ = {np.degrees(angle):.0f}°' if angle_idx % 6 == 0 else None
    ax.plot(radii, gaps_along_ray, alpha=0.7, linewidth=1.5, label=label)

ax.axhline(0, color='black', linewidth=1.5, linestyle='-')
ax.axvline(threshold, color='green', linewidth=2, linestyle='--',
           label=f'Certified radius = {threshold:.2f}')
ax.fill_between(radii, -1, 0, alpha=0.1, color='red')
ax.fill_betweenx([0, base_gap * 1.2], 0, threshold, alpha=0.1, color='green')

ax.set_xlabel('Perturbation radius r', fontsize=13)
ax.set_ylabel('Lorentzian gap', fontsize=13)
ax.set_title('Gap vs Perturbation Radius\n(Multiple directions)',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(-1, base_gap * 1.2)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('gap_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved gap_heatmap.png")
