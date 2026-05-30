#!/usr/bin/env python3
"""
Visualization: Product Tensorization and Complexity Growth

Shows how exchange family complexity grows under iterated products,
demonstrating the additive behavior of worst-case descent length and
the multiplicative growth of state space.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(figsize=(16, 6))
fig.suptitle("Product Tensorization: Complexity Amplification", fontsize=16, fontweight='bold')

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 1: 3D surface — WDL as function of (dim_F, dim_G)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax1 = fig.add_subplot(131, projection='3d')

d1 = np.arange(1, 8)
d2 = np.arange(1, 8)
D1, D2 = np.meshgrid(d1, d2)

# WDL of product = WDL(F) + WDL(G)
# Assume WDL(F) ~ d^2 for illustration
WDL_product = D1**2 + D2**2

surf = ax1.plot_surface(D1, D2, WDL_product, cmap='viridis', alpha=0.8, edgecolor='k', linewidth=0.3)
ax1.set_xlabel('dim(F)')
ax1.set_ylabel('dim(G)')
ax1.set_zlabel('WDL(F⊗G)')
ax1.set_title('Product WDL Surface')
fig.colorbar(surf, ax=ax1, shrink=0.5, pad=0.1)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 2: Iterated product dimension and WDL growth
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax2 = fig.add_subplot(132)

n_range = np.arange(1, 11)
base_dims = [2, 3, 4, 5]
colors = plt.cm.plasma(np.linspace(0.2, 0.8, len(base_dims)))

for d, color in zip(base_dims, colors):
    wdl_base = d ** 2  # Example: WDL ~ d²
    dims = n_range * d
    wdls = n_range * wdl_base

    ax2.plot(n_range, wdls, 'o-', color=color, linewidth=2,
             label=f'd₀={d}, WDL₀={wdl_base}', markersize=5)

ax2.set_xlabel('Number of Copies n', fontsize=12)
ax2.set_ylabel('WDL(F^⊗n)', fontsize=12)
ax2.set_title('Linear Growth: WDL(F^⊗n) = n·WDL(F)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 3: State space explosion vs linear WDL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax3 = fig.add_subplot(133)

n_range2 = np.arange(1, 9)
base_states = 4  # |State| for base family
base_wdl = 5

state_counts = base_states ** n_range2  # Multiplicative growth
wdl_values = n_range2 * base_wdl  # Additive growth

ax3_twin = ax3.twinx()

line1, = ax3.semilogy(n_range2, state_counts, 'rs-', linewidth=2.5,
                       markersize=8, label='|State^⊗n| (exponential)')
line2, = ax3_twin.plot(n_range2, wdl_values, 'b^-', linewidth=2.5,
                        markersize=8, label='WDL(F^⊗n) (linear)')

ax3.set_xlabel('Number of Copies n', fontsize=12)
ax3.set_ylabel('State Space Size (log)', fontsize=12, color='red')
ax3_twin.set_ylabel('Worst Descent Length', fontsize=12, color='blue')
ax3.set_title('State Explosion vs Linear WDL', fontsize=13)

lines = [line1, line2]
labels = [l.get_label() for l in lines]
ax3.legend(lines, labels, fontsize=9, loc='center left')
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("product_growth.png", dpi=150, bbox_inches='tight')
print("Saved product_growth.png")
