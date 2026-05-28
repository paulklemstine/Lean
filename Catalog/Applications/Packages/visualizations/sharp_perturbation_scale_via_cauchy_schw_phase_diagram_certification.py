#!/usr/bin/env python3
"""
Visualization: Phase Diagram Certification Regions

Visualizes how the sharp perturbation theorem expands the certified
region of a phase diagram. For an Ising-type model, shows the
parameter space where phase classification is certified correct
under measurement uncertainty, comparing sharp vs crude bounds.
"""

import numpy as np
from numpy.linalg import eigvalsh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from matplotlib.collections import PatchCollection


def ising_hessian(n, J, h):
    """
    Hessian of the mean-field Ising free energy at the paramagnetic fixed point.
    H = I - β·J_matrix where J_matrix has J/n off-diagonal, h on diagonal.
    """
    beta = 1.0
    J_mat = np.full((n, n), J / n)
    np.fill_diagonal(J_mat, h)
    return np.eye(n) - beta * J_mat


def phase_type(H):
    """Classify phase from Hessian signature."""
    eigs = eigvalsh(H)
    if np.all(eigs > 1e-10):
        return 'stable'
    elif np.all(eigs < -1e-10):
        return 'unstable'
    else:
        return 'transition'


n = 10
J_range = np.linspace(0, 3, 80)
h_range = np.linspace(-1, 2, 80)

phase_map = np.zeros((len(h_range), len(J_range)))
gap_map = np.zeros((len(h_range), len(J_range)))

for i, h in enumerate(h_range):
    for j, J in enumerate(J_range):
        H = ising_hessian(n, J, h)
        eigs = eigvalsh(H)
        gap_map[i, j] = np.min(np.abs(eigs))
        if np.all(eigs > 1e-10):
            phase_map[i, j] = 1  # stable
        elif np.all(eigs < -1e-10):
            phase_map[i, j] = -1  # unstable
        else:
            phase_map[i, j] = 0  # transition

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle(f'Phase Diagram Certification (n={n})', fontsize=14, fontweight='bold')

# Plot 1: Phase diagram
ax = axes[0]
cmap = plt.cm.RdYlGn
im = ax.contourf(J_range, h_range, phase_map, levels=[-1.5, -0.5, 0.5, 1.5],
                  colors=['#d32f2f', '#ffeb3b', '#4caf50'], alpha=0.7)
ax.contour(J_range, h_range, phase_map, levels=[-0.5, 0.5], colors='black', linewidths=2)
ax.set_xlabel('Coupling J', fontsize=11)
ax.set_ylabel('Field h', fontsize=11)
ax.set_title('Phase Diagram', fontsize=12)
ax.text(0.3, 1.5, 'Stable', fontsize=12, fontweight='bold', color='darkgreen')
ax.text(2.2, -0.5, 'Unstable', fontsize=12, fontweight='bold', color='darkred')

# Plot 2: Spectral gap (determines tolerance)
ax = axes[1]
im2 = ax.contourf(J_range, h_range, gap_map, levels=20, cmap='viridis')
ax.contour(J_range, h_range, phase_map, levels=[-0.5, 0.5], colors='white', linewidths=2)
plt.colorbar(im2, ax=ax, label='Spectral gap ε')
ax.set_xlabel('Coupling J', fontsize=11)
ax.set_ylabel('Field h', fontsize=11)
ax.set_title('Spectral Gap Map', fontsize=12)

# Plot 3: Certified tolerance comparison
ax = axes[2]
sharp_tol = gap_map / (2 * n)
crude_tol = gap_map / (2 * n**2)
ratio = np.where(crude_tol > 0, sharp_tol / crude_tol, 1)
im3 = ax.contourf(J_range, h_range, sharp_tol, levels=20, cmap='plasma')
ax.contour(J_range, h_range, phase_map, levels=[-0.5, 0.5], colors='white', linewidths=2)
plt.colorbar(im3, ax=ax, label='Sharp tolerance ε/(2n)')
ax.set_xlabel('Coupling J', fontsize=11)
ax.set_ylabel('Field h', fontsize=11)
ax.set_title(f'Certified Tolerance (n={n}×  improvement)', fontsize=12)

plt.tight_layout()
plt.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_diagram.png")
