#!/usr/bin/env python3
"""
Visualization: Depth Amplification Theorem

Shows how region count grows exponentially with depth for fixed width,
and compares depth vs. width tradeoffs for a fixed neuron budget.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def zaslavsky_bound(m: int, n: int) -> int:
    return sum(math.comb(m, k) for k in range(n + 1))


def network_region_bound(input_dim: int, layer_widths: list) -> int:
    bound = 1
    for w in layer_widths:
        bound *= zaslavsky_bound(w, input_dim)
    return bound


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Region bound vs depth for fixed width
ax = axes[0]
input_dim = 3
for w in [2, 4, 6, 8]:
    depths = list(range(1, 12))
    bounds = [math.log10(network_region_bound(input_dim, [w] * L)) for L in depths]
    ax.plot(depths, bounds, 'o-', label=f'w={w}', linewidth=2, markersize=5)

ax.set_xlabel('Depth (L)', fontsize=12)
ax.set_ylabel('log₁₀(Region Bound)', fontsize=12)
ax.set_title(f'Region Bound vs Depth (n={input_dim})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Depth vs width tradeoff for fixed neuron budget
ax = axes[1]
for budget in [10, 20, 40, 60]:
    widths_list = []
    bounds_list = []
    for L in range(1, budget + 1):
        w = budget // L
        if w < 1:
            break
        bound = network_region_bound(input_dim, [w] * L)
        widths_list.append(L)
        bounds_list.append(math.log10(bound))
    ax.plot(widths_list, bounds_list, 'o-', label=f'{budget} neurons',
            linewidth=2, markersize=4)

ax.set_xlabel('Depth (L)', fontsize=12)
ax.set_ylabel('log₁₀(Region Bound)', fontsize=12)
ax.set_title(f'Depth vs Width Tradeoff (n={input_dim})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Hodge bounds heatmap
ax = axes[2]
layer_widths = [8, 12, 8]
max_pq = 6
hodge_matrix = np.zeros((max_pq + 1, max_pq + 1))
for p in range(max_pq + 1):
    for q in range(max_pq + 1):
        w1, wL = layer_widths[0], layer_widths[-1]
        middle = math.prod(layer_widths[1:-1]) if len(layer_widths) > 2 else 1
        hb = math.comb(w1, p) * math.comb(wL, q) * middle
        hodge_matrix[p, q] = math.log10(max(hb, 1))

im = ax.imshow(hodge_matrix, cmap='YlOrRd', origin='lower')
ax.set_xlabel('q', fontsize=12)
ax.set_ylabel('p', fontsize=12)
ax.set_title(f'log₁₀(Hodge Bound) for {layer_widths}', fontsize=14)
plt.colorbar(im, ax=ax, shrink=0.8)

for p in range(max_pq + 1):
    for q in range(max_pq + 1):
        val = hodge_matrix[p, q]
        ax.text(q, p, f'{val:.1f}', ha='center', va='center', fontsize=7,
                color='white' if val > 2 else 'black')

plt.tight_layout()
plt.savefig('depth_amplification.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved depth_amplification.png")
