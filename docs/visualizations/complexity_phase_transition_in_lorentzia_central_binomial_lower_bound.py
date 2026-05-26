"""
Visualization: Central Binomial Coefficient Lower Bound

Illustrates the key combinatorial inequality C(2k, k) ≥ 2^k that drives
the exponential lower bound on derivative tree size. Shows the growing
gap between the central binomial coefficient and the exponential baseline.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Log-scale comparison
ks = np.arange(0, 26)
central_binom = [comb(2*k, k) for k in ks]
exp_bound = [2**k for k in ks]
four_pow = [4**k for k in ks]

ax1.semilogy(ks, central_binom, 'b-o', markersize=6, linewidth=2,
             label=r'C(2k, k)', zorder=3)
ax1.semilogy(ks, exp_bound, 'r--s', markersize=4, linewidth=1.5,
             label=r'$2^k$ (lower bound)', alpha=0.8)
ax1.semilogy(ks, four_pow, 'g--^', markersize=4, linewidth=1.5,
             label=r'$4^k$ (upper bound)', alpha=0.6)
ax1.fill_between(ks, exp_bound, central_binom, alpha=0.15, color='blue',
                 label='Proved gap')

ax1.set_xlabel('k', fontsize=13)
ax1.set_ylabel('Value (log scale)', fontsize=13)
ax1.set_title('Central Binomial Coefficient vs Exponentials', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)

# Right: Ratio C(2k,k) / 2^k
ratios = [comb(2*k, k) / 2**k for k in ks]

ax2.plot(ks, ratios, 'b-o', markersize=6, linewidth=2)
ax2.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='Minimum ratio = 1')
ax2.fill_between(ks, 1, ratios, alpha=0.15, color='blue')

# Add asymptotic formula annotation
ax2.annotate(r'$\frac{C(2k,k)}{2^k} \sim \frac{2^k}{\sqrt{\pi k}}$',
             xy=(15, ratios[15]), xytext=(18, ratios[10]),
             fontsize=12, arrowprops=dict(arrowstyle='->', color='black'),
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

ax2.set_xlabel('k', fontsize=13)
ax2.set_ylabel('C(2k, k) / 2^k', fontsize=13)
ax2.set_title('Ratio: Central Binomial to Exponential', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.suptitle('The Central Binomial Lower Bound: Engine of Exponential Growth',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('central_binomial.png', dpi=150, bbox_inches='tight')
print("Saved central_binomial.png")
