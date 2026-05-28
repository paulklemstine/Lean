#!/usr/bin/env python3
"""
Visualization: Phase Transition in Lorentzian Certificate Complexity

Shows the heatmap of log₂(certificate size) across the (n, d) parameter space,
revealing the sharp transition from polynomial (fixed degree) to exponential
(unbounded degree) certificate complexity.

This visualizes the central theorem: when degree grows with the number of variables,
the number of quadratic leaves in the recursive Lorentzian recognition tree
explodes exponentially.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2


def multiindex_count(n: int, d: int) -> int:
    if n <= 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n: int, d: int) -> int:
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


# Compute the heatmap data
n_max = 25
d_max = 25
data = np.zeros((d_max, n_max))

for n_idx in range(n_max):
    for d_idx in range(d_max):
        n = n_idx + 1
        d = d_idx + 1
        leaves = quadratic_leaf_count(n, d)
        data[d_idx, n_idx] = log2(leaves) if leaves > 0 else 0

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Heatmap
ax1 = axes[0]
im = ax1.imshow(data, origin='lower', aspect='auto', cmap='inferno',
                extent=[0.5, n_max + 0.5, 0.5, d_max + 0.5])
cbar = plt.colorbar(im, ax=ax1, label='log₂(certificate size)')
ax1.set_xlabel('Number of variables (n)', fontsize=12)
ax1.set_ylabel('Degree (d)', fontsize=12)
ax1.set_title('Certificate Complexity Landscape', fontsize=14, fontweight='bold')

# Draw phase boundary: d ≈ 2 log₂(n) + 2
ns = np.arange(2, n_max + 1)
boundary = 2 * np.log2(ns) + 4
ax1.plot(ns, boundary, 'w--', linewidth=2, label='Phase boundary')
ax1.plot(ns, ns + 1, 'c-', linewidth=2, alpha=0.7, label='d = n + 1 (exponential)')
ax1.legend(loc='upper left', fontsize=9, facecolor='black', 
           labelcolor='white', edgecolor='gray')

# Right: Growth curves
ax2 = axes[1]

# Fixed degree curves
for d in [4, 6, 8]:
    ns_plot = range(2, 26)
    leaves = [quadratic_leaf_count(n, d) for n in ns_plot]
    ax2.semilogy(list(ns_plot), leaves, '-', linewidth=2, label=f'd = {d} (fixed)')

# Growing degree curves
ns_grow = range(2, 20)
leaves_grow = [quadratic_leaf_count(n, n + 1) for n in ns_grow]
ax2.semilogy(list(ns_grow), leaves_grow, 'r-', linewidth=3, label='d = n+1 (growing)')

# Lower bound 2^(n-1)
ns_lb = range(2, 20)
lower = [2 ** (n - 1) for n in ns_lb]
ax2.semilogy(list(ns_lb), lower, 'r--', linewidth=2, alpha=0.6, label='2^(n-1) lower bound')

ax2.set_xlabel('Number of variables (n)', fontsize=12)
ax2.set_ylabel('Certificate size (log scale)', fontsize=12)
ax2.set_title('Growth Curves: Fixed vs. Growing Degree', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")
