#!/usr/bin/env python3
"""
Visualization: Certificate Complexity Barrier

Visualizes the superpolynomial barrier theorem: for any polynomial bound n^c,
there exist parameters where the Lorentzian certificate complexity exceeds it.
Shows the "impossible region" where polynomial-time recognition fails.

This illustrates Theorem D: unbounded degree forces superpolynomial complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2, log10


def multiindex_count(n, d):
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def number_of_quadratic_leaves(n, d):
    return 1 if d < 2 else multiindex_count(n, d - 2)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Leaf count vs polynomial bounds
ax1 = axes[0]
ns = list(range(2, 25))

# Balanced regime: d = 2n
leaves_balanced = [number_of_quadratic_leaves(n, 2*n) for n in ns]
ax1.semilogy(ns, leaves_balanced, 'ko-', label='Leaves (d=2n)', markersize=5, linewidth=2)

# Polynomial bounds
for c, color in [(2, 'blue'), (3, 'green'), (5, 'orange'), (10, 'red')]:
    bounds = [n**c for n in ns]
    ax1.semilogy(ns, bounds, f'{color[0]}--', label=f'n^{c}', linewidth=1.5, alpha=0.7)

ax1.set_xlabel('Number of variables n', fontsize=12)
ax1.set_ylabel('Count (log scale)', fontsize=12)
ax1.set_title('Certificate Size vs Polynomial Bounds\n(d = 2n regime)', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: The crossing points — when exponential overtakes polynomial
ax2 = axes[1]

crossing_data = []
for c in range(1, 16):
    for n in range(2, 100):
        leaves = number_of_quadratic_leaves(n, 2*n)
        if leaves > n**c:
            crossing_data.append((c, n))
            break

cs, crossing_ns = zip(*crossing_data) if crossing_data else ([], [])
ax2.bar(cs, crossing_ns, color='steelblue', alpha=0.8)
ax2.set_xlabel('Polynomial exponent c', fontsize=12)
ax2.set_ylabel('Smallest n where leaves > n^c', fontsize=12)
ax2.set_title('Superpolynomial Witnesses\n(Theorem D)', fontsize=13)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Growth rate comparison
ax3 = axes[2]

ds = list(range(4, 30))
# Exact growth for n = d
exact_growth = []
lower_bound_growth = []
for d in ds:
    exact = number_of_quadratic_leaves(d, d)
    lower = 2**((d-2)//2)
    exact_growth.append(log2(exact) if exact > 0 else 0)
    lower_bound_growth.append((d-2)//2)

ax3.plot(ds, exact_growth, 'bo-', label='log₂(exact)', markersize=4, linewidth=2)
ax3.plot(ds, lower_bound_growth, 'r^--', label='(d-2)/2 (our bound)', markersize=4)
ax3.plot(ds, [d-2 for d in ds], 'g--', label='d-2 (linear ref)', alpha=0.5)

# Theoretical asymptotic: log2(C(2d-3, d-2)) ≈ 2d·log2(2) - 0.5·log2(d)
asymptotic = [2*(d-2)*1 - 0.5*log2(max(1,d)) for d in ds]
ax3.plot(ds, asymptotic, 'k:', label='~2(d-2) (Stirling)', alpha=0.5)

ax3.set_xlabel('Degree d (with n = d)', fontsize=12)
ax3.set_ylabel('log₂(leaf count)', fontsize=12)
ax3.set_title('Growth Rate of Certificate Complexity\n(Balanced Regime)', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle('Lorentzian Recognition: The Superpolynomial Barrier',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_certificate_barrier.png', dpi=150, bbox_inches='tight')
print("Saved viz_certificate_barrier.png")
