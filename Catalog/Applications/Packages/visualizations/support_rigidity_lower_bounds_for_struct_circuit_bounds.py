#!/usr/bin/env python3
"""
Visualization 2: Circuit Lower Bounds from Support Rigidity

Visualizes how support rigidity translates into depth-3 nonneg circuit
lower bounds for different gate fan-in bounds. Shows the tradeoff
between gate complexity and circuit size, illustrating the main
complexity-theoretic theorem.
"""

import itertools
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def shadow_size(n: int) -> int:
    """Shadow size for degree-4 family = C(n,2)."""
    return n * (n - 1) // 2


def circuit_lower_bound(n: int, B: int) -> int:
    """Lower bound on number of multiplication gates."""
    return shadow_size(n) // B if B > 0 else 0


# Compute data
ns = np.arange(4, 25)
gate_bounds = [1, 3, 6, 10, 15]
colors = ['#E53935', '#FB8C00', '#43A047', '#1E88E5', '#8E24AA']

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Lower bounds for different B
ax1 = axes[0]
for B, color in zip(gate_bounds, colors):
    bounds = [circuit_lower_bound(n, B) for n in ns]
    ax1.plot(ns, bounds, 'o-', color=color, linewidth=2, markersize=5,
             label=f'B = {B}', alpha=0.85)

# Reference quadratic
ax1.plot(ns, [n**2 // 12 for n in ns], 'k--', linewidth=1.5,
         alpha=0.4, label='n²/12 reference')

ax1.set_xlabel('Number of variables n', fontsize=13)
ax1.set_ylabel('Minimum multiplication gates', fontsize=13)
ax1.set_title('Depth-3 Circuit Lower Bounds\nvs. Gate Shadow Bound B', 
              fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, title='Max shadow/gate', title_fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_yscale('log')
ax1.set_xlim(3.5, 24.5)

# Right panel: Heatmap of lower bounds
ax2 = axes[1]
B_range = list(range(1, 16))
n_range = list(range(4, 20))
heatmap_data = np.array([
    [circuit_lower_bound(n, B) for B in B_range]
    for n in n_range
])

im = ax2.imshow(heatmap_data, aspect='auto', cmap='YlOrRd',
                origin='lower', interpolation='nearest')
ax2.set_xticks(range(len(B_range)))
ax2.set_xticklabels(B_range)
ax2.set_yticks(range(0, len(n_range), 2))
ax2.set_yticklabels([n_range[i] for i in range(0, len(n_range), 2)])
ax2.set_xlabel('Max shadow per gate (B)', fontsize=13)
ax2.set_ylabel('Number of variables (n)', fontsize=13)
ax2.set_title('Circuit Cost Lower Bound\nHeatmap', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax2, label='Min gates needed')

plt.tight_layout()
plt.savefig('circuit_bounds.png', dpi=150, bbox_inches='tight')
print("Saved circuit_bounds.png")
