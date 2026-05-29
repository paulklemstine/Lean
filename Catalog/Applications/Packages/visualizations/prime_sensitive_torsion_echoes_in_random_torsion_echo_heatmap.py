#!/usr/bin/env python3
"""
Visualization 1: Torsion Echo Heatmap

Visualizes the torsion echo profile across different primes and group orders.
Each cell shows v_p(n) — the p-adic valuation of n — creating a visual "fingerprint"
of how different primes decompose integers. The non-uniform pattern demonstrates
that prime identity matters: each prime "sees" a different arithmetic landscape.

This is the visual core of the prime-separation phenomenon.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def padic_valuation(p: int, n: int) -> int:
    """Compute v_p(n)."""
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


# Parameters
primes = [2, 3, 5, 7, 11, 13]
n_values = list(range(2, 61))

# Build the heatmap data
data = np.zeros((len(primes), len(n_values)))
for i, p in enumerate(primes):
    for j, n in enumerate(n_values):
        data[i, j] = padic_valuation(p, n)

# Create figure
fig, ax = plt.subplots(figsize=(16, 5))

# Custom colormap: white for 0, blues for increasing valuations
colors = ['#ffffff', '#c6dbef', '#6baed6', '#2171b5', '#08306b', '#041833']
cmap = mcolors.ListedColormap(colors)
bounds = [-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5]
norm = mcolors.BoundaryNorm(bounds, cmap.N)

im = ax.imshow(data, aspect='auto', cmap=cmap, norm=norm, interpolation='nearest')

# Labels
ax.set_yticks(range(len(primes)))
ax.set_yticklabels([f'p = {p}' for p in primes], fontsize=12)

# Show every 5th n value
tick_positions = [j for j, n in enumerate(n_values) if n % 5 == 0]
tick_labels = [str(n_values[j]) for j in tick_positions]
ax.set_xticks(tick_positions)
ax.set_xticklabels(tick_labels, fontsize=10)

ax.set_xlabel('Integer n', fontsize=13)
ax.set_ylabel('Prime p', fontsize=13)
ax.set_title('Prime Torsion Weight: $v_p(n)$ — Each Prime Sees a Different Pattern',
             fontsize=14, fontweight='bold')

# Colorbar
cbar = plt.colorbar(im, ax=ax, ticks=[0, 1, 2, 3, 4, 5], shrink=0.8)
cbar.set_label('$v_p(n)$', fontsize=12)

# Highlight prime-separated columns
for j, n in enumerate(n_values):
    vals = [padic_valuation(p, n) for p in primes]
    if len(set(vals)) > 1 and max(vals) >= 2:
        ax.axvline(x=j, color='red', alpha=0.15, linewidth=2)

plt.tight_layout()
plt.savefig('viz_torsion_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_torsion_heatmap.png")
