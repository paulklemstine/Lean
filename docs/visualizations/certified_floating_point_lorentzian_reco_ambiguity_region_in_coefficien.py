"""
Visualization: Ambiguity Region in Coefficient Space

This script visualizes the three-valued certified decision (YES/NO/UNKNOWN)
across a 2D slice of bivariate polynomial coefficient space. It shows how
the ambiguity region (UNKNOWN) shrinks as the uncertainty radius ε decreases,
demonstrating the O(ε) volume bound from the formal theory.

The plot reveals the geometric structure of the Lorentzian/non-Lorentzian
boundary and the thin band of numerical indecision.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


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


def perturbation_bound(max_radius, degree):
    n = max(degree - 1, 1)
    max_scaling = degree * degree
    entry_bound = max_radius * max_scaling
    return n**2 * entry_bound


def certify(center, eps, degree):
    lower = center - eps
    upper = center + eps
    if np.any(upper < 0):
        return -1  # NO
    H = bivariate_hessian(center)
    margin = spectral_margin(H)
    err = perturbation_bound(eps, degree)
    if margin > 0 and err < margin and np.all(lower >= -1e-12):
        return 1   # YES
    if margin < 0 and err < -margin:
        return -1  # NO
    return 0       # UNKNOWN


# Set up the figure
fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Certified Lorentzian Recognition: Ambiguity Region',
             fontsize=14, fontweight='bold')

degree = 4
base_coeffs = np.array([1.0, 1.5, 0.0, 1.5, 1.0])  # vary index 2 and 3
grid_size = 200

a2_range = np.linspace(0, 4, grid_size)
a3_range = np.linspace(0, 4, grid_size)

epsilons = [0.01, 0.05, 0.2]

cmap = mcolors.ListedColormap(['#e74c3c', '#f39c12', '#2ecc71'])
bounds = [-1.5, -0.5, 0.5, 1.5]
norm = mcolors.BoundaryNorm(bounds, cmap.N)

for ax_idx, eps in enumerate(epsilons):
    ax = axes[ax_idx]
    decision_grid = np.zeros((grid_size, grid_size))
    
    for i, a2 in enumerate(a2_range):
        for j, a3 in enumerate(a3_range):
            coeffs = base_coeffs.copy()
            coeffs[2] = a2
            coeffs[3] = a3
            decision_grid[j, i] = certify(coeffs, eps, degree)
    
    n_yes = np.sum(decision_grid == 1)
    n_no = np.sum(decision_grid == -1)
    n_unk = np.sum(decision_grid == 0)
    total = grid_size**2
    
    im = ax.imshow(decision_grid, origin='lower', aspect='equal',
                   extent=[0, 4, 0, 4], cmap=cmap, norm=norm,
                   interpolation='nearest')
    
    ax.set_xlabel('$a_2$ (coefficient of $x^2y^2$)', fontsize=11)
    ax.set_ylabel('$a_3$ (coefficient of $xy^3$)', fontsize=11)
    ax.set_title(f'ε = {eps}\n'
                 f'YES: {100*n_yes/total:.1f}%  '
                 f'NO: {100*n_no/total:.1f}%  '
                 f'UNK: {100*n_unk/total:.1f}%',
                 fontsize=10)

# Add colorbar
cbar_ax = fig.add_axes([0.92, 0.15, 0.02, 0.7])
cbar = fig.colorbar(im, cax=cbar_ax, ticks=[-1, 0, 1])
cbar.ax.set_yticklabels(['Non-Lorentzian', 'Unknown', 'Lorentzian'])

plt.tight_layout(rect=[0, 0, 0.91, 0.95])
plt.savefig('viz_ambiguity_region.png', dpi=150, bbox_inches='tight')
print("Saved: viz_ambiguity_region.png")
