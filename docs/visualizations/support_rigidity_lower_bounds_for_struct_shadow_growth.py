#!/usr/bin/env python3
"""
Visualization 1: Shadow Growth vs Quadratic Bound

Visualizes the quadratic growth of the second-derivative shadow size
for the degree-4 elementary symmetric polynomial family, compared to
the theoretical lower bound n*(n-1)/2. This directly illustrates the
support rigidity theorem: shadow size grows quadratically with n.
"""

import itertools
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_shadow_size(n: int) -> int:
    """Compute |shadow(e_4 over n variables)| = C(n,2)."""
    quads = list(itertools.combinations(range(n), 4))
    shadow = set()
    for q in quads:
        for pair in itertools.combinations(q, 2):
            shadow.add(pair)
    return len(shadow)


# Compute data
ns = list(range(4, 21))
shadow_sizes = [compute_shadow_size(n) for n in ns]
lower_bounds = [n * (n - 1) // 2 for n in ns]
support_sizes = [math.comb(n, 4) for n in ns]

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Shadow size vs lower bound
ax1 = axes[0]
ax1.plot(ns, shadow_sizes, 'o-', color='#2196F3', linewidth=2,
         markersize=8, label='Shadow size |shadow(e₄)|', zorder=3)
ax1.plot(ns, lower_bounds, 's--', color='#F44336', linewidth=2,
         markersize=6, label='Lower bound n(n-1)/2', zorder=2)
ax1.fill_between(ns, 0, lower_bounds, alpha=0.1, color='#F44336')
ax1.set_xlabel('Number of variables n', fontsize=13)
ax1.set_ylabel('Cardinality', fontsize=13)
ax1.set_title('Quadratic Shadow Growth', fontsize=15, fontweight='bold')
ax1.legend(fontsize=11, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(3.5, 20.5)

# Right panel: Shadow / Support ratio
ax2 = axes[1]
ratios = [s / sup if sup > 0 else 0 for s, sup in zip(shadow_sizes, support_sizes)]
ax2.bar(ns, ratios, color='#4CAF50', alpha=0.7, edgecolor='#2E7D32', linewidth=1.5)
ax2.set_xlabel('Number of variables n', fontsize=13)
ax2.set_ylabel('|Shadow| / |Support|', fontsize=13)
ax2.set_title('Shadow-to-Support Ratio', fontsize=15, fontweight='bold')
ax2.grid(True, alpha=0.3, axis='y')
ax2.set_xlim(3.5, 20.5)

# Add annotation
ax2.annotate(
    'Ratio → 0 as n → ∞\n(shadow is much smaller\nthan support)',
    xy=(15, ratios[11]), xytext=(12, max(ratios) * 0.7),
    fontsize=10, ha='center',
    arrowprops=dict(arrowstyle='->', color='gray'),
    bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', edgecolor='gray')
)

plt.tight_layout()
plt.savefig('shadow_growth.png', dpi=150, bbox_inches='tight')
print("Saved shadow_growth.png")
