"""
Visualization 2: Stability Radius Heatmap for U_{r,n}

This script creates a heatmap showing the predicted Lorentzian stability
radius across all uniform matroids U_{r,n} for n up to 15. The stability
radius is 1/m = 1/(n-r+2), which depends only on the "excess" n-r.

The visualization reveals the elegant structure: stability depends only
on the codimension n-r, not on n and r separately.
"""

import numpy as np
import matplotlib.pyplot as plt

max_n = 15

# Create data matrix
data = np.full((max_n + 1, max_n + 1), np.nan)
for n in range(4, max_n + 1):
    for r in range(2, n - 1):
        m = n - r + 2
        data[r, n] = 1.0 / m

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Stability radius heatmap
ax1 = axes[0]
im = ax1.imshow(data[2:max_n-1, 4:max_n+1], cmap='viridis', aspect='auto',
                origin='lower', interpolation='nearest')
ax1.set_xlabel('n (ground set size)', fontsize=13)
ax1.set_ylabel('r (rank)', fontsize=13)
ax1.set_title('Entrywise Stability Radius 1/(n−r+2)\nfor Uniform Matroids U_{r,n}',
              fontsize=14, fontweight='bold')
ax1.set_xticks(range(0, max_n - 3))
ax1.set_xticklabels(range(4, max_n + 1))
ax1.set_yticks(range(0, max_n - 3))
ax1.set_yticklabels(range(2, max_n - 1))
plt.colorbar(im, ax=ax1, label='Stability radius', shrink=0.8)

# Panel 2: Stability radius vs m for fixed values
ax2 = axes[1]
m_vals = np.arange(2, 16)
radii = 1.0 / m_vals

# Theoretical curve
m_fine = np.linspace(2, 15, 100)
ax2.plot(m_fine, 1.0 / m_fine, 'b-', linewidth=2, label=r'$\rho = 1/m$ (theoretical)',
         alpha=0.7)

# Discrete points
ax2.plot(m_vals, radii, 'ro', markersize=8, label='Matroid leaf dimensions',
         zorder=5)

# Annotate a few points
for n, r in [(6, 3), (8, 4), (10, 5), (12, 6)]:
    m = n - r + 2
    ax2.annotate(f'$U_{{{r},{n}}}$', xy=(m, 1.0/m),
                xytext=(m + 0.3, 1.0/m + 0.02),
                fontsize=10, color='darkred',
                arrowprops=dict(arrowstyle='->', color='darkred', lw=1))

ax2.set_xlabel('Leaf dimension m = n − r + 2', fontsize=13)
ax2.set_ylabel('Stability radius', fontsize=13)
ax2.set_title('Stability Radius Scaling Law', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(1.5, 15.5)

plt.tight_layout()
plt.savefig('stability_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: stability_heatmap.png")
