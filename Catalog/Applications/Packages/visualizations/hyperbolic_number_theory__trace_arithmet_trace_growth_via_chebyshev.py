"""
Visualization 3: Trace Growth — Chebyshev Polynomials and Exponential Divergence

This script visualizes how traces of powers of SL₂(ℤ) elements grow.
For parabolic elements (tr=2), traces stay constant.
For hyperbolic elements (tr≥3), traces grow exponentially — this is
the group-theoretic manifestation of geodesic divergence in hyperbolic space.

The Chebyshev polynomial connection tr(g^n) = T_n(tr(g)) makes this precise.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math


def chebyshev_trace(n, t):
    """Trace Chebyshev: T_0=2, T_1=t, T_{n+2}=t·T_{n+1}-T_n."""
    if n == 0:
        return 2
    if n == 1:
        return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


fig, axes = plt.subplots(1, 2, figsize=(14, 6), dpi=150)

# Left: Linear scale
ax1 = axes[0]
ns = list(range(12))

trace_values = {
    'tr = 0 (elliptic, order 4)': 0,
    'tr = 1 (elliptic, order 6)': 1,
    'tr = 2 (parabolic)': 2,
    'tr = 3 (hyperbolic)': 3,
    'tr = 4 (hyperbolic)': 4,
    'tr = 5 (hyperbolic)': 5,
}

colors = ['purple', 'blue', 'green', 'orange', 'red', 'brown']

for (label, t), color in zip(trace_values.items(), colors):
    vals = [chebyshev_trace(n, t) for n in ns]
    ax1.plot(ns, vals, 'o-', color=color, label=label, markersize=4)

ax1.set_xlabel('Power n', fontsize=12)
ax1.set_ylabel('tr(g^n)', fontsize=12)
ax1.set_title('Trace of Powers (Linear Scale)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-50, 500)

# Right: Log scale for hyperbolic elements
ax2 = axes[1]
ns_long = list(range(20))

for t in [3, 4, 5, 7, 10]:
    vals = [abs(chebyshev_trace(n, t)) for n in ns_long]
    ax2.semilogy(ns_long, vals, 'o-', markersize=3,
                 label=f'tr = {t}')
    
    # Show theoretical growth rate
    eigenvalue = (t + math.sqrt(t**2 - 4)) / 2
    theoretical = [2 * eigenvalue**n for n in ns_long]
    ax2.semilogy(ns_long, theoretical, '--', alpha=0.3, color='gray')

ax2.set_xlabel('Power n', fontsize=12)
ax2.set_ylabel('|tr(g^n)| (log scale)', fontsize=12)
ax2.set_title('Exponential Growth for Hyperbolic Elements', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Add annotation about growth rate
ax2.text(0.5, 0.05,
         'Dashed lines: theoretical λ^n growth\n'
         'λ = (tr + √(tr²−4))/2 (largest eigenvalue)',
         transform=ax2.transAxes, fontsize=8,
         verticalalignment='bottom', style='italic',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('Chebyshev Polynomials and Hyperbolic Trace Growth',
             fontsize=15, fontweight='bold', y=1.02)
fig.tight_layout()
plt.savefig('viz_trace_growth.png', dpi=150, bbox_inches='tight')
print("Saved trace growth visualization")
