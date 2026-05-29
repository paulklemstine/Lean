#!/usr/bin/env python3
"""
Visualization 3: Helly Number 2 for Tropical Box Systems

Visualizes the Helly-2 phenomenon: for box constraints, pairwise
intersection implies global intersection. Shows how the coordinatewise
maximum of lower bounds constructs the global witness.

This illustrates Theorem 4 (helly_two_boxes) from the Lean formalization.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# ── Define 4 boxes in 2D ──
boxes = [
    {'lo': np.array([0.0, 1.0]), 'hi': np.array([4.0, 5.0]), 'color': 'blue', 'label': '$B_1$'},
    {'lo': np.array([1.0, 0.0]), 'hi': np.array([5.0, 4.0]), 'color': 'red', 'label': '$B_2$'},
    {'lo': np.array([2.0, 2.0]), 'hi': np.array([6.0, 6.0]), 'color': 'green', 'label': '$B_3$'},
    {'lo': np.array([0.5, 1.5]), 'hi': np.array([3.5, 4.5]), 'color': 'purple', 'label': '$B_4$'},
]

# ── Panel 1: All boxes overlaid ──
ax = axes[0]
ax.set_title("Four Box Constraints\n(pairwise intersecting)", fontsize=12, fontweight='bold')

for b in boxes:
    rect = patches.Rectangle(b['lo'], b['hi'][0]-b['lo'][0], b['hi'][1]-b['lo'][1],
                              linewidth=2, edgecolor=b['color'],
                              facecolor=b['color'], alpha=0.15)
    ax.add_patch(rect)
    rect2 = patches.Rectangle(b['lo'], b['hi'][0]-b['lo'][0], b['hi'][1]-b['lo'][1],
                               linewidth=2, edgecolor=b['color'],
                               facecolor='none')
    ax.add_patch(rect2)
    ax.text(b['hi'][0] - 0.3, b['hi'][1] - 0.3, b['label'],
            fontsize=12, fontweight='bold', color=b['color'])

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# ── Panel 2: Pairwise intersections ──
ax = axes[1]
ax.set_title("Pairwise Intersections\n(all non-empty ✓)", fontsize=12, fontweight='bold')

# Show pairwise intersection regions
from itertools import combinations
pair_colors = ['orange', 'cyan', 'magenta', 'yellow', 'lime', 'pink']

resolution = 200
x0r = np.linspace(-0.5, 7, resolution)
x1r = np.linspace(-0.5, 7, resolution)
X0, X1 = np.meshgrid(x0r, x1r)

for idx, (i, j) in enumerate(combinations(range(4), 2)):
    b1, b2 = boxes[i], boxes[j]
    in_both = ((X0 >= b1['lo'][0]) & (X0 <= b1['hi'][0]) &
               (X1 >= b1['lo'][1]) & (X1 <= b1['hi'][1]) &
               (X0 >= b2['lo'][0]) & (X0 <= b2['hi'][0]) &
               (X1 >= b2['lo'][1]) & (X1 <= b2['hi'][1]))
    if np.any(in_both):
        ax.contourf(X0, X1, in_both.astype(float), levels=[0.5, 1.5],
                    colors=[pair_colors[idx]], alpha=0.2)
        ax.contour(X0, X1, in_both.astype(float), levels=[0.5],
                   colors=[pair_colors[idx]], linewidths=1, alpha=0.5)

# Draw box outlines
for b in boxes:
    rect = patches.Rectangle(b['lo'], b['hi'][0]-b['lo'][0], b['hi'][1]-b['lo'][1],
                              linewidth=1.5, edgecolor=b['color'],
                              facecolor='none', linestyle='--', alpha=0.5)
    ax.add_patch(rect)

npairs = len(list(combinations(range(4), 2)))
ax.text(3.5, 6.2, str(npairs) + " pairs,\nall intersecting",
        fontsize=10, ha="center", color="gray")

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# ── Panel 3: Global intersection with witness ──
ax = axes[2]
ax.set_title("Global Intersection\n+ Canonical Witness", fontsize=12, fontweight='bold')

# Compute global intersection
all_boxes = ((X0 >= boxes[0]['lo'][0]) & (X0 <= boxes[0]['hi'][0]) &
             (X1 >= boxes[0]['lo'][1]) & (X1 <= boxes[0]['hi'][1]))
for b in boxes[1:]:
    all_boxes &= ((X0 >= b['lo'][0]) & (X0 <= b['hi'][0]) &
                  (X1 >= b['lo'][1]) & (X1 <= b['hi'][1]))

ax.contourf(X0, X1, all_boxes.astype(float), levels=[0.5, 1.5],
            colors=['gold'], alpha=0.5)
ax.contour(X0, X1, all_boxes.astype(float), levels=[0.5],
           colors=['darkorange'], linewidths=2.5)

# Draw box outlines
for b in boxes:
    rect = patches.Rectangle(b['lo'], b['hi'][0]-b['lo'][0], b['hi'][1]-b['lo'][1],
                              linewidth=1, edgecolor=b['color'],
                              facecolor='none', linestyle='--', alpha=0.4)
    ax.add_patch(rect)

# Canonical witness: x_i = max_k (lo_k[i])
x_witness = np.array([max(b['lo'][0] for b in boxes),
                       max(b['lo'][1] for b in boxes)])

ax.plot(*x_witness, 'r*', markersize=20, zorder=10,
        markeredgecolor='darkred', markeredgewidth=1)
ax.annotate(f'Witness\n$x = ({x_witness[0]:.0f}, {x_witness[1]:.0f})$',
            xy=x_witness, xytext=(x_witness[0]+1, x_witness[1]+1),
            fontsize=11, fontweight='bold', color='darkred',
            arrowprops=dict(arrowstyle='->', color='darkred', lw=1.5),
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# Show the construction
ax.axhline(y=x_witness[1], color='darkred', linestyle=':', alpha=0.4)
ax.axvline(x=x_witness[0], color='darkred', linestyle=':', alpha=0.4)

ax.text(5.5, 0.3, "$x_i = \\max_k \\ell_k(i)$",
        fontsize=11, color='darkred', fontweight='bold',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

plt.suptitle("Helly Number 2: Pairwise Box Intersection ⟹ Global Intersection",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_helly.png", dpi=150, bbox_inches='tight')
print("Saved: viz_helly.png")
