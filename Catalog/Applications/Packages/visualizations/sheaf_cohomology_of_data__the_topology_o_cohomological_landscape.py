"""
Visualization 3: Cohomological Landscape of Missing Data

Creates a 3D surface plot showing how the coboundary norm (H¹ proxy)
varies with both the number of features and the missing rate.
This reveals the "landscape" of information loss: a smooth surface
whose height measures the fundamental difficulty of data recovery.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Self-contained implementations
def coboundary_delta0(data):
    return data[None, :, :] - data[:, None, :]

def coboundary_norm_sq_full(mask, g):
    m, n = mask.shape
    total = 0.0
    for i in range(m):
        for j in range(m):
            shared = np.where(mask[i] & mask[j])[0]
            if len(shared) > 0:
                total += np.sum(g[i, j, shared] ** 2)
    return total

def mean_impute(mask, data):
    imputed = data.copy()
    m, n = mask.shape
    for j in range(n):
        obs = data[mask[:, j], j]
        imputed[~mask[:, j], j] = np.mean(obs) if len(obs) > 0 else 0.0
    return imputed

rng = np.random.default_rng(42)
m = 15  # Fixed number of observations

# Parameter grid
n_values = np.arange(2, 13, 1)  # 2 to 12 features
r_values = np.arange(0.05, 0.80, 0.05)  # 5% to 75% missing

Z = np.zeros((len(r_values), len(n_values)))

for ri, r in enumerate(r_values):
    for ni, n in enumerate(n_values):
        data = rng.standard_normal((m, int(n)))
        mask = (np.random.RandomState(42 + ri * 100 + ni).random((m, int(n))) >= r).astype(bool)
        imputed = mean_impute(mask, data)
        d0 = coboundary_delta0(imputed)
        Z[ri, ni] = coboundary_norm_sq_full(mask, d0)

# Normalize for visualization
Z_norm = Z / (Z.max() + 1e-10)

fig = plt.figure(figsize=(16, 6))

# Left: 3D surface
ax1 = fig.add_subplot(121, projection='3d')
R, N = np.meshgrid(r_values, n_values, indexing='ij')
surf = ax1.plot_surface(R, N, Z_norm, cmap='inferno', alpha=0.85,
                         edgecolor='none', antialiased=True)
ax1.set_xlabel('Missing Rate r', fontsize=11)
ax1.set_ylabel('Features n', fontsize=11)
ax1.set_zlabel('Normalized Coboundary Norm²', fontsize=10)
ax1.set_title('Cohomological Landscape\nof Missing Data', fontsize=13, fontweight='bold')
ax1.view_init(elev=25, azim=225)

# Right: Contour plot (top-down view)
ax2 = fig.add_subplot(122)
contour = ax2.contourf(R, N, Z_norm, levels=20, cmap='inferno')
ax2.contour(R, N, Z_norm, levels=10, colors='white', linewidths=0.5, alpha=0.3)
fig.colorbar(contour, ax=ax2, label='Normalized Coboundary Norm²')
ax2.set_xlabel('Missing Rate r', fontsize=11)
ax2.set_ylabel('Number of Features n', fontsize=11)
ax2.set_title('Information Loss Contours\n(Higher = harder to recover)', fontsize=13, fontweight='bold')

# Add theoretical curves: r*n*r*log(1/r) = const
for c in [0.2, 0.4, 0.6]:
    r_curve = np.linspace(0.05, 0.75, 100)
    n_curve = c / (r_curve ** 2 * np.log(1.0 / r_curve + 1e-10))
    valid = (n_curve >= 2) & (n_curve <= 12)
    if np.any(valid):
        ax2.plot(r_curve[valid], n_curve[valid], 'w--', alpha=0.5, linewidth=1)

plt.tight_layout()
plt.savefig('viz_cohomology_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_cohomology_landscape.png")
