#!/usr/bin/env python3
"""
Visualization: Entropy-Energy Phase Diagram

Shows the entropy-energy landscape for subgroup families. The key insight
is that pressure decays when energy (index exponent b) dominates entropy
(count exponent a), specifically when a < 2b. This creates a phase transition
in the (a, b) plane between the "generating" regime (pressure → 0) and
the "non-generating" regime (pressure stays positive).
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Entropy-Energy Phase Diagram for Subgroup Pressure', 
             fontsize=15, fontweight='bold')

# Plot 1: Phase diagram in (a, b) plane
ax1 = axes[0]
a_vals = np.linspace(0, 3, 300)
b_vals = np.linspace(0, 2, 300)
A, B = np.meshgrid(a_vals, b_vals)
# Pressure exponent = 2b - a. Positive → decay, negative → growth
exponent = 2 * B - A

# Color map: green for decay (exponent > 0), red for growth
im = ax1.contourf(A, B, exponent, levels=np.linspace(-3, 3, 25),
                   cmap='RdYlGn', extend='both')
ax1.contour(A, B, exponent, levels=[0], colors='black', linewidths=2)
ax1.plot([0, 3], [0, 1.5], 'k-', linewidth=2, label='Critical line a = 2b')

# Mark known group families
# PSL₂(p): a ≈ 2, b ≈ 1 → exponent ≈ 0 (borderline)
ax1.plot(2, 1, 'wo', markersize=12, markeredgecolor='black', markeredgewidth=2)
ax1.annotate('PSL₂(p)\n(a≈2, b≈1)', xy=(2, 1), xytext=(2.3, 0.6),
            fontsize=10, ha='left',
            arrowprops=dict(arrowstyle='->', color='black'))

# Alternating groups: a ≈ 1, b ≈ 1 → exponent ≈ 1
ax1.plot(1, 1, 'w^', markersize=12, markeredgecolor='blue', markeredgewidth=2)
ax1.annotate('Aₙ\n(a≈1, b≈1)', xy=(1, 1), xytext=(0.2, 1.5),
            fontsize=10, ha='left',
            arrowprops=dict(arrowstyle='->', color='blue'))

# Sporadic: a ≈ 0, b ≈ 0.5 → exponent ≈ 1
ax1.plot(0.3, 0.7, 'ws', markersize=12, markeredgecolor='purple', markeredgewidth=2)
ax1.annotate('Sporadic\n(small a,b)', xy=(0.3, 0.7), xytext=(0.5, 0.2),
            fontsize=10, ha='left',
            arrowprops=dict(arrowstyle='->', color='purple'))

cbar = plt.colorbar(im, ax=ax1)
cbar.set_label('Pressure exponent (2b - a)', fontsize=11)
ax1.set_xlabel('Entropy exponent a (log|F| / log|G|)', fontsize=12)
ax1.set_ylabel('Energy exponent b (log D / log|G|)', fontsize=12)
ax1.set_title('Phase Diagram: Generating vs Non-Generating', fontsize=13)
ax1.text(0.5, 1.7, 'GENERATING\n(pressure → 0)', fontsize=12, 
         ha='center', color='darkgreen', fontweight='bold')
ax1.text(2.5, 0.3, 'NON-GEN\n(pressure ≫ 0)', fontsize=12, 
         ha='center', color='darkred', fontweight='bold')

# Plot 2: Pressure as function of group order for different exponents
ax2 = axes[1]
orders = np.logspace(2, 12, 100)

for a, b, label, color, style in [
    (1.0, 1.0, '2b-a = 1.0', 'green', '-'),
    (1.5, 1.0, '2b-a = 0.5', 'blue', '-'),
    (2.0, 1.0, '2b-a = 0.0', 'orange', '--'),
    (2.5, 1.0, '2b-a = -0.5', 'red', ':'),
]:
    exponent = a - 2 * b
    pressures = orders ** exponent
    ax2.loglog(orders, pressures, color=color, linestyle=style, 
               linewidth=2, label=label)

ax2.set_xlabel('Group order |G|', fontsize=12)
ax2.set_ylabel('Pressure bound C·|G|^(a-2b)', fontsize=12)
ax2.set_title('Pressure Decay vs Group Order', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, which='both')
ax2.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax2.set_ylim(1e-6, 1e6)
ax2.text(1e4, 2, 'pressure = 1', fontsize=9, color='gray')

plt.tight_layout()
plt.savefig('entropy_energy_phase.png', dpi=150, bbox_inches='tight')
print("Saved entropy_energy_phase.png")
