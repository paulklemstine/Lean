#!/usr/bin/env python3
"""
Visualization: Erdős-Szekeres Bounds Comparison

This script plots the known values, conjectured values, and upper bounds
for the Erdős-Szekeres number ES(n), illustrating the gap between what
is known and what is conjectured.
"""
import matplotlib.pyplot as plt
import numpy as np
from math import comb, log2


def es_conjectured(n):
    """Conjectured value: 2^(n-2) + 1."""
    return 2**(n-2) + 1


def es_upper_bound(n):
    """Classical upper bound: C(2n-4, n-2) + 1."""
    if n <= 2:
        return n
    return comb(2*n-4, n-2) + 1


# Known exact values
known = {3: 3, 4: 5, 5: 9, 6: 17}

n_vals = list(range(3, 11))
conjectured = [es_conjectured(n) for n in n_vals]
upper = [es_upper_bound(n) for n in n_vals]
known_vals = [known.get(n, None) for n in n_vals]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: Absolute values (log scale)
ax1.semilogy(n_vals, conjectured, 'b-o', label='Conjecture: $2^{n-2}+1$',
             markersize=8, linewidth=2)
ax1.semilogy(n_vals, upper, 'r--s', label=r'Upper bound: $\binom{2n-4}{n-2}+1$',
             markersize=8, linewidth=2)

# Plot known values
known_n = [n for n in n_vals if known.get(n) is not None]
known_v = [known[n] for n in known_n]
ax1.semilogy(known_n, known_v, 'g^', label='Known exact values',
             markersize=12, linewidth=2, markeredgecolor='darkgreen',
             markerfacecolor='lime', zorder=5)

# Suk bound approximation
suk = [2**(1.05*n) for n in n_vals]
ax1.semilogy(n_vals, suk, 'purple', label='Suk (2017): $2^{n+o(n)}$',
             linewidth=2, linestyle=':')

ax1.set_xlabel('n (polygon size)', fontsize=12)
ax1.set_ylabel('ES(n) — number of points needed', fontsize=12)
ax1.set_title('Erdős–Szekeres Number: Bounds Comparison', fontsize=13,
              fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xticks(n_vals)

# Plot 2: Ratio to conjecture
ratios_upper = [u / c for u, c in zip(upper, conjectured)]
ax2.plot(n_vals, ratios_upper, 'r-s', label='Upper bound / Conjecture',
         markersize=8, linewidth=2)
ax2.axhline(y=1.0, color='blue', linestyle='--', alpha=0.5,
            label='Conjecture (ratio = 1)')

# Known values ratio
known_ratios = [(known[n] / es_conjectured(n)) for n in known_n]
ax2.plot(known_n, known_ratios, 'g^', label='Known / Conjecture',
         markersize=12, markeredgecolor='darkgreen',
         markerfacecolor='lime', zorder=5)

ax2.set_xlabel('n (polygon size)', fontsize=12)
ax2.set_ylabel('Ratio to conjecture', fontsize=12)
ax2.set_title('Gap Between Bounds and Conjecture', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(n_vals)
ax2.set_yscale('log')

fig.tight_layout()
plt.savefig('es_bounds.png', dpi=150, bbox_inches='tight')
print("Saved es_bounds.png")
