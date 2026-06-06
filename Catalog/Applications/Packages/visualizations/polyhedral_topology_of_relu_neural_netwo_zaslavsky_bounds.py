#!/usr/bin/env python3
"""
Visualization: Zaslavsky Bound Properties

Demonstrates the recurrence, growth rates, and bounds
of the Zaslavsky region-counting function.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def zaslavsky_bound(m: int, n: int) -> int:
    return sum(math.comb(m, k) for k in range(n + 1))


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Z(m, n) vs m for various n
ax = axes[0]
ms = list(range(1, 25))
for n in [1, 2, 3, 4, 5]:
    zs = [zaslavsky_bound(m, n) for m in ms]
    ax.plot(ms, zs, 'o-', label=f'n={n}', markersize=4, linewidth=2)

ax.set_xlabel('m (hyperplanes)', fontsize=12)
ax.set_ylabel('Z(m, n)', fontsize=12)
ax.set_title('Zaslavsky Bound Z(m,n)', fontsize=14)
ax.set_yscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Ratio Z(m,n) / (m+1)^n → tightness of polynomial bound
ax = axes[1]
ms = list(range(1, 30))
for n in [2, 3, 4, 5]:
    ratios = [zaslavsky_bound(m, n) / ((m + 1) ** n) for m in ms]
    ax.plot(ms, ratios, '-', label=f'n={n}', linewidth=2)

ax.set_xlabel('m (hyperplanes)', fontsize=12)
ax.set_ylabel('Z(m,n) / (m+1)ⁿ', fontsize=12)
ax.set_title('Tightness of Polynomial Bound', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1.1)

# Plot 3: Recurrence visualization
ax = axes[2]
n = 4
ms = list(range(0, 15))
z_vals = [zaslavsky_bound(m, n) for m in ms]
z_prev = [zaslavsky_bound(m, n - 1) for m in ms]
z_diff = [z_vals[i + 1] - z_vals[i] for i in range(len(ms) - 1)]

ax.bar(ms[:-1], z_diff, alpha=0.6, label='Z(m+1,n) - Z(m,n)', color='steelblue')
ax.plot(ms, z_prev, 'ro-', label=f'Z(m, {n-1})', markersize=5, linewidth=2)
ax.set_xlabel('m', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title(f'Zaslavsky Recurrence (n={n})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('zaslavsky_bounds.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved zaslavsky_bounds.png")
