#!/usr/bin/env python3
"""
Visualization: The ULC Counterexample Landscape

This script creates a heatmap showing where the naive Shadow-Hodge ULC
conjecture (with D = max degree) fails across different (n, r) pairs.

Green cells indicate the ULC inequality holds for all valid k.
Red cells indicate at least one k where it fails.
The diagonal (r = n) always passes (trivially).

This visualizes the counterexample theorem: conjecture_counterexample.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def check_ulc_all_k(n, r):
    """Check if ULC(D=r) holds for all valid k with a_k = C(n,k)."""
    for k in range(1, r):
        lhs = comb(n, k) ** 2 * comb(r, k - 1) * comb(r, k + 1)
        rhs = comb(n, k - 1) * comb(n, k + 1) * comb(r, k) ** 2
        if lhs < rhs:
            return False
    return True


def min_ulc_ratio(n, r):
    """Compute minimum ULC ratio across all valid k."""
    min_ratio = float('inf')
    for k in range(1, r):
        lhs = comb(n, k) ** 2 * comb(r, k - 1) * comb(r, k + 1)
        rhs = comb(n, k - 1) * comb(n, k + 1) * comb(r, k) ** 2
        if rhs > 0:
            ratio = lhs / rhs
            min_ratio = min(min_ratio, ratio)
    return min_ratio if min_ratio != float('inf') else 1.0


max_n = 15
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Pass/Fail heatmap
data_pass = np.full((max_n, max_n), np.nan)
for n in range(2, max_n + 1):
    for r in range(2, n + 1):
        passes = check_ulc_all_k(n, r)
        data_pass[n - 1, r - 1] = 1.0 if passes else 0.0

im1 = ax1.imshow(data_pass, cmap='RdYlGn', origin='lower',
                  extent=[0.5, max_n + 0.5, 0.5, max_n + 0.5],
                  vmin=0, vmax=1, aspect='equal')
ax1.set_xlabel('r (rank = max degree)', fontsize=12)
ax1.set_ylabel('n (ambient dimension)', fontsize=12)
ax1.set_title('ULC(D=r) for Uniform Matroid U(r,n)\nGreen = passes, Red = fails',
              fontsize=13)

# Mark the specific counterexample
ax1.plot(3, 4, 'k*', markersize=15, label='U(3,4) counterexample')
ax1.legend(fontsize=10, loc='upper left')

# Add diagonal line r = n
ax1.plot([0.5, max_n + 0.5], [0.5, max_n + 0.5], 'b--', alpha=0.5, label='r=n')

# Panel 2: Minimum ULC ratio heatmap
data_ratio = np.full((max_n, max_n), np.nan)
for n in range(2, max_n + 1):
    for r in range(2, n + 1):
        ratio = min_ulc_ratio(n, r)
        data_ratio[n - 1, r - 1] = ratio

im2 = ax2.imshow(data_ratio, cmap='RdYlGn', origin='lower',
                  extent=[0.5, max_n + 0.5, 0.5, max_n + 0.5],
                  vmin=0.5, vmax=1.5, aspect='equal')
ax2.set_xlabel('r (rank = max degree)', fontsize=12)
ax2.set_ylabel('n (ambient dimension)', fontsize=12)
ax2.set_title('Minimum ULC Ratio (< 1 means failure)\nDarker red = stronger failure',
              fontsize=13)

fig.colorbar(im2, ax=ax2, label='min ULC ratio', shrink=0.8)

# Mark threshold
ax2.plot(3, 4, 'k*', markersize=15)

plt.tight_layout()
plt.savefig('ulc_counterexample_landscape.png', dpi=150, bbox_inches='tight')
plt.close()

print("Counterexample landscape saved to ulc_counterexample_landscape.png")
