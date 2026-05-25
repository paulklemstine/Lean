#!/usr/bin/env python3
"""
Visualization 1: Obstruction Profile Heatmap

Visualizes the cubic obstruction profile as a heatmap where each cell (k, m)
is colored based on whether x³ + y³ + z³ ≡ k (mod m) is solvable.
Dark cells indicate obstructions; light cells indicate solvability.
The mod 9 pattern is clearly visible as vertical dark bands at k ≡ 4, 5 (mod 9).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def has_cubic_solution_mod(k, m):
    if m <= 0:
        return True
    target = k % m
    cubes = {pow(x, 3, m) for x in range(m)}
    for c1 in cubes:
        for c2 in cubes:
            if (target - c1 - c2) % m in cubes:
                return True
    return False


# Parameters
K_max = 100
M_max = 50

# Build the heatmap data
data = np.zeros((M_max, K_max))
for k in range(1, K_max + 1):
    for m in range(1, M_max + 1):
        data[m - 1, k - 1] = 0 if has_cubic_solution_mod(k, m) else 1

fig, ax = plt.subplots(figsize=(14, 8))

# Custom colormap: white (solvable) to dark red (obstructed)
cmap = mcolors.LinearSegmentedColormap.from_list('obstruction', ['#f0f0f0', '#8b0000'])
im = ax.imshow(data, aspect='auto', cmap=cmap, interpolation='nearest',
               extent=[0.5, K_max + 0.5, M_max + 0.5, 0.5])

ax.set_xlabel('k (target value)', fontsize=13)
ax.set_ylabel('m (modulus)', fontsize=13)
ax.set_title('Cubic Obstruction Profile Heatmap\n'
             r'Dark = $x^3+y^3+z^3 \equiv k \pmod{m}$ has no solution',
             fontsize=14)

# Mark the mod 9 obstructed columns
for k in range(1, K_max + 1):
    if k % 9 in [4, 5]:
        ax.axvline(x=k, color='blue', alpha=0.15, linewidth=1)

# Add colorbar
cbar = plt.colorbar(im, ax=ax, fraction=0.02, pad=0.04)
cbar.set_ticks([0, 1])
cbar.set_ticklabels(['Solvable', 'Obstructed'])

# Highlight mod 9 row
ax.axhline(y=9, color='cyan', alpha=0.5, linewidth=2, linestyle='--',
           label='m = 9')
ax.legend(loc='upper right', fontsize=10)

plt.tight_layout()
plt.savefig('viz_obstruction_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_obstruction_heatmap.png")
