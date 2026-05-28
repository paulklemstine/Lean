#!/usr/bin/env python3
"""
Visualization: Boolean-to-Multiindex Injection

Illustrates the key injection theorem: each Boolean assignment maps to a
distinct multiindex, proving that the multiindex count grows exponentially.
Shows the injection for m=4 as a bipartite graph, and the exponential
growth curve for larger m.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import comb
import itertools


def bool_to_multiindex(m, b):
    count_true = sum(1 for x in b if x)
    alpha_0 = m - count_true
    rest = tuple(1 if bi else 0 for bi in b)
    return (alpha_0,) + rest


def multiindex_count(n, d):
    if n <= 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


fig, axes = plt.subplots(1, 2, figsize=(16, 8))

# Left: Injection diagram for m=4
ax1 = axes[0]
m = 4
assignments = list(itertools.product([False, True], repeat=m))

# Position Boolean assignments on the left
n_left = len(assignments)
left_y = np.linspace(0, 1, n_left)

# Position multiindices on the right
multiindices = set()
for b in assignments:
    multiindices.add(bool_to_multiindex(m, b))
all_multis = sorted(multiindices)
right_y_map = {mi: i / max(len(all_multis) - 1, 1) for i, mi in enumerate(all_multis)}

# Draw connections
colors = plt.cm.viridis(np.linspace(0.2, 0.9, n_left))
for i, b in enumerate(assignments):
    mi = bool_to_multiindex(m, b)
    ry = right_y_map[mi]
    ax1.plot([0.1, 0.9], [left_y[i], ry], '-', color=colors[i], 
             alpha=0.6, linewidth=1.5)

# Draw nodes
for i, b in enumerate(assignments):
    bits_str = "".join("1" if x else "0" for x in b)
    ax1.plot(0.1, left_y[i], 'o', color=colors[i], markersize=8)
    ax1.text(-0.05, left_y[i], bits_str, ha='right', va='center', fontsize=7,
             fontfamily='monospace')

for mi, ry in right_y_map.items():
    ax1.plot(0.9, ry, 's', color='coral', markersize=8, zorder=5)
    ax1.text(0.95, ry, str(mi), ha='left', va='center', fontsize=7,
             fontfamily='monospace')

ax1.set_xlim(-0.25, 1.4)
ax1.set_ylim(-0.05, 1.05)
ax1.set_title(f'Boolean → Multiindex Injection (m={m})', fontsize=13, fontweight='bold')
ax1.text(0.1, -0.03, f'2^{m} = {2**m} assignments', ha='center', fontsize=9)
ax1.text(0.9, -0.03, f'{len(all_multis)} multiindices\n(of {multiindex_count(m+1, m)} total)', 
         ha='center', fontsize=9)
ax1.axis('off')

# Right: Exponential growth comparison
ax2 = axes[1]
ms = range(1, 18)

exact_counts = [multiindex_count(m + 1, m) for m in ms]
lower_bounds = [2 ** m for m in ms]
upper_bounds = [(m + 1) ** m for m in ms]

ax2.semilogy(list(ms), exact_counts, 'b-o', linewidth=2, markersize=6,
             label=f'Exact: C(2m, m)')
ax2.semilogy(list(ms), lower_bounds, 'r--', linewidth=2,
             label=f'Lower: 2^m (our theorem)')
ax2.semilogy(list(ms), upper_bounds, 'g--', linewidth=2,
             label=f'Upper: (m+1)^m (catalog)')

# Shade the gap
ax2.fill_between(list(ms), lower_bounds, exact_counts, alpha=0.15, color='blue',
                 label='Proved range')

ax2.set_xlabel('m (= degree parameter)', fontsize=12)
ax2.set_ylabel('Multiindex count (log scale)', fontsize=12)
ax2.set_title('Exponential Growth: Lower vs. Upper Bounds', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('injection_growth.png', dpi=150, bbox_inches='tight')
print("Saved injection_growth.png")
