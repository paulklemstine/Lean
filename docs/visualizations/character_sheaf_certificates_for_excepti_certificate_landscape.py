#!/usr/bin/env python3
"""
Visualization: Certificate Landscape

Shows the relationship between the certificate parameters C and q and
the resulting expansion guarantees. Displays the "expansion region"
where C < q guarantees positive Cheeger constant.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Expansion region in (q, C) space
ax1 = axes[0]
q_range = np.linspace(2, 50, 200)
C_range = np.linspace(0, 50, 200)
Q, CC = np.meshgrid(q_range, C_range)

# Cheeger bound = (1 - C/q) / 2 when C < q, else 0
cheeger = np.where(CC < Q, (1 - CC/Q) / 2, 0)

im = ax1.contourf(Q, CC, cheeger, levels=20, cmap='YlGn')
plt.colorbar(im, ax=ax1, label='Cheeger bound h')

# Boundary: C = q (expansion threshold)
ax1.plot(q_range, q_range, 'r-', linewidth=2, label='C = q (threshold)')

# Mark exceptional group constants
exceptional_data = {
    'G₂': (2.0, 'blue'),
    'F₄': (3.5, 'orange'),
    'E₆': (5.0, 'green'),
    'E₈': (8.0, 'purple'),
}

for name, (C_val, color) in exceptional_data.items():
    ax1.axhline(y=C_val, color=color, linestyle='--', alpha=0.7, linewidth=1.5)
    ax1.text(45, C_val + 0.5, name, color=color, fontsize=10, fontweight='bold')

ax1.set_xlabel('Field size q', fontsize=12)
ax1.set_ylabel('Bounding constant C', fontsize=12)
ax1.set_title('Certificate Landscape\n(Green = expansion region)', fontsize=13)
ax1.legend(fontsize=10, loc='upper left')
ax1.set_xlim(2, 50)
ax1.set_ylim(0, 50)

# Plot 2: Cheeger bound for different exceptional groups
ax2 = axes[1]
q_vals = np.arange(3, 101)

for name, (C_val, color) in exceptional_data.items():
    cheeger_vals = np.maximum(0, (1 - C_val / q_vals) / 2)
    ax2.plot(q_vals, cheeger_vals, '-', color=color, linewidth=2, label=f'{name} (C={C_val})')

ax2.axhline(y=0.25, color='gray', linestyle=':', alpha=0.5, label='h = 1/4')
ax2.set_xlabel('Field size q', fontsize=12)
ax2.set_ylabel('Certified Cheeger bound h', fontsize=12)
ax2.set_title('Expansion Guarantees by Group Type\n(Conjectured constants)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.05, 0.55)

plt.tight_layout()
plt.savefig('certificate_landscape_plot.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved certificate_landscape_plot.png")
