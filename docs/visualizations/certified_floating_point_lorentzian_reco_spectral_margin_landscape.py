"""
Visualization: Spectral Margin Landscape

This script creates a heatmap of the spectral margin across a 2D slice
of coefficient space, showing the smooth landscape that transitions from
positive (Lorentzian) to negative (non-Lorentzian) values. The zero
contour is the Lorentzian boundary — the locus of phase transitions.

The smoothness of the margin function is what makes certified recognition
possible: small perturbations produce small changes in the margin.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm


def bivariate_hessian(coeffs):
    d = len(coeffs) - 1
    if d < 2:
        return np.array([[coeffs[0]]])
    n = d - 1
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            idx = i + j
            if idx < len(coeffs):
                H[i, j] = coeffs[idx] * (i + 1) * (j + 1)
    return H


def spectral_margin(H):
    if H.shape[0] <= 1:
        return float('inf')
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    return -eigenvalues[1]


# Create the figure
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Spectral Margin Landscape in Coefficient Space',
             fontsize=14, fontweight='bold')

grid_size = 300

# Panel 1: Vary a₁ and a₃ in [1, a₁, 2, a₃, 1]
ax = axes[0]
a1_range = np.linspace(0, 4, grid_size)
a3_range = np.linspace(0, 4, grid_size)
margin_grid = np.zeros((grid_size, grid_size))

for i, a1 in enumerate(a1_range):
    for j, a3 in enumerate(a3_range):
        coeffs = np.array([1.0, a1, 2.0, a3, 1.0])
        H = bivariate_hessian(coeffs)
        margin_grid[j, i] = spectral_margin(H)

# Clip for visualization
margin_clipped = np.clip(margin_grid, -50, 50)
im1 = ax.imshow(margin_clipped, origin='lower', aspect='equal',
                extent=[0, 4, 0, 4], cmap='RdYlGn',
                vmin=-30, vmax=30)
ax.contour(a1_range, a3_range, margin_grid, levels=[0],
           colors='black', linewidths=2)
ax.set_xlabel('$a_1$ (coefficient of $x^3y$)', fontsize=11)
ax.set_ylabel('$a_3$ (coefficient of $xy^3$)', fontsize=11)
ax.set_title('p(x,y) = x⁴ + a₁x³y + 2x²y² + a₃xy³ + y⁴', fontsize=11)
plt.colorbar(im1, ax=ax, label='Spectral Margin', shrink=0.8)

# Panel 2: Vary a₂ in [1, 2, a₂, 2, 1] — 1D cross-section
ax2 = axes[1]
a2_values = np.linspace(0, 6, 500)
margins = []
for a2 in a2_values:
    coeffs = np.array([1.0, 2.0, a2, 2.0, 1.0])
    H = bivariate_hessian(coeffs)
    margins.append(spectral_margin(H))

margins = np.array(margins)
ax2.plot(a2_values, margins, 'b-', linewidth=2, label='Spectral Margin')
ax2.axhline(y=0, color='k', linestyle='--', alpha=0.5)
ax2.fill_between(a2_values, margins, 0,
                 where=(margins > 0), alpha=0.2, color='green',
                 label='Lorentzian region')
ax2.fill_between(a2_values, margins, 0,
                 where=(margins < 0), alpha=0.2, color='red',
                 label='Non-Lorentzian region')

# Mark the critical point
zero_crossings = a2_values[:-1][np.diff(np.sign(margins)) != 0]
for zc in zero_crossings:
    ax2.axvline(x=zc, color='orange', linestyle=':', alpha=0.8)
    ax2.annotate(f'Critical: a₂≈{zc:.2f}', xy=(zc, 0),
                xytext=(zc + 0.5, max(margins) * 0.5),
                arrowprops=dict(arrowstyle='->', color='orange'),
                fontsize=9, color='orange')

ax2.set_xlabel('$a_2$ (coefficient of $x^2y^2$)', fontsize=11)
ax2.set_ylabel('Spectral Margin', fontsize=11)
ax2.set_title('1D Cross-Section: [1, 2, a₂, 2, 1]', fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_margin_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: viz_margin_landscape.png")
