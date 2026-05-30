#!/usr/bin/env python3
"""
Visualization 2: The Radical Function and Information Compression

Shows how the radical function 'compresses' numbers by stripping exponents.
Plots rad(n) vs n, highlighting squarefree numbers (where rad(n) = n)
and highly composite numbers (where rad(n) << n). Also shows the
'compression ratio' log(rad(n))/log(n) as a measure of information efficiency.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, prod


def factorize(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    temp = abs(n)
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = 1
    return factors


def radical(n):
    if n <= 1:
        return 1
    f = factorize(n)
    return prod(f.keys()) if f else 1


N = 500
ns = list(range(1, N + 1))
rads = [radical(n) for n in ns]
is_sqfree = [r == n for r, n in zip(rads, ns)]
compression = [log(r) / log(n) if n > 1 and r > 0 else 1.0 for r, n in zip(rads, ns)]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: rad(n) vs n
ax1 = axes[0, 0]
sqfree_x = [n for n, s in zip(ns, is_sqfree) if s]
sqfree_y = [r for r, s in zip(rads, is_sqfree) if s]
nonsqfree_x = [n for n, s in zip(ns, is_sqfree) if not s]
nonsqfree_y = [r for r, s in zip(rads, is_sqfree) if not s]

ax1.scatter(sqfree_x, sqfree_y, s=4, alpha=0.6, c='#2ecc71',
            label='Squarefree (rad=n)')
ax1.scatter(nonsqfree_x, nonsqfree_y, s=4, alpha=0.6, c='#e74c3c',
            label='Non-squarefree (rad<n)')
ax1.plot([1, N], [1, N], 'k--', alpha=0.3, linewidth=1, label='y = x')
ax1.set_xlabel('n', fontsize=11)
ax1.set_ylabel('rad(n)', fontsize=11)
ax1.set_title('Radical Function: rad(n) vs n', fontsize=12)
ax1.legend(fontsize=9)

# Top-right: Compression ratio
ax2 = axes[0, 1]
ax2.scatter(ns[1:], compression[1:], s=3, alpha=0.5, c='#3498db')
ax2.axhline(y=1.0, color='#2ecc71', linestyle='--', linewidth=1.5,
            label='Perfect efficiency (squarefree)', alpha=0.7)
ax2.set_xlabel('n', fontsize=11)
ax2.set_ylabel('log(rad(n)) / log(n)', fontsize=11)
ax2.set_title('Information Compression Ratio', fontsize=12)
ax2.set_ylim(0, 1.1)
ax2.legend(fontsize=9)

# Bottom-left: Redundancy n/rad(n)
ax3 = axes[1, 0]
redundancies = [n / r if r > 0 else 0 for n, r in zip(ns, rads)]
ax3.scatter(ns, redundancies, s=4, alpha=0.5,
            c=['#e74c3c' if r > 2 else '#f39c12' if r > 1 else '#2ecc71'
               for r in redundancies])
ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('n / rad(n)', fontsize=11)
ax3.set_title('Redundancy: n / rad(n)', fontsize=12)
ax3.set_yscale('log')

# Bottom-right: Prime powers highlighted
ax4 = axes[1, 1]
# Show rad(n!) vs n (our proved theorem: rad(n!) >= n)
from math import factorial
fact_ns = list(range(2, 25))
fact_rads = [radical(factorial(n)) for n in fact_ns]
ax4.semilogy(fact_ns, fact_rads, 'o-', color='#9b59b6', markersize=5,
             label='rad(n!)')
ax4.semilogy(fact_ns, fact_ns, 's--', color='#e74c3c', markersize=4,
             label='n (lower bound)')
ax4.semilogy(fact_ns, [factorial(n) for n in fact_ns], '^:', color='#95a5a6',
             markersize=4, alpha=0.5, label='n!')
ax4.set_xlabel('n', fontsize=11)
ax4.set_ylabel('Value (log scale)', fontsize=11)
ax4.set_title('Radical of Factorials: rad(n!) ≥ n', fontsize=12)
ax4.legend(fontsize=9)

plt.tight_layout()
plt.savefig('radical_function_analysis.png', dpi=150, bbox_inches='tight')
print("Saved radical_function_analysis.png")
