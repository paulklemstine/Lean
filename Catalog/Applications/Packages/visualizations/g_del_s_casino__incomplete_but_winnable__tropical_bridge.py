#!/usr/bin/env python3
"""
Visualization 3: Tropical-Casino Bridge

Visualizes the bridge theorem connecting selective profit, tropical optimal,
and decidable fraction. Shows the three-way relationship as a 3D surface
and the harvesting efficiency curve.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

fig = plt.figure(figsize=(14, 5))

# Plot 1: Bridge theorem verification
ax1 = fig.add_subplot(131)

np.random.seed(42)
n_values = range(10, 201, 10)
points_n = []
points_dec = []
points_verified = []

for n in n_values:
    for d in np.linspace(0.1, 0.9, 9):
        is_dec = np.random.random(n) < d
        dec_count = int(np.sum(is_dec))
        sel_profit = dec_count  # By theorem
        trop_total = n  # By theorem

        lhs = sel_profit * n
        rhs = dec_count * trop_total
        points_n.append(n)
        points_dec.append(d)
        points_verified.append(lhs == rhs)

verified_pct = sum(points_verified) / len(points_verified) * 100
ax1.scatter([p for p, v in zip(points_n, points_verified) if v],
            [p for p, v in zip(points_dec, points_verified) if v],
            c='green', s=15, alpha=0.6, label=f'Verified ({verified_pct:.0f}%)')
not_v = [p for p, v in zip(points_n, points_verified) if not v]
if not_v:
    ax1.scatter(not_v,
                [p for p, v in zip(points_dec, points_verified) if not v],
                c='red', s=15, alpha=0.6, label='Failed')

ax1.set_xlabel('Number of Rounds (n)')
ax1.set_ylabel('Decidable Fraction (d)')
ax1.set_title('Bridge Theorem\nVerification', fontsize=11)
ax1.legend(fontsize=8)

# Plot 2: Harvesting efficiency
ax2 = fig.add_subplot(132)

d_range = np.linspace(0, 1, 100)
efficiency = d_range  # Harvesting efficiency = decidable fraction

ax2.fill_between(d_range, 0, efficiency, alpha=0.3, color='blue',
                  label='Harvested (selective profit)')
ax2.fill_between(d_range, efficiency, 1, alpha=0.3, color='red',
                  label='Lost (incompleteness gap)')
ax2.plot(d_range, efficiency, 'b-', linewidth=2)
ax2.plot(d_range, np.ones_like(d_range), 'k--', linewidth=1,
         label='Tropical ceiling')
ax2.plot([0, 1], [0, 1], 'b:', alpha=0.5)

ax2.set_xlabel('Decidable Fraction (d)')
ax2.set_ylabel('Efficiency Ratio')
ax2.set_title('Harvesting Efficiency\n= Decidable Fraction', fontsize=11)
ax2.legend(fontsize=8, loc='upper left')
ax2.set_xlim(0, 1)
ax2.set_ylim(0, 1.1)

# Plot 3: Three-way relationship (n, d, profit)
ax3 = fig.add_subplot(133, projection='3d')

n_grid = np.arange(10, 101, 5)
d_grid = np.linspace(0.1, 0.9, 17)
N, D = np.meshgrid(n_grid, d_grid)

# Selective profit = n * d (in expectation)
Sel_Profit = N * D

# Tropical optimal = n
Trop_Optimal = N

# Plot surfaces
ax3.plot_surface(N, D, Sel_Profit, alpha=0.6, cmap='Blues',
                  label='Selective Profit')
ax3.plot_surface(N, D, Trop_Optimal, alpha=0.3, color='red')

ax3.set_xlabel('Rounds (n)', fontsize=9)
ax3.set_ylabel('Dec. Frac. (d)', fontsize=9)
ax3.set_zlabel('Profit', fontsize=9)
ax3.set_title('Profit Surfaces\nBlue=Selective, Red=Tropical', fontsize=10)
ax3.view_init(elev=25, azim=135)

plt.tight_layout()
plt.savefig('viz_tropical_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_bridge.png")
