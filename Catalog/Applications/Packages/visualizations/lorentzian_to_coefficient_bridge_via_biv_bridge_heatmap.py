#!/usr/bin/env python3
"""
Visualization 2: Lorentzian Bridge Heatmap

Heatmap showing the k-fold log-concavity depth achieved by bivariate
specializations of products of linear forms, as a function of degree d
and the number of ratio transform levels. Illustrates the main theorem:
recursive Lorentzianity of depth k => k-fold log-concavity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def product_coeffs(weights, d):
    """Compute bivariate specialization coefficients."""
    coeffs = [0.0] * (d + 1)
    for m in range(d + 1):
        total = 0.0
        for S in combinations(range(d), m):
            S_set = set(S)
            prod_val = 1.0
            for i in range(d):
                prod_val *= weights[i][0] if i in S_set else weights[i][1]
            total += prod_val
        coeffs[m] = total
    return coeffs


def find_max_depth(seq, max_k=30):
    """Find maximum k-fold log-concavity depth."""
    current = list(seq)
    if any(x <= 0 for x in current):
        return -1
    for k in range(max_k):
        if len(current) < 3:
            return k
        is_lc = all(current[m] ** 2 >= current[m - 1] * current[m + 1] - 1e-10
                     for m in range(1, len(current) - 1))
        if not is_lc:
            return k
        ratios = [current[m + 1] / current[m] for m in range(len(current) - 1)]
        if any(x <= 0 for x in ratios):
            return k + 1
        current = ratios
    return max_k


# Compute depths for various degrees and trials
degrees = list(range(3, 16))
num_trials = 20
depth_matrix = np.zeros((len(degrees), num_trials))

for i, d in enumerate(degrees):
    for trial in range(num_trials):
        np.random.seed(1000 * d + trial)
        weights = [(np.random.uniform(0.3, 4.0), np.random.uniform(0.3, 4.0))
                   for _ in range(d)]
        coeffs = product_coeffs(weights, d)
        depth = find_max_depth(coeffs)
        depth_matrix[i, trial] = depth

# Create figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Heatmap
im = ax1.imshow(depth_matrix, aspect='auto', cmap='YlOrRd',
                interpolation='nearest')
ax1.set_xlabel("Trial index", fontsize=12)
ax1.set_ylabel("Degree d", fontsize=12)
ax1.set_yticks(range(len(degrees)))
ax1.set_yticklabels(degrees)
ax1.set_title("k-Fold Log-Concavity Depth\n(products of random positive linear forms)",
              fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax1, label='Depth k')

# Panel 2: Depth vs degree with theoretical bound
mean_depths = depth_matrix.mean(axis=1)
min_depths = depth_matrix.min(axis=1)
max_depths = depth_matrix.max(axis=1)
theoretical = [d - 2 for d in degrees]

ax2.fill_between(degrees, min_depths, max_depths, alpha=0.3, color='steelblue',
                 label='Range across trials')
ax2.plot(degrees, mean_depths, 'o-', color='steelblue', linewidth=2,
         markersize=6, label='Mean depth')
ax2.plot(degrees, theoretical, 's--', color='firebrick', linewidth=2,
         markersize=6, label='Theoretical bound d−2')
ax2.set_xlabel("Degree d", fontsize=12)
ax2.set_ylabel("k-fold depth", fontsize=12)
ax2.set_title("Achieved vs Theoretical Bound", fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig("viz_bridge_heatmap.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_bridge_heatmap.png")
