#!/usr/bin/env python3
"""
Visualization: Virality Landscape
===================================
3D surface plot showing how virality depends on H⁰ (interpretation
diversity) and H¹ (transmission barriers). The key insight:
maximum virality occurs at high H⁰ and zero H¹.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Parameters
h0_range = np.arange(1, 21)  # dim H⁰ from 1 to 20
h1_range = np.arange(0, 16)  # dim H¹ from 0 to 15
H0, H1 = np.meshgrid(h0_range, h1_range)

# Virality index: V = H⁰ / (1 + H¹)
# This models: more interpretations × fewer barriers = higher virality
V = H0.astype(float) / (1 + H1.astype(float))

# Create figure
fig = plt.figure(figsize=(14, 10))

# 3D surface plot
ax1 = fig.add_subplot(221, projection='3d')
surf = ax1.plot_surface(H0, H1, V, cmap='viridis', alpha=0.8,
                         edgecolor='none')
ax1.set_xlabel('dim H⁰\n(Interpretations)', fontsize=10)
ax1.set_ylabel('dim H¹\n(Barriers)', fontsize=10)
ax1.set_zlabel('Virality Index', fontsize=10)
ax1.set_title('Virality Landscape', fontsize=12, fontweight='bold')
ax1.view_init(elev=30, azim=135)
fig.colorbar(surf, ax=ax1, shrink=0.5, label='Virality')

# Contour plot (top view)
ax2 = fig.add_subplot(222)
contour = ax2.contourf(H0, H1, V, levels=20, cmap='viridis')
ax2.set_xlabel('dim H⁰ (Interpretations)', fontsize=11)
ax2.set_ylabel('dim H¹ (Barriers)', fontsize=11)
ax2.set_title('Virality Contours', fontsize=12, fontweight='bold')
fig.colorbar(contour, ax=ax2, label='Virality Index')

# Mark the "viral sweet spot"
ax2.scatter([20], [0], color='red', s=200, marker='*', zorder=5, 
            label='Maximum virality\n(high H⁰, zero H¹)')
ax2.legend(fontsize=9)

# Virality vs H¹ for fixed H⁰
ax3 = fig.add_subplot(223)
for h0 in [1, 5, 10, 15, 20]:
    v = h0 / (1 + h1_range.astype(float))
    ax3.plot(h1_range, v, 'o-', label=f'dim H⁰ = {h0}', markersize=3)
ax3.set_xlabel('dim H¹ (Transmission Barriers)', fontsize=11)
ax3.set_ylabel('Virality Index', fontsize=11)
ax3.set_title('Virality Decreases with Barriers\n(Proven: viral_meme_max_virality)', 
              fontsize=11, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Phase transition plot
ax4 = fig.add_subplot(224)
n_values = [20, 50, 100, 200]
for n in n_values:
    p_values = np.linspace(0.001, 0.3, 50)
    threshold = np.log(n) / n
    # Approximate: P(connected) ≈ sigmoid around threshold
    connectivity_prob = 1 / (1 + np.exp(-80 * (p_values - threshold)))
    ax4.plot(p_values, connectivity_prob, linewidth=2, label=f'n = {n}')
    ax4.axvline(x=threshold, color='gray', linestyle=':', alpha=0.3)

ax4.set_xlabel('Edge probability p', fontsize=11)
ax4.set_ylabel('P(connected) ≈ P(dim H⁰ = 1)', fontsize=11)
ax4.set_title('Phase Transition: Connectivity Threshold\n'
              'p* = ln(n)/n', fontsize=11, fontweight='bold')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)
ax4.set_xlim(0, 0.3)

plt.suptitle('Viral Information Topology: The Mathematics of Meme Virality',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('virality_landscape.png', dpi=150, bbox_inches='tight')
print("Saved virality_landscape.png")
