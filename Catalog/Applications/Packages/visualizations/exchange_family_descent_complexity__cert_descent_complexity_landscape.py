#!/usr/bin/env python3
"""
Visualization: Exchange Family Descent Landscape

Visualizes the descent complexity landscape across different exchange families,
showing how worst-case descent length scales with dimension and certificate depth.
This illustrates the core gap phenomenon between theoretical bounds and actual complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Exchange Family Descent Complexity Landscape", fontsize=16, fontweight='bold')

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 1: Theoretical upper bounds d^k for various k
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax1 = axes[0, 0]
dims = np.arange(2, 12)
for k in range(1, 5):
    bounds = dims ** k
    ax1.semilogy(dims, bounds, 'o-', label=f'k={k}: d^{k}', linewidth=2, markersize=5)

ax1.set_xlabel('Dimension d', fontsize=12)
ax1.set_ylabel('Upper Bound (log scale)', fontsize=12)
ax1.set_title('Certificate Depth Bounds: d^k', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 2: Product tensorization — WDL grows linearly
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax2 = axes[0, 1]
n_copies = np.arange(1, 11)
base_wdl_values = [3, 5, 8, 12]
colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(base_wdl_values)))

for wdl, color in zip(base_wdl_values, colors):
    product_wdl = n_copies * wdl
    ax2.plot(n_copies, product_wdl, 's-', color=color, label=f'WDL₀={wdl}',
             linewidth=2, markersize=6)

ax2.set_xlabel('Number of Copies n', fontsize=12)
ax2.set_ylabel('Product WDL', fontsize=12)
ax2.set_title('Product Additivity: WDL(F^n) = n · WDL(F)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 3: Amplification profile — monotone step function
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax3 = axes[1, 0]

# Simulate amplification profiles for different families
dim = 4
depths = np.arange(0, 6)

# Family 1: measures = [1, 4, 16, 64]
measures_1 = [1, 4, 16, 64]
profile_1 = []
for k in depths:
    bound = dim ** k
    filtered = [m for m in measures_1 if m <= bound]
    profile_1.append(max(filtered) if filtered else 0)

# Family 2: measures = [0, 2, 5, 10]
measures_2 = [0, 2, 5, 10]
profile_2 = []
for k in depths:
    bound = dim ** k
    filtered = [m for m in measures_2 if m <= bound]
    profile_2.append(max(filtered) if filtered else 0)

ax3.step(depths, profile_1, where='post', linewidth=2.5, label='High complexity family',
         color='crimson', marker='D', markersize=6)
ax3.step(depths, profile_2, where='post', linewidth=2.5, label='Low complexity family',
         color='steelblue', marker='o', markersize=6)
ax3.fill_between(depths, 0, profile_1, alpha=0.1, color='crimson', step='post')
ax3.fill_between(depths, 0, profile_2, alpha=0.1, color='steelblue', step='post')

ax3.set_xlabel('Certificate Depth k', fontsize=12)
ax3.set_ylabel('Amplification Profile', fontsize=12)
ax3.set_title('Certificate Amplification Profiles', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 4: Entropy-complexity bridge
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax4 = axes[1, 1]

# For injective measures: card(State) ≤ WDL + 1
wdl_range = np.arange(1, 25)
max_states = wdl_range + 1

ax4.fill_between(wdl_range, 0, max_states, alpha=0.2, color='green',
                 label='Feasible region')
ax4.plot(wdl_range, max_states, 'g-', linewidth=2.5, label='Bound: N ≤ WDL + 1')

# Example families
examples = [
    (5, 4, "Matroid"),
    (8, 8, "Simplex"),
    (15, 10, "Max states"),
    (3, 3, "Tight"),
    (20, 20, "Identity"),
]
for wdl, n, name in examples:
    color = 'darkgreen' if n <= wdl + 1 else 'red'
    ax4.plot(wdl, n, 'o', color=color, markersize=10, zorder=5)
    ax4.annotate(name, (wdl, n), textcoords="offset points",
                 xytext=(8, 5), fontsize=9)

ax4.set_xlabel('Worst Descent Length (WDL)', fontsize=12)
ax4.set_ylabel('Number of States N', fontsize=12)
ax4.set_title('Entropy Bridge: N ≤ WDL + 1 (injective)', fontsize=13)
ax4.legend(fontsize=10, loc='upper left')
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("descent_landscape.png", dpi=150, bbox_inches='tight')
print("Saved descent_landscape.png")
