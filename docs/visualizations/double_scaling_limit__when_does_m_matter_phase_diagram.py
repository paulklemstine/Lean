"""
Visualization: Phase Diagram for Wreath Product Double Scaling

Visualizes the three perturbation regimes (subcritical, critical, supercritical)
as a heatmap in the (k, m) plane, with the critical boundary m*(k) = k^α overlaid.
This is the central result: the boundary between "wreath coupling doesn't matter"
and "wreath coupling changes the universality class."
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Parameters
k_max = 40
m_max = 80
alpha = 1.0  # conjectured critical exponent
C0 = 0.5
gamma = 1.0

# Compute wreath defect on grid
k_vals = np.arange(3, k_max + 1)
m_vals = np.arange(1, m_max + 1)
K, M = np.meshgrid(k_vals, m_vals)

# Rescaled ratio m / k^alpha
ratio = M.astype(float) / np.power(K.astype(float), alpha)

# Phase classification
phase = np.zeros_like(ratio)
phase[ratio < 0.5] = 0   # subcritical (irrelevant)
phase[(ratio >= 0.5) & (ratio <= 2.0)] = 1  # critical (marginal)
phase[ratio > 2.0] = 2   # supercritical (relevant)

# Color map
cmap = mcolors.ListedColormap(['#3498db', '#f39c12', '#e74c3c'])
bounds = [-0.5, 0.5, 1.5, 2.5]
norm = mcolors.BoundaryNorm(bounds, cmap.N)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Phase diagram
ax1 = axes[0]
im = ax1.pcolormesh(k_vals, m_vals, phase, cmap=cmap, norm=norm, shading='nearest')

# Critical boundary
k_line = np.linspace(3, k_max, 200)
m_star = k_line ** alpha
ax1.plot(k_line, m_star, 'w-', linewidth=2.5, label=f'm*(k) = k^{alpha:.1f}')
ax1.plot(k_line, 0.5 * m_star, 'w--', linewidth=1.0, alpha=0.7, label='m = 0.5·m*(k)')
ax1.plot(k_line, 2.0 * m_star, 'w--', linewidth=1.0, alpha=0.7, label='m = 2·m*(k)')

ax1.set_xlabel('k (base group S_k)', fontsize=12)
ax1.set_ylabel('m (number of copies)', fontsize=12)
ax1.set_title('Phase Diagram: When Does m Matter?', fontsize=14, fontweight='bold')
ax1.legend(loc='upper left', fontsize=9)

# Add colorbar with labels
cbar = plt.colorbar(im, ax=ax1, ticks=[0, 1, 2])
cbar.ax.set_yticklabels(['Irrelevant\n(subcritical)', 'Marginal\n(critical)', 'Relevant\n(supercritical)'])

# Right: Defect magnitude heatmap
ax2 = axes[1]

# Simulated defect
defect_mag = C0 * M.astype(float)**gamma / K.astype(float)
defect_rescaled = defect_mag * K.astype(float)**alpha / M.astype(float)

im2 = ax2.pcolormesh(k_vals, m_vals, np.log10(defect_mag + 1e-10),
                      cmap='viridis', shading='nearest')
ax2.plot(k_line, m_star, 'r-', linewidth=2.5, label=f'Critical boundary')
ax2.set_xlabel('k (base group S_k)', fontsize=12)
ax2.set_ylabel('m (number of copies)', fontsize=12)
ax2.set_title('log₁₀|Δ(k,m)|: Defect Magnitude', fontsize=14, fontweight='bold')
ax2.legend(loc='upper left', fontsize=9)
plt.colorbar(im2, ax=ax2, label='log₁₀|Δ(k,m)|')

plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
plt.close()
print("Phase diagram saved to phase_diagram.png")
