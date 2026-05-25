#!/usr/bin/env python3
"""
Visualization: Higher-Order Log-Concavity Hierarchy

Produces a heatmap showing the log-concavity depth of various
combinatorial sequences, plus ratio sequence evolution plots.
"""

import math
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.use('Agg')


def ratio_seq(seq):
    return [seq[i+1] / seq[i] for i in range(len(seq)-1)]

def is_positive(seq, tol=1e-12):
    return all(x > tol for x in seq)

def is_log_concave(seq, tol=1e-10):
    for n in range(len(seq) - 2):
        if seq[n+1]**2 < seq[n] * seq[n+2] - tol:
            return False
    return True

def kfold_depth(seq, max_depth=20):
    if not is_positive(seq):
        return -1
    current = list(seq)
    depth = 0
    for _ in range(max_depth):
        if len(current) < 3:
            return depth + max_depth - _
        if not is_log_concave(current):
            return depth
        depth += 1
        current = ratio_seq(current)
        if not is_positive(current):
            return depth
    return depth


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Heatmap of log-concavity depth
ax1 = axes[0, 0]
families = []
family_names = []

for n in range(3, 16):
    seq = [float(math.comb(n, k)) for k in range(n+1)]
    families.append(seq)
    family_names.append(f"C({n},k)")

# Compute depths
depths = [kfold_depth(seq) for seq in families]
# Cap for display
depths_display = [min(d, 10) for d in depths]

ax1.barh(range(len(family_names)), depths_display, color=plt.cm.viridis(
    [d/10 for d in depths_display]))
ax1.set_yticks(range(len(family_names)))
ax1.set_yticklabels(family_names, fontsize=8)
ax1.set_xlabel('Log-Concavity Depth k')
ax1.set_title('Binomial Coefficient Depth Profile', fontweight='bold')
ax1.invert_yaxis()

# Panel 2: Ratio sequence evolution for binomial
ax2 = axes[0, 1]
for n in [6, 8, 10, 12]:
    seq = [float(math.comb(n, k)) for k in range(n+1)]
    r = ratio_seq(seq)
    ax2.plot(range(len(r)), r, 'o-', label=f'C({n},k)', markersize=4)

ax2.set_xlabel('Index n')
ax2.set_ylabel('Ratio r(n) = a(n+1)/a(n)')
ax2.set_title('Ratio Sequences of Binomials', fontweight='bold')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Panel 3: Product stability demonstration
ax3 = axes[1, 0]
# Show that product preserves depth
ns = range(3, 16)
single_depths = []
product_depths = []

for n in ns:
    seq = [float(math.comb(n, k)) for k in range(n+1)]
    d1 = kfold_depth(seq)
    prod_seq = [x**2 for x in seq]
    d2 = kfold_depth(prod_seq)
    single_depths.append(d1)
    product_depths.append(d2)

x = list(ns)
ax3.plot(x, single_depths, 's-', label='C(n,k)', color='blue', markersize=6)
ax3.plot(x, product_depths, 'D-', label='C(n,k)²', color='red', markersize=6)
ax3.set_xlabel('n')
ax3.set_ylabel('Log-Concavity Depth')
ax3.set_title('Product Stability: depth(a·b) ≥ min(depth(a), depth(b))',
              fontweight='bold', fontsize=10)
ax3.legend()
ax3.grid(True, alpha=0.3)

# Panel 4: Geometric vs binomial depth comparison
ax4 = axes[1, 1]
geo_depths = []
binom_depths = []
lengths = range(3, 20)

for n in lengths:
    geo = [2.0**k for k in range(n)]
    geo_depths.append(min(kfold_depth(geo), 15))
    binom = [float(math.comb(n, k)) for k in range(n+1)]
    binom_depths.append(kfold_depth(binom))

ax4.plot(list(lengths), geo_depths, 's-', label='Geometric (r=2)',
         color='green', markersize=5)
ax4.plot(list(lengths), binom_depths, 'o-', label='Binomial C(n,k)',
         color='orange', markersize=5)
ax4.set_xlabel('Sequence Length')
ax4.set_ylabel('Log-Concavity Depth')
ax4.set_title('Depth: Geometric (∞) vs Binomial (1)', fontweight='bold')
ax4.legend()
ax4.grid(True, alpha=0.3)
ax4.set_ylim(0, 16)

plt.suptitle('Higher-Order Log-Concavity Hierarchy',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('hierarchy_visualization.png', dpi=150, bbox_inches='tight')
print("Saved hierarchy_visualization.png")
