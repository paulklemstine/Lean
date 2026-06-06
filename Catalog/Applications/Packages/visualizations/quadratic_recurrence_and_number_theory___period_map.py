#!/usr/bin/env python3
"""
Visualization: Mandelbrot Set Period Map

Colors each point c in the Mandelbrot set by the period of its
attracting cycle, revealing the number-theoretic structure of bulbs.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def find_period(c, max_iter=200, max_period=50, tol=1e-8):
    """Find the period of the attracting cycle for parameter c."""
    z = complex(0)
    # Iterate to settle onto the attractor
    for _ in range(max_iter):
        z = z * z + c
        if abs(z) > 10:
            return 0  # escaping
    # Now check for periodicity
    z_ref = z
    for p in range(1, max_period + 1):
        z = z * z + c
        if abs(z) > 10:
            return 0
        if abs(z - z_ref) < tol:
            return p
    return -1  # period not found


# Generate period map
nx, ny = 800, 600
x = np.linspace(-2.2, 0.8, nx)
y = np.linspace(-1.2, 1.2, ny)
periods = np.zeros((ny, nx))

for j in range(ny):
    for i in range(nx):
        c = complex(x[i], y[j])
        periods[j, i] = find_period(c)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Plot 1: Period map
ax = axes[0]
# Create custom colormap
cmap = plt.cm.get_cmap('tab20', 20)
im = ax.imshow(periods, extent=[-2.2, 0.8, -1.2, 1.2],
               cmap=cmap, vmin=0, vmax=20, aspect='auto', origin='lower')
ax.set_xlabel('Re(c)')
ax.set_ylabel('Im(c)')
ax.set_title('Mandelbrot Set: Period of Attracting Cycles')
cbar = plt.colorbar(im, ax=ax, label='Period')
cbar.set_ticks(range(0, 21, 2))

# Annotate key bulbs
annotations = [
    (0.25, 0, '1'),
    (-0.75, 0, '2'),
    (-0.12, 0.74, '3'),
    (-1.25, 0, '3'),
    (0.28, 0.53, '4'),
    (-0.5, 0.56, '5'),
]
for cx, cy, label in annotations:
    ax.annotate(label, (cx, cy), fontsize=8, color='white',
                ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.2', fc='black', alpha=0.6))

# Plot 2: Period histogram
ax = axes[1]
period_counts = {}
for p in range(1, 21):
    count = np.sum(periods == p)
    if count > 0:
        period_counts[p] = count

bars = ax.bar(list(period_counts.keys()), list(period_counts.values()),
              color='steelblue', alpha=0.7)
# Color prime periods differently
for bar, p in zip(bars, period_counts.keys()):
    is_prime = p > 1 and all(p % d != 0 for d in range(2, int(p**0.5) + 1))
    if is_prime:
        bar.set_color('#e41a1c')
        bar.set_alpha(0.8)
ax.set_xlabel('Period')
ax.set_ylabel('Pixel count')
ax.set_title('Distribution of Periods (red = prime period)')
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/mandelbrot_periods.png', dpi=150)
plt.close()
print("Saved mandelbrot_periods.png")
