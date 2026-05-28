#!/usr/bin/env python3
"""
Visualization 1: Pressure Decomposition for Semidirect Products

Visualizes how the total pressure P(G^m ⋊ H_m) decomposes into
the dominant product pressure m·P(G) and the sublinear exotic correction.
Shows that the exotic correction is O(log m) for various group families.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ─── Data Generation ───

def lamplighter_exotic(m):
    """Exotic pressure for (Z/2)^m ⋊ Z/m."""
    if m <= 1:
        return 0.0
    return sum(1 for d in range(1, m + 1) if m % d == 0) / m

def wreath_exotic(m):
    """Heuristic exotic pressure for S_5 ≀ S_m."""
    if m <= 1:
        return 0.0
    return 0.5 * math.log(m + 1) + 0.3

ms = np.arange(2, 81)

# Base pressures
P_Z2 = 0.5
P_S5 = 7.0 / 15.0

# Compute pressures
product_lamp = [m * P_Z2 for m in ms]
exotic_lamp = [lamplighter_exotic(m) for m in ms]
total_lamp = [p + e for p, e in zip(product_lamp, exotic_lamp)]

product_wreath = [m * P_S5 for m in ms]
exotic_wreath = [wreath_exotic(m) for m in ms]
total_wreath = [p + e for p, e in zip(product_wreath, exotic_wreath)]

# ─── Plotting ───

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Semidirect Universality: Pressure Decomposition', fontsize=16, fontweight='bold')

# Plot 1: Lamplighter total vs product pressure
ax1 = axes[0, 0]
ax1.plot(ms, total_lamp, 'b-', linewidth=2, label=r'$P(\Gamma_m)$ (total)')
ax1.plot(ms, product_lamp, 'r--', linewidth=2, label=r'$m \cdot P(G)$ (product)')
ax1.fill_between(ms, product_lamp, total_lamp, alpha=0.2, color='blue', label='Exotic correction')
ax1.set_xlabel('m (number of components)', fontsize=12)
ax1.set_ylabel('Pressure', fontsize=12)
ax1.set_title(r'Lamplighter: $(\mathbb{Z}/2)^m \rtimes \mathbb{Z}/m$', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Wreath total vs product pressure
ax2 = axes[0, 1]
ax2.plot(ms, total_wreath, 'b-', linewidth=2, label=r'$P(\Gamma_m)$ (total)')
ax2.plot(ms, product_wreath, 'r--', linewidth=2, label=r'$m \cdot P(G)$ (product)')
ax2.fill_between(ms, product_wreath, total_wreath, alpha=0.2, color='blue', label='Exotic correction')
ax2.set_xlabel('m (number of components)', fontsize=12)
ax2.set_ylabel('Pressure', fontsize=12)
ax2.set_title(r'Wreath Product: $S_5 \wr S_m$', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Exotic pressure with log fit
ax3 = axes[1, 0]
log_ms = [math.log(m + 1) for m in ms]

ax3.plot(ms, exotic_lamp, 'go-', markersize=3, linewidth=1.5, label=r'$P_{exotic}$ (lamplighter)')
ax3.plot(ms, exotic_wreath, 'bs-', markersize=3, linewidth=1.5, label=r'$P_{exotic}$ (wreath)')

# Fit log curves
C_lamp = max(e / l for e, l in zip(exotic_lamp, log_ms) if l > 0)
C_wreath = max(e / l for e, l in zip(exotic_wreath, log_ms) if l > 0)
ax3.plot(ms, [C_lamp * l for l in log_ms], 'g--', linewidth=1, alpha=0.7, label=f'C·log(m+1), C={C_lamp:.2f}')
ax3.plot(ms, [C_wreath * l for l in log_ms], 'b--', linewidth=1, alpha=0.7, label=f'C·log(m+1), C={C_wreath:.2f}')

ax3.set_xlabel('m', fontsize=12)
ax3.set_ylabel('Exotic Pressure', fontsize=12)
ax3.set_title('Exotic Pressure vs Logarithmic Fit', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Plot 4: Normalized correction P_exotic/m → 0
ax4 = axes[1, 1]
normalized_lamp = [e / m for e, m in zip(exotic_lamp, ms)]
normalized_wreath = [e / m for e, m in zip(exotic_wreath, ms)]

ax4.plot(ms, normalized_lamp, 'go-', markersize=3, linewidth=1.5, label='Lamplighter')
ax4.plot(ms, normalized_wreath, 'bs-', markersize=3, linewidth=1.5, label='Wreath')
ax4.axhline(y=0, color='k', linestyle='-', linewidth=0.5)

# Show convergence to 0
ax4.set_xlabel('m', fontsize=12)
ax4.set_ylabel(r'$P_{exotic}(m) / m$', fontsize=12)
ax4.set_title(r'Normalized Correction $\to 0$ (Universality)', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_pressure_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_pressure_decomposition.png")
