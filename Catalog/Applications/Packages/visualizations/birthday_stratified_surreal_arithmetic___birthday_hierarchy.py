#!/usr/bin/env python3
"""
Visualization: Surreal Birthday Hierarchy

Plots the dyadic rationals colored by birthday (2-adic valuation),
showing how each birthday level fills in the number line.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction


def dyadic_valuation(q: Fraction) -> int:
    d = q.denominator
    v = 0
    while d % 2 == 0:
        v += 1
        d //= 2
    return v


def generate_dyadics(max_birthday: int, x_range: tuple = (-3, 3)):
    """Generate all dyadic rationals up to a given birthday in a range."""
    results = []
    for n in range(max_birthday + 1):
        denom = 2 ** n
        lo = int(x_range[0] * denom)
        hi = int(x_range[1] * denom)
        for num in range(lo, hi + 1):
            q = Fraction(num, denom)
            v = dyadic_valuation(q)
            if v == n:  # Only include if this is the birth day
                results.append((float(q), n))
    return results


fig, axes = plt.subplots(2, 1, figsize=(14, 8), gridspec_kw={'height_ratios': [3, 1]})

# Top plot: Birthday hierarchy
ax1 = axes[0]
max_bday = 6
colors = plt.cm.viridis(np.linspace(0, 0.9, max_bday + 1))

for bday in range(max_bday + 1):
    points = [(x, b) for x, b in generate_dyadics(max_bday) if b == bday]
    if points:
        xs, bs = zip(*points)
        ax1.scatter(xs, bs, c=[colors[bday]], s=max(10, 80 - bday * 10),
                   label=f'Birthday {bday}', zorder=5 - bday, alpha=0.8)

ax1.set_xlabel('Value on the number line', fontsize=12)
ax1.set_ylabel('Birthday (2-adic valuation)', fontsize=12)
ax1.set_title('Surreal Birthday Hierarchy: Dyadic Rationals by Construction Day',
              fontsize=14, fontweight='bold')
ax1.legend(loc='upper right', fontsize=9)
ax1.set_yticks(range(max_bday + 1))
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-3, 3)

# Bottom plot: Counting function
ax2 = axes[1]
ns = list(range(8))
counts = [2 ** (n + 1) - 1 for n in ns]
new_counts = [1] + [2 ** n for n in range(1, 8)]

ax2.bar([n - 0.15 for n in ns], counts, width=0.3, color='steelblue',
        label='Total: $2^{n+1}-1$', alpha=0.8)
ax2.bar([n + 0.15 for n in ns], new_counts, width=0.3, color='coral',
        label='New at day n', alpha=0.8)

for i, (c, nc) in enumerate(zip(counts, new_counts)):
    ax2.text(i - 0.15, c + 1, str(c), ha='center', va='bottom', fontsize=8)
    ax2.text(i + 0.15, nc + 1, str(nc), ha='center', va='bottom', fontsize=8)

ax2.set_xlabel('Birthday (day n)', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Surreal Counting: Exponential Growth', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.set_xticks(ns)

plt.tight_layout()
plt.savefig('birthday_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: birthday_hierarchy.png")
