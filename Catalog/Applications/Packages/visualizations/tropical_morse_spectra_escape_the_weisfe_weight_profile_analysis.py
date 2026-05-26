#!/usr/bin/env python3
"""
Visualization: Non-Uniform CFI Weight Profiles

Shows the canonical weight profile w(i) = 1/(2i+1) and its effect
on the tropical Morse filtration. Demonstrates how distinct weights
create unique critical values that make topological events distinguishable.

SELF-CONTAINED: does not import any local modules.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Weight profile
ax = axes[0]
ns = [5, 8, 12, 20]
for n in ns:
    xs = np.arange(n)
    ws = 1.0 / (2 * xs + 1)
    ax.plot(xs, ws, 'o-', label=f'n={n}', markersize=5, linewidth=1.5)

ax.set_xlabel('Edge index i', fontsize=12)
ax.set_ylabel('Weight w(i) = 1/(2i+1)', fontsize=12)
ax.set_title('CFI Weight Profile', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1.1)

# Panel 2: Weight distinctness heatmap
ax = axes[1]
n = 8
ws = np.array([1.0 / (2*i + 1) for i in range(n)])
diff_matrix = np.abs(ws[:, None] - ws[None, :])
im = ax.imshow(diff_matrix, cmap='YlOrRd', aspect='equal')
ax.set_xlabel('Edge j', fontsize=12)
ax.set_ylabel('Edge i', fontsize=12)
ax.set_title(f'Weight Distance |w(i)-w(j)| (n={n})', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, shrink=0.8)
ax.set_xticks(range(n))
ax.set_yticks(range(n))

# Panel 3: Cycle-death count vs n
ax = axes[2]
ns_range = range(3, 16)
cycle_single = [1] * len(ns_range)  # C_{2n} always has β₁ = 1
cycle_double = [2] * len(ns_range)  # 2×C_n always has β₁ = 2

ax.bar([n - 0.2 for n in ns_range], cycle_single, width=0.35,
       label='C$_{2n}$ (single cycle)', color='#2196F3', alpha=0.8)
ax.bar([n + 0.2 for n in ns_range], cycle_double, width=0.35,
       label='2×C$_n$ (two cycles)', color='#F44336', alpha=0.8)

ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Cycle-death count (= β₁)', fontsize=12)
ax.set_title('β₁ Gap Across All n', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_yticks([0, 1, 2, 3])
ax.grid(True, alpha=0.3, axis='y')

plt.suptitle('Non-Uniform Weights and Topological Separation',
             fontsize=15, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('weight_profile.png', dpi=150, bbox_inches='tight')
print("Saved weight_profile.png")
