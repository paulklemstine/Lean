#!/usr/bin/env python3
"""
Visualization: Central Binomial Coefficient Lower Bound

Plots C(2n, n) vs 2^n and 4^n/sqrt(πn), showing:
1. The proved lower bound C(2n,n) ≥ 2^n
2. The asymptotic behavior C(2n,n) ~ 4^n/sqrt(πn)
3. The ratio C(2n,n)/2^n growing as 2^n/sqrt(πn)

This illustrates Theorem 3.1 (centralBinom_ge_two_pow) and its
role as the engine for exponential lower bounds.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb, sqrt, pi, log2


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Data
ns = list(range(0, 21))
central_binom = [comb(2*n, n) for n in ns]
two_pow = [2**n for n in ns]
four_pow_approx = [4**n / sqrt(pi * n) if n > 0 else 1 for n in ns]

# Panel 1: Log-scale comparison
ax1 = axes[0]
ax1.semilogy(ns, central_binom, 'bo-', markersize=6, label='C(2n, n)', linewidth=2)
ax1.semilogy(ns, two_pow, 'r^--', markersize=5, label='2^n (lower bound)', linewidth=1.5)
ax1.semilogy(ns, four_pow_approx, 'g*--', markersize=5, label='4^n/√(πn) (asymptotic)', linewidth=1.5)
ax1.fill_between(ns, two_pow, central_binom, alpha=0.15, color='blue',
                  label='Gap: C(2n,n) − 2^n')
ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('Value (log scale)', fontsize=12)
ax1.set_title('Central Binomial Coefficient\nvs. Lower Bound', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Ratio C(2n,n)/2^n
ax2 = axes[1]
ratios = [central_binom[n] / two_pow[n] for n in ns]
theoretical_ratio = [2**n / sqrt(pi * n) if n > 0 else 1 for n in ns]
ax2.plot(ns, ratios, 'bo-', markersize=6, label='C(2n,n) / 2^n', linewidth=2)
ax2.plot(ns[1:], theoretical_ratio[1:], 'g--', markersize=4,
         label='2^n/√(πn) (asymptotic)', linewidth=1.5)
ax2.axhline(y=1, color='red', linestyle=':', alpha=0.7, label='Ratio = 1 (bound)')
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('Ratio', fontsize=12)
ax2.set_title('Ratio C(2n,n)/2^n\n(always ≥ 1, grows exponentially)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

# Panel 3: Inductive multiplier
ax3 = axes[2]
multipliers = [2 * (2*n + 1) / (n + 1) for n in ns]
ax3.plot(ns, multipliers, 'mo-', markersize=6, linewidth=2,
         label='2(2n+1)/(n+1)')
ax3.axhline(y=2, color='red', linestyle='--', alpha=0.7,
            label='Threshold = 2')
ax3.axhline(y=4, color='green', linestyle=':', alpha=0.5,
            label='Limit = 4')
ax3.set_xlabel('n', fontsize=12)
ax3.set_ylabel('Multiplier', fontsize=12)
ax3.set_title('Inductive Multiplier\nC(2(n+1),n+1)/C(2n,n) ≥ 2', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(1.5, 4.5)

plt.tight_layout()
plt.savefig('viz_central_binom.png', dpi=150, bbox_inches='tight')
print("Saved viz_central_binom.png")
