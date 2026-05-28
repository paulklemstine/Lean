#!/usr/bin/env python3
"""
Visualization: Catalan Collapse under Canonical Normalization

This script visualizes how the exponentially large space of binary tree
parenthesizations collapses to a single canonical form under normalization.
It shows the Catalan number growth and the collapse ratio.
"""

import matplotlib.pyplot as plt
import numpy as np
import math


def catalan(n):
    """Compute the nth Catalan number."""
    if n <= 0:
        return 1
    c = 1
    for i in range(n):
        c = c * (2 * n - i) // (i + 1)
    return c // (n + 1)


def factorial(n):
    return math.factorial(n)


# ── Data ──

ns = list(range(2, 16))

catalan_nums = [catalan(n - 1) for n in ns]
factorials = [factorial(n) for n in ns]
search_spaces = [catalan(n - 1) * factorial(n) for n in ns]


# ── Plot ──

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Search space growth
ax1 = axes[0]
ax1.semilogy(ns, catalan_nums, 'o-', color='steelblue', linewidth=2,
             markersize=6, label='Parenthesizations C(n-1)')
ax1.semilogy(ns, factorials, 's-', color='darkorange', linewidth=2,
             markersize=6, label='Permutations n!')
ax1.semilogy(ns, search_spaces, 'D-', color='crimson', linewidth=2,
             markersize=6, label='Total search space C(n-1)·n!')
ax1.axhline(y=1, color='seagreen', linestyle='--', linewidth=3,
            label='Canonical forms (always 1)')
ax1.set_xlabel('Number of summands (n)', fontsize=13)
ax1.set_ylabel('Count (log scale)', fontsize=13)
ax1.set_title('Catalan Collapse:\nExponential Search Space → Single Canonical Form',
              fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1.5, 15.5)

# Panel 2: Compression ratio
ax2 = axes[1]
compression = [1.0 / s for s in search_spaces]
ax2.semilogy(ns, compression, 'o-', color='purple', linewidth=2, markersize=8)
ax2.fill_between(ns, compression, alpha=0.2, color='purple')
ax2.set_xlabel('Number of summands (n)', fontsize=13)
ax2.set_ylabel('Compression Ratio (1 / search space)', fontsize=13)
ax2.set_title('Compression Power of Canonical Normalization\n'
              '(lower = more expressions collapsed)',
              fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3)

# Add annotations
for i, n in enumerate(ns):
    if n in [3, 5, 8, 12, 15]:
        ax2.annotate(f'n={n}\n{search_spaces[i]:,} → 1',
                     (n, compression[i]),
                     textcoords="offset points",
                     xytext=(10, 10),
                     fontsize=9,
                     arrowprops=dict(arrowstyle='->', color='gray'))

plt.tight_layout()
plt.savefig('catalan_collapse.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: catalan_collapse.png")
