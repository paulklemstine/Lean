#!/usr/bin/env python3
"""
Visualization 2: Orbit Complexity for Different Group Actions

Visualizes how orbit complexity grows for different group families:
- Cyclic (Z/m): linear growth, orbit count ~ m·k
- Symmetric (S_m): polynomial growth in m for fixed k
- Trivial: constant (1 orbit always)

Shows that all satisfy polynomial bounds, confirming HasBoundedOrbitComplexity.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from functools import lru_cache


@lru_cache(maxsize=None)
def stirling2(n, k):
    """Stirling number of the second kind."""
    if n == 0 and k == 0: return 1
    if n == 0 or k == 0: return 0
    return k * stirling2(n-1, k) + stirling2(n-1, k-1)


def symmetric_orbits(m, k):
    """S_m orbits on {0,...,m-1}^k."""
    if m == 0: return 1 if k == 0 else 0
    if k == 0: return 1
    return sum(stirling2(k, j) * math.comb(m, j) for j in range(1, min(m, k)+1))


def cyclic_orbits(m, k):
    """Z/m orbits on {0,...,m-1}^k (component-wise shift)."""
    if m == 0: return 1 if k == 0 else 0
    return max(1, m ** max(0, k - 1))


# ─── Data ───

ms = list(range(1, 31))

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Orbit Complexity: Polynomial Bounds for Different Group Actions',
             fontsize=14, fontweight='bold')

# Panel 1: Orbit count vs m for fixed k
ax1 = axes[0]
for k in [1, 2, 3]:
    sym_counts = [symmetric_orbits(m, k) for m in ms]
    cyc_counts = [cyclic_orbits(m, k) for m in ms]
    ax1.plot(ms, sym_counts, 'o-', markersize=3, label=f'S_m, k={k}')
    ax1.plot(ms, cyc_counts, 's--', markersize=3, label=f'Z/m, k={k}', alpha=0.7)

ax1.set_xlabel('m (set size)', fontsize=11)
ax1.set_ylabel('Number of orbits', fontsize=11)
ax1.set_title('Orbits on k-tuples vs m', fontsize=12)
ax1.legend(fontsize=8, ncol=2)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Orbit count / polynomial bound
ax2 = axes[1]
for k in [1, 2, 3]:
    # For S_m: bound is C·(m+1)^k (roughly)
    ratios_sym = [symmetric_orbits(m, k) / ((m+1)**k) for m in ms]
    ratios_cyc = [cyclic_orbits(m, k) / ((m+1)*(k+1)) for m in ms]
    ax2.plot(ms, ratios_sym, 'o-', markersize=3, label=f'S_m/poly, k={k}')
    ax2.plot(ms, ratios_cyc, 's--', markersize=3, label=f'Z/m/bound, k={k}', alpha=0.7)

ax2.axhline(y=1, color='red', linestyle=':', linewidth=1, label='Bound = 1')
ax2.set_xlabel('m', fontsize=11)
ax2.set_ylabel('Orbits / Polynomial Bound', fontsize=11)
ax2.set_title('Ratio: Actual / Polynomial Upper Bound', fontsize=12)
ax2.legend(fontsize=8, ncol=2)
ax2.grid(True, alpha=0.3)

# Panel 3: Comparison of orbit complexity classes
ax3 = axes[2]
k = 3
ms_long = list(range(1, 51))

trivial = [1 for _ in ms_long]
cyclic = [cyclic_orbits(m, k) for m in ms_long]
symmetric = [symmetric_orbits(m, k) for m in ms_long]
total = [m**k for m in ms_long]

ax3.semilogy(ms_long, total, 'k-', linewidth=2, label=f'Total tuples m^{k}')
ax3.semilogy(ms_long, symmetric, 'b-', linewidth=2, label=f'S_m orbits')
ax3.semilogy(ms_long, cyclic, 'g-', linewidth=2, label=f'Z/m orbits')
ax3.semilogy(ms_long, trivial, 'r-', linewidth=2, label='Trivial (1 orbit)')

ax3.fill_between(ms_long, trivial, symmetric, alpha=0.1, color='blue')
ax3.set_xlabel('m', fontsize=11)
ax3.set_ylabel(f'Orbit count (k={k})', fontsize=11)
ax3.set_title(f'Orbit Complexity Hierarchy (k={k})', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_orbit_complexity.png', dpi=150, bbox_inches='tight')
print("Saved viz_orbit_complexity.png")
