"""
Visualization: Complexity Phase Transition in Lorentzian Recognition

Shows the dramatic difference between fixed-degree (polynomial) and
unrestricted-degree (exponential) certificate complexity. The left panel
shows polynomial growth for fixed d; the right panel shows exponential
growth when d grows with n.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Fixed degree, varying n (polynomial growth)
ax1 = axes[0]
for d in [4, 6, 8, 10]:
    ns = np.arange(2, 51)
    counts = [comb(n + d - 3, d - 2) for n in ns]
    ax1.semilogy(ns, counts, 'o-', markersize=3, label=f'd = {d}')

ax1.set_xlabel('Number of variables n', fontsize=12)
ax1.set_ylabel('Certificate complexity (log scale)', fontsize=12)
ax1.set_title('Fixed Degree: Polynomial Growth in n', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.text(0.05, 0.95, 'TAME REGIME', transform=ax1.transAxes,
         fontsize=14, fontweight='bold', color='green', va='top',
         bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))

# Right panel: Unrestricted degree (n = 2d), exponential growth
ax2 = axes[1]
ds = np.arange(2, 25)

# Exact certificate complexity C(3d-5, d-2)
exact = [comb(3*d - 5, d - 2) for d in ds]
# Upper bound n^(d-2) = (2d)^(d-2)
upper = [(2*d)**(d-2) for d in ds]
# Lower bound 2^(d-2)
lower = [2**(d-2) for d in ds]

ax2.semilogy(ds, exact, 'b-o', markersize=5, linewidth=2, label='Exact: C(3d−5, d−2)')
ax2.semilogy(ds, upper, 'r--', linewidth=1.5, alpha=0.7, label='Upper: (2d)^(d−2)')
ax2.semilogy(ds, lower, 'g--', linewidth=1.5, alpha=0.7, label='Lower: 2^(d−2)')
ax2.fill_between(ds, lower, upper, alpha=0.1, color='purple')

ax2.set_xlabel('Degree d (with n = 2d variables)', fontsize=12)
ax2.set_ylabel('Certificate complexity (log scale)', fontsize=12)
ax2.set_title('Unrestricted Degree: Exponential Growth in d', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.text(0.05, 0.95, 'HARD REGIME', transform=ax2.transAxes,
         fontsize=14, fontweight='bold', color='red', va='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))

plt.suptitle('Complexity Phase Transition in Lorentzian Recognition',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")
