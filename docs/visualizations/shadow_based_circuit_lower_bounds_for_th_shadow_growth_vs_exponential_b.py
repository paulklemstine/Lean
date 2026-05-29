#!/usr/bin/env python3
"""
Visualization: Shadow Growth vs Exponential Bound

Visualizes the super-exponential growth of |Sh₂(suppPerm(n))| = C(n,2)² · (n-2)!
compared to the exponential lower bound 2^(n/2). Shows how the permanent's
support shadow grows far faster than any exponential function, demonstrating
the power of the shadow-based approach to circuit lower bounds.

This is a self-contained script — no local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import factorial, comb, log2

# Compute data
ns = list(range(2, 21))
shadow_sizes = [comb(n, 2)**2 * factorial(n - 2) for n in ns]
exp_bounds = [2**(n // 2) for n in ns]
factorials = [factorial(n) for n in ns]

# Log scale values
log_shadow = [log2(s) if s > 0 else 0 for s in shadow_sizes]
log_exp = [n // 2 for n in ns]
log_fact = [log2(f) if f > 0 else 0 for f in factorials]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: log₂ comparison
ax1.plot(ns, log_shadow, 'bo-', linewidth=2, markersize=8, label='log₂|Sh₂| = log₂[C(n,2)²·(n-2)!]')
ax1.plot(ns, log_exp, 'rs--', linewidth=2, markersize=7, label='n/2 (exponential bound)')
ax1.plot(ns, log_fact, 'g^:', linewidth=1.5, markersize=6, label='log₂(n!) (permanent terms)', alpha=0.7)
ax1.set_xlabel('n (matrix dimension)', fontsize=13)
ax1.set_ylabel('log₂(count)', fontsize=13)
ax1.set_title('Shadow Size vs Exponential Bound\n(logarithmic scale)', fontsize=14)
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1.5, 20.5)

# Right plot: ratio |Sh₂| / 2^(n/2)
ratios = [shadow_sizes[i] / exp_bounds[i] for i in range(len(ns))]
ax2.semilogy(ns, ratios, 'ko-', linewidth=2, markersize=8, color='darkblue')
ax2.axhline(y=1, color='red', linestyle='--', linewidth=1, alpha=0.5, label='ratio = 1')
ax2.set_xlabel('n (matrix dimension)', fontsize=13)
ax2.set_ylabel('|Sh₂| / 2^(n/2)', fontsize=13)
ax2.set_title('Shadow-to-Exponential Ratio\n(grows super-exponentially)', fontsize=14)
ax2.grid(True, alpha=0.3)
ax2.legend(fontsize=10)
ax2.set_xlim(1.5, 20.5)

# Annotate key values
for i, n in enumerate(ns):
    if n in [4, 8, 12, 16, 20]:
        ax2.annotate(f'{ratios[i]:.0f}', (n, ratios[i]),
                    textcoords="offset points", xytext=(10, 5),
                    fontsize=9, color='darkblue')

plt.suptitle('Permanent Support Shadow: Super-Exponential Growth', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('shadow_growth.png', dpi=150, bbox_inches='tight')
print("Saved shadow_growth.png")
