#!/usr/bin/env python3
"""
Visualization 3: Collision Index Theorem Illustration
======================================================

This visualization illustrates the proved theorem:
  Collision Index = 1 ⟺ Uniform edge sizes

It shows how the collision index varies as we interpolate between
uniform and heterogeneous edge-size distributions, and demonstrates
the information-theoretic interpretation: CI measures "determinism"
of the edge-size distribution.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import Counter


# ---- Inline helper ----

def compute_collision_index(sizes):
    """Compute collision index for a list of edge sizes."""
    if not sizes:
        return 1.0
    n = len(sizes)
    counts = Counter(sizes)
    return sum((c / n) ** 2 for c in counts.values())


def compute_heterogeneity(sizes):
    """Compute variance of edge sizes."""
    if not sizes:
        return 0.0
    mu = np.mean(sizes)
    return float(np.mean([(s - mu)**2 for s in sizes]))


# ---- Generate interpolation data ----

# Experiment: Start with 20 edges all of size 3, gradually change some to size 5
total_edges = 20
base_size = 3
other_size = 5

fractions_changed = np.linspace(0, 1, 50)
cis = []
hets = []
widths = []

for frac in fractions_changed:
    n_changed = int(round(frac * total_edges))
    n_base = total_edges - n_changed
    sizes = [base_size] * n_base + [other_size] * n_changed
    cis.append(compute_collision_index(sizes))
    hets.append(compute_heterogeneity(sizes))
    widths.append(max(sizes) - min(sizes) if len(set(sizes)) > 1 else 0)

# ---- Multi-size experiment ----
# Gradually distribute edges across {2, 3, 4, 5}
multi_cis = []
multi_hets = []
alphas = np.linspace(0, 1, 50)

for alpha in alphas:
    if alpha < 0.01:
        sizes = [3] * total_edges
    else:
        # Distribute more evenly as alpha increases
        n2 = int(alpha * total_edges * 0.25)
        n3 = int((1 - alpha) * total_edges * 0.5 + alpha * total_edges * 0.25)
        n4 = int(alpha * total_edges * 0.25)
        n5 = total_edges - n2 - n3 - n4
        sizes = [2] * n2 + [3] * n3 + [4] * n4 + [5] * max(0, n5)
    multi_cis.append(compute_collision_index(sizes))
    multi_hets.append(compute_heterogeneity(sizes))

# ---- Plot ----
fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Top left: CI vs fraction changed (two-level)
ax = axes[0, 0]
ax.plot(fractions_changed * 100, cis, 'b-', linewidth=2.5)
ax.axhline(y=1.0, color='green', linestyle=':', linewidth=1.5, alpha=0.5)
ax.axhline(y=0.5, color='red', linestyle=':', linewidth=1.5, alpha=0.5)
ax.set_xlabel('% of edges changed from size 3 to size 5', fontsize=12)
ax.set_ylabel('Collision Index', fontsize=12)
ax.set_title('CI drops from 1 as uniformity breaks\n(Two-level distribution)', fontsize=13)
ax.annotate('CI = 1\n(perfectly uniform)', xy=(0, 1.0),
            xytext=(15, 0.92), fontsize=10, color='green',
            arrowprops=dict(arrowstyle='->', color='green'))
ax.annotate('CI = 0.5\n(equal split)', xy=(50, 0.5),
            xytext=(60, 0.6), fontsize=10, color='red',
            arrowprops=dict(arrowstyle='->', color='red'))
ax.grid(True, alpha=0.3)
ax.set_ylim(0.4, 1.05)

# Top right: Heterogeneity vs fraction changed
ax = axes[0, 1]
ax.plot(fractions_changed * 100, hets, 'r-', linewidth=2.5)
ax.fill_between(fractions_changed * 100, 0, hets, alpha=0.1, color='red')
ax.set_xlabel('% of edges changed from size 3 to size 5', fontsize=12)
ax.set_ylabel('Heterogeneity (σ²)', fontsize=12)
ax.set_title('Heterogeneity peaks at equal split\n(Variance of edge sizes)', fontsize=13)
ax.grid(True, alpha=0.3)

# Bottom left: CI vs Heterogeneity (parametric curve)
ax = axes[1, 0]
ax.plot(hets, cis, 'purple', linewidth=2.5, marker='o', markersize=3)
ax.set_xlabel('Heterogeneity (σ²)', fontsize=12)
ax.set_ylabel('Collision Index', fontsize=12)
ax.set_title('CI vs Heterogeneity Trade-off\n(Two-level case)', fontsize=13)
ax.annotate('Uniform\n(origin)', xy=(0, 1), fontsize=10, color='green',
            xytext=(0.3, 0.95),
            arrowprops=dict(arrowstyle='->', color='green'))
ax.grid(True, alpha=0.3)

# Bottom right: Multi-size comparison
ax = axes[1, 1]
ax.plot(alphas * 100, multi_cis, 'b-', linewidth=2.5, label='Collision Index')
ax2 = ax.twinx()
ax2.plot(alphas * 100, multi_hets, 'r--', linewidth=2.5, label='Heterogeneity')
ax.set_xlabel('Disorder parameter α (%)', fontsize=12)
ax.set_ylabel('Collision Index', fontsize=12, color='blue')
ax2.set_ylabel('Heterogeneity (σ²)', fontsize=12, color='red')
ax.set_title('Multi-size distribution: {2,3,4,5}\nDisorder increases with α', fontsize=13)
ax.grid(True, alpha=0.3)

# Combined legend
lines1, labels1 = ax.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax.legend(lines1 + lines2, labels1 + labels2, fontsize=11, loc='center right')

fig.suptitle('The Collision Index Theorem: CI = 1 ⟺ Uniform Edge Sizes',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('collision_index_theorem.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved collision_index_theorem.png")
