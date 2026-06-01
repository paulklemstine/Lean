#!/usr/bin/env python3
"""
Visualization: Dyadic Valuation Landscape

Shows the dyadic valuation ν₂(q) as a function of q for dyadic rationals,
revealing the fractal-like structure of the birthday function.
"""

import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction


def dyadic_valuation(q: Fraction) -> int:
    d = q.denominator
    v = 0
    while d % 2 == 0:
        v += 1
        d //= 2
    return v


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Valuation landscape
ax1 = axes[0]
max_n = 7
xs, ys = [], []
for n in range(max_n + 1):
    denom = 2 ** n
    for num in range(1, 4 * denom + 1):
        q = Fraction(num, denom)
        v = dyadic_valuation(q)
        xs.append(float(q))
        ys.append(v)

scatter = ax1.scatter(xs, ys, c=ys, cmap='plasma', s=2, alpha=0.6)
ax1.set_xlabel('q (dyadic rational)', fontsize=12)
ax1.set_ylabel('ν₂(q) = padicValNat(2, q.den)', fontsize=12)
ax1.set_title('Dyadic Valuation Landscape', fontsize=14, fontweight='bold')
ax1.set_xlim(0, 4)
ax1.set_ylim(-0.5, max_n + 0.5)
plt.colorbar(scatter, ax=ax1, label='Birthday')

# Right: Subadditivity demonstration
ax2 = axes[1]
dyadics = []
for n in range(6):
    denom = 2 ** n
    for num in range(1, 3 * denom + 1):
        q = Fraction(num, denom)
        if dyadic_valuation(q) == n:
            dyadics.append(q)

# Sample pairs and plot ν₂(p+q) vs ν₂(p) + ν₂(q)
sums_actual = []
sums_bound = []
for i in range(min(200, len(dyadics))):
    for j in range(i, min(200, len(dyadics))):
        p, q = dyadics[i], dyadics[j]
        va = dyadic_valuation(p + q)
        vb = dyadic_valuation(p) + dyadic_valuation(q)
        sums_actual.append(va)
        sums_bound.append(vb)

ax2.scatter(sums_bound, sums_actual, s=3, alpha=0.3, c='steelblue')
max_val = max(max(sums_bound), max(sums_actual)) + 1
ax2.plot([0, max_val], [0, max_val], 'r--', linewidth=1.5, label='ν₂(p+q) = ν₂(p)+ν₂(q)')
ax2.set_xlabel('ν₂(p) + ν₂(q) (upper bound)', fontsize=12)
ax2.set_ylabel('ν₂(p + q) (actual)', fontsize=12)
ax2.set_title('Valuation Subadditivity', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_aspect('equal')
ax2.set_xlim(0, max_val)
ax2.set_ylim(0, max_val)

plt.tight_layout()
plt.savefig('valuation_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: valuation_landscape.png")
