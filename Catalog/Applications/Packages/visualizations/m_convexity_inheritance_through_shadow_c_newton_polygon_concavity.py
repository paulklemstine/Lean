#!/usr/bin/env python3
"""
Visualization 2: Newton Polygon Concavity Across Cascade Levels

Visualizes the tropical geometry connection: the Newton polygon of
an exchange sequence is concave, and this concavity is preserved
through the entire cascade. The slopes (log-ratios) form a
nonincreasing sequence at every level.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def weighted_derivative(a):
    return [(k + 1) * a[k + 1] for k in range(len(a) - 1)]

def newton_slopes(a):
    return [np.log(a[k+1]) - np.log(a[k]) for k in range(len(a) - 1)]

# Base sequence: binomial coefficients
n = 14
a_base = [float(comb(n, k)) for k in range(n + 1)]

# Compute cascade
cascade = [a_base]
for _ in range(4):
    if len(cascade[-1]) >= 2:
        cascade.append(weighted_derivative(cascade[-1]))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Tropical Newton Polygon: Concavity Preserved Through Cascade',
             fontsize=14, fontweight='bold')

# Left panel: Newton polygon (log values)
ax1 = axes[0]
colors = plt.cm.plasma(np.linspace(0.1, 0.9, len(cascade)))

for level, (seq, color) in enumerate(zip(cascade, colors)):
    log_vals = [np.log(v) for v in seq]
    x = np.arange(len(log_vals))
    ax1.plot(x, log_vals, 'o-', color=color, markersize=4,
             label=f'Level {level}', linewidth=1.5)

ax1.set_xlabel('Index k', fontsize=12)
ax1.set_ylabel('log(coefficient)', fontsize=12)
ax1.set_title('Newton Polygon (Log-Coefficients)', fontsize=12)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Right panel: slopes (should be nonincreasing)
ax2 = axes[1]

for level, (seq, color) in enumerate(zip(cascade, colors)):
    if len(seq) < 2:
        continue
    slopes = newton_slopes(seq)
    x = np.arange(len(slopes))
    ax2.plot(x, slopes, 's-', color=color, markersize=5,
             label=f'Level {level}', linewidth=1.5)

ax2.axhline(y=0, color='black', linestyle='--', alpha=0.3)
ax2.set_xlabel('Index k', fontsize=12)
ax2.set_ylabel('Slope Δ log(a)', fontsize=12)
ax2.set_title('Newton Slopes (Nonincreasing = Concave)', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Add annotation
ax2.annotate('All slopes nonincreasing\n= Exchange property\n= Lorentzian positivity',
             xy=(0.95, 0.95), xycoords='axes fraction',
             ha='right', va='top', fontsize=9,
             bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_newton_polygon.png', dpi=150, bbox_inches='tight')
print("Saved: viz_newton_polygon.png")
