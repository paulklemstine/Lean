#!/usr/bin/env python3
"""
Visualization 1: Phase Diagram for Wreath-Product Scaling Regimes

Visualizes the three perturbation regimes (irrelevant, marginal, relevant)
in the (k, m) plane, with the critical boundary m = k^(alpha_c) separating
the regions. Colors indicate the magnitude of the wreath defect.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def model_defect(k, m, C=0.5, a=1, b=2):
    """Wreath defect: Delta(k,m) = C * m^a / k^b"""
    return C * (m ** a) / (k ** b)


# Create grid
k_vals = np.linspace(2, 50, 300)
m_vals = np.linspace(1, 2500, 300)
K, M = np.meshgrid(k_vals, m_vals)

# Compute defect magnitude
Delta = model_defect(K, M)

# Critical boundary: m = k^(b/a) = k^2
alpha_c = 2.0
k_boundary = np.linspace(2, 50, 200)
m_boundary = k_boundary ** alpha_c

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Plot defect heatmap
pcm = ax.pcolormesh(K, M, Delta, cmap='magma_r', shading='gouraud',
                     norm=LogNorm(vmin=0.001, vmax=100))
cbar = fig.colorbar(pcm, ax=ax, label='Wreath Defect |Δ(k,m)|', pad=0.02)

# Plot critical boundary
ax.plot(k_boundary, m_boundary, 'w-', linewidth=3, label=r'Critical: $m = k^2$')
ax.plot(k_boundary, m_boundary, 'r--', linewidth=1.5)

# Label regions
ax.text(35, 200, 'IRRELEVANT\n(same universality class)',
        fontsize=14, color='white', ha='center', va='center',
        fontweight='bold', style='italic')
ax.text(10, 2000, 'RELEVANT\n(new universality class)',
        fontsize=14, color='white', ha='center', va='center',
        fontweight='bold', style='italic')

# Mark example trajectories
# Subcritical: m = sqrt(k)
k_sub = np.linspace(2, 50, 100)
m_sub = np.sqrt(k_sub) * 10  # scaled for visibility
ax.plot(k_sub, m_sub, 'c-', linewidth=2, alpha=0.8, label=r'Subcritical: $m \sim \sqrt{k}$')

# Supercritical: m = k^3
k_sup = np.linspace(2, 13, 50)
m_sup = k_sup ** 3
mask = m_sup <= 2500
ax.plot(k_sup[mask], m_sup[mask], 'lime', linewidth=2, alpha=0.8,
        label=r'Supercritical: $m \sim k^3$')

ax.set_xlabel('k (base group parameter)', fontsize=14)
ax.set_ylabel('m (multiplicity parameter)', fontsize=14)
ax.set_title('Phase Diagram: Wreath-Product Perturbation Regimes\n'
             r'Critical exponent $\alpha_c = b/a = 2$',
             fontsize=16, fontweight='bold')
ax.legend(loc='upper left', fontsize=11, facecolor='black', edgecolor='white',
          labelcolor='white', framealpha=0.7)
ax.set_xlim(2, 50)
ax.set_ylim(1, 2500)

plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved phase_diagram.png")
