#!/usr/bin/env python3
"""
Visualization: Support Exclusion Map
=====================================

This visualization shows which prime supports are excluded by the
energy barrier theorem. For each pair of primes from the first 10
odd primes, we compute the support energy and mark excluded supports
in red and non-excluded ones in green.

The plot reveals the phase transition: small prime sets are excluded
(energy < 2), while larger or denser sets cross the barrier.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from fractions import Fraction
from itertools import combinations


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def support_energy(primes):
    result = Fraction(1)
    for p in primes:
        result *= Fraction(p, p - 1)
    return result


primes = [p for p in range(3, 50, 2) if is_prime(p)][:10]

fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Left: 2-element support heatmap
ax = axes[0]
n = len(primes)
Z = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i != j:
            e = float(support_energy([primes[i], primes[j]]))
            Z[i, j] = e
        else:
            Z[i, j] = float(Fraction(primes[i], primes[i] - 1))

im = ax.imshow(Z, cmap='RdYlGn_r', vmin=1.0, vmax=2.5, interpolation='nearest')
ax.set_xticks(range(n))
ax.set_xticklabels([str(p) for p in primes], fontsize=9)
ax.set_yticks(range(n))
ax.set_yticklabels([str(p) for p in primes], fontsize=9)
ax.set_xlabel('Prime q', fontsize=12)
ax.set_ylabel('Prime p', fontsize=12)
ax.set_title('Two-Prime Support Energy\n{p, q} → p/(p-1) · q/(q-1)', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax, label='Support Energy')

# Mark the 2.0 boundary
for i in range(n):
    for j in range(n):
        if i != j:
            val = Z[i, j]
            color = 'white' if val > 1.8 else 'black'
            marker = '✓' if val >= 2.0 else '✗'
            ax.text(j, i, f'{val:.2f}\n{marker}', ha='center', va='center',
                    fontsize=6, color=color)

# Right: exclusion fraction by support size
ax2 = axes[1]
max_size = min(8, len(primes))
sizes = list(range(2, max_size + 1))
excluded_fracs = []
total_counts = []

for k in sizes:
    excluded = 0
    total = 0
    for combo in combinations(primes, k):
        total += 1
        if support_energy(list(combo)) < 2:
            excluded += 1
    excluded_fracs.append(excluded / total * 100 if total > 0 else 0)
    total_counts.append(total)

bars = ax2.bar(sizes, excluded_fracs, color='#e74c3c', alpha=0.7, edgecolor='white')
ax2.set_xlabel('Support size |S|', fontsize=12)
ax2.set_ylabel('Percentage of supports excluded (%)', fontsize=12)
ax2.set_title('Fraction of Supports Excluded\nby Energy Barrier', fontsize=14, fontweight='bold')
ax2.set_ylim(0, 105)
ax2.set_xticks(sizes)

# Annotate with counts
for i, (bar, frac, total) in enumerate(zip(bars, excluded_fracs, total_counts)):
    ax2.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 2,
             f'{frac:.0f}%\n({total} total)', ha='center', fontsize=8)

# Add a horizontal line at 0%
ax2.axhline(y=0, color='gray', linewidth=0.5)

plt.tight_layout()
plt.savefig('viz_exclusion_map.png', dpi=150, bbox_inches='tight')
print("Saved viz_exclusion_map.png")
