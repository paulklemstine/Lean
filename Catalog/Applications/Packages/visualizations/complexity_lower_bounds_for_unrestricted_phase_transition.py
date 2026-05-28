#!/usr/bin/env python3
"""
Visualization: Complexity Phase Transition for Lorentzian Recognition

Plots the certificate complexity (quadratic leaf count) as a function of
the number of variables n, for different degree regimes:
- Fixed degree (polynomial growth)
- Degree proportional to n (exponential growth)

This visualizes the central theorem: the phase transition between
polynomial and exponential certificate complexity.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb, log2


def multiindex_count(n, d):
    """Number of multiindices of weight d in n variables."""
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n, d):
    """Number of quadratic leaves for degree d in n variables."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: log-scale comparison
ax1 = axes[0]
ns = list(range(3, 26))

# Fixed degree regimes
for d in [4, 6, 8]:
    leaves = [quadratic_leaf_count(n, d) for n in ns]
    ax1.semilogy(ns, leaves, 'o-', label=f'Fixed d={d} (≤ n^{d-2})', markersize=4)

# Growing degree regime: d = n
leaves_growing = [quadratic_leaf_count(n, n) for n in ns]
ax1.semilogy(ns, leaves_growing, 's-', color='red', linewidth=2.5,
             markersize=6, label='d = n (exponential)')

# Reference line: 2^n
ref_exp = [2**(n-2) for n in ns]
ax1.semilogy(ns, ref_exp, '--', color='darkred', alpha=0.5, label='2^(n-2) lower bound')

ax1.set_xlabel('Number of variables n', fontsize=12)
ax1.set_ylabel('Certificate complexity (leaf count)', fontsize=12)
ax1.set_title('Phase Transition: Fixed vs. Growing Degree', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Right panel: heatmap of certificate complexity
ax2 = axes[1]
n_range = list(range(2, 18))
d_range = list(range(2, 18))
data = np.zeros((len(d_range), len(n_range)))

for i, d in enumerate(d_range):
    for j, n in enumerate(n_range):
        val = quadratic_leaf_count(n, d)
        data[i, j] = log2(max(val, 1))

im = ax2.imshow(data, aspect='auto', cmap='YlOrRd', origin='lower',
                extent=[n_range[0]-0.5, n_range[-1]+0.5,
                        d_range[0]-0.5, d_range[-1]+0.5])

# Draw the phase transition line d = n
ax2.plot(n_range, n_range, 'w--', linewidth=2, label='d = n (transition)')
ax2.plot(n_range, [6]*len(n_range), 'w:', linewidth=1.5, label='d = 6 (fixed)')

plt.colorbar(im, ax=ax2, label='log₂(leaf count)')
ax2.set_xlabel('Number of variables n', fontsize=12)
ax2.set_ylabel('Degree d', fontsize=12)
ax2.set_title('Certificate Complexity Heatmap (log₂ scale)', fontsize=13)
ax2.legend(fontsize=9, loc='upper left')

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")
