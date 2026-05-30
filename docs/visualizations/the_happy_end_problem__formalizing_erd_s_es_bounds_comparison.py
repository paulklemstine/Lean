"""
Visualization: Erdős–Szekeres Bounds Comparison

Plots the conjectured bound ES(n) = 2^(n-2) + 1 against the classical
bound C(2n-4, n-2) + 1, showing the exponential gap between them.
The gap represents the potential improvement that would follow from
proving the ES conjecture.
"""

import math
import matplotlib.pyplot as plt
import numpy as np

# Compute bounds
ns = list(range(3, 12))
conjecture = [2 ** (n - 2) + 1 for n in ns]
classical = [math.comb(2 * n - 4, n - 2) + 1 for n in ns]
known_es = {3: 3, 4: 5, 5: 9, 6: 17}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: bounds on log scale
ax1.semilogy(ns, conjecture, 'o-', color='#2196F3', linewidth=2.5, 
             markersize=8, label='Conjecture: $2^{n-2}+1$', zorder=3)
ax1.semilogy(ns, classical, 's-', color='#FF5722', linewidth=2.5,
             markersize=8, label='Classical: $\\binom{2n-4}{n-2}+1$', zorder=3)

# Mark known values
known_ns = sorted(known_es.keys())
known_vals = [known_es[n] for n in known_ns]
ax1.semilogy(known_ns, known_vals, 'D', color='#4CAF50', markersize=12,
             label='Known exact values', zorder=4, markeredgecolor='black',
             markeredgewidth=1.5)

ax1.set_xlabel('n (polygon size)', fontsize=13)
ax1.set_ylabel('Minimum points needed (log scale)', fontsize=13)
ax1.set_title('Erdős–Szekeres Bounds', fontsize=15, fontweight='bold')
ax1.legend(fontsize=11, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xticks(ns)

# Right plot: ratio classical/conjecture
ratios = [c / j for c, j in zip(classical, conjecture)]
colors = plt.cm.plasma(np.linspace(0.2, 0.8, len(ns)))
bars = ax2.bar(ns, ratios, color=colors, edgecolor='black', linewidth=0.8)

for bar, ratio in zip(bars, ratios):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
             f'{ratio:.1f}×', ha='center', va='bottom', fontsize=10, fontweight='bold')

ax2.set_xlabel('n (polygon size)', fontsize=13)
ax2.set_ylabel('Classical / Conjecture ratio', fontsize=13)
ax2.set_title('Gap Between Bounds', fontsize=15, fontweight='bold')
ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
ax2.set_xticks(ns)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_bounds.png', dpi=150, bbox_inches='tight')
print("Saved viz_bounds.png")
