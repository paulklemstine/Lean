#!/usr/bin/env python3
"""
Visualization 3: Cayley Graph Structure for S_3

Draws the Cayley graph of S_3 with the bubble-rotation generators,
showing how the long cycle creates "shortcuts" through the graph
compared to adjacent transpositions alone.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


def perm_to_str(p):
    return ''.join(str(x + 1) for x in p)


def bubble_rotation_generators(n):
    gens_adj = []
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens_adj.append(tuple(p))
    rho = tuple((i + 1) % n for i in range(n))
    rho_inv = tuple((i - 1) % n for i in range(n))
    return gens_adj, rho, rho_inv


n = 3
perms = list(permutations(range(n)))
perm_idx = {p: i for i, p in enumerate(perms)}
N = len(perms)

# Arrange vertices in a circle
angles = np.linspace(0, 2 * np.pi, N, endpoint=False) + np.pi / 2
pos = {p: (np.cos(a), np.sin(a)) for p, a in zip(perms, angles)}

gens_adj, rho, rho_inv = bubble_rotation_generators(n)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Adjacent transpositions only
ax = axes[0]
ax.set_title('Adjacent Transpositions Only', fontsize=14, fontweight='bold')
for p in perms:
    x, y = pos[p]
    ax.plot(x, y, 'ko', markersize=20, zorder=5)
    ax.annotate(perm_to_str(p), (x, y), ha='center', va='center',
                fontsize=9, fontweight='bold', color='white', zorder=6)

for p in perms:
    for g in gens_adj:
        q = tuple(g[p[j]] for j in range(n))
        x1, y1 = pos[p]
        x2, y2 = pos[q]
        ax.plot([x1, x2], [y1, y2], 'b-', linewidth=1.5, alpha=0.6)

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Panel 2: Long cycle edges only
ax = axes[1]
ax.set_title('Long Cycle Edges Only', fontsize=14, fontweight='bold')
for p in perms:
    x, y = pos[p]
    ax.plot(x, y, 'ko', markersize=20, zorder=5)
    ax.annotate(perm_to_str(p), (x, y), ha='center', va='center',
                fontsize=9, fontweight='bold', color='white', zorder=6)

for p in perms:
    for g in [rho, rho_inv]:
        q = tuple(g[p[j]] for j in range(n))
        x1, y1 = pos[p]
        x2, y2 = pos[q]
        # Draw as curved arrow
        mid_x = (x1 + x2) / 2 + 0.15 * (y2 - y1)
        mid_y = (y1 + y2) / 2 - 0.15 * (x2 - x1)
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color='red',
                                    connectionstyle='arc3,rad=0.2',
                                    linewidth=2, alpha=0.7))

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Panel 3: Combined (bubble-rotation)
ax = axes[2]
ax.set_title('Bubble-Rotation (Combined)', fontsize=14, fontweight='bold')
for p in perms:
    x, y = pos[p]
    ax.plot(x, y, 'ko', markersize=20, zorder=5)
    ax.annotate(perm_to_str(p), (x, y), ha='center', va='center',
                fontsize=9, fontweight='bold', color='white', zorder=6)

# Adjacent edges
for p in perms:
    for g in gens_adj:
        q = tuple(g[p[j]] for j in range(n))
        x1, y1 = pos[p]
        x2, y2 = pos[q]
        ax.plot([x1, x2], [y1, y2], 'b-', linewidth=1.5, alpha=0.5)

# Cycle edges
for p in perms:
    q = tuple(rho[p[j]] for j in range(n))
    x1, y1 = pos[p]
    x2, y2 = pos[q]
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color='red',
                                connectionstyle='arc3,rad=0.25',
                                linewidth=2, alpha=0.6))

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Add legend
from matplotlib.lines import Line2D
legend_elements = [Line2D([0], [0], color='blue', linewidth=2, label='Adjacent swap'),
                   Line2D([0], [0], color='red', linewidth=2, label='Long cycle')]
fig.legend(handles=legend_elements, loc='lower center', ncol=2, fontsize=12,
           bbox_to_anchor=(0.5, -0.02))

plt.suptitle('Cayley Graph of S₃: How the Long Cycle Creates Shortcuts',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('cayley_graph_s3.png', dpi=150, bbox_inches='tight')
print("Saved cayley_graph_s3.png")
