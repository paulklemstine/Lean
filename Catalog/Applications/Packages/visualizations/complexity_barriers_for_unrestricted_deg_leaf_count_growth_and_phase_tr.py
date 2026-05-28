#!/usr/bin/env python3
"""
Visualization: Leaf Count Growth and Complexity Barrier

Visualizes the exponential growth of quadratic leaf counts in the
Lorentzian recognition tree, comparing exact counts with our proved
lower bounds and the catalog's upper bounds.

This illustrates the core complexity phase transition: fixed degree
gives polynomial growth (bottom curves), while balanced parameters
give exponential growth (top curves).
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2


def multiindex_count(n, d):
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def number_of_quadratic_leaves(n, d):
    return 1 if d < 2 else multiindex_count(n, d - 2)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Leaf count vs degree for fixed n
ax1 = axes[0]
for n in [2, 3, 5, 8, 12]:
    ds = list(range(2, 20))
    leaves = [number_of_quadratic_leaves(n, d) for d in ds]
    ax1.semilogy(ds, leaves, 'o-', label=f'n={n}', markersize=4)

# Lower bound: d - 1
ds_lb = list(range(2, 20))
lower = [max(1, d - 1) for d in ds_lb]
ax1.semilogy(ds_lb, lower, 'k--', label='Lower: d-1', linewidth=2)

ax1.set_xlabel('Degree d', fontsize=12)
ax1.set_ylabel('Number of Quadratic Leaves', fontsize=12)
ax1.set_title('Leaf Count vs Degree\n(Fixed Variables)', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Balanced regime (n = d) — exponential growth
ax2 = axes[1]
ds = list(range(2, 22))
exact = [number_of_quadratic_leaves(d, d) for d in ds]
lower_exp = [2**((d-2)//2) for d in ds]
upper = [d**(d-2) if d >= 2 else 1 for d in ds]

ax2.semilogy(ds, exact, 'bo-', label='Exact count', markersize=5, linewidth=2)
ax2.semilogy(ds, lower_exp, 'r^--', label='Lower: 2^((d-2)/2)', markersize=5)
ax2.semilogy(ds, upper, 'gs--', label='Upper: d^(d-2)', markersize=4, alpha=0.6)

ax2.set_xlabel('Degree d = n', fontsize=12)
ax2.set_ylabel('Number of Quadratic Leaves', fontsize=12)
ax2.set_title('Balanced Regime (n = d)\nExponential Growth', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Phase transition heatmap
ax3 = axes[2]
ns = list(range(2, 21))
ds = list(range(2, 21))
data = np.zeros((len(ns), len(ds)))

for i, n in enumerate(ns):
    for j, d in enumerate(ds):
        leaves = number_of_quadratic_leaves(n, d)
        data[i, j] = log2(max(1, leaves))

im = ax3.imshow(data, aspect='auto', origin='lower',
                extent=[ds[0]-0.5, ds[-1]+0.5, ns[0]-0.5, ns[-1]+0.5],
                cmap='YlOrRd')
cbar = plt.colorbar(im, ax=ax3, label='log₂(leaf count)')

# Draw the "phase boundary" where leaves ≈ 10^6
boundary_n = []
boundary_d = []
for d in ds:
    for n in ns:
        if number_of_quadratic_leaves(n, d) >= 10**6:
            boundary_n.append(n)
            boundary_d.append(d)
            break

if boundary_d and boundary_n:
    ax3.plot(boundary_d, boundary_n, 'w-', linewidth=2, label='10⁶ boundary')
    ax3.legend(fontsize=9)

ax3.set_xlabel('Degree d', fontsize=12)
ax3.set_ylabel('Variables n', fontsize=12)
ax3.set_title('Complexity Phase Transition\nlog₂(leaf count)', fontsize=13)

plt.suptitle('Lorentzian Recognition: Certificate Complexity Barriers',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_leaf_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_leaf_growth.png")
