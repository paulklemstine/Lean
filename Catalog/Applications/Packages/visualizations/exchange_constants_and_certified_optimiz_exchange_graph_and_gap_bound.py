"""
Visualization: Exchange Graph and Optimization Landscape

Visualizes the exchange graph of a small matroid, with nodes colored by weight
and edges showing exchange moves. The local and global maxima are highlighted,
demonstrating how the exchange constant K controls optimization quality.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
import math


def uniform_matroid_bases(n, r):
    return [frozenset(c) for c in combinations(range(n), r)]


def compute_exchange_constant(bases, w):
    K = 0.0
    bases_set = set(bases)
    for B1 in bases:
        for B2 in bases:
            for x in B1 - B2:
                best_gap = float('inf')
                for y in B2 - B1:
                    B1_new = (B1 - {x}) | {y}
                    B2_new = (B2 - {y}) | {x}
                    if B1_new in bases_set and B2_new in bases_set:
                        gap = w(B1) + w(B2) - w(B1_new) - w(B2_new)
                        best_gap = min(best_gap, gap)
                if best_gap != float('inf'):
                    K = max(K, best_gap)
    return max(K, 0.0)


def is_exchange_local_max(basis, bases, w, ground):
    bases_set = set(bases)
    for x in basis:
        for y in ground:
            if y not in basis:
                new_basis = (basis - {x}) | {y}
                if new_basis in bases_set and w(new_basis) > w(basis):
                    return False
    return True


# Setup: U(3, 5) uniform matroid
n, r = 5, 3
ground = list(range(n))
bases = uniform_matroid_bases(n, r)

# Non-additive weight function with quadratic interaction
def w(B):
    base = sum(x * 2 + 1 for x in B)
    interaction = sum(1 for x in B for y in B if x < y and abs(x - y) == 1)
    return base + interaction * 1.5

K = compute_exchange_constant(bases, w)
weights = {B: w(B) for B in bases}

# Build exchange graph edges
edges = []
for i, B1 in enumerate(bases):
    for j, B2 in enumerate(bases):
        if i < j and len(B1 - B2) == 1:
            edges.append((i, j))

# Layout using spring-like positioning
n_bases = len(bases)
angles = np.linspace(0, 2 * np.pi, n_bases, endpoint=False)
radius = 3.0
pos = {}
for i in range(n_bases):
    pos[i] = (radius * np.cos(angles[i]), radius * np.sin(angles[i]))

# Identify local maxima
local_maxima = [i for i, B in enumerate(bases) if is_exchange_local_max(B, bases, w, ground)]
global_max_idx = max(range(n_bases), key=lambda i: weights[bases[i]])

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# === Panel 1: Exchange Graph ===
ax1 = axes[0]
ax1.set_title(f'Exchange Graph of U({r},{n})\n{n_bases} bases, {len(edges)} exchange edges',
              fontsize=13, fontweight='bold')

# Draw edges
for i, j in edges:
    x1, y1 = pos[i]
    x2, y2 = pos[j]
    ax1.plot([x1, x2], [y1, y2], 'gray', alpha=0.3, linewidth=0.8)

# Color nodes by weight
w_values = [weights[bases[i]] for i in range(n_bases)]
w_min, w_max = min(w_values), max(w_values)

for i in range(n_bases):
    x, y = pos[i]
    w_norm = (w_values[i] - w_min) / (w_max - w_min) if w_max > w_min else 0.5
    color = plt.cm.YlOrRd(w_norm)

    if i == global_max_idx:
        ax1.scatter(x, y, c=[color], s=300, zorder=5, edgecolors='gold', linewidths=3)
        ax1.annotate('★ GLOBAL\nMAX', (x, y), textcoords="offset points",
                     xytext=(0, 20), ha='center', fontsize=8, fontweight='bold', color='darkred')
    elif i in local_maxima:
        ax1.scatter(x, y, c=[color], s=200, zorder=5, edgecolors='blue', linewidths=2)
    else:
        ax1.scatter(x, y, c=[color], s=100, zorder=5, edgecolors='black', linewidths=0.5)

    label = '{' + ','.join(str(e) for e in sorted(bases[i])) + '}'
    ax1.annotate(label, (x, y), textcoords="offset points",
                 xytext=(0, -15), ha='center', fontsize=7, color='gray')

ax1.set_xlim(-4.5, 4.5)
ax1.set_ylim(-4.5, 4.5)
ax1.set_aspect('equal')
ax1.axis('off')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='gold', edgecolor='gold', label=f'Global Max (w={w_values[global_max_idx]:.1f})'),
    mpatches.Patch(facecolor='lightblue', edgecolor='blue', label='Local Max'),
    mpatches.Patch(facecolor='lightgray', edgecolor='black', label='Other Bases'),
]
ax1.legend(handles=legend_elements, loc='lower left', fontsize=9)

# === Panel 2: Gap Bound Visualization ===
ax2 = axes[1]
ax2.set_title(f'Gap Bound: w(Y) ≤ w(B) + K·|Y\\B|\nK = {K:.2f}', fontsize=13, fontweight='bold')

# For the global max, plot gap vs distance for all other bases
B_star = bases[global_max_idx]
w_star = weights[B_star]
distances = []
gaps = []
for B in bases:
    d = len(B - B_star)
    g = weights[B] - w_star
    distances.append(d)
    gaps.append(g)

ax2.scatter(distances, gaps, c='steelblue', s=60, alpha=0.7, edgecolors='navy', linewidths=0.5)

# Plot the certified bound line
d_range = np.linspace(0, max(distances) + 0.5, 100)
bound_line = K * d_range
ax2.plot(d_range, bound_line, 'r--', linewidth=2, label=f'Certified bound: K·d (K={K:.2f})')
ax2.fill_between(d_range, -10, bound_line, alpha=0.1, color='green',
                 label='Certified region')

ax2.set_xlabel('Exchange distance |Y \\ B|', fontsize=12)
ax2.set_ylabel('Weight gap w(Y) - w(B)', fontsize=12)
ax2.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('exchange_graph_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: exchange_graph_visualization.png")
plt.close()
