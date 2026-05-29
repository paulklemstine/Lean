#!/usr/bin/env python3
"""
Visualization 1: Tropical Band Feasibility Regions

Visualizes the feasible region of a 2D tropical band system as the
intersection of box constraints and difference constraint halfplanes.
Shows how slack constraints carve out a polytope from the box.

This illustrates the core concept: tropical bands = boxes + difference constraints.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Polygon

# ── Define a 2D tropical band system ──
lower = np.array([1.0, 0.0])
upper = np.array([6.0, 5.0])
# slack[i,j] means x_i ≤ x_j + slack[i,j]
# Constraint 1: x_0 ≤ x_1 + 3  (x_0 - x_1 ≤ 3)
# Constraint 2: x_1 ≤ x_0 + 2  (x_1 - x_0 ≤ 2)
slack_01 = 3.0  # x0 - x1 ≤ 3
slack_10 = 2.0  # x1 - x0 ≤ 2

# ── Create figure ──
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ── Panel 1: Box only ──
ax = axes[0]
ax.set_title("Box Constraints Only", fontsize=13, fontweight='bold')
box = patches.Rectangle((lower[0], lower[1]),
                         upper[0] - lower[0], upper[1] - lower[1],
                         linewidth=2, edgecolor='steelblue',
                         facecolor='lightblue', alpha=0.5)
ax.add_patch(box)
ax.set_xlim(-1, 8)
ax.set_ylim(-1, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.text(3.5, 2.5, '$[\\ell_0, u_0] \\times [\\ell_1, u_1]$',
        ha='center', fontsize=11, color='steelblue')

# ── Panel 2: Box + difference constraints ──
ax = axes[1]
ax.set_title("Box + Difference Constraints", fontsize=13, fontweight='bold')

# Draw box
box2 = patches.Rectangle((lower[0], lower[1]),
                          upper[0] - lower[0], upper[1] - lower[1],
                          linewidth=2, edgecolor='steelblue',
                          facecolor='lightblue', alpha=0.2, linestyle='--')
ax.add_patch(box2)

# Compute feasible polygon (intersection of box and halfplanes)
# x0 - x1 ≤ 3  →  x1 ≥ x0 - 3
# x1 - x0 ≤ 2  →  x1 ≤ x0 + 2
# plus box bounds

# Sample feasible region
resolution = 200
x0_range = np.linspace(lower[0], upper[0], resolution)
x1_range = np.linspace(lower[1], upper[1], resolution)
X0, X1 = np.meshgrid(x0_range, x1_range)

feasible = ((X0 >= lower[0]) & (X0 <= upper[0]) &
            (X1 >= lower[1]) & (X1 <= upper[1]) &
            (X0 - X1 <= slack_01) &  # x0 ≤ x1 + slack_01
            (X1 - X0 <= slack_10))   # x1 ≤ x0 + slack_10

ax.contourf(X0, X1, feasible.astype(float), levels=[0.5, 1.5],
            colors=['coral'], alpha=0.5)
ax.contour(X0, X1, feasible.astype(float), levels=[0.5],
           colors=['red'], linewidths=2)

# Draw constraint lines
x_line = np.linspace(-1, 8, 100)
ax.plot(x_line, x_line - slack_01, 'r--', linewidth=1.5, alpha=0.7,
        label=f'$x_0 - x_1 = {slack_01:.0f}$')
ax.plot(x_line, x_line + slack_10, 'g--', linewidth=1.5, alpha=0.7,
        label=f'$x_1 - x_0 = {slack_10:.0f}$')

ax.set_xlim(-1, 8)
ax.set_ylim(-1, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=9, loc='upper left')

# ── Panel 3: Feasible point as graph potential ──
ax = axes[2]
ax.set_title("Feasible Point = Graph Potential", fontsize=13, fontweight='bold')

# Draw feasible region
ax.contourf(X0, X1, feasible.astype(float), levels=[0.5, 1.5],
            colors=['lightyellow'], alpha=0.8)
ax.contour(X0, X1, feasible.astype(float), levels=[0.5],
           colors=['orange'], linewidths=2)

# Canonical potential: x_i = max_j (lower_j - dist_j_i)
# For this small example, compute manually
# dist[0,0]=0, dist[0,1]=slack_01=3, dist[1,0]=slack_10=2, dist[1,1]=0
# x[0] = max(lower[0]-0, lower[1]-slack_10) = max(1, 0-2) = 1
# x[1] = max(lower[0]-slack_01, lower[1]-0) = max(1-3, 0) = 0
x_canonical = np.array([1.0, 0.0])

# Also find the "upper" canonical point
x_center = np.array([3.0, 2.5])

ax.plot(*x_canonical, 'ro', markersize=10, zorder=5, label='Canonical potential')
ax.plot(*x_center, 'b^', markersize=10, zorder=5, label='Interior point')

# Draw arrows showing constraint graph
ax.annotate('', xy=(4.5, 3.5), xytext=(2, 3.5),
            arrowprops=dict(arrowstyle='->', color='darkred', lw=2))
ax.text(3.25, 3.8, f'slack={slack_01:.0f}', fontsize=9, color='darkred', ha='center')

ax.annotate('', xy=(2, 1), xytext=(4.5, 1),
            arrowprops=dict(arrowstyle='->', color='darkgreen', lw=2))
ax.text(3.25, 0.6, f'slack={slack_10:.0f}', fontsize=9, color='darkgreen', ha='center')

ax.set_xlim(-1, 8)
ax.set_ylim(-1, 7)
ax.set_xlabel('$x_0$', fontsize=12)
ax.set_ylabel('$x_1$', fontsize=12)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=9, loc='upper left')

plt.suptitle("Tropical Band Systems: From Boxes to Constrained Polytopes",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_tropical_bands.png", dpi=150, bbox_inches='tight')
print("Saved: viz_tropical_bands.png")
