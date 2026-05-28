#!/usr/bin/env python3
"""
Visualization: Eigenvalue Landscape and Lorentzian Boundary

Visualizes how the Lorentzian condition partitions the space of 2×2 symmetric
matrices by eigenvalue sign pattern. For 2×2 matrices parametrized by (a, b, c)
where A = [[a, b], [b, c]], the Lorentzian boundary is the hypersurface
separating matrices with ≤1 vs ≥2 positive eigenvalues.

Must be fully self-contained — no imports from local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def count_positive_eigenvalues(a, b, c):
    """For A = [[a,b],[b,c]], count positive eigenvalues."""
    trace = a + c
    det = a * c - b * b
    disc = np.sqrt(np.maximum((a - c)**2 + 4*b**2, 0))
    lambda1 = (trace + disc) / 2
    lambda2 = (trace - disc) / 2
    return (lambda1 > 1e-10).astype(int) + (lambda2 > 1e-10).astype(int)


# ── Figure 1: Lorentzian region in (a, c) plane for fixed b ──
fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle("Lorentzian Signature Region for 2×2 Symmetric Matrices\n"
             r"$A = \begin{pmatrix} a & b \\ b & c \end{pmatrix}$, "
             "green = at most 1 positive eigenvalue (Lorentzian)",
             fontsize=13, fontweight='bold')

b_values = [0, 0.5, 1.0, 2.0]
a_range = np.linspace(-3, 3, 400)
c_range = np.linspace(-3, 3, 400)

for idx, b_val in enumerate(b_values):
    ax = axes[idx // 2, idx % 2]
    A_grid, C_grid = np.meshgrid(a_range, c_range)
    
    n_pos = count_positive_eigenvalues(A_grid, b_val, C_grid)
    
    # Color: green for ≤1 (Lorentzian), red for ≥2
    colors = np.zeros((*n_pos.shape, 3))
    colors[n_pos <= 1] = [0.2, 0.7, 0.3]  # Green = Lorentzian
    colors[n_pos >= 2] = [0.8, 0.2, 0.2]  # Red = not Lorentzian
    
    ax.imshow(colors, extent=[a_range[0], a_range[-1], c_range[0], c_range[-1]],
              origin='lower', aspect='equal')
    
    # Draw boundary curves
    # At most 1 positive eigenvalue when det(A) ≥ 0 and trace ≤ 0, OR det ≤ 0
    # Boundary: det = 0 (ac = b²) or one eigenvalue = 0
    det_boundary = np.sqrt(np.maximum(b_val**2, 0))
    if b_val > 0:
        c_boundary = b_val**2 / np.maximum(a_range[a_range > 0], 1e-10)
        ax.plot(a_range[a_range > 0], c_boundary, 'k-', linewidth=2, label=r'$ac = b^2$')
        a_neg = a_range[a_range < 0]
        c_boundary_neg = b_val**2 / np.minimum(a_neg, -1e-10)
        ax.plot(a_neg, c_boundary_neg, 'k-', linewidth=2)
    
    ax.axhline(0, color='gray', linewidth=0.5)
    ax.axvline(0, color='gray', linewidth=0.5)
    ax.set_xlabel('a (diagonal entry)', fontsize=10)
    ax.set_ylabel('c (diagonal entry)', fontsize=10)
    ax.set_title(f'b = {b_val}', fontsize=12, fontweight='bold')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    
    # Add legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor=(0.2, 0.7, 0.3), label='≤1 pos. eigenvalue (Lorentzian)'),
        Patch(facecolor=(0.8, 0.2, 0.2), label='≥2 pos. eigenvalues')
    ]
    if idx == 0:
        ax.legend(handles=legend_elements, loc='upper left', fontsize=8)

plt.tight_layout()
plt.savefig("eigenvalue_landscape.png", dpi=150, bbox_inches='tight')
print("Saved: eigenvalue_landscape.png")
