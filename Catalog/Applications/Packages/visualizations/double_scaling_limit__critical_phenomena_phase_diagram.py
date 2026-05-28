#!/usr/bin/env python3
"""
Visualization 1: Phase Diagram for Wreath-Product Scaling Regimes

Visualizes the (k, m) parameter space colored by perturbation regime
(irrelevant / marginal / relevant), with the critical boundary
m = k^(b/a) shown as a curve. This is the finite-group analog of
the phase diagram showing the upper critical dimension boundary
in statistical mechanics.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap

# === Inline functions (self-contained) ===

def wreath_defect(k, m, C=1.0, a=1, b=1):
    """Compute wreath defect Δ(k,m) = C·m^a/k^b."""
    if k <= 0:
        return 0.0
    return C * (m ** a) / (k ** b)

# === Computation ===

C, a, b = 1.0, 1, 1
alpha_c = b / a

k_vals = np.arange(3, 51)
m_vals = np.arange(1, 101)
K, M = np.meshgrid(k_vals, m_vals)

# Compute scaling ratio m / k^alpha_c
scaling_ratio = M.astype(float) / np.power(K.astype(float), alpha_c)

# Compute defect
defects = np.zeros_like(K, dtype=float)
for i in range(K.shape[0]):
    for j in range(K.shape[1]):
        defects[i, j] = wreath_defect(int(K[i, j]), int(M[i, j]), C, a, b)

# Classify regimes
regimes = np.zeros_like(K, dtype=float)
regimes[scaling_ratio < 0.3] = 0    # irrelevant
regimes[(scaling_ratio >= 0.3) & (scaling_ratio <= 3.0)] = 1  # marginal
regimes[scaling_ratio > 3.0] = 2    # relevant

# === Plotting ===

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Regime classification
ax1 = axes[0]
cmap = ListedColormap(['#2ecc71', '#f39c12', '#e74c3c'])
im1 = ax1.pcolormesh(K, M, regimes, cmap=cmap, shading='auto')

# Critical boundary
k_crit = np.linspace(3, 50, 200)
m_crit = k_crit ** alpha_c
ax1.plot(k_crit, m_crit, 'k--', linewidth=2, label=f'm = k^{{{alpha_c:.1f}}} (critical)')
ax1.plot(k_crit, 0.3 * m_crit, 'k:', linewidth=1, alpha=0.5)
ax1.plot(k_crit, 3.0 * m_crit, 'k:', linewidth=1, alpha=0.5)

ax1.set_xlabel('k (internal symmetry)', fontsize=13)
ax1.set_ylabel('m (number of copies)', fontsize=13)
ax1.set_title('Perturbation Regime Phase Diagram', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='upper left')
ax1.set_xlim(3, 50)
ax1.set_ylim(1, 100)

# Add regime labels
ax1.text(35, 10, 'IRRELEVANT', fontsize=12, fontweight='bold',
         color='white', ha='center',
         bbox=dict(boxstyle='round', facecolor='#2ecc71', alpha=0.8))
ax1.text(10, 70, 'RELEVANT', fontsize=12, fontweight='bold',
         color='white', ha='center',
         bbox=dict(boxstyle='round', facecolor='#e74c3c', alpha=0.8))
ax1.text(25, 40, 'MARGINAL', fontsize=10, fontweight='bold',
         color='white', ha='center',
         bbox=dict(boxstyle='round', facecolor='#f39c12', alpha=0.8))

# Panel 2: Defect heatmap
ax2 = axes[1]
log_defects = np.log10(defects + 1e-10)
im2 = ax2.pcolormesh(K, M, log_defects, cmap='viridis', shading='auto')
ax2.plot(k_crit, m_crit, 'w--', linewidth=2, label=f'Critical boundary')
cbar = fig.colorbar(im2, ax=ax2, label='log₁₀|Δ(k,m)|')
ax2.set_xlabel('k (internal symmetry)', fontsize=13)
ax2.set_ylabel('m (number of copies)', fontsize=13)
ax2.set_title('Wreath Defect Magnitude', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11, loc='upper left')
ax2.set_xlim(3, 50)
ax2.set_ylim(1, 100)

plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved phase_diagram.png")
