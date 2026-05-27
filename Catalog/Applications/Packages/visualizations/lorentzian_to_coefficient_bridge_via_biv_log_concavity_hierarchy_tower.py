#!/usr/bin/env python3
"""
Visualization 1: Log-Concavity Hierarchy

Visualizes the k-fold log-concavity tower for coefficient sequences arising
from products of linear forms. Shows how each ratio transform preserves
the log-concave bell shape, with the sequence becoming more tightly constrained
at each level.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def product_coeffs(weights, d):
    """Compute bivariate specialization coefficients of a product of linear forms."""
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


def ratio_transform(seq):
    """Compute r(m) = a(m+1)/a(m)."""
    return [seq[m + 1] / seq[m] for m in range(len(seq) - 1) if seq[m] > 0]


# Generate coefficient sequence
np.random.seed(42)
d = 10
weights = [(np.random.uniform(0.5, 3.0), np.random.uniform(0.5, 3.0))
           for _ in range(d)]
coeffs = product_coeffs(weights, d)

# Compute iterated ratio transforms
transforms = [coeffs]
labels = [f"Original (a_m)"]
current = coeffs
for level in range(4):
    if len(current) < 3:
        break
    r = ratio_transform(current)
    if all(x > 0 for x in r):
        transforms.append(r)
        labels.append(f"Ratio level {level + 1}")
        current = r
    else:
        break

# Plot
fig, axes = plt.subplots(len(transforms), 1, figsize=(10, 3 * len(transforms)),
                         sharex=False)
if len(transforms) == 1:
    axes = [axes]

colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(transforms)))

for i, (seq, label, color) in enumerate(zip(transforms, labels, colors)):
    ax = axes[i]
    x = np.arange(len(seq))
    ax.bar(x, seq, color=color, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.set_ylabel("Value", fontsize=11)
    ax.set_title(label, fontsize=13, fontweight='bold')
    ax.grid(axis='y', alpha=0.3)

    # Check and annotate log-concavity
    is_lc = all(seq[m] ** 2 >= seq[m - 1] * seq[m + 1] - 1e-10
                for m in range(1, len(seq) - 1))
    status = "✓ Log-concave" if is_lc else "✗ Not log-concave"
    ax.text(0.98, 0.85, status, transform=ax.transAxes,
            fontsize=11, ha='right', va='top',
            bbox=dict(boxstyle='round,pad=0.3',
                      facecolor='lightgreen' if is_lc else 'lightcoral',
                      alpha=0.8))

axes[-1].set_xlabel("Index m", fontsize=12)
fig.suptitle(f"k-Fold Log-Concavity Tower (d={d}, product of linear forms)",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_logconcavity.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_logconcavity.png")
