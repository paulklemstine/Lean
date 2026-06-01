#!/usr/bin/env python3
"""
Visualization: Erdős's Ramsey Lower Bounds

Shows the exponential growth of the Erdős bound R(k,k) > 2^{k/2}
alongside known Ramsey numbers.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, floor

def erdos_bound(k):
    return floor(2 ** (k / 2))

def erdos_expected_mono(n, k):
    """Expected number of monochromatic k-cliques in random 2-coloring of K_n."""
    return 2 * comb(n, k) * 2 ** (-comb(k, 2))

# Known Ramsey numbers
known_R = {3: 6, 4: 18}
known_R_lower = {5: 43, 6: 102, 7: 205, 8: 282, 9: 565}
known_R_upper = {5: 48, 6: 165, 7: 540, 8: 1870, 9: 6588}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Erdős bound vs known values
ax1 = axes[0]
ks = range(3, 10)
erdos_bounds = [erdos_bound(k) for k in ks]
ax1.semilogy(list(ks), erdos_bounds, 'bo-', linewidth=2, markersize=8, label='Erdős bound 2^{k/2}')

# Known exact values
exact_k = [3, 4]
exact_R = [known_R[k] for k in exact_k]
ax1.semilogy(exact_k, exact_R, 'r^', markersize=12, label='Known R(k,k)')

# Known ranges
for k in range(5, 10):
    ax1.semilogy([k, k], [known_R_lower[k], known_R_upper[k]], 'g-', linewidth=3, alpha=0.7)
    ax1.semilogy(k, known_R_lower[k], 'gv', markersize=8)
    ax1.semilogy(k, known_R_upper[k], 'g^', markersize=8)

ax1.semilogy([5], [known_R_lower[5]], 'gv', markersize=8, label='Known range')

ax1.set_xlabel('k', fontsize=14)
ax1.set_ylabel('R(k,k)', fontsize=14)
ax1.set_title("Erdős's Ramsey Lower Bound", fontsize=16)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Expected monochromatic cliques
ax2 = axes[1]
for k in [3, 4, 5]:
    ns = range(2, 30)
    expected = [erdos_expected_mono(n, k) for n in ns]
    ax2.semilogy(list(ns), expected, linewidth=2, label=f'k={k}')
    # Mark where expected = 1
    threshold_n = erdos_bound(k)
    ax2.axvline(x=threshold_n, color='gray', linestyle='--', alpha=0.5)

ax2.axhline(y=1, color='red', linestyle='-', linewidth=1.5, alpha=0.7, label='Threshold = 1')
ax2.set_xlabel('n (number of vertices)', fontsize=14)
ax2.set_ylabel('Expected monochromatic K_k', fontsize=14)
ax2.set_title('First Moment Method: E[mono K_k] vs n', fontsize=16)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(1e-3, 1e8)

plt.tight_layout()
plt.savefig('ramsey_bounds.png', dpi=150, bbox_inches='tight')
print("Saved ramsey_bounds.png")
