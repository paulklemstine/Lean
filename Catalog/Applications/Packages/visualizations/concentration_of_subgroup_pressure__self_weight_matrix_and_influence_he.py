#!/usr/bin/env python3
"""
Visualization: Weight Matrix and Influence Heatmap

Shows the structure of the pair interaction weight matrix w(H,K)
for different subgroup families of symmetric groups, and how
the influence profile determines concentration quality.
"""

import numpy as np
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def young_subgroup_data(n, max_parts=2):
    """Generate Young subgroup indices for S_n."""
    index_list = []
    label_list = []
    
    def gen(remaining, max_p, current):
        if max_p == 1:
            if remaining >= 1:
                parts = current + [remaining]
                denom = 1
                for a in parts:
                    denom *= factorial(a)
                idx = factorial(n) // denom
                if idx > 1:
                    index_list.append(idx)
                    label_list.append('+'.join(str(a) for a in sorted(parts, reverse=True)))
            return
        for a in range(1, remaining):
            gen(remaining - a, max_p - 1, current + [a])
        parts = current + [remaining]
        denom = 1
        for a in parts:
            denom *= factorial(a)
        idx = factorial(n) // denom
        if idx > 1:
            index_list.append(idx)
            label_list.append('+'.join(str(a) for a in sorted(parts, reverse=True)))
    
    gen(n, max_parts, [])
    return np.array(index_list, dtype=float), label_list


fig, axes = plt.subplots(2, 3, figsize=(18, 11))

# Top row: Weight matrices for different n
for col, n in enumerate([6, 8, 10]):
    indices, labels = young_subgroup_data(n, max_parts=2)
    inv = 1.0 / (indices ** 2)
    W = np.outer(inv, inv)
    
    ax = axes[0, col]
    im = ax.imshow(W, cmap='hot', norm=LogNorm(vmin=max(W.min(), 1e-15), vmax=W.max()),
                   aspect='auto')
    ax.set_title(f'$S_{{{n}}}$ Weight Matrix ($|S|={len(indices)}$)', fontsize=13)
    if col == 0:
        ax.set_ylabel('Subgroup $H$', fontsize=11)
    ax.set_xlabel('Subgroup $K$', fontsize=11)
    plt.colorbar(im, ax=ax, shrink=0.8)

# Bottom-left: Influence vs index
ax = axes[1, 0]
for n, color, marker in [(6, 'blue', 'o'), (8, 'red', 's'), (10, 'green', '^'), (12, 'purple', 'D')]:
    indices, _ = young_subgroup_data(n, max_parts=2)
    inv = 1.0 / (indices ** 2)
    W = np.outer(inv, inv)
    influences = np.sum(np.abs(W), axis=1) + np.sum(np.abs(W), axis=0)
    ax.scatter(indices, influences, c=color, marker=marker, s=30, alpha=0.7,
               label=f'$S_{{{n}}}$')

ax.set_xlabel('Subgroup Index $[G:H]$', fontsize=12)
ax.set_ylabel('Influence', fontsize=12)
ax.set_title('Influence vs Subgroup Index', fontsize=13)
ax.set_xscale('log')
ax.set_yscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom-center: Cumulative influence
ax = axes[1, 1]
all_ns = range(5, 16)
total_inf_sq = []
for n in all_ns:
    indices, _ = young_subgroup_data(n, max_parts=2)
    if len(indices) == 0:
        total_inf_sq.append(0)
        continue
    inv = 1.0 / (indices ** 2)
    W = np.outer(inv, inv)
    influences = np.sum(np.abs(W), axis=1) + np.sum(np.abs(W), axis=0)
    total_inf_sq.append(np.sum(influences**2))

ax.semilogy(list(all_ns), total_inf_sq, 'bo-', markersize=6)
ax.set_xlabel('$n$', fontsize=12)
ax.set_ylabel('$\\sum c_H^2$', fontsize=12)
ax.set_title('Total Squared Influence (Young)', fontsize=13)
ax.grid(True, alpha=0.3)

# Bottom-right: Sorted influence spectrum
ax = axes[1, 2]
for n, color in [(8, 'blue'), (10, 'orange'), (12, 'green')]:
    indices, _ = young_subgroup_data(n, max_parts=2)
    if len(indices) == 0:
        continue
    inv = 1.0 / (indices ** 2)
    W = np.outer(inv, inv)
    influences = np.sum(np.abs(W), axis=1) + np.sum(np.abs(W), axis=0)
    sorted_inf = np.sort(influences)[::-1]
    ax.plot(range(1, len(sorted_inf) + 1), sorted_inf, 'o-', 
            color=color, markersize=4, label=f'$S_{{{n}}}$')

ax.set_xlabel('Rank', fontsize=12)
ax.set_ylabel('Influence', fontsize=12)
ax.set_title('Sorted Influence Spectrum', fontsize=13)
ax.set_yscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Interaction Structure of Subgroup Pressure Models', 
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")
