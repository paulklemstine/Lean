#!/usr/bin/env python3
"""
Visualization: Complexity Phase Transition for Lorentzian Recognition

Shows the phase transition from polynomial (fixed degree) to exponential
(unbounded degree) certificate complexity. Creates a heatmap of log₂(leaves)
across (n, d) parameter space, with the exponential diagonal highlighted.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2


def multiindex_count(n, d):
    """Number of multiindices of weight d in n variables."""
    if n <= 0 or d < 0:
        return 0
    return comb(n + d - 1, d)


def number_of_quadratic_leaves(n, d):
    """Number of quadratic leaves in Lorentzian recognition tree."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


# Build the data grid
max_param = 20
ns = list(range(2, max_param + 1))
ds = list(range(2, max_param + 1))

log_leaves = np.zeros((len(ds), len(ns)))
for i, d in enumerate(ds):
    for j, n in enumerate(ns):
        leaves = number_of_quadratic_leaves(n, d)
        log_leaves[i, j] = log2(max(leaves, 1))

# Create the figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left panel: Heatmap
ax1 = axes[0]
im = ax1.imshow(log_leaves, origin='lower', aspect='auto',
                cmap='inferno', interpolation='nearest',
                extent=[ns[0]-0.5, ns[-1]+0.5, ds[0]-0.5, ds[-1]+0.5])
ax1.set_xlabel('Number of Variables (n)', fontsize=13)
ax1.set_ylabel('Degree (d)', fontsize=13)
ax1.set_title('log₂(Quadratic Leaves) — Certificate Complexity', fontsize=14)
cbar = plt.colorbar(im, ax=ax1, label='log₂(number of leaves)')

# Draw the phase transition diagonal d = n+1
diag_ns = np.array(ns, dtype=float)
diag_ds = diag_ns + 1
mask = (diag_ds >= ds[0]) & (diag_ds <= ds[-1])
ax1.plot(diag_ns[mask], diag_ds[mask], 'w--', linewidth=2, label='d = n+1 (hard regime)')
ax1.legend(loc='upper left', fontsize=11, facecolor='black', labelcolor='white')

# Right panel: Growth curves
ax2 = axes[1]
ms = list(range(1, 16))
lower_bounds = [2**m for m in ms]
exact_counts = [comb(2*m, m) for m in ms]
upper_bounds = [(m+1)**m for m in ms]

ax2.semilogy(ms, lower_bounds, 'b-o', linewidth=2, markersize=6, label='Lower bound: 2^m')
ax2.semilogy(ms, exact_counts, 'r-s', linewidth=2, markersize=6, label='Exact: C(2m, m)')
ax2.semilogy(ms, upper_bounds, 'g-^', linewidth=2, markersize=6, label='Upper bound: (m+1)^m')

# Reference lines
ax2.semilogy(ms, [4**m / np.sqrt(np.pi * m) for m in ms], 'r--', alpha=0.5,
             linewidth=1, label='Asymptotic: 4^m/√(πm)')

ax2.set_xlabel('Parameter m (where n=m+1, d=m+2)', fontsize=13)
ax2.set_ylabel('Number of Quadratic Leaves', fontsize=13)
ax2.set_title('Exponential Growth Along the Phase Transition', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, 15.5)

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")
