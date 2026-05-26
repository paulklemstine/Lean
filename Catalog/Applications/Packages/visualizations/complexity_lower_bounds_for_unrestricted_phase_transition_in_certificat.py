"""
Visualization: Phase Transition in Lorentzian Recognition Complexity

Shows how certificate complexity transitions from polynomial (fixed degree)
to exponential (degree growing with variables). This is the central visual
of the hardness result.

Self-contained — does not import any local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2

def quadratic_leaf_count(n, d):
    if d < 2:
        return 1
    return comb(n + d - 3, d - 2)

# Compute data
ns = list(range(3, 16))

fixed_3 = [quadratic_leaf_count(n, 3) for n in ns]
fixed_5 = [quadratic_leaf_count(n, 5) for n in ns]
growing = [quadratic_leaf_count(n + 1, n) for n in ns]
lower_bound = [2 ** (n - 2) for n in ns]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Linear scale
ax = axes[0]
ax.plot(ns, fixed_3, 'b-o', label='Fixed degree d=3', markersize=5)
ax.plot(ns, fixed_5, 'g-s', label='Fixed degree d=5', markersize=5)
ax.plot(ns, growing, 'r-^', label='Growing degree d=n', markersize=5)
ax.plot(ns, lower_bound, 'k--', label='Lower bound 2^(n-2)', linewidth=1.5)
ax.set_xlabel('Number of variables n', fontsize=12)
ax.set_ylabel('Certificate size (leaf count)', fontsize=12)
ax.set_title('Certificate Complexity: Linear Scale', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Right panel: Log scale showing phase transition
ax = axes[1]
log_fixed_3 = [log2(x) if x > 0 else 0 for x in fixed_3]
log_fixed_5 = [log2(x) if x > 0 else 0 for x in fixed_5]
log_growing = [log2(x) if x > 0 else 0 for x in growing]
log_lower = [n - 2 for n in ns]

ax.plot(ns, log_fixed_3, 'b-o', label='Fixed d=3: O(log n)', markersize=5)
ax.plot(ns, log_fixed_5, 'g-s', label='Fixed d=5: O(log n)', markersize=5)
ax.plot(ns, log_growing, 'r-^', label='d=n: Θ(n)', markersize=5)
ax.plot(ns, log_lower, 'k--', label='Lower bound: n-2', linewidth=1.5)

# Shade the two regimes
ax.axvspan(2.5, 15.5, alpha=0.05, color='red')
ax.text(9, max(log_growing) * 0.85, 'EXPONENTIAL\n(d grows with n)',
        ha='center', fontsize=11, color='red', fontweight='bold')
ax.text(5, max(log_fixed_5) + 1, 'POLYNOMIAL\n(d fixed)',
        ha='center', fontsize=10, color='blue')

ax.set_xlabel('Number of variables n', fontsize=12)
ax.set_ylabel('log₂(Certificate size)', fontsize=12)
ax.set_title('Phase Transition: log₂ Scale', fontsize=13)
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)

plt.suptitle('Complexity Phase Transition in Lorentzian Recognition',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")
