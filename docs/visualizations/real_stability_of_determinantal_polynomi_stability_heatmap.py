"""
Visualization 1: Stability Heatmap
===================================
Visualizes |det(I + z·K)| for a 1×1 PSD matrix K=[k] as a function of z in the 
complex plane. The upper half-plane (Im(z) > 0) shows the polynomial never vanishes
(warm colors everywhere), while zeros can appear on or below the real axis.
This directly illustrates the main theorem for the simplest case.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Parameters
k_val = 2.0  # PSD "matrix" value (1x1 case)
resolution = 500

# Create complex plane grid
re = np.linspace(-3, 1, resolution)
im = np.linspace(-2, 2, resolution)
Re, Im = np.meshgrid(re, im)
Z = Re + 1j * Im

# Compute |1 + k*z|
F = np.abs(1 + k_val * Z)

# The zero is at z = -1/k
zero_re, zero_im = -1/k_val, 0

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Log scale for better visualization
F_log = np.log10(F + 1e-15)

# Custom colormap
pcm = ax.pcolormesh(Re, Im, F_log, cmap='inferno', shading='auto',
                    vmin=-2, vmax=2)
cbar = fig.colorbar(pcm, ax=ax, label='log₁₀ |1 + kz|')

# Mark the zero
ax.plot(zero_re, zero_im, 'wo', markersize=10, markeredgecolor='cyan',
        markeredgewidth=2, label=f'Zero at z = {zero_re:.2f}')

# Draw the real axis
ax.axhline(y=0, color='white', linewidth=1, alpha=0.5, linestyle='--')

# Shade the upper half-plane boundary
ax.fill_between(re, 0, 2, alpha=0.1, color='cyan',
                label='Upper half-plane ℍ (no zeros here!)')

# Contour lines
contours = ax.contour(Re, Im, F, levels=[0.1, 0.5, 1, 2, 5],
                      colors='white', linewidths=0.5, alpha=0.4)

ax.set_xlabel('Re(z)', fontsize=14)
ax.set_ylabel('Im(z)', fontsize=14)
ax.set_title(f'|1 + {k_val}z| in the Complex Plane\n'
             f'Real stability: no zeros in upper half-plane',
             fontsize=16)
ax.legend(loc='upper left', fontsize=11)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('stability_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved stability_heatmap.png")
