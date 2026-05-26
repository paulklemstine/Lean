#!/usr/bin/env python3
"""
Visualization 1: Affected Derivative Node Heatmap

Visualizes the affected derivative profile for different monomial exponent
vectors α, showing how sparse monomials produce fewer affected nodes.
This is the visual manifestation of the Locality Theorem: only derivative
directions coordinatewise dominated by α are affected by a rank-1 update.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as iterproduct


def affected_count_dp(alpha, k):
    """Count affected multiindices using dynamic programming."""
    n = len(alpha)
    if k < 0:
        return 0
    dp = [0] * (k + 1)
    dp[0] = 1
    for i in range(n):
        new_dp = [0] * (k + 1)
        for j in range(k + 1):
            if dp[j] == 0:
                continue
            for v in range(min(alpha[i], k - j) + 1):
                new_dp[j + v] += dp[j]
        dp = new_dp
    return dp[k]


def total_multiindex_count(n, k):
    """Stars and bars: C(n+k-1, k)."""
    from math import comb
    if n == 0 and k == 0:
        return 1
    if n == 0:
        return 0
    return comb(n + k - 1, k)


# Parameters
n = 6
d = 6

# Different monomial shapes
alphas = {
    'Uniform\n(1,1,1,1,1,1)': (1, 1, 1, 1, 1, 1),
    'Concentrated\n(3,2,1,0,0,0)': (3, 2, 1, 0, 0, 0),
    'Sparse\n(6,0,0,0,0,0)': (6, 0, 0, 0, 0, 0),
    'Balanced\n(2,2,2,0,0,0)': (2, 2, 2, 0, 0, 0),
    'Spread\n(2,1,1,1,1,0)': (2, 1, 1, 1, 1, 0),
}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Affected counts by depth
ax1 = axes[0]
depths = list(range(d - 1))
for label, alpha in alphas.items():
    counts = [affected_count_dp(alpha, k) for k in depths]
    ax1.plot(depths, counts, 'o-', label=label.replace('\n', ' '), linewidth=2, markersize=6)

# Add total (unaffected) counts
total_counts = [total_multiindex_count(n, k) for k in depths]
ax1.plot(depths, total_counts, 'k--', label='Total (all β)', linewidth=1.5, alpha=0.5)

ax1.set_xlabel('Derivative Depth k', fontsize=12)
ax1.set_ylabel('Number of Affected Nodes', fontsize=12)
ax1.set_title('Affected Node Counts by Depth', fontsize=13)
ax1.legend(fontsize=9)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Plot 2: Total affected fraction (dynamic cost savings)
ax2 = axes[1]
labels = list(alphas.keys())
total_affected = []
total_possible = sum(total_multiindex_count(n, k) for k in depths)

for label, alpha in alphas.items():
    ta = sum(affected_count_dp(alpha, k) for k in depths)
    total_affected.append(ta)

fractions = [ta / total_possible for ta in total_affected]
short_labels = [l.split('\n')[0] for l in labels]
colors = plt.cm.viridis([0.1, 0.3, 0.5, 0.7, 0.9])
bars = ax2.bar(short_labels, fractions, color=colors, edgecolor='black', linewidth=0.5)

ax2.set_ylabel('Fraction of Nodes Affected', fontsize=12)
ax2.set_title('Dynamic Update Cost as Fraction of Rebuild', fontsize=13)
ax2.set_ylim(0, 1.05)
ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Full rebuild')
ax2.legend(fontsize=10)

# Add value labels on bars
for bar, frac in zip(bars, fractions):
    ax2.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.02,
             f'{frac:.1%}', ha='center', va='bottom', fontsize=10)

plt.suptitle('Locality of Rank-1 Updates in Certificate Trees\n'
             f'(n={n} variables, degree d={d})', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_affected_nodes.png', dpi=150, bbox_inches='tight')
print("Saved viz_affected_nodes.png")
